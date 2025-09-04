#!/usr/bin/env python3
"""
Parse backend operator test logs and classify support levels.

Classification rules (case-insensitive):
    - fail:    any occurrence of "FAIL"
    - partial: contains both "OK" and "NOT SUPPORTED"
    - supported: contains at least one "OK" and no "NOT SUPPORTED"
    - unsupported: contains "NOT SUPPORTED" only
    - unknown: none of the above keywords found
"""
from __future__ import annotations

import argparse
from collections import defaultdict
from pathlib import Path
from typing import Dict, List


def classify_log(text: str) -> str:
    upper = text.upper()
    has_fail = "FAIL" in upper
    has_ok = "OK" in upper
    has_not_supported = "NOT SUPPORTED" in upper

    if has_fail:
        return "fail"
    if has_ok and has_not_supported:
        return "partial"
    if has_ok:
        return "supported"
    if has_not_supported:
        return "unsupported"
    return "unknown"


STATUS_SYMBOLS = {
    "supported": "✅",
    "partial": "🟡",
    "fail": "❌",
    "unsupported": "❓",
    "unknown": "🔍",
}

STATUS_SYMBOLS_INV = {v: k for k, v in STATUS_SYMBOLS.items()}


def format_markdown(classification: Dict[str, List[str]]) -> str:
    lines = [
        "### Backend Operator Support Summary",
        "",
        "| Operator | Status |",
        "| --- | --- |",
    ]

    ordered_statuses = ["supported", "partial", "fail", "unsupported", "unknown"]
    for status in ordered_statuses:
        operators = classification.get(status, [])
        if not operators:
            continue
        symbol = STATUS_SYMBOLS.get(status, "?")
        for op in sorted(operators):
            lines.append(f"| {op} | {symbol} |")

    if len(lines) == 4:  # no rows added
        lines.append("| None | - |")

    lines.append("\nTips: ✅ supported, 🟡 partially supported, ❌ fail, ❓ unsupported, 🔍 unknown")
    return "\n".join(lines)


def parse_summary_table(summary_text: str) -> Dict[str, str]:
    """Parse an existing markdown summary back into {op: status} mapping."""

    op_status: Dict[str, str] = {}
    for line in summary_text.splitlines():
        if not line.startswith("|"):
            continue
        parts = [p.strip() for p in line.split("|") if p.strip()]
        if len(parts) != 2:  # header or malformed rows
            continue
        op, symbol = parts
        status = STATUS_SYMBOLS_INV.get(symbol)
        if status:
            op_status[op] = status
    return op_status


def tail_lines(path: Path, limit: int = 120) -> str:
    """Return the last N lines of a text file as a single string."""

    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()
    return "\n".join(lines[-limit:])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--log-dir",
        required=True,
        help="Directory containing per-operator backend test logs.",
    )
    parser.add_argument(
        "--summary-file",
        help="Optional file (e.g., $GITHUB_STEP_SUMMARY) to append markdown summary.",
    )
    args = parser.parse_args()

    log_dir = Path(args.log_dir)
    if not log_dir.is_dir():
        raise SystemExit(f"log directory not found: {log_dir}")

    classification: Dict[str, List[str]] = defaultdict(list)
    for log_file in sorted(log_dir.glob("*.log")):
        text = log_file.read_text(encoding="utf-8", errors="ignore")
        status = classify_log(text)
        classification[status].append(log_file.stem)

    previous_content = ""
    previous_classification: Dict[str, str] = {}
    summary_path: Path | None = None
    if args.summary_file:
        summary_path = Path(args.summary_file)
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        if summary_path.exists():
            previous_content = summary_path.read_text(encoding="utf-8")
            previous_classification = parse_summary_table(previous_content)

    changed_ops: List[tuple[str, str | None, str]] = []
    if previous_classification:
        for status, ops in classification.items():
            for op in ops:
                prev_status = previous_classification.get(op)
                if prev_status is not None and prev_status != status:
                    changed_ops.append((op, prev_status, status))

    markdown = format_markdown(classification)

    if changed_ops:
        change_lines: List[str] = [
            "",
            "### Operators with changed status",
            "",
            "| Operator | Previous | Current |",
            "| --- | --- | --- |",
        ]
        for op, prev_status, curr_status in sorted(changed_ops):
            change_lines.append(
                f"| {op} | {prev_status} ({STATUS_SYMBOLS.get(prev_status, '?')}) | {curr_status} ({STATUS_SYMBOLS.get(curr_status, '?')}) |"
            )

        for op, prev_status, curr_status in sorted(changed_ops):
            log_file = log_dir / f"{op}.log"
            if not log_file.is_file():
                change_lines.append(f"- {op}: log file not found ({log_file})")
                continue
            change_lines.extend(
                [
                    "",
                    f"#### {op} log ({prev_status} -> {curr_status})",
                    "```text",
                    tail_lines(log_file),
                    "```",
                ]
            )

        change_log_path.parent.mkdir(parents=True, exist_ok=True)
        new_change_content = "\n".join(change_lines) + "\n"
        previous_change_content = ""
        if change_log_path.exists():
            previous_change_content = change_log_path.read_text(encoding="utf-8")
        if previous_change_content != new_change_content:
            change_log_path.write_text(new_change_content, encoding="utf-8")

    print(markdown)
    if args.summary_file:
        summary_path = Path(args.summary_file)
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        if summary_path.exists():
            previous_content = summary_path.read_text(encoding="utf-8")
            previous_classification = parse_summary_table(previous_content)

    changed_ops: List[tuple[str, str | None, str]] = []
    if previous_classification:
        for status, ops in classification.items():
            for op in ops:
                prev_status = previous_classification.get(op)
                if prev_status is not None and prev_status != status:
                    changed_ops.append((op, prev_status, status))

    markdown = format_markdown(classification)

    if changed_ops:
        change_lines: List[str] = [
            "",
            "### Operators with changed status",
            "",
            "| Operator | Previous | Current |",
            "| --- | --- | --- |",
        ]
        for op, prev_status, curr_status in sorted(changed_ops):
            change_lines.append(
                f"| {op} | {prev_status} ({STATUS_SYMBOLS.get(prev_status, '?')}) | {curr_status} ({STATUS_SYMBOLS.get(curr_status, '?')}) |"
            )

        for op, prev_status, curr_status in sorted(changed_ops):
            log_file = log_dir / f"{op}.log"
            if not log_file.is_file():
                change_lines.append(f"- {op}: log file not found ({log_file})")
                continue
            change_lines.extend(
                [
                    "",
                    f"#### {op} log ({prev_status} -> {curr_status})",
                    "```text",
                    tail_lines(log_file),
                    "```",
                ]
            )

        markdown = markdown + "\n" + "\n".join(change_lines)

    print(markdown)
    if args.summary_file:
        new_content = markdown + "\n"
        if previous_content != new_content:
            summary_path.write_text(new_content, encoding="utf-8")


if __name__ == "__main__":
    main()
