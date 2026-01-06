# Makefile for Enterprise Payments Testing Framework

.PHONY: install test test-smoke test-api test-web test-payments test-security test-compliance clean help setup lint format

# Variables
PYTHON = .venv/bin/python
ROBOT = .venv/bin/robot
PABOT = .venv/bin/pabot
PIP = .venv/bin/pip
RESULTS_DIR = results
PAYMENT_RESULTS_DIR = results/payments
SECURITY_RESULTS_DIR = results/security
VENV_DIR = .venv
PARALLEL_PROCESSES = 4

# Default target
help:
	@echo "Enterprise Payments Testing Framework Commands:"
	@echo "  setup       - Set up the project with virtual environment"
	@echo "  install     - Install dependencies"
	@echo "  test        - Run all tests"
	@echo "  test-smoke  - Run smoke tests only"
	@echo "  test-payments - Run all payment-related tests"
	@echo "  test-security - Run security and compliance tests"
	@echo "  test-credit-cards - Run credit card processing tests"
	@echo "  test-stripe - Run Stripe gateway integration tests"
	@echo "  test-api    - Run API tests only"
	@echo "  test-web    - Run web UI tests only"
	@echo "  test-parallel - Run all tests in parallel"
	@echo "  lint        - Run linting on robot files"
	@echo "  format      - Format robot files"
	@echo "  clean       - Clean all test results"
	@echo "  clean-payments - Clean payment test results"
	@echo "  install-dev - Install development dependencies"

# Set up project
setup:
	@echo "Setting up Enterprise Payments Testing Framework..."
	python3 -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "Setup complete!"

# Install dependencies
install:
	$(PIP) install -r requirements.txt

# Install development dependencies
install-dev:
	$(PIP) install robotframework-lint robotframework-tidy pytest flake8 black isort

# Run all tests
test:
	mkdir -p $(RESULTS_DIR)
	$(ROBOT) --outputdir $(RESULTS_DIR) tests/

# Run smoke tests
test-smoke:
	mkdir -p $(RESULTS_DIR)
	$(ROBOT) --outputdir $(RESULTS_DIR) --include smoke tests/

# Payment-specific test targets
test-payments:
	mkdir -p $(PAYMENT_RESULTS_DIR)
	$(ROBOT) --outputdir $(PAYMENT_RESULTS_DIR) --include payment tests/

test-credit-cards:
	mkdir -p $(PAYMENT_RESULTS_DIR)
	$(ROBOT) --outputdir $(PAYMENT_RESULTS_DIR) --include credit_card tests/

test-stripe:
	mkdir -p $(PAYMENT_RESULTS_DIR)
	$(ROBOT) --outputdir $(PAYMENT_RESULTS_DIR) --include stripe tests/

test-security:
	mkdir -p $(SECURITY_RESULTS_DIR)
	$(ROBOT) --outputdir $(SECURITY_RESULTS_DIR) --include security tests/

test-compliance:
	mkdir -p $(SECURITY_RESULTS_DIR)
	$(ROBOT) --outputdir $(SECURITY_RESULTS_DIR) --include compliance tests/

# API and Web tests
test-api:
	mkdir -p $(RESULTS_DIR)
	$(ROBOT) --outputdir $(RESULTS_DIR) --include api tests/

test-web:
	mkdir -p $(RESULTS_DIR)
	$(ROBOT) --outputdir $(RESULTS_DIR) --include web tests/

# Parallel execution
test-parallel:
	mkdir -p $(RESULTS_DIR)
	$(PABOT) --processes $(PARALLEL_PROCESSES) --outputdir $(RESULTS_DIR) tests/

test-payments-parallel:
	mkdir -p $(PAYMENT_RESULTS_DIR)
	$(PABOT) --processes $(PARALLEL_PROCESSES) --outputdir $(PAYMENT_RESULTS_DIR) --include payment tests/

# Linting and formatting
lint:
	$(PYTHON) -m robot.tidy --check tests/
	$(PYTHON) -m robot.lint tests/

format:
	$(PYTHON) -m robot.tidy tests/

# Clean targets
clean:
	rm -rf $(RESULTS_DIR)/*

clean-payments:
	rm -rf $(PAYMENT_RESULTS_DIR)

clean-security:
	rm -rf $(SECURITY_RESULTS_DIR)

# Development and validation targets
validate-payments:
	@echo "Validating payment test data..."
	$(PYTHON) -c "\
from variables.payment_variables import TEST_CREDIT_CARDS, CURRENCIES; \
from libraries.PaymentLibrary import PaymentLibrary; \
lib = PaymentLibrary(); \
print('Validating test credit cards...'); \
for card_type, card_data in TEST_CREDIT_CARDS.items(): \
    is_valid = lib.validate_credit_card_number(card_data['number']); \
    print(f'{card_type}: {is_valid}'); \
print('Payment validation complete!') \
"

# Environment setup targets
setup-dev: setup install-dev
	@echo "Development environment setup complete!"

setup-ci:
	@echo "Setting up CI environment..."
	python3 -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	$(PIP) install coverage pytest-cov

# Reporting targets
report-payments:
	@echo "Generating payment test reports..."
	@if [ -d "$(PAYMENT_RESULTS_DIR)" ]; then \
		echo "Payment test results available in $(PAYMENT_RESULTS_DIR)"; \
		if [ -f "$(PAYMENT_RESULTS_DIR)/report.html" ]; then \
			echo "Open $(PAYMENT_RESULTS_DIR)/report.html in your browser"; \
		fi; \
	else \
		echo "No payment test results found. Run 'make test-payments' first."; \
	fi

report-security:
	@echo "Generating security test reports..."
	@if [ -d "$(SECURITY_RESULTS_DIR)" ]; then \
		echo "Security test results available in $(SECURITY_RESULTS_DIR)"; \
		if [ -f "$(SECURITY_RESULTS_DIR)/report.html" ]; then \
			echo "Open $(SECURITY_RESULTS_DIR)/report.html in your browser"; \
		fi; \
	else \
		echo "No security test results found. Run 'make test-security' first."; \
	fi

# Quick test validation
validate-setup:
	@echo "Validating test setup..."
	$(ROBOT) --dryrun --outputdir /tmp tests/credit_card_processing_tests.robot || echo "Setup validation failed"
