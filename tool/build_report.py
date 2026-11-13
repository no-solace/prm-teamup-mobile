#!/usr/bin/env python3
"""Build the Lab 3 final report (PDF) and the slide deck (PDF) from Markdown.

Usage:
    python tool/build_report.py --student-id SE180776

The script
  1. renders every ```mermaid block of the source Markdown to SVG
     (mermaid CLI, `mmdc`),
  2. converts the Markdown to a self-contained HTML page with print styles,
  3. prints it to PDF with a headless Chromium.

Outputs:
    report/Lab03_<StudentID>.pdf
    slides/Lab03_<StudentID>_slides.pdf

The generated HTML files are kept next to the PDF so a slide can be re-exported
by hand after an edit.
"""
from __future__ import annotations

import argparse
import base64
import html
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import markdown

ROOT = Path(__file__).resolve().parent.parent
BROWSER_CANDIDATES = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
]

FENCE = re.compile(r"```(?P<lang>[a-zA-Z0-9_+-]*)\n(?P<body>.*?)```", re.DOTALL)


def find_browser() -> str:
    for candidate in BROWSER_CANDIDATES:
        if Path(candidate).exists():
            return candidate
    found = (
        shutil.which("chrome")
        or shutil.which("chromium")
        or shutil.which("msedge")
        or shutil.which("google-chrome")
    )
    if found:
        return found
    raise SystemExit("No Chromium/Chrome binary found for PDF export.")


def render_mermaid(block: str, target: Path) -> bool:
    """Render one mermaid block to SVG. Returns False when it cannot be done."""
    if target.exists():
        return True
    with tempfile.NamedTemporaryFile(
        "w", suffix=".mmd", delete=False, encoding="utf-8"
    ) as handle:
        handle.write(block)
        temp = handle.name
    try:
        result = subprocess.run(
            ["mmdc", "-i", temp, "-o", str(target), "-b", "transparent"],
            capture_output=True,
            text=True,
        )
        return result.returncode == 0 and target.exists()
    finally:
        Path(temp).unlink(missing_ok=True)


def svg_data_uri(path: Path) -> str:
    data = path.read_bytes()
    return "data:image/svg+xml;base64," + base64.b64encode(data).decode()


def convert(source: Path, css: str, title: str, diagram_dir: Path) -> str:
    text = source.read_text(encoding="utf-8")
    blocks: list[str] = []

    def collect(match: re.Match[str]) -> str:
        lang = match.group("lang")
        body = match.group("body")
        if lang == "mermaid":
            blocks.append(body)
            return f"@@MERMAID{len(blocks) - 1}@@"
        escaped = html.escape(body)
        return f"<pre><code>{escaped}</code></pre>"

    text = FENCE.sub(collect, text)
    body = markdown.markdown(text, extensions=["tables", "fenced_code", "toc"])

    for index, block in enumerate(blocks):
        target = diagram_dir / f"{source.stem}-{index + 1}.svg"
        if render_mermaid(block, target):
            body = body.replace(
                f"@@MERMAID{index}@@",
                f'<figure><img src="{svg_data_uri(target)}" alt="diagram"/></figure>',
            )
        else:
            body = body.replace(f"@@MERMAID{index}@@", "<p>(diagram)</p>")

    return f"""<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8"/>
<title>{html.escape(title)}</title>
<style>{css}</style>
</head>
<body>
{body}
</body>
</html>"""


def print_pdf(html_path: Path, pdf_path: Path) -> None:
    browser = find_browser()
    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    command = [
        browser,
        "--headless",
        "--disable-gpu",
        "--no-sandbox",
        "--no-pdf-header-footer",
        f"--print-to-pdf={pdf_path.resolve()}",
        html_path.resolve().as_uri(),
    ]
    result = subprocess.run(command, capture_output=True, text=True)
    if not pdf_path.exists():
        raise SystemExit(f"PDF export failed:\n{result.stderr[-2000:]}")


def build(
    source: Path,
    css_path: Path,
    title: str,
    pdf_path: Path,
    html_path: Path,
    diagram_dir: Path,
) -> None:
    css = css_path.read_text(encoding="utf-8")
    page = convert(source, css, title, diagram_dir)
    with tempfile.TemporaryDirectory() as tmp:
        temp_html = Path(tmp) / "page.html"
        temp_html.write_text(page, encoding="utf-8")
        print_pdf(temp_html, pdf_path)
    html_path.write_text(page, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--student-id", default="group6")
    args = parser.parse_args()

    diagram_dir = ROOT / "build" / "diagrams"

    build(
        ROOT / "report" / "Lab03_report.md",
        ROOT / "tool" / "report.css",
        "TeamUp EXE - PRM393 Lab 3 report",
        ROOT / "report" / f"Lab03_{args.student_id}.pdf",
        ROOT / "report" / "Lab03_report.html",
        diagram_dir,
    )
    build(
        ROOT / "slides" / "Lab03_slides.md",
        ROOT / "tool" / "slides.css",
        "TeamUp EXE - PRM393 Lab 3 slides",
        ROOT / "slides" / f"Lab03_{args.student_id}_slides.pdf",
        ROOT / "slides" / "Lab03_slides.html",
        diagram_dir,
    )

    print(f"report/Lab03_{args.student_id}.pdf")
    print(f"slides/Lab03_{args.student_id}_slides.pdf")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
