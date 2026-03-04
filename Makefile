# =============================================================================
# AuditIQ Documentation Build System
# =============================================================================
# Builds AsciiDoc documentation to PDF, HTML, and DOCX formats.
#
# Diagram rendering strategy:
#   All diagrams (Mermaid, PlantUML, Graphviz, Ditaa) are rendered via Kroki.
#   In CI, a self-hosted Kroki container runs as a service sidecar.
#   For local Docker builds, the public kroki.io API is used by default.
#
# Prerequisites (native):
#   gem install asciidoctor asciidoctor-pdf asciidoctor-kroki \
#              asciidoctor-mathematical
#   apt install pandoc    # or brew install pandoc
#
# Or use Docker (recommended — zero local deps):
#   make docker-all
# =============================================================================

# --- Configuration -----------------------------------------------------------
DOC_NAME     := auditiq-product-architecture-delivery-plan
DOC_SRC      := src/docs/asciidoc/$(DOC_NAME)/index.adoc
BUILD_DIR    := build
RESOURCES    := src/docs/resources
THEME        := $(RESOURCES)/themes/riskexec-theme.yml
FONTS_DIR    := $(RESOURCES)/fonts
IMAGES_DIR   := $(RESOURCES)/images
STYLES_DIR   := $(RESOURCES)/styles

# Kroki server for diagram rendering (public instance; override for self-hosted)
KROKI_URL    ?= https://kroki.io

# Docker image (ships with asciidoctor + asciidoctor-kroki)
DOCKER_IMAGE := asciidoctor/docker-asciidoctor:latest
DOCKER_RUN   := docker run --rm -v "$(CURDIR)":/documents -w /documents $(DOCKER_IMAGE)

# --- Common Asciidoctor flags ------------------------------------------------
# Kroki handles all diagram types: Mermaid, PlantUML, Graphviz, Ditaa
ASCIIDOCTOR_COMMON := \
	-r asciidoctor-kroki \
	-a kroki-server-url=$(KROKI_URL) \
	-a kroki-fetch-diagram \
	-a imagesoutdir=$(BUILD_DIR)/images \
	-a allow-uri-read \
	-a icons=font

# --- Targets -----------------------------------------------------------------
.PHONY: all html pdf docx clean docker-all docker-html docker-pdf docker-docx help

all: html pdf docx ## Build all formats (native)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# --- HTML Build --------------------------------------------------------------
html: $(BUILD_DIR) ## Build HTML output
	asciidoctor \
		$(ASCIIDOCTOR_COMMON) \
		-a data-uri \
		-a toc=left \
		-a toclevels=3 \
		-a source-highlighter=highlight.js \
		-D $(BUILD_DIR) \
		-o $(DOC_NAME).html \
		$(DOC_SRC)
	@echo "HTML output: $(BUILD_DIR)/$(DOC_NAME).html"

# --- PDF Build ---------------------------------------------------------------
pdf: $(BUILD_DIR) ## Build PDF output
	asciidoctor-pdf \
		$(ASCIIDOCTOR_COMMON) \
		-a pdf-theme=$(THEME) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-D $(BUILD_DIR) \
		-o $(DOC_NAME).pdf \
		$(DOC_SRC)
	@echo "PDF output: $(BUILD_DIR)/$(DOC_NAME).pdf"

# --- DOCX Build (via DocBook + pandoc) ---------------------------------------
docx: $(BUILD_DIR) ## Build DOCX output
	asciidoctor \
		-b docbook5 \
		$(ASCIIDOCTOR_COMMON) \
		-a data-uri \
		-D $(BUILD_DIR) \
		-o $(DOC_NAME).xml \
		$(DOC_SRC)
	cd $(BUILD_DIR) && pandoc \
		--from docbook \
		--to docx \
		--toc \
		--toc-depth=3 \
		--resource-path=.:../$(IMAGES_DIR) \
		-o $(DOC_NAME).docx \
		$(DOC_NAME).xml
	rm -f $(BUILD_DIR)/$(DOC_NAME).xml
	@echo "DOCX output: $(BUILD_DIR)/$(DOC_NAME).docx"

# --- Docker Builds -----------------------------------------------------------
docker-all: docker-html docker-pdf docker-docx ## Build all formats via Docker

docker-html: $(BUILD_DIR) ## Build HTML via Docker
	$(DOCKER_RUN) make html

docker-pdf: $(BUILD_DIR) ## Build PDF via Docker
	$(DOCKER_RUN) make pdf

docker-docx: $(BUILD_DIR) ## Build DOCX via Docker
	$(DOCKER_RUN) sh -c "apk add --no-cache pandoc && make docx"

docker-shell: ## Open a shell in the Docker container
	docker run --rm -it -v "$(CURDIR)":/documents -w /documents $(DOCKER_IMAGE) sh

# --- Utilities ---------------------------------------------------------------
clean: ## Remove all build artifacts
	rm -rf $(BUILD_DIR)
	@echo "Build directory cleaned."

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
