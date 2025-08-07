import argparse
import os
import sys

src_parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(src_parent_dir)
from src.benchmark.utils import read_metrics, to_markdown_table


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", type=str, required=True, help="Report path.")
    parser.add_argument("--write-gh-job-summary", action="store_true", help="Write to GitHub job summary.")
    parser.add_argument("--update-readme", action="store_true", help="Update statistics report in README.md.")
    return parser.parse_args()


def generate_report(path: str):
    metrics = read_metrics(path, metric="accuracy")
    html_table = to_markdown_table(metrics)
    return html_table


def write_job_summary(report):
    summary_path = os.environ["GITHUB_STEP_SUMMARY"]
    with open(summary_path, "a") as f:
        f.write("## Torchbenchmark statistics report\n")
        f.write(report)


def update_readme(report):
    project_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    readme_path = os.path.join(project_path, "README.md")
    print(readme_path)
    with open(readme_path, "r") as f:
        readme_content = f.read()

    start_marker = "<!-- Torchbenchmark start -->"
    end_marker = "<!-- Torchbenchmark end -->"
    start_index = readme_content.find(start_marker)
    end_index = readme_content.find(end_marker)
    assert start_index != -1
    assert end_index != -1

    start_index += len(start_marker)
    new_readme_content = (
            readme_content[:start_index] + "\n\n" +
            report + "\n\n" +
            readme_content[end_index:]
    )
    with open(readme_path, "w") as f:
        f.write(new_readme_content)


if __name__ == "__main__":
    args = parse_args()

    # Generate statistics report
    report = generate_report(args.path)

    # Write to workflow job summary
    if args.write_gh_job_summary:
        write_job_summary(report)

    # Update README.md
    if args.update_readme:
        update_readme(report)
