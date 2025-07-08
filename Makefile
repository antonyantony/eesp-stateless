MD_SOURCE ?= eesp-stateless-encryption.md

# Define the base name of your draft (without extension)
# Using sed to remove prefix, then another sed to remove suffix
DRAFT_BASE := $(shell sed -n 's/^docname: //p' $(MD_SOURCE) | sed -E 's/-[0-9]{2}$$//')
# Using sed to extract the last two digits
VERSION := $(shell sed -n -E 's/^.*-([0-9]{2})$$/\1/p' $(MD_SOURCE))
DRAFT_NAME := $(DRAFT_BASE)-$(VERSION)

# Debugging: Print resolved variables (optional, remove after fixing)
$(info DRAFT_BASE is: $(DRAFT_BASE))
$(info VERSION is: $(VERSION))
$(info DRAFT_NAME is: $(DRAFT_NAME))

VERSION_NOZERO := $(shell echo "$(VERSION)" | sed -e 's/^0*//')
NEXT_VERSION := $(shell printf "%02d" "$$(($(VERSION_NOZERO) + 1))")
PREV_VERSION := $(shell printf "%02d" "$$(($(VERSION_NOZERO) - 1))")

# Define source and target files
XML_TARGET := draft/$(DRAFT_NAME).xml
TXT_TARGET := draft/$(DRAFT_NAME).txt
HTML_TARGET := draft/$(DRAFT_NAME).html

# Define commands for the converters
# kramdown-rfc is typically available as a Ruby gem
KRAMDOWN_RFC := kramdown-rfc

# xml2rfc is a Python package
# pip install xml2rfc
XML2RFC := xml2rfc

# Default target: build all common formats
all: $(TXT_TARGET) $(HTML_TARGET)

# Rule to convert Markdown to RFCXML
$(XML_TARGET): $(MD_SOURCE)
	mkdir -p draft || true
	@echo "Converting $(MD_SOURCE) to RFCXML ($(XML_TARGET))..."
	$(KRAMDOWN_RFC) $< > $@
	@echo "RFCXML conversion complete $@"

# Rule to convert RFCXML to TXT
$(TXT_TARGET): $(XML_TARGET)
	@echo "Converting $(XML_TARGET) to TXT ($(TXT_TARGET))..."
	$(XML2RFC) --text $< -o $@
	@echo "TXT conversion complete."

# Rule to convert RFCXML to HTML
$(HTML_TARGET): $(XML_TARGET)
	@echo "Converting $(XML_TARGET) to HTML ($(HTML_TARGET))..."
	$(XML2RFC) --html $< -o $@
	@echo "HTML conversion complete."

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -f $(XML_TARGET) $(TXT_TARGET) $(HTML_TARGET) $(PDF_TARGET)
	@echo "Clean up complete."

.PHONY: all clean

