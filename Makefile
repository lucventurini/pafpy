PROJECT = pafpy
COVG_REPORT = htmlcov/index.html
DOCS_DIR = docs/
DOCS_TEMPLATE = docs/templates/
OS := $(shell uname -s)
# MAIN #########################################################################

.PHONY: all
all: install

# DEPENDENCIES #################################################################
.PHONY: install
install:
	poetry install

# TIDY #################################################################
.PHONY: fmt
fmt: clean
	poetry run isort --apply --atomic tests/*.py $(PROJECT)/*.py
	poetry run black .

.PHONY: lint
lint: clean
	poetry run flake8 .

# BUILD ########################################################################

# TEST ########################################################################
.PHONY: test-code
test-code: clean
	poetry run pytest tests/

.PHONY: test-docs
test-docs:
	poetry run scripts/mdpydoctest -o tests/test_docs.py $(PROJECT)/

.PHONY: test
test: test-code test-docs clean

.PHONY: coverage
coverage:
	poetry run pytest --cov-report term --cov-report html --cov=$(PROJECT) --cov-branch tests/
ifeq ($(OS), Linux)
	xdg-open $(COVG_REPORT)
else ifeq ($(OS), Darwin)
	open $(COVG_REPORT)
else
	echo "ERROR: Unknown OS detected - $OS"
endif

# PRECOMMIT ########################################################################
.PHONY: precommit
precommit: fmt lint test

# DOCS ########################################################################
.PHONY: build-docs
build-docs:
	poetry run pdoc --template-dir $(DOCS_TEMPLATE) \
	  --html --force --output-dir $(DOCS_DIR) $(PROJECT) && \
	mv $(DOCS_DIR)/$(PROJECT)/* $(DOCS_DIR)/

.PHONY: docs
docs: build-docs clean

.PHONY: serve-docs
serve-docs:
	poetry run pdoc --template-dir $(DOCS_TEMPLATE) --http : $(PROJECT)

# CLEANUP ######################################################################
.PHONY: clean
clean:
	rm -rf tests/test_docs.py $(DOCS_DIR)/$(PROJECT)/