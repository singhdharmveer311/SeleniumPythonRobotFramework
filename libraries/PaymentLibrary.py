"""
Payment Processing Library for Robot Framework
Contains utilities for credit card validation, payment processing, encryption, and compliance
"""

import re
import hashlib
import hmac
import json
import random
import string
from datetime import datetime, timedelta
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64


class PaymentLibrary:
    """Library for payment processing operations and validations."""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        """Initialize the payment library."""
        self.encryption_key = None
        self.test_mode = True

    def set_encryption_key(self, key=None):
        """Set encryption key for sensitive data handling."""
        if key:
            self.encryption_key = key.encode()
        else:
            # Generate a test key
            self.encryption_key = Fernet.generate_key()

    def validate_credit_card_number(self, card_number):
        """Validate credit card number using Luhn algorithm."""
        card_number = str(card_number).replace(' ', '').replace('-', '')

        if not card_number.isdigit():
            return False

        # Luhn algorithm implementation
        def luhn_checksum(card_num):
            def digits_of(n):
                return [int(d) for d in str(n)]
            digits = digits_of(card_num)
            odd_digits = digits[-1::-2]
            even_digits = digits[-2::-2]
            checksum = sum(odd_digits)
            for d in even_digits:
                checksum += sum(digits_of(d*2))
            return checksum % 10

        return luhn_checksum(card_number) == 0

    def get_credit_card_type(self, card_number):
        """Determine credit card type from card number."""
        card_number = str(card_number).replace(' ', '').replace('-', '')

        # Card type patterns
        patterns = {
            'visa': r'^4[0-9]{12}(?:[0-9]{3})?$',
            'mastercard': r'^5[1-5][0-9]{14}$',
            'amex': r'^3[47][0-9]{13}$',
            'discover': r'^6(?:011|5[0-9]{2})[0-9]{12}$',
            'diners': r'^3[0689][0-9]{11}$',
            'jcb': r'^(?:2131|1800|35\d{3})\d{11}$'
        }

        for card_type, pattern in patterns.items():
            if re.match(pattern, card_number):
                return card_type

        return 'unknown'

    def validate_expiry_date(self, month, year):
        """Validate credit card expiry date."""
        try:
            exp_month = int(month)
            exp_year = int(year)

            if exp_month < 1 or exp_month > 12:
                return False

            current_date = datetime.now()
            expiry_date = datetime(exp_year, exp_month, 1)

            # Add one month to get the last day of the expiry month
            if expiry_date.month == 12:
                expiry_date = expiry_date.replace(year=expiry_date.year + 1, month=1)
            else:
                expiry_date = expiry_date.replace(month=expiry_date.month + 1)

            return expiry_date > current_date

        except (ValueError, TypeError):
            return False

    def validate_cvv(self, cvv, card_type):
        """Validate CVV based on card type."""
        cvv = str(cvv).strip()

        if not cvv.isdigit():
            return False

        if card_type.lower() == 'amex':
            return len(cvv) == 4
        else:
            return len(cvv) == 3

    def generate_test_credit_card(self, card_type='visa'):
        """Generate a valid test credit card number."""
        prefixes = {
            'visa': ['4532015112830366'],  # Valid Visa test number
            'mastercard': ['5555555555554444'],  # Valid Mastercard test number
            'amex': ['378282246310005'],  # Valid Amex test number
            'discover': ['6011111111111117']  # Valid Discover test number
        }

        if card_type.lower() in prefixes:
            return random.choice(prefixes[card_type.lower()])
        else:
            return '4111111111111111'  # Default Visa test number

    def tokenize_payment_data(self, payment_data):
        """Tokenize sensitive payment data."""
        if not self.encryption_key:
            self.set_encryption_key()

        f = Fernet(self.encryption_key)
        data_str = json.dumps(payment_data)
        token = f.encrypt(data_str.encode())
        return token.decode()

    def detokenize_payment_data(self, token):
        """Detokenize payment data."""
        if not self.encryption_key:
            raise ValueError("Encryption key not set")

        f = Fernet(self.encryption_key)
        decrypted = f.decrypt(token.encode())
        return json.loads(decrypted.decode())

    def hash_payment_data(self, data, salt=None):
        """Create SHA-256 hash of payment data for secure storage."""
        if salt is None:
            salt = ''.join(random.choices(string.ascii_letters + string.digits, k=16))

        data_str = str(data) + salt
        hash_obj = hashlib.sha256(data_str.encode())
        return hash_obj.hexdigest() + ':' + salt

    def verify_payment_hash(self, data, hashed_data):
        """Verify payment data against its hash."""
        if ':' not in hashed_data:
            return False

        hash_value, salt = hashed_data.split(':', 1)
        data_str = str(data) + salt
        computed_hash = hashlib.sha256(data_str.encode()).hexdigest()

        return hmac.compare_digest(computed_hash, hash_value)

    def generate_payment_reference(self, prefix='PAY', length=12):
        """Generate a unique payment reference number."""
        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        random_part = ''.join(random.choices(string.ascii_uppercase + string.digits, k=length-14))
        return f"{prefix}{timestamp}{random_part}"

    def calculate_payment_fee(self, amount, fee_percentage=2.9, fixed_fee=0.30):
        """Calculate payment processing fee."""
        try:
            amount = float(amount)
            percentage_fee = amount * (fee_percentage / 100)
            total_fee = percentage_fee + fixed_fee
            return round(total_fee, 2)
        except (ValueError, TypeError):
            raise ValueError("Invalid amount provided")

    def validate_payment_amount(self, amount, min_amount=0.01, max_amount=10000.00):
        """Validate payment amount within acceptable ranges."""
        try:
            amount = float(amount)
            return min_amount <= amount <= max_amount
        except (ValueError, TypeError):
            return False

    def format_currency_amount(self, amount, currency='USD'):
        """Format amount according to currency standards."""
        try:
            amount = float(amount)
            currency_formats = {
                'USD': '${:,.2f}',
                'EUR': '€{:,.2f}',
                'GBP': '£{:,.2f}',
                'JPY': '¥{:,.0f}',
                'CAD': 'C${:,.2f}',
                'AUD': 'A${:,.2f}'
            }

            if currency in currency_formats:
                return currency_formats[currency].format(amount)
            else:
                return f"{currency} {amount:,.2f}"

        except (ValueError, TypeError):
            return str(amount)

    def validate_billing_address(self, address_data):
        """Validate billing address data."""
        required_fields = ['street', 'city', 'state', 'zip', 'country']

        if not isinstance(address_data, dict):
            return False

        for field in required_fields:
            if field not in address_data or not address_data[field].strip():
                return False

        # Basic ZIP code validation for US
        if address_data.get('country', '').upper() == 'US':
            zip_pattern = r'^\d{5}(-\d{4})?$'
            if not re.match(zip_pattern, address_data.get('zip', '')):
                return False

        return True

    def check_fraud_indicators(self, transaction_data):
        """Check for basic fraud indicators in transaction data."""
        indicators = []

        # Check for unusual amounts
        amount = transaction_data.get('amount', 0)
        if amount > 10000:
            indicators.append('high_amount')

        # Check for international transactions
        billing_country = transaction_data.get('billing_country', '')
        ip_country = transaction_data.get('ip_country', '')
        if billing_country and ip_country and billing_country != ip_country:
            indicators.append('country_mismatch')

        # Check for rapid successive transactions
        transaction_count = transaction_data.get('recent_transaction_count', 0)
        if transaction_count > 5:
            indicators.append('velocity_check')

        return indicators

    def generate_payment_receipt(self, transaction_id, amount, currency='USD', customer_email=None):
        """Generate a payment receipt data structure."""
        receipt = {
            'transaction_id': transaction_id,
            'amount': float(amount),
            'currency': currency,
            'timestamp': datetime.now().isoformat(),
            'status': 'completed'
        }

        if customer_email:
            receipt['customer_email'] = customer_email

        return receipt

    def validate_subscription_payment(self, subscription_data):
        """Validate subscription payment data."""
        required_fields = ['amount', 'interval', 'currency', 'customer_id']

        if not isinstance(subscription_data, dict):
            return False

        for field in required_fields:
            if field not in subscription_data:
                return False

        # Validate interval
        valid_intervals = ['day', 'week', 'month', 'year']
        if subscription_data.get('interval') not in valid_intervals:
            return False

        # Validate amount
        if not self.validate_payment_amount(subscription_data.get('amount')):
            return False

        return True

    def simulate_payment_gateway_response(self, success_rate=0.95):
        """Simulate payment gateway response for testing."""
        import random

        success = random.random() < success_rate

        if success:
            return {
                'status': 'success',
                'transaction_id': self.generate_payment_reference(),
                'authorization_code': ''.join(random.choices(string.digits, k=6)),
                'timestamp': datetime.now().isoformat()
            }
        else:
            error_messages = [
                'Insufficient funds',
                'Card declined',
                'Invalid card number',
                'Expired card',
                'Transaction blocked'
            ]

            return {
                'status': 'failed',
                'error_message': random.choice(error_messages),
                'error_code': 'CARD_DECLINED',
                'timestamp': datetime.now().isoformat()
            }
