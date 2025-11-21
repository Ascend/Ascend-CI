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
    "fail": "✗",
    "partial": "△",
    "unsupported": "unsupported",
    "supported": "✓",
    "unknown": "?",
}


def format_markdown(classification: Dict[str, List[str]]) -> str:
    lines = [
        "### Backend Operator Support Summary",
        "",
        "| Operator | Status |",
        "| --- | --- |",
    ]

    ordered_statuses = ["fail", "partial", "unsupported", "supported", "unknown"]
    for status in ordered_statuses:
        operators = classification.get(status, [])
        if not operators:
            continue
        symbol = STATUS_SYMBOLS.get(status, "?")
        for op in sorted(operators):
            lines.append(f"| {op} | {symbol} |")

    if len(lines) == 4:  # no rows added
        lines.append("| None | - |")

    lines.append("\nTips:the legend: ✓ supported, △ partially supported, ✗ fail, unsupported, ? unknown")
    return "\n".join(lines)


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

    markdown = format_markdown(classification)
    print(markdown)
    if args.summary_file:
        with open(args.summary_file, "a", encoding="utf-8") as fh:
            fh.write(markdown + "\n")


if __name__ == "__main__":
    main()
