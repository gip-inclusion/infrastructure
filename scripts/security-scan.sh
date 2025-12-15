#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

SCAN_PATH="${1:-infrastructure/}"

if [ ! -d "$SCAN_PATH" ]; then
    log_error "$SCAN_PATH does not exist"
    exit 1
fi

log_info "Security scan for: $SCAN_PATH"
echo ""

if ! command -v tfsec &> /dev/null; then
    log_warn "tfsec not installed"
    echo "Installation:"
    echo "  macOS:   brew install tfsec"
    echo "  Linux:   curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash"
    echo "  Windows: choco install tfsec"
    echo ""
    TFSEC_INSTALLED=false
else
    TFSEC_INSTALLED=true
fi

if ! command -v checkov &> /dev/null; then
    log_warn "checkov not installed"
    echo "Installation:"
    echo "  pip install checkov"
    echo "  ou: brew install checkov"
    echo ""
    CHECKOV_INSTALLED=false
else
    CHECKOV_INSTALLED=true
fi

if [ "$TFSEC_INSTALLED" = false ] && [ "$CHECKOV_INSTALLED" = false ]; then
    log_error "No IaC scanning tool installed. Install at least tfsec or checkov."
    exit 1
fi

TFSEC_ISSUES=0
CHECKOV_FAILED=0
TOTAL_CRITICAL=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$TFSEC_INSTALLED" = true ]; then
    log_info "Executing tfsec..."
    echo ""

    mkdir -p .security-scan-results

    set +e
    tfsec "$SCAN_PATH" \
        --format=lovely \
        --minimum-severity=LOW \
        --out=.security-scan-results/tfsec-results.txt
    TFSEC_EXIT_CODE=$?
    set -e

    if [ $TFSEC_EXIT_CODE -eq 0 ]; then
        log_info "✅ tfsec: No issues detected"
    else
        TFSEC_ISSUES=1
        log_error "❌ tfsec: Security issues detected"
        echo ""
        echo "Full results in: .security-scan-results/tfsec-results.txt"

        # Compter les critiques
        TFSEC_CRITICAL=$(grep -c "CRITICAL" .security-scan-results/tfsec-results.txt || echo "0")
        TOTAL_CRITICAL=$((TOTAL_CRITICAL + TFSEC_CRITICAL))

        if [ "$TFSEC_CRITICAL" -gt 0 ]; then
            log_error "⚠️  $TFSEC_CRITICAL CRITICAL ISSUE(S) DETECTED"
        fi
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

if [ "$CHECKOV_INSTALLED" = true ]; then
    log_info "Executing checkov..."
    echo ""

    mkdir -p .security-scan-results

    set +e
    checkov -d "$SCAN_PATH" \
        --framework terraform \
        --compact \
        --skip-check CKV_GIT_1 \
        --output cli \
        --output-file-path .security-scan-results
    CHECKOV_EXIT_CODE=$?
    set -e

    if [ $CHECKOV_EXIT_CODE -eq 0 ]; then
        log_info "✅ checkov: No issues detected"
    else
        CHECKOV_FAILED=1
        log_error "❌ checkov: Security issues detected"
        echo ""
        echo "Full results in: .security-scan-results/results_cli.txt"

        if [ -f .security-scan-results/results_cli.txt ]; then
            CHECKOV_HIGH=$(grep -c "HIGH" .security-scan-results/results_cli.txt || echo "0")
            TOTAL_CRITICAL=$((TOTAL_CRITICAL + CHECKOV_HIGH))

            if [ "$CHECKOV_HIGH" -gt 0 ]; then
                log_error "⚠️  $CHECKOV_HIGH HIGH ISSUE(S) DETECTED"
            fi
        fi
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

log_info "Security scan summary"
echo ""

if [ $TFSEC_ISSUES -eq 0 ] && [ $CHECKOV_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ No security issues detected${NC}"
    echo ""
    echo "✓ Code ready for commit/push"
    exit 0
else
    echo -e "${RED}❌ Security issues detected${NC}"
    echo ""
    echo "Tools that detected issues:"
    [ $TFSEC_ISSUES -eq 1 ] && echo "  - tfsec"
    [ $CHECKOV_FAILED -eq 1 ] && echo "  - checkov"
    echo ""

    if [ $TOTAL_CRITICAL -gt 0 ]; then
        echo -e "${RED}⚠️  BLOCKING: $TOTAL_CRITICAL CRITICAL ISSUE(S)${NC}"
        echo "These issues must be fixed before commit."
        echo ""
    fi

    echo "Recommended actions:"
    echo "  1. Consult the result files in .security-scan-results/"
    echo "  2. Fix CRITICAL/HIGH issues first"
    echo "  3. Re-run this script: ./scripts/security-scan.sh"
    echo "  4. Consult docs/security/SEC-INFRASTRUCTURE.md for guidance"
    echo ""

    exit 1
fi
