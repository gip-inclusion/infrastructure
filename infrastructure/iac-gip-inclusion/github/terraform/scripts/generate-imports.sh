#!/usr/bin/env bash
# Generate Terraform configuration and import blocks from existing GitHub resources
# Usage: ./scripts/generate-imports.sh [options] [organization]
# Requirements: gh CLI authenticated, jq

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
DEFAULT_ORG="gip-inclusion"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/.."

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
usage() {
  cat << EOF
Usage: $(basename "$0") [options] [organization]

Generate Terraform import blocks and update locals in existing .tf files.
Creates/updates:
  - imports.tf        Import blocks for terraform apply
  - organization.tf   Prepends org_settings and org_rulesets locals
  - teams.tf          Prepends teams and team_repositories locals
  - repositories.tf   Prepends repositories locals

Arguments:
  organization    GitHub organization name (default: $DEFAULT_ORG)

Options:
  -h, --help      Show this help message
  -q, --quiet     Suppress progress output

Examples:
  $(basename "$0")                    # Use default org ($DEFAULT_ORG)
  $(basename "$0") my-org             # Specify organization
  $(basename "$0") -q my-org          # Quiet mode
EOF
  exit 0
}

die() {
  echo "Error: $1" >&2
  exit 1
}

check_dependencies() {
  command -v gh >/dev/null 2>&1 || die "gh CLI is required but not installed. See https://cli.github.com/"
  command -v jq >/dev/null 2>&1 || die "jq is required but not installed."
  gh auth status >/dev/null 2>&1 || die "gh CLI is not authenticated. Run 'gh auth login' first."
}

# Escape string for HCL
escape_hcl() {
  local str="$1"
  str="${str//\\/\\\\}"    # Escape backslashes first
  str="${str//\"/\\\"}"    # Escape double quotes
  str="${str//\$/\$\$}"    # Escape dollar signs (Terraform interpolation)
  str="${str//$'\n'/\\n}"  # Escape newlines
  str="${str//$'\t'/\\t}"  # Escape tabs
  printf '%s' "$str"
}

# Clear current line for progress display
clear_line() {
  printf '\r\033[K' >&2
}

progress() {
  if [ "$QUIET" = false ]; then
    echo "$@" >&2
  fi
}

progress_inline() {
  if [ "$QUIET" = false ]; then
    clear_line
    printf '%s' "$1" >&2
  fi
}

# Update a file by replacing content between markers, or prepending if no markers exist
# Usage: update_file_with_markers <file> <content>
update_file_with_markers() {
  local file="$1"
  local content="$2"
  local marker_start="# BEGIN GENERATED LOCALS"
  local marker_end="# END GENERATED LOCALS"

  if [ ! -f "$file" ]; then
    die "File not found: $file"
  fi

  local generated_block="${marker_start}
${content}
${marker_end}
"

  if grep -q "$marker_start" "$file"; then
    # Replace existing generated block
    local tmp_file
    tmp_file=$(mktemp)
    awk -v start="$marker_start" -v end="$marker_end" -v new="$generated_block" '
      $0 ~ start { skip=1; printf "%s", new; next }
      $0 ~ end { skip=0; next }
      !skip { print }
    ' "$file" > "$tmp_file"
    mv "$tmp_file" "$file"
  else
    # Prepend generated block
    local tmp_file
    tmp_file=$(mktemp)
    echo "$generated_block" > "$tmp_file"
    cat "$file" >> "$tmp_file"
    mv "$tmp_file" "$file"
  fi
}

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
QUIET=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      ;;
    -q|--quiet)
      QUIET=true
      shift
      ;;
    -*)
      die "Unknown option: $1. Use --help for usage."
      ;;
    *)
      ORG="$1"
      shift
      ;;
  esac
done

ORG="${ORG:-$DEFAULT_ORG}"

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
check_dependencies

progress "Fetching GitHub organization data for: $ORG"
progress "============================================="

# Fetch organization data once (used for validation + settings)
progress ""
progress "Fetching organization settings..."
ORG_JSON=$(gh api "/orgs/$ORG" 2>/dev/null) || die "Organization '$ORG' not found or not accessible."
progress "Organization settings fetched"

# -----------------------------------------------------------------------------
# TEAMS + TEAM REPOSITORY ACCESS
# -----------------------------------------------------------------------------
# Fetch teams and their repository access in one pass (more efficient than per-repo)
progress ""
progress "Fetching teams..."

TEAMS_JSON=$(gh api "/orgs/$ORG/teams" --paginate 2>/dev/null || echo "[]")
TEAMS_COUNT=$(echo "$TEAMS_JSON" | jq -s 'flatten | length')
progress "Found $TEAMS_COUNT teams"

TEAMS_LOCALS=""
TEAMS_IMPORTS=""
TEAM_REPOS_LOCALS=""
TEAM_REPOS_IMPORTS=""

team_count=0
while IFS= read -r team_json; do
  team_count=$((team_count + 1))

  slug=$(echo "$team_json" | jq -r '.slug')
  name=$(echo "$team_json" | jq -r '.name')
  description=$(echo "$team_json" | jq -r '.description // ""')
  privacy=$(echo "$team_json" | jq -r '.privacy')
  id=$(echo "$team_json" | jq -r '.id')

  progress_inline "Processing team $team_count/$TEAMS_COUNT: $slug"

  description_escaped=$(escape_hcl "$description")

  TEAMS_LOCALS+="    \"$slug\" = {
      name        = \"$name\"
      description = \"$description_escaped\"
      privacy     = \"$privacy\"
    }
"

  TEAMS_IMPORTS+="import {
  to = github_team.teams[\"$slug\"]
  id = \"$id\"
}

"

  # Fetch repositories this team has access to
  TEAM_REPOS=$(gh api "/orgs/$ORG/teams/$slug/repos" --paginate 2>/dev/null || echo "[]")
  while IFS= read -r repo_json; do
    [ -z "$repo_json" ] && continue
    repo_name=$(echo "$repo_json" | jq -r '.name')
    permission=$(echo "$repo_json" | jq -r '.role_name')
    [ -z "$repo_name" ] && continue

    TEAM_REPOS_LOCALS+="    \"$slug:$repo_name\" = {
      team       = \"$slug\"
      repository = \"$repo_name\"
      permission = \"$permission\"
    }
"

    TEAM_REPOS_IMPORTS+="import {
  to = github_team_repository.access[\"$slug:$repo_name\"]
  id = \"$id:$repo_name\"
}

"
  done < <(echo "$TEAM_REPOS" | jq -c '.[]' 2>/dev/null || true)

done < <(echo "$TEAMS_JSON" | jq -c '.[]')

clear_line
progress "Processed $team_count teams"

# -----------------------------------------------------------------------------
# REPOSITORIES
# -----------------------------------------------------------------------------
progress ""
progress "Fetching repositories..."

REPOS_JSON=$(gh api "/orgs/$ORG/repos" --paginate 2>/dev/null || echo "[]")
REPOS_COUNT=$(echo "$REPOS_JSON" | jq -s 'flatten | length')
ARCHIVED_COUNT=$(echo "$REPOS_JSON" | jq -s 'flatten | map(select(.archived == true)) | length')
ACTIVE_COUNT=$((REPOS_COUNT - ARCHIVED_COUNT))
progress "Found $REPOS_COUNT repositories ($ARCHIVED_COUNT archived)"

REPOS_LOCALS=""
REPOS_IMPORTS=""

active_repo_count=0
while IFS= read -r repo_json; do
  name=$(echo "$repo_json" | jq -r '.name')
  description=$(echo "$repo_json" | jq -r '.description // ""')
  visibility=$(echo "$repo_json" | jq -r '.visibility')
  has_issues=$(echo "$repo_json" | jq -r '.has_issues')
  has_wiki=$(echo "$repo_json" | jq -r '.has_wiki')
  has_projects=$(echo "$repo_json" | jq -r '.has_projects')
  archived=$(echo "$repo_json" | jq -r '.archived')
  repo_secret_scanning=$(echo "$repo_json" | jq -r '.security_and_analysis.secret_scanning.status // "disabled"')
  repo_secret_scanning_push_protection=$(echo "$repo_json" | jq -r '.security_and_analysis.secret_scanning_push_protection.status // "disabled"')

  # Check vulnerability alerts (separate API call, skip for archived repos)
  vulnerability_alerts="false"
  if [ "$archived" = "false" ]; then
    active_repo_count=$((active_repo_count + 1))
    progress_inline "Checking vulnerability alerts $active_repo_count/$ACTIVE_COUNT: $name"
    if gh api "/repos/$ORG/$name/vulnerability-alerts" --silent 2>/dev/null; then
      vulnerability_alerts="true"
    fi
  fi

  description_escaped=$(escape_hcl "$description")

  # Convert status to boolean
  secret_scanning_enabled="false"
  [ "$repo_secret_scanning" = "enabled" ] && secret_scanning_enabled="true"
  secret_scanning_push_protection_enabled="false"
  [ "$repo_secret_scanning_push_protection" = "enabled" ] && secret_scanning_push_protection_enabled="true"

  REPOS_LOCALS+="    \"$name\" = {
      description                     = \"$description_escaped\"
      visibility                      = \"$visibility\"
      has_issues                      = $has_issues
      has_wiki                        = $has_wiki
      has_projects                    = $has_projects
      archived                        = $archived
      vulnerability_alerts            = $vulnerability_alerts
      secret_scanning                 = $secret_scanning_enabled
      secret_scanning_push_protection = $secret_scanning_push_protection_enabled
    }
"

  REPOS_IMPORTS+="import {
  to = github_repository.repos[\"$name\"]
  id = \"$name\"
}

"
done < <(echo "$REPOS_JSON" | jq -c '.[]')

clear_line
progress "Processed $REPOS_COUNT repositories ($active_repo_count checked for vulnerability alerts)"

# -----------------------------------------------------------------------------
# ORGANIZATION SETTINGS (from cached ORG_JSON)
# -----------------------------------------------------------------------------

read -r org_billing_email org_default_repo_permission org_members_can_create_repos org_members_can_create_public_repos \
  org_members_can_create_private_repos org_members_can_create_internal_repos org_members_can_fork_private_repos \
  org_web_commit_signoff org_dependabot_alerts org_dependabot_security_updates org_dependency_graph \
  org_secret_scanning org_secret_scanning_push_protection < <(echo "$ORG_JSON" | jq -r '[
    (.billing_email // ""),
    .default_repository_permission,
    .members_can_create_repositories,
    .members_can_create_public_repositories,
    .members_can_create_private_repositories,
    .members_can_create_internal_repositories,
    .members_can_fork_private_repositories,
    .web_commit_signoff_required,
    .dependabot_alerts_enabled_for_new_repositories,
    .dependabot_security_updates_enabled_for_new_repositories,
    .dependency_graph_enabled_for_new_repositories,
    .secret_scanning_enabled_for_new_repositories,
    .secret_scanning_push_protection_enabled_for_new_repositories
  ] | @tsv')

ORG_SETTINGS_LOCALS="  org_settings = {
    billing_email = \"$org_billing_email\"

    # Repository creation permissions
    default_repository_permission            = \"$org_default_repo_permission\"
    members_can_create_repositories          = $org_members_can_create_repos
    members_can_create_public_repositories   = $org_members_can_create_public_repos
    members_can_create_private_repositories  = $org_members_can_create_private_repos
    members_can_create_internal_repositories = $org_members_can_create_internal_repos
    members_can_fork_private_repositories    = $org_members_can_fork_private_repos

    # Security features for new repositories
    dependabot_alerts_enabled               = $org_dependabot_alerts
    dependabot_security_updates_enabled     = $org_dependabot_security_updates
    dependency_graph_enabled                = $org_dependency_graph
    secret_scanning_enabled                 = $org_secret_scanning
    secret_scanning_push_protection_enabled = $org_secret_scanning_push_protection

    # Commit settings
    web_commit_signoff_required = $org_web_commit_signoff
  }"

ORG_IMPORTS="import {
  to = github_organization_settings.this
  id = \"$ORG\"
}
"

# -----------------------------------------------------------------------------
# ORGANIZATION RULESETS
# -----------------------------------------------------------------------------
progress ""
progress "Fetching organization rulesets..."

RULESETS_JSON=$(gh api "/orgs/$ORG/rulesets" 2>/dev/null || echo "[]")
RULESETS_COUNT=$(echo "$RULESETS_JSON" | jq 'length')
progress "Found $RULESETS_COUNT organization rulesets"

ORG_RULESETS_LOCALS=""
ORG_RULESETS_IMPORTS=""

while IFS=$'\t' read -r ruleset_id ruleset_name target enforcement; do
  [ -z "$ruleset_id" ] && continue

  # Fetch full ruleset details and extract all values in one jq call
  RULESET_DETAIL=$(gh api "/orgs/$ORG/rulesets/$ruleset_id" 2>/dev/null || echo "{}")

  # Extract all ruleset data in a single jq call
  read -r ref_include ref_exclude repo_include repo_exclude \
    deletion non_fast_forward required_linear_history required_signatures \
    has_pr_rule pr_approvals pr_dismiss_stale pr_code_owner pr_last_push pr_thread_resolution \
    < <(echo "$RULESET_DETAIL" | jq -r '[
      (.conditions.ref_name.include // [] | tojson),
      (.conditions.ref_name.exclude // [] | tojson),
      (.conditions.repository_name.include // [] | tojson),
      (.conditions.repository_name.exclude // [] | tojson),
      (.rules | map(select(.type == "deletion")) | length > 0),
      (.rules | map(select(.type == "non_fast_forward")) | length > 0),
      (.rules | map(select(.type == "required_linear_history")) | length > 0),
      (.rules | map(select(.type == "required_signatures")) | length > 0),
      (.rules | map(select(.type == "pull_request")) | length > 0),
      (.rules | map(select(.type == "pull_request")) | .[0].parameters.required_approving_review_count),
      (.rules | map(select(.type == "pull_request")) | .[0].parameters.dismiss_stale_reviews_on_push),
      (.rules | map(select(.type == "pull_request")) | .[0].parameters.require_code_owner_review),
      (.rules | map(select(.type == "pull_request")) | .[0].parameters.require_last_push_approval),
      (.rules | map(select(.type == "pull_request")) | .[0].parameters.required_review_thread_resolution)
    ] | @tsv')

  # Build pull request block if PR rules exist
  pr_block=""
  if [ "$has_pr_rule" = "true" ]; then
    pr_block="
        pull_request = {
          required_approving_review_count   = $pr_approvals
          dismiss_stale_reviews_on_push     = $pr_dismiss_stale
          require_code_owner_review         = $pr_code_owner
          require_last_push_approval        = $pr_last_push
          required_review_thread_resolution = $pr_thread_resolution
        }"
  fi

  ORG_RULESETS_LOCALS+="    \"$ruleset_name\" = {
      target      = \"$target\"
      enforcement = \"$enforcement\"
      conditions = {
        ref_include        = $ref_include
        ref_exclude        = $ref_exclude
        repository_include = $repo_include
        repository_exclude = $repo_exclude
      }
      rules = {
        deletion                = $deletion
        non_fast_forward        = $non_fast_forward
        required_linear_history = $required_linear_history
        required_signatures     = $required_signatures$pr_block
      }
    }
"

  ORG_RULESETS_IMPORTS+="import {
  to = github_organization_ruleset.rulesets[\"$ruleset_name\"]
  id = \"$ruleset_id\"
}

"
done < <(echo "$RULESETS_JSON" | jq -r '.[] | [.id, .name, .target, .enforcement] | @tsv' 2>/dev/null || true)

# -----------------------------------------------------------------------------
# OUTPUT FILES
# -----------------------------------------------------------------------------

# Generate imports.tf
cat > "$OUTPUT_DIR/imports.tf" << EOF
# Auto-generated import blocks
# Generated: $(date -Iseconds)
# Organization: $ORG
#
# Run: terraform plan (to preview) then terraform apply (to import)
# Delete this file after successful import

# Organization settings
$ORG_IMPORTS
# Teams
$TEAMS_IMPORTS
# Repositories
$REPOS_IMPORTS
# Team repository access
$TEAM_REPOS_IMPORTS
# Organization rulesets
$ORG_RULESETS_IMPORTS
EOF

progress ""
progress "============================================="
progress "Generated: $OUTPUT_DIR/imports.tf"

# Update organization.tf with locals
ORG_LOCALS_CONTENT="locals {
$ORG_SETTINGS_LOCALS

  org_rulesets = {
$ORG_RULESETS_LOCALS  }
}"
update_file_with_markers "$OUTPUT_DIR/organization.tf" "$ORG_LOCALS_CONTENT"
progress "Updated: $OUTPUT_DIR/organization.tf"

# Update teams.tf with locals
TEAMS_LOCALS_CONTENT="locals {
  teams = {
$TEAMS_LOCALS  }

  team_repositories = {
$TEAM_REPOS_LOCALS  }
}"
update_file_with_markers "$OUTPUT_DIR/teams.tf" "$TEAMS_LOCALS_CONTENT"
progress "Updated: $OUTPUT_DIR/teams.tf"

# Update repositories.tf with locals
REPOS_LOCALS_CONTENT="locals {
  repositories = {
$REPOS_LOCALS  }
}"
update_file_with_markers "$OUTPUT_DIR/repositories.tf" "$REPOS_LOCALS_CONTENT"
progress "Updated: $OUTPUT_DIR/repositories.tf"

progress ""
progress "Next steps:"
progress "1. Review updated .tf files"
progress "2. Run: terraform init"
progress "3. Run: terraform plan"
progress "4. Run: terraform apply (to import current state)"
progress "5. Delete imports.tf after successful import"
