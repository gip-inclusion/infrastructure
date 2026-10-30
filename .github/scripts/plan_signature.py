#!/usr/bin/env python3

"""
Sign and verify Terraform plan artifacts with an HMAC-SHA256.

Usage: plan_signature.py sign|verify, every other input is read from the environment

The plan job signs its artifact (`sign` writes tfplan.sig)
The apply job checks that signature before decrypting the plan (`verify`), so that the apply job only runs
plans signed by a plan job
The signing key only exists in the terraform-plan and terraform-apply environments

The signed message binds:
- The PR head commit
- The module name
- The PR base branch
- The plan run id
- The checksums of the plaintext plan (tfplan.sha256) and of the encrypted plan (tfplan.bin.age)
"""

import hashlib
import hmac
import os
import sys
from pathlib import Path


TF_PLAN_SIGNING_KEY = os.getenv("TF_PLAN_SIGNING_KEY", "").strip()
PLAN_COMMIT_SHA = os.getenv("PLAN_COMMIT_SHA", "")
MODULE_ID = os.getenv("MODULE_ID", "")
# PLAN_BASE_REF may be empty: workflow_dispatch runs have no PR base, and their plans are never applied
PLAN_BASE_REF = os.getenv("PLAN_BASE_REF", "")
PLAN_RUN_ID = os.getenv("PLAN_RUN_ID", "")
PLAN_DIR = os.getenv("PLAN_DIR", "")


def check_inputs() -> None:
    if not TF_PLAN_SIGNING_KEY:
        sys.exit("::error::TF_PLAN_SIGNING_KEY is empty")
    required = {
        "PLAN_COMMIT_SHA": PLAN_COMMIT_SHA,
        "MODULE_ID": MODULE_ID,
        "PLAN_RUN_ID": PLAN_RUN_ID,
        "PLAN_DIR": PLAN_DIR,
    }
    for name, value in required.items():
        if not value:
            sys.exit(f"::error::{name} is empty")


def read_plan_file(name: str) -> bytes:
    try:
        return (Path(PLAN_DIR) / name).read_bytes()
    except FileNotFoundError:
        sys.exit(f"::error::{name} not found in {PLAN_DIR}")


def build_message() -> bytes:
    plan_checksum = read_plan_file("tfplan.sha256").decode().strip()
    encrypted_checksum = hashlib.sha256(read_plan_file("tfplan.bin.age")).hexdigest()
    fields = {
        "PLAN_COMMIT_SHA": PLAN_COMMIT_SHA,
        "MODULE_ID": MODULE_ID,
        "PLAN_BASE_REF": PLAN_BASE_REF,
        "PLAN_RUN_ID": PLAN_RUN_ID,
        "tfplan.sha256": plan_checksum,
        "tfplan.bin.age": encrypted_checksum,
    }
    for name, value in fields.items():
        if "\n" in value:
            sys.exit(f"::error::{name} must not contain a newline")
    return "\n".join(fields.values()).encode()


def compute_signature() -> str:
    return hmac.new(TF_PLAN_SIGNING_KEY.encode(), build_message(), hashlib.sha256).hexdigest()


def sign() -> None:
    signature_path = Path(PLAN_DIR) / "tfplan.sig"
    signature_path.write_text(f"{compute_signature()}\n")
    print(f"Plan signature written to {signature_path}")


def verify() -> None:
    signature = read_plan_file("tfplan.sig").strip()
    if not signature:
        sys.exit("::error::tfplan.sig is empty")
    if not hmac.compare_digest(compute_signature().encode(), signature):
        sys.exit("::error::Plan signature does not match the plan artifact")
    print("Plan signature verified")


def main() -> None:
    command = sys.argv[1] if len(sys.argv) == 2 else None
    if command not in ("sign", "verify"):
        sys.exit("::error::Usage: plan_signature.py sign|verify")
    check_inputs()
    match command:
        case "sign":
            sign()
        case "verify":
            verify()


if __name__ == "__main__":
    main()
