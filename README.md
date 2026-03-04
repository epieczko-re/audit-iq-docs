# AuditIQ Documentation

Product architecture and delivery plan documentation for AuditIQ, built with [AsciiDoc](https://docs.asciidoctor.org/) and published automatically via CI/CD.

## Published Documentation

| Format | Location |
|--------|----------|
| **HTML** (GitHub Pages) | `https://epieczko-re.github.io/audit-iq-docs/` |
| **PDF / DOCX** | Download from [Releases](../../releases) or [Actions](../../actions) build artifacts |

GitHub Pages is updated automatically on every push to `main`.

## Project Structure

```
src/docs/
├── asciidoc/
│   └── auditiq-product-architecture-delivery-plan/
│       ├── index.adoc                  ← main entry point
│       ├── executive-summary/
│       ├── architecture-overview/
│       ├── component-level-design/
│       ├── data-model/
│       ├── delivery-plan/
│       ├── scoring-framework/
│       └── ...                         ← 30+ topic sections
└── resources/
    ├── fonts/          ← Barlow font family
    ├── images/         ← Logos and diagrams
    ├── styles/         ← Custom CSS
    └── themes/         ← PDF theme (riskexec-theme.yml)
```

## Building Locally

### With Docker (recommended — zero local dependencies)

```bash
make docker-all          # Build HTML + PDF + DOCX
make docker-html         # Build HTML only
make docker-pdf          # Build PDF only
make docker-docx         # Build DOCX only
make docker-shell        # Open a shell in the build container
```

### Without Docker

Install prerequisites:

```bash
gem install asciidoctor asciidoctor-pdf asciidoctor-diagram \
           asciidoctor-kroki asciidoctor-mathematical
brew install pandoc      # or apt install pandoc
```

Then:

```bash
make all                 # Build HTML + PDF + DOCX
make html                # Build HTML only
make pdf                 # Build PDF only
make docx                # Build DOCX only
```

Output goes to `build/`.

## Diagrams

Diagrams are authored inline in AsciiDoc source using fenced blocks:

| Type | Rendering | Example syntax |
|------|-----------|----------------|
| Mermaid | Kroki (remote) | `[mermaid]\n----\ngraph LR; A-->B\n----` |
| PlantUML | Local (built-in) | `[plantuml]\n----\nAlice -> Bob\n----` |
| Graphviz | Local (built-in) | `[graphviz]\n----\ndigraph { a -> b }\n----` |
| Ditaa | Local (built-in) | `[ditaa]\n----\n+--+\n|  |\n+--+\n----` |

Mermaid is rendered by a [Kroki](https://kroki.io) service container in CI. For local Docker builds, diagrams go through the public `kroki.io` API (override with `KROKI_URL`).

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/build-docs.yml`) runs on pushes to `main` and on pull requests:

1. **Build** — Generates HTML, PDF, and DOCX inside the `asciidoctor/docker-asciidoctor` container with a Kroki sidecar for Mermaid rendering
2. **Deploy** — Publishes HTML to GitHub Pages (on push to `main`)
3. **Release** — Attaches PDF and DOCX to GitHub Releases (on version tags like `v1.0.0`)

### Creating a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers the release job, which creates a GitHub Release with the PDF and DOCX attached.
