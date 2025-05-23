# Usage

Command to generate weather report PDF: `make` / `make report.pdf`

Steps to generate weather report PDF of different city:
1. Put appropriate web URL in Makefile.
2. Use command: `make` / `make report.pdf`

*The clean target works only immediately after a successful build.*

# Dependency

Uses `pdftex` on Linux to render LaTeX into PDF. Last tested with:
```sh
pdfTeX 3.14159265-2.6-1.40.20 (TeX Live 2019/Debian)
kpathsea version 6.3.1
```
