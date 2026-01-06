"""
Database Integration Library for Payment Testing
Handles payment records, transaction logging, and data persistence
"""

import sqlite3
import json
from datetime import datetime, timedelta
from typing import List, Dict, Optional
import logging

class DatabaseLibrary:
    """Library for database operations in payment testing."""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        """Initialize database connection."""
        self.connection = None
        self.db_path = ':memory:'  # Default to in-memory database

    def connect_to_database(self, db_path=':memory:', db_type='sqlite'):
        """Connect to the specified database."""
        try:
            if db_type.lower() == 'sqlite':
                self.connection = sqlite3.connect(db_path)
                self.db_path = db_path
                self._initialize_schema()
                logging.info(f"Connected to SQLite database: {db_path}")
            else:
                raise ValueError(f"Unsupported database type: {db_type}")
        except Exception as e:
            logging.error(f"Failed to connect to database: {e}")
            raise

    def disconnect_from_database(self):
        """Close database connection."""
        if self.connection:
            self.connection.close()
            self.connection = None
            logging.info("Database connection closed")

    def _initialize_schema(self):
        """Initialize database schema for payment testing."""
        cursor = self.connection.cursor()

        # Payment transactions table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS payment_transactions (
                id TEXT PRIMARY KEY,
                amount REAL NOT NULL,
                currency TEXT NOT NULL,
                payment_method TEXT NOT NULL,
                gateway TEXT NOT NULL,
                status TEXT NOT NULL,
                customer_id TEXT,
                merchant_id TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                gateway_transaction_id TEXT,
                failure_reason TEXT,
                metadata TEXT
            )
        ''')

        # Payment methods table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS payment_methods (
                id TEXT PRIMARY KEY,
                customer_id TEXT NOT NULL,
                type TEXT NOT NULL,
                gateway_payment_method_id TEXT,
                is_default BOOLEAN DEFAULT FALSE,
                status TEXT NOT NULL,
                expiry_month INTEGER,
                expiry_year INTEGER,
                last_four TEXT,
                card_brand TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        # Customers table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS customers (
                id TEXT PRIMARY KEY,
                email TEXT UNIQUE,
                first_name TEXT,
                last_name TEXT,
                phone TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        # Refunds table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS refunds (
                id TEXT PRIMARY KEY,
                original_transaction_id TEXT NOT NULL,
                amount REAL NOT NULL,
                currency TEXT NOT NULL,
                reason TEXT,
                status TEXT NOT NULL,
                gateway_refund_id TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                processed_at TIMESTAMP,
                FOREIGN KEY (original_transaction_id) REFERENCES payment_transactions(id)
            )
        ''')

        # Fraud alerts table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS fraud_alerts (
                id TEXT PRIMARY KEY,
                transaction_id TEXT,
                alert_type TEXT NOT NULL,
                severity TEXT NOT NULL,
                risk_score INTEGER,
                triggered_rules TEXT,
                ip_address TEXT,
                user_agent TEXT,
                resolved BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (transaction_id) REFERENCES payment_transactions(id)
            )
        ''')

        # Test execution logs table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS test_execution_logs (
                id TEXT PRIMARY KEY,
                test_suite TEXT NOT NULL,
                test_case TEXT NOT NULL,
                status TEXT NOT NULL,
                execution_time REAL,
                environment TEXT,
                error_message TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        self.connection.commit()
        logging.info("Database schema initialized")

    def insert_payment_transaction(self, transaction_data: Dict) -> str:
        """Insert a payment transaction record."""
        cursor = self.connection.cursor()

        transaction_id = transaction_data.get('id', f"txn_{datetime.now().strftime('%Y%m%d_%H%M%S')}")

        cursor.execute('''
            INSERT INTO payment_transactions
            (id, amount, currency, payment_method, gateway, status, customer_id,
             merchant_id, gateway_transaction_id, failure_reason, metadata)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            transaction_id,
            transaction_data['amount'],
            transaction_data['currency'],
            transaction_data['payment_method'],
            transaction_data.get('gateway', 'unknown'),
            transaction_data['status'],
            transaction_data.get('customer_id'),
            transaction_data.get('merchant_id', 'default'),
            transaction_data.get('gateway_transaction_id'),
            transaction_data.get('failure_reason'),
            json.dumps(transaction_data.get('metadata', {}))
        ))

        self.connection.commit()
        logging.info(f"Payment transaction inserted: {transaction_id}")
        return transaction_id

    def get_payment_transaction(self, transaction_id: str) -> Optional[Dict]:
        """Retrieve a payment transaction by ID."""
        cursor = self.connection.cursor()
        cursor.execute('SELECT * FROM payment_transactions WHERE id = ?', (transaction_id,))

        row = cursor.fetchone()
        if row:
            columns = [desc[0] for desc in cursor.description]
            transaction = dict(zip(columns, row))
            transaction['metadata'] = json.loads(transaction['metadata'] or '{}')
            return transaction
        return None

    def update_payment_status(self, transaction_id: str, status: str, failure_reason: str = None):
        """Update payment transaction status."""
        cursor = self.connection.cursor()

        cursor.execute('''
            UPDATE payment_transactions
            SET status = ?, failure_reason = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ''', (status, failure_reason, transaction_id))

        self.connection.commit()
        logging.info(f"Payment status updated: {transaction_id} -> {status}")

    def insert_payment_method(self, method_data: Dict) -> str:
        """Insert a payment method record."""
        cursor = self.connection.cursor()

        method_id = method_data.get('id', f"pm_{datetime.now().strftime('%Y%m%d_%H%M%S')}")

        cursor.execute('''
            INSERT INTO payment_methods
            (id, customer_id, type, gateway_payment_method_id, status,
             expiry_month, expiry_year, last_four, card_brand)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            method_id,
            method_data['customer_id'],
            method_data['type'],
            method_data.get('gateway_payment_method_id'),
            method_data.get('status', 'active'),
            method_data.get('expiry_month'),
            method_data.get('expiry_year'),
            method_data.get('last_four'),
            method_data.get('card_brand')
        ))

        self.connection.commit()
        logging.info(f"Payment method inserted: {method_id}")
        return method_id

    def get_customer_payment_methods(self, customer_id: str) -> List[Dict]:
        """Get all payment methods for a customer."""
        cursor = self.connection.cursor()
        cursor.execute('SELECT * FROM payment_methods WHERE customer_id = ? ORDER BY created_at DESC',
                      (customer_id,))

        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        return [dict(zip(columns, row)) for row in rows]

    def insert_customer(self, customer_data: Dict) -> str:
        """Insert a customer record."""
        cursor = self.connection.cursor()

        customer_id = customer_data.get('id', f"cus_{datetime.now().strftime('%Y%m%d_%H%M%S')}")

        cursor.execute('''
            INSERT INTO customers (id, email, first_name, last_name, phone)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            customer_id,
            customer_data.get('email'),
            customer_data.get('first_name'),
            customer_data.get('last_name'),
            customer_data.get('phone')
        ))

        self.connection.commit()
        logging.info(f"Customer inserted: {customer_id}")
        return customer_id

    def insert_refund(self, refund_data: Dict) -> str:
        """Insert a refund record."""
        cursor = self.connection.cursor()

        refund_id = refund_data.get('id', f"ref_{datetime.now().strftime('%Y%m%d_%H%M%S')}")

        cursor.execute('''
            INSERT INTO refunds
            (id, original_transaction_id, amount, currency, reason, status, gateway_refund_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            refund_id,
            refund_data['original_transaction_id'],
            refund_data['amount'],
            refund_data['currency'],
            refund_data.get('reason'),
            refund_data.get('status', 'pending'),
            refund_data.get('gateway_refund_id')
        ))

        self.connection.commit()
        logging.info(f"Refund inserted: {refund_id}")
        return refund_id

    def insert_fraud_alert(self, alert_data: Dict) -> str:
        """Insert a fraud alert record."""
        cursor = self.connection.cursor()

        alert_id = alert_data.get('id', f"fraud_{datetime.now().strftime('%Y%m%d_%H%M%S')}")

        cursor.execute('''
            INSERT INTO fraud_alerts
            (id, transaction_id, alert_type, severity, risk_score, triggered_rules, ip_address, user_agent)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            alert_id,
            alert_data.get('transaction_id'),
            alert_data['alert_type'],
            alert_data['severity'],
            alert_data.get('risk_score'),
            json.dumps(alert_data.get('triggered_rules', [])),
            alert_data.get('ip_address'),
            alert_data.get('user_agent')
        ))

        self.connection.commit()
        logging.info(f"Fraud alert inserted: {alert_id}")
        return alert_id

    def log_test_execution(self, test_suite: str, test_case: str, status: str,
                          execution_time: float = None, error_message: str = None):
        """Log test execution results."""
        cursor = self.connection.cursor()

        log_id = f"log_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        cursor.execute('''
            INSERT INTO test_execution_logs
            (id, test_suite, test_case, status, execution_time, environment, error_message)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            log_id,
            test_suite,
            test_case,
            status,
            execution_time,
            'ci',  # Could be parameterized
            error_message
        ))

        self.connection.commit()
        logging.info(f"Test execution logged: {test_suite}.{test_case} - {status}")

    def get_transaction_count_by_status(self, status: str = None, hours: int = 24) -> int:
        """Get transaction count by status within time window."""
        cursor = self.connection.cursor()

        time_threshold = datetime.now() - timedelta(hours=hours)

        if status:
            cursor.execute('''
                SELECT COUNT(*) FROM payment_transactions
                WHERE status = ? AND created_at >= ?
            ''', (status, time_threshold))
        else:
            cursor.execute('''
                SELECT COUNT(*) FROM payment_transactions
                WHERE created_at >= ?
            ''', (time_threshold,))

        return cursor.fetchone()[0]

    def get_fraud_alert_count(self, severity: str = None, hours: int = 24) -> int:
        """Get fraud alert count by severity within time window."""
        cursor = self.connection.cursor()

        time_threshold = datetime.now() - timedelta(hours=hours)

        if severity:
            cursor.execute('''
                SELECT COUNT(*) FROM fraud_alerts
                WHERE severity = ? AND created_at >= ?
            ''', (severity, time_threshold))
        else:
            cursor.execute('''
                SELECT COUNT(*) FROM fraud_alerts
                WHERE created_at >= ?
            ''', (time_threshold,))

        return cursor.fetchone()[0]

    def get_test_success_rate(self, test_suite: str = None, hours: int = 24) -> float:
        """Get test success rate for given time window."""
        cursor = self.connection.cursor()

        time_threshold = datetime.now() - timedelta(hours=hours)

        if test_suite:
            cursor.execute('''
                SELECT
                    COUNT(CASE WHEN status = 'PASS' THEN 1 END) as passed,
                    COUNT(*) as total
                FROM test_execution_logs
                WHERE test_suite = ? AND created_at >= ?
            ''', (test_suite, time_threshold))
        else:
            cursor.execute('''
                SELECT
                    COUNT(CASE WHEN status = 'PASS' THEN 1 END) as passed,
                    COUNT(*) as total
                FROM test_execution_logs
                WHERE created_at >= ?
            ''', (time_threshold,))

        row = cursor.fetchone()
        passed, total = row
        return (passed / total * 100) if total > 0 else 0.0

    def cleanup_old_data(self, days_to_keep: int = 90):
        """Clean up old test data and logs."""
        cursor = self.connection.cursor()

        cutoff_date = datetime.now() - timedelta(days=days_to_keep)

        # Clean up old test execution logs
        cursor.execute('DELETE FROM test_execution_logs WHERE created_at < ?', (cutoff_date,))

        # Clean up old fraud alerts (keep longer for compliance)
        fraud_cutoff = datetime.now() - timedelta(days=365)
        cursor.execute('DELETE FROM fraud_alerts WHERE created_at < ?', (fraud_cutoff,))

        deleted_count = cursor.rowcount
        self.connection.commit()

        logging.info(f"Cleaned up {deleted_count} old records")
        return deleted_count

    def get_payment_method_stats(self) -> Dict:
        """Get payment method usage statistics."""
        cursor = self.connection.cursor()

        cursor.execute('''
            SELECT type, COUNT(*) as count
            FROM payment_methods
            WHERE status = 'active'
            GROUP BY type
            ORDER BY count DESC
        ''')

        stats = {}
        for row in cursor.fetchall():
            stats[row[0]] = row[1]

        return stats

    def get_transaction_volume_by_currency(self, hours: int = 24) -> Dict:
        """Get transaction volume by currency."""
        cursor = self.connection.cursor()

        time_threshold = datetime.now() - timedelta(hours=hours)

        cursor.execute('''
            SELECT currency, COUNT(*) as count, SUM(amount) as total_amount
            FROM payment_transactions
            WHERE created_at >= ?
            GROUP BY currency
            ORDER BY total_amount DESC
        ''', (time_threshold,))

        volume = {}
        for row in cursor.fetchall():
            currency, count, total = row
            volume[currency] = {
                'transaction_count': count,
                'total_amount': total
            }

        return volume
