"""
Payment-specific variables for enterprise payment testing
Contains test data for credit cards, payment amounts, currencies, etc.
"""

# Payment Gateway URLs (use test/sandbox environments)
STRIPE_API_URL = "https://api.stripe.com/v1"
PAYPAL_API_URL = "https://api-m.sandbox.paypal.com"
BRAINTREE_API_URL = "https://api.sandbox.braintreegateway.com"

# Test API Keys (replace with actual test keys)
STRIPE_PUBLIC_KEY = "pk_test_..."
STRIPE_SECRET_KEY = "sk_test_..."
PAYPAL_CLIENT_ID = "test_client_id"
PAYPAL_CLIENT_SECRET = "test_client_secret"

# Supported Currencies
CURRENCIES = {
    "USD": {"symbol": "$", "decimal_places": 2},
    "EUR": {"symbol": "€", "decimal_places": 2},
    "GBP": {"symbol": "£", "decimal_places": 2},
    "JPY": {"symbol": "¥", "decimal_places": 0},
    "CAD": {"symbol": "C$", "decimal_places": 2},
    "AUD": {"symbol": "A$", "decimal_places": 2}
}

# Test Payment Amounts
PAYMENT_AMOUNTS = {
    "small": 1.00,
    "medium": 99.99,
    "large": 999.99,
    "zero": 0.00,
    "negative": -10.00,
    "decimal": 10.505
}

# Credit Card Test Data (use only for testing - never real cards)
TEST_CREDIT_CARDS = {
    "visa": {
        "number": "4111111111111111",
        "type": "visa",
        "cvv": "123",
        "expiry_month": "12",
        "expiry_year": "2026"
    },
    "mastercard": {
        "number": "5555555555554444",
        "type": "mastercard",
        "cvv": "123",
        "expiry_month": "12",
        "expiry_year": "2026"
    },
    "amex": {
        "number": "378282246310005",
        "type": "american_express",
        "cvv": "1234",
        "expiry_month": "12",
        "expiry_year": "2026"
    },
    "discover": {
        "number": "6011111111111117",
        "type": "discover",
        "cvv": "123",
        "expiry_month": "12",
        "expiry_year": "2026"
    },
    "invalid": {
        "number": "4000000000000002",
        "type": "visa",
        "cvv": "123",
        "expiry_month": "12",
        "expiry_year": "2020"  # Expired
    }
}

# Digital Wallet Test Data
DIGITAL_WALLETS = {
    "apple_pay": {
        "type": "apple_pay",
        "token": "test_apple_pay_token",
        "device_data": "test_device_data"
    },
    "google_pay": {
        "type": "google_pay",
        "token": "test_google_pay_token",
        "payment_method_data": "test_payment_method_data"
    },
    "paypal": {
        "type": "paypal",
        "email": "test@example.com",
        "payer_id": "test_payer_id"
    }
}

# Bank Account Test Data (for ACH/direct debit)
TEST_BANK_ACCOUNTS = {
    "checking": {
        "account_number": "123456789",
        "routing_number": "021000021",
        "account_type": "checking"
    },
    "savings": {
        "account_number": "987654321",
        "routing_number": "021000021",
        "account_type": "savings"
    }
}

# Billing Address Test Data
BILLING_ADDRESSES = {
    "us": {
        "street": "123 Test Street",
        "city": "San Francisco",
        "state": "CA",
        "zip": "94105",
        "country": "US"
    },
    "international": {
        "street": "456 Test Avenue",
        "city": "London",
        "state": "England",
        "zip": "SW1A 1AA",
        "country": "GB"
    }
}

# Payment Status Codes
PAYMENT_STATUSES = {
    "success": "succeeded",
    "pending": "pending",
    "failed": "failed",
    "cancelled": "cancelled",
    "refunded": "refunded",
    "disputed": "disputed"
}

# Transaction Types
TRANSACTION_TYPES = {
    "sale": "sale",
    "refund": "refund",
    "void": "void",
    "capture": "capture",
    "authorize": "authorize"
}

# Test Customer Data
TEST_CUSTOMERS = {
    "individual": {
        "name": "John Doe",
        "email": "john.doe@example.com",
        "phone": "+1-555-123-4567"
    },
    "business": {
        "name": "Acme Corporation",
        "email": "billing@acme.com",
        "phone": "+1-555-987-6543",
        "tax_id": "12-3456789"
    }
}

# PCI DSS Test Data (for compliance testing)
PCI_TEST_DATA = {
    "valid_pan": "4111111111111111",
    "invalid_pan": "4111111111111112",
    "luhn_valid": "4532015112830366",
    "luhn_invalid": "4532015112830367"
}

# Fraud Detection Test Scenarios
FRAUD_SCENARIOS = {
    "velocity_check": {
        "amount": 1000.00,
        "time_window": 3600,  # 1 hour
        "max_transactions": 5
    },
    "geolocation_check": {
        "ip_address": "192.168.1.1",
        "expected_country": "US",
        "actual_country": "RU"
    }
}

# Subscription/Payment Plan Test Data
SUBSCRIPTION_PLANS = {
    "monthly": {
        "amount": 29.99,
        "interval": "month",
        "currency": "USD"
    },
    "yearly": {
        "amount": 299.99,
        "interval": "year",
        "currency": "USD"
    }
}
