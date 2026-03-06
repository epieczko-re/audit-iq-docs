# AuditIQ Documentation Repository

## Project Overview

This repository contains the AuditIQ Product Architecture & Delivery Plan, written in AsciiDoc.
The document is built into HTML, PDF, and DOCX formats via a GitHub Actions CI/CD pipeline.

## Repository Structure

- `src/docs/asciidoc/auditiq-product-architecture-delivery-plan/` — Main document source (AsciiDoc)
  - `index.adoc` — Root document that includes all section files
  - Each subdirectory contains an `index.adoc` for that section
- `src/docs/resources/` — Themes, fonts, images, and CSS
- `.github/workflows/build-docs.yml` — CI/CD pipeline (build + deploy to GitHub Pages)
- `.editorconfig` — Editor configuration enforcing one-sentence-per-line for AsciiDoc files
- `Makefile` / `Dockerfile` — Local build tooling

## Writing Conventions

- **One sentence per line** in all `.adoc` files.
  Each sentence must start on its own line.
  This improves diffs, review, and merge conflict resolution.
- Use AsciiDoc cross-references (`<<anchor-id>>` or `<<anchor-id, Display Text>>`) to link between sections.
- All confidence metrics, thresholds, and glossary terms are defined in the Canonical Glossary (Appendices section).
  If a value conflicts elsewhere, the Glossary governs.

## Version History Protocol

**Update the version history** in `src/docs/asciidoc/auditiq-product-architecture-delivery-plan/document-control/index.adoc` using these rules:

- **One entry per calendar day.** If a row already exists for today's date, update it. Otherwise, increment the minor version and add a new row.
- **High-level business impact only.** Describe _what_ changed and _why_ it matters in one to three sentences. Do not list formatting fixes, file renames, CSS tweaks, or implementation details — those belong in git history, not the version table.
- **Examples of good entries:** "Added Compliance Framework Library with 13-framework priority list and cross-framework mapping engine" or "Reorganized document into seven-Part structure for clearer audience navigation."
- **Examples of bad entries:** "Fixed linting violations in section 17" or "Replaced broken @font-face declarations with Google Fonts CDN."

## Build

### Local (Docker)

```bash
make build
```

### CI/CD

Pushes to `main`/`master` trigger the GitHub Actions workflow which:
1. Builds HTML, PDF, and DOCX
2. Deploys HTML to GitHub Pages
3. Creates a release with PDF/DOCX on tag pushes (`v*`)

## Linting

The CI pipeline includes a sentence-per-line lint check for all `.adoc` files.
Lines containing multiple sentences (detected by `. [A-Z]` patterns mid-line) will fail the build.
Exceptions exist for AsciiDoc directives, table rows, source blocks, and listing blocks.
