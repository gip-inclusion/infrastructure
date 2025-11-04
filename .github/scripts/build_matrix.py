#!/usr/bin/env python3

import json
import os
import re
import subprocess
import sys
from pathlib import Path

WORKSPACE = os.environ["GITHUB_WORKSPACE"]
REPOSITORY = os.environ["GITHUB_REPOSITORY"]
EVENT_NAME = os.environ["GITHUB_EVENT_NAME"]
SHA = os.environ["GITHUB_SHA"]

INPUT_BASE = os.getenv("INPUT_BASE")
INPUT_MODULE_PATH = os.getenv("INPUT_MODULE_PATH")

PR_BASE_SHA = os.getenv("PR_BASE_SHA")
BEFORE_SHA = os.getenv("BEFORE_SHA")


def git_cmd(args: list[str], check: bool = True) -> tuple[str, int]:
    result = subprocess.run(
        ["git", *args],
        cwd=WORKSPACE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    if check and result.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed:\n{result.stderr.strip()}")

    return result.stdout.strip(), result.returncode


def fetch_remote_branch(ref: str) -> None:
    """
    Check that refs/remotes/origin/<ref> exists locally
    """
    return_code = git_cmd(["rev-parse", "--verify", "-q", f"refs/remotes/origin/{ref}"], check=False)[1]
    if return_code != 0:
        # Only fetch target branch
        git_cmd(["fetch", "--no-tags", "origin", f"+refs/heads/{ref}:refs/remotes/origin/{ref}"])


def get_module_label(module_path: str) -> str:
    return re.sub(r"^infrastructure/|/terraform$", "", module_path)


def build_matrix() -> None:
    # Manual override: single entry matrix
    if INPUT_MODULE_PATH:
        matrix = [
            {
                "module_path": INPUT_MODULE_PATH,
                "module_label": get_module_label(INPUT_MODULE_PATH),
            }
        ]
    else:
        # Determine BASE commit according to the event type
        diff_refs = None
        if EVENT_NAME == "pull_request":
            if not PR_BASE_SHA:
                sys.exit("::error:: PR_BASE_SHA is missing for pull_request event")
            diff_refs = f"{PR_BASE_SHA}..{SHA}"
        elif EVENT_NAME == "push":
            if not BEFORE_SHA:
                sys.exit("::error:: BEFORE_SHA is missing for push event")
            diff_refs = f"{BEFORE_SHA}..{SHA}"
        elif EVENT_NAME == "workflow_dispatch":
            if not INPUT_BASE:
                sys.exit("::error:: INPUT_BASE is empty; set workflow_dispatch.inputs.base")
            if re.fullmatch(r"[\da-f]{7,40}", INPUT_BASE, re.I):
                base = git_cmd(["rev-parse", "--verify", f"{INPUT_BASE}^{{commit}}"])[0]
                diff_refs = f"{base}..{SHA}"
            else:
                fetch_remote_branch(INPUT_BASE)
                diff_refs = f"refs/remotes/origin/{INPUT_BASE}...HEAD"
        else:
            sys.exit(f"::error::Unsupported event: {EVENT_NAME}")

        if not diff_refs:
            message = f"Failed to compute diff refs for event={EVENT_NAME}"
            if EVENT_NAME == "workflow_dispatch":
                message = f"{message} and base={INPUT_BASE}"
            sys.exit(f"::error::{message}")

        # Collect changed files (include deletions)
        diff = git_cmd(["diff", "--name-status", "--diff-filter=ACDMR", diff_refs])[0]
        files = []
        for line in diff.splitlines():
            columns = line.split("\t")
            status = columns[0]
            kind = status[0]

            match kind:
                case "R":
                    # Renamed: append both old and new path
                    files.append(columns[1])
                    files.append(columns[2])
                case "C":
                    # Copied: only append new path
                    files.append(columns[2])
                case "A" | "D" | "M":
                    # Status among:
                    # - A (added)
                    # - D (deleted)
                    # - M (modified)
                    # Append the only one path returned by diff
                    files.append(columns[1])

        # Normalize to modules root (`infrastructure/.../terraform`)
        module_re = re.compile(r"^(infrastructure/[^_].*/terraform)(?:/.*)?$")
        skip_md = re.compile(r"\.(md|markdown)$", re.I)
        changed_modules = sorted(
            {
                module_path.group(1)
                for filename in files
                # Ignore markdown files
                if not skip_md.search(filename)
                if (module_path := module_re.match(filename))
                # Ignore deleted modules
                if (Path(WORKSPACE) / module_path.group(1)).is_dir()
            }
        )
        matrix = [
            {
                "module_path": module_path,
                "module_label": get_module_label(module_path),
            }
            for module_path in changed_modules
        ]

    # Emit outputs
    matrix_json = json.dumps(matrix, separators=(",", ":"))
    count = len(matrix)
    with open(os.getenv("GITHUB_OUTPUT"), "a") as output_fd:
        output_fd.write(f"matrix={matrix_json}\n")
        output_fd.write(f"count={count}\n")

    # Display a human-friendly summary
    lines = ["### Terraform modules to run", ""]
    if count:
        lines += [
            "| # | Module | Lien |",
            "|--:|:-------|:-----|",
        ]
        for cnt, module_info in enumerate(matrix, 1):
            path = module_info["module_path"]
            url = f"https://github.com/{REPOSITORY}/tree/{SHA}/{path}"
            lines.append(f"| {cnt} | `{path}` | [Lien]({url}) |")
    else:
        lines += ["_No Terraform modules changed._"]
    with open(os.getenv("GITHUB_STEP_SUMMARY"), "a") as step_summary_fd:
        step_summary_fd.write(f"{'\n'.join(lines)}\n")


if __name__ == "__main__":
    build_matrix()
