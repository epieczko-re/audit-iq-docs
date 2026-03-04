# =============================================================================
# AuditIQ Documentation Build Environment
# =============================================================================
# Extends the official asciidoctor Docker image with pandoc for DOCX conversion.
#
# The base image already includes:
#   - asciidoctor, asciidoctor-pdf, asciidoctor-diagram, asciidoctor-kroki
#   - PlantUML, Graphviz, Ditaa (local diagram rendering)
#   - Java (OpenJDK 21), Python3
#
# Mermaid diagrams are rendered via Kroki (kroki.io) — no Node.js or
# headless browser needed. Override KROKI_URL in the Makefile to point
# to a self-hosted instance if network access is restricted.
#
# Build:   docker build -t auditiq-docs .
# Usage:   docker run --rm -v "$(pwd)":/documents auditiq-docs make all
# =============================================================================

FROM asciidoctor/docker-asciidoctor:latest

LABEL maintainer="RiskExec Engineering"
LABEL description="AuditIQ documentation build environment with diagram support"

# Install pandoc for DOCX conversion
RUN apk add --no-cache pandoc

# Set working directory
WORKDIR /documents

# Default command: build all formats
CMD ["make", "all"]
