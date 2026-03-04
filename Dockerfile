# =============================================================================
# AuditIQ Documentation Build Environment
# =============================================================================
# Extends the official asciidoctor Docker image with Mermaid support,
# pandoc for DOCX conversion, and additional diagram tools.
#
# Build:   docker build -t auditiq-docs .
# Usage:   docker run --rm -v "$(pwd)":/documents auditiq-docs make all
# =============================================================================

FROM asciidoctor/docker-asciidoctor:latest

LABEL maintainer="RiskExec Engineering"
LABEL description="AuditIQ documentation build environment with diagram support"

# Install pandoc for DOCX conversion
RUN apk add --no-cache pandoc

# Install mermaid-cli for Mermaid diagram rendering
# The base image already includes Node.js and Chromium
RUN npm install -g @mermaid-js/mermaid-cli && \
    npm cache clean --force

# Create puppeteer config for headless Chromium in containers
RUN mkdir -p /root && \
    echo '{"executablePath":"/usr/bin/chromium-browser","args":["--no-sandbox","--disable-setuid-sandbox","--disable-dev-shm-usage"]}' \
    > /root/.puppeteerrc.json

# Set working directory
WORKDIR /documents

# Default command: build all formats
CMD ["make", "all"]
