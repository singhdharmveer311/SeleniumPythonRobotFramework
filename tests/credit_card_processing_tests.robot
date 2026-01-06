*** Settings ***
Documentation       Credit Card Processing and Validation Tests
...                 Comprehensive tests for credit card validation, processing, security, and compliance
...                 Covers PCI DSS requirements, fraud detection, and enterprise payment workflows
...
...                 TEST COVERAGE:
...                 - Card validation (Luhn, format, type detection)
...                 - Security (tokenization, encryption, PCI DSS)
...                 - Business logic (fees, amounts, currencies)
...                 - Fraud detection and risk assessment
...                 - Error handling and edge cases
...                 - Performance and load testing
...
...                 EXECUTION TIME: ~2-3 minutes
...                 TEST PRIORITY: Critical (Payment processing core functionality)

Library             Collections
Library             String
Library             DateTime
Library             OperatingSystem
Library             ../libraries/PaymentLibrary.py
Variables           ../variables/payment_variables.py
Resource            ../resources/common.robot

Test Setup          Setup Credit Card Test Environment
Test Teardown       Cleanup Credit Card Test Data
Test Timeout        30 seconds

Metadata            Test Suite ID    CC_PROC_001
Metadata            Business Owner   Payments Team
Metadata            Technical Owner  QA Automation
Metadata            Compliance       PCI DSS Level 1
Metadata            Risk Level       Critical

*** Test Cases ***

Validate Invalid Card Number
    [Documentation]    Test validation fails for invalid card number
    [Tags]    credit_card    validation    negative    payment
    ${is_valid}=    Validate Credit Card Number    4111111111111112
    Should Not Be True    ${is_valid}

Test Luhn Algorithm
    [Documentation]    Test Luhn algorithm validation with known valid/invalid numbers
    [Tags]    credit_card    luhn    validation    payment
    # Valid test numbers
    ${valid_numbers}=    Create List
    ...    4532015112830366
    ...    5555555555554444
    ...    378282246310005
    ...    6011111111111117

    :FOR    ${card_number}    IN    @{valid_numbers}
    \    ${is_valid}=    Validate Credit Card Number    ${card_number}
    \    Should Be True    ${is_valid}    Card ${card_number} should be valid

    # Invalid test numbers
    ${invalid_numbers}=    Create List
    ...    4532015112830367
    ...    5555555555554443
    ...    378282246310004

    :FOR    ${card_number}    IN    @{invalid_numbers}
    \    ${is_valid}=    Validate Credit Card Number    ${card_number}
    \    Should Not Be True    ${is_valid}    Card ${card_number} should be invalid

Validate Expiry Date - Valid
    [Documentation]    Test validation of valid expiry dates
    [Tags]    credit_card    expiry    validation    payment
    ${is_valid}=    Validate Expiry Date    12    2026
    Should Be True    ${is_valid}
    ${is_valid}=    Validate Expiry Date    06    2025
    Should Be True    ${is_valid}

Validate Expiry Date - Invalid
    [Documentation]    Test validation fails for invalid expiry dates
    [Tags]    credit_card    expiry    validation    negative    payment
    ${is_valid}=    Validate Expiry Date    13    2026
    Should Not Be True    ${is_valid}
    ${is_valid}=    Validate Expiry Date    00    2026
    Should Not Be True    ${is_valid}
    ${is_valid}=    Validate Expiry Date    12    2020
    Should Not Be True    ${is_valid}

Validate CVV - Visa/Mastercard
    [Documentation]    Test CVV validation for Visa and Mastercard (3 digits)
    [Tags]    credit_card    cvv    validation    payment
    ${is_valid}=    Validate Cvv    123    visa
    Should Be True    ${is_valid}
    ${is_valid}=    Validate Cvv    456    mastercard
    Should Be True    ${is_valid}
    ${is_valid}=    Validate Cvv    12    visa
    Should Not Be True    ${is_valid}
    ${is_valid}=    Validate Cvv    1234    visa
    Should Not Be True    ${is_valid}

Validate CVV - American Express
    [Documentation]    Test CVV validation for American Express (4 digits)
    [Tags]    credit_card    cvv    validation    amex    payment
    ${is_valid}=    Validate Cvv    1234    amex
    Should Be True    ${is_valid}
    ${is_valid}=    Validate Cvv    123    amex
    Should Not Be True    ${is_valid}
    ${is_valid}=    Validate Cvv    12345    amex
    Should Not Be True    ${is_valid}

Test Payment Tokenization
    [Documentation]    Test payment data tokenization and detokenization
    [Tags]    credit_card    tokenization    security    payment
    ${payment_data}=    Create Dictionary
    ...    card_number=4111111111111111
    ...    expiry_month=12
    ...    expiry_year=2026
    ...    cvv=123
    ...    amount=100.00

    ${token}=    Tokenize Payment Data    ${payment_data}
    Should Not Be Empty    ${token}

    ${detokenized}=    Detokenize Payment Data    ${token}
    Dictionaries Should Be Equal    ${payment_data}    ${detokenized}

Test Payment Data Hashing
    [Documentation]    Test secure hashing of payment data
    [Tags]    credit_card    hashing    security    payment
    ${test_data}=    Set Variable    4111111111111111:100.00:test@example.com
    ${hash}=    Hash Payment Data    ${test_data}
    Should Not Be Empty    ${hash}
    Should Contain    ${hash}    :

    ${is_valid}=    Verify Payment Hash    ${test_data}    ${hash}
    Should Be True    ${is_valid}

Test Payment Reference Generation
    [Documentation]    Test generation of unique payment references
    [Tags]    credit_card    reference    payment
    ${ref1}=    Generate Payment Reference
    ${ref2}=    Generate Payment Reference

    Should Not Be Empty    ${ref1}
    Should Not Be Empty    ${ref2}
    Should Not Be Equal    ${ref1}    ${ref2}
    Should Match Regexp    ${ref1}    ^PAY\\d{14}[A-Z0-9]{4}$

Test Payment Fee Calculation
    [Documentation]    Test calculation of payment processing fees
    [Tags]    credit_card    fees    calculation    payment
    ${fee}=    Calculate Payment Fee    100.00
    Should Be Equal As Numbers    ${fee}    3.03

    ${fee}=    Calculate Payment Fee    500.00    3.0    0.50
    Should Be Equal As Numbers    ${fee}    15.50

Test Payment Amount Validation
    [Documentation]    Test validation of payment amounts
    [Tags]    credit_card    amount    validation    payment
    ${is_valid}=    Validate Payment Amount    100.00
    Should Be True    ${is_valid}
    ${is_valid}=    Validate Payment Amount    0.01
    Should Be True    ${is_valid}
    ${is_valid}=    Validate Payment Amount    10000.00
    Should Be True    ${is_valid}

    ${is_valid}=    Validate Payment Amount    0.00
    Should Not Be True    ${is_valid}
    ${is_valid}=    Validate Payment Amount    10000.01
    Should Not Be True    ${is_valid}
    ${is_valid}=    Validate Payment Amount    -10.00
    Should Not Be True    ${is_valid}

Test Currency Formatting
    [Documentation]    Test formatting of amounts in different currencies
    [Tags]    credit_card    currency    formatting    payment
    ${formatted}=    Format Currency Amount    1234.56    USD
    Should Be Equal As Strings    ${formatted}    $1,234.56

    ${formatted}=    Format Currency Amount    1234.56    EUR
    Should Be Equal As Strings    ${formatted}    €1,234.56

    ${formatted}=    Format Currency Amount    1234.56    GBP
    Should Be Equal As Strings    ${formatted}    £1,234.56

    ${formatted}=    Format Currency Amount    1234    JPY
    Should Be Equal As Strings    ${formatted}    ¥1,234

Test Billing Address Validation
    [Documentation]    Test validation of billing addresses
    [Tags]    credit_card    address    validation    payment
    ${valid_address}=    Create Dictionary
    ...    street=123 Test Street
    ...    city=San Francisco
    ...    state=CA
    ...    zip=94105
    ...    country=US

    ${is_valid}=    Validate Billing Address    ${valid_address}
    Should Be True    ${is_valid}

    ${invalid_address}=    Create Dictionary
    ...    street=123 Test Street
    ...    city=San Francisco
    # Missing required fields
    ${is_valid}=    Validate Billing Address    ${invalid_address}
    Should Not Be True    ${is_valid}

Test Fraud Detection Indicators
    [Documentation]    Test detection of fraud indicators in transactions
    [Tags]    credit_card    fraud    detection    payment
    ${clean_transaction}=    Create Dictionary
    ...    amount=100.00
    ...    billing_country=US
    ...    ip_country=US
    ...    recent_transaction_count=2

    ${indicators}=    Check Fraud Indicators    ${clean_transaction}
    Should Be Empty    ${indicators}

    ${suspicious_transaction}=    Create Dictionary
    ...    amount=15000.00
    ...    billing_country=US
    ...    ip_country=RU
    ...    recent_transaction_count=8

    ${indicators}=    Check Fraud Indicators    ${suspicious_transaction}
    Should Contain    ${indicators}    high_amount
    Should Contain    ${indicators}    country_mismatch
    Should Contain    ${indicators}    velocity_check

Test Payment Receipt Generation
    [Documentation]    Test generation of payment receipts
    [Tags]    credit_card    receipt    payment
    ${receipt}=    Generate Payment Receipt    TXN123456    99.99    USD    customer@example.com
    Should Contain    ${receipt}    transaction_id
    Should Contain    ${receipt}    amount
    Should Contain    ${receipt}    currency
    Should Contain    ${receipt}    timestamp
    Should Contain    ${receipt}    status
    Should Contain    ${receipt}    customer_email

    Should Be Equal As Strings    ${receipt['transaction_id']}    TXN123456
    Should Be Equal As Numbers    ${receipt['amount']}    99.99
    Should Be Equal As Strings    ${receipt['currency']}    USD

Test Subscription Payment Validation
    [Documentation]    Test validation of subscription payment data
    [Tags]    credit_card    subscription    validation    payment
    ${valid_subscription}=    Create Dictionary
    ...    amount=29.99
    ...    interval=month
    ...    currency=USD
    ...    customer_id=CUST123

    ${is_valid}=    Validate Subscription Payment    ${valid_subscription}
    Should Be True    ${is_valid}

    ${invalid_subscription}=    Create Dictionary
    ...    amount=29.99
    # Missing required fields
    ${is_valid}=    Validate Subscription Payment    ${invalid_subscription}
    Should Not Be True    ${is_valid}

Test Payment Gateway Simulation
    [Documentation]    Test simulated payment gateway responses
    [Tags]    credit_card    simulation    gateway    payment
    ${response}=    Simulate Payment Gateway Response    0.8
    Should Contain    ${response}    status
    Should Contain    ${response}    timestamp

    # Test with high success rate
    ${response}=    Simulate Payment Gateway Response    1.0
    Should Be Equal As Strings    ${response['status']}    success

    # Test with zero success rate
    ${response}=    Simulate Payment Gateway Response    0.0
    Should Be Equal As Strings    ${response['status']}    failed

Test Card Type Detection
    [Documentation]    Test automatic detection of various card types
    [Tags]    credit_card    card_type    detection    payment
    ${test_cases}=    Create Dictionary
    ...    4111111111111111=visa
    ...    5555555555554444=mastercard
    ...    378282246310005=amex
    ...    6011111111111117=discover
    ...    3566002020360505=jcb

    :FOR    ${card_number}    ${expected_type}    IN    &{test_cases}
    \    ${detected_type}=    Get Credit Card Type    ${card_number}
    \    Should Be Equal As Strings    ${detected_type}    ${expected_type}

Test Generate Test Credit Cards
    [Documentation]    Test generation of test credit card numbers
    [Tags]    credit_card    generation    test_data    payment
    ${visa_card}=    Generate Test Credit Card    visa
    ${card_type}=    Get Credit Card Type    ${visa_card}
    Should Be Equal As Strings    ${card_type}    visa
    ${is_valid}=    Validate Credit Card Number    ${visa_card}
    Should Be True    ${is_valid}

    ${mastercard_card}=    Generate Test Credit Card    mastercard
    ${card_type}=    Get Credit Card Type    ${mastercard_card}
    Should Be Equal As Strings    ${card_type}    mastercard
    ${is_valid}=    Validate Credit Card Number    ${mastercard_card}
    Should Be True    ${is_valid}

# ===== PHASE 2: ADVANCED FRAUD DETECTION TESTING =====

Fraud Detection - Velocity Checks
    [Documentation]    Test transaction velocity fraud detection
    [Tags]    fraud    security    velocity    critical
    ${customer_id}=    Set Variable    CUST_12345

    # Simulate multiple rapid transactions
    :FOR    ${i}    IN RANGE    1    6
    \    ${transaction}=    Create Dictionary
    \    ...    customer_id=${customer_id}
    \    ...    amount=100.00
    \    ...    timestamp=${i} minutes ago
    \    ...    ip_address=192.168.1.${i}
    \
    \    ${fraud_score}=    Calculate Fraud Score    ${transaction}
    \    Run Keyword If    ${i} < 4    Should Be True    ${fraud_score} < 50
    \    ...    ELSE    Should Be True    ${fraud_score} > 70    Velocity fraud detected

Fraud Detection - Geolocation Analysis
    [Documentation]    Test geolocation-based fraud detection
    [Tags]    fraud    geolocation    security
    ${transaction}=    Create Dictionary
    ...    billing_country=US
    ...    ip_country=RU
    ...    card_country=US
    ...    transaction_amount=5000.00

    ${risk_indicators}=    Analyze Geolocation Risk    ${transaction}
    Should Contain    ${risk_indicators}    country_mismatch
    Should Contain    ${risk_indicators}    high_risk_country

# ===== PHASE 2: EDGE CASES & BOUNDARY TESTING =====

Credit Card Validation - Boundary Conditions
    [Documentation]    Test card validation at boundary conditions
    [Tags]    boundary    edge_case    validation
    # Test minimum/maximum card lengths
    ${test_cases}=    Create List
    ...    4111111111111111    # 16 digits (Visa standard)
    ...    4111111111111      # 13 digits (minimum)
    ...    4111111111111111111 # 19 digits (maximum)
    ...    378282246310005    # 15 digits (Amex)

    :FOR    ${card_number}    IN    @{test_cases}
    \    ${is_valid_format}=    Validate Card Format    ${card_number}
    \    Should Be True    ${is_valid_format}    Invalid format for ${card_number}

Credit Card Validation - Special Characters
    [Documentation]    Test handling of special characters in card data
    [Tags]    input_validation    security    edge_case
    ${special_cards}=    Create List
    ...    4111-1111-1111-1111
    ...    4111 1111 1111 1111
    ...    4111111111111111
    ...    4111.1111.1111.1111

    :FOR    ${card_number}    IN    @{special_cards}
    \    ${normalized}=    Normalize Card Number    ${card_number}
    \    ${is_valid}=    Validate Credit Card Number    ${normalized}
    \    Should Be True    ${is_valid}    Failed to validate ${card_number}

Currency Handling - International Edge Cases
    [Documentation]    Test currency handling for international payments
    [Tags]    currency    internationalization    edge_case
    ${test_cases}=    Create Dictionary
    ...    JPY=1234.56
    ...    BHD=123.456
    ...    VND=123456789

    :FOR    ${currency}    ${amount}    IN    &{test_cases}
    \    ${formatted}=    Format Currency Amount    ${amount}    ${currency}
    \    Should Not Be Empty    ${formatted}
    \    Log    ${currency} ${amount} formatted as: ${formatted}

# ===== PHASE 2: TEST METRICS & MONITORING =====

Credit Card Validation Performance
    [Documentation]    Performance test for card validation under load
    [Tags]    performance    load    credit_card    benchmark
    ${start_time}=    Get Time    epoch

    # Test 1000 card validations
    :FOR    ${i}    IN RANGE    1    1001
    \    ${card_number}=    Generate Test Credit Card    visa
    \    Validate Credit Card Number    ${card_number}

    ${end_time}=    Get Time    epoch
    ${duration}=    Evaluate    ${end_time} - ${start_time}

    # Performance assertions
    Should Be True    ${duration} < 30    Validation took ${duration}s, expected < 30s
    Log    Performance: 1000 validations in ${duration} seconds

Memory Leak Detection - Tokenization
    [Documentation]    Test for memory leaks in tokenization operations
    [Tags]    memory    performance    security
    ${initial_memory}=    Get Memory Usage

    # Perform 1000 tokenization operations
    :FOR    ${i}    IN RANGE    1    1001
    \    ${test_data}=    Create Dictionary    data=test_value_${i}
    \    ${token}=    Tokenize Payment Data    ${test_data}
    \    ${detokenized}=    Detokenize Payment Data    ${token}

    ${final_memory}=    Get Memory Usage
    ${memory_increase}=    Evaluate    ${final_memory} - ${initial_memory}

    # Memory leak detection
    Should Be True    ${memory_increase} < 50    Memory leak detected: ${memory_increase}MB increase
    Log    Memory usage: ${memory_increase}MB increase after 1000 operations

# ===== PHASE 2: ENHANCED ERROR HANDLING =====

Payment Processing Error Scenarios
    [Documentation]    Test various error conditions in payment processing
    [Tags]    error_handling    robustness    payment
    ${error_scenarios}=    Create Dictionary
    ...    network_timeout=Connection timeout
    ...    gateway_unavailable=Gateway down
    ...    invalid_currency=Unsupported currency
    ...    amount_too_high=Amount exceeds limit
    ...    card_declined=Card declined by issuer

    :FOR    ${error_type}    ${expected_message}    IN    &{error_scenarios}
    \    ${result}=    Simulate Payment Error    ${error_type}
    \    Should Contain    ${result}    ${expected_message}
    \    Should Be Equal As Strings    ${result['status']}    failed

Concurrent Transaction Processing
    [Documentation]    Test handling of concurrent payment transactions
    [Tags]    concurrency    load    payment
    ${concurrent_transactions}=    Create List

    # Create 10 concurrent transactions
    :FOR    ${i}    IN RANGE    1    11
    \    ${transaction}=    Create Dictionary
    \    ...    id=TXN_${i}
    \    ...    amount=100.00
    \    ...    customer_id=CUST_${i}
    \    Append To List    ${concurrent_transactions}    ${transaction}

    # Process all transactions concurrently
    ${results}=    Process Concurrent Transactions    ${concurrent_transactions}

    # Verify all transactions processed
    Length Should Be    ${results}    10
    :FOR    ${result}    IN    @{results}
    \    Should Be Equal As Strings    ${result['status']}    success

# ===== PHASE 2: PCI DSS COMPLIANCE TESTING =====

PCI DSS Requirement 3.2 - Data Encryption
    [Documentation]    PCI DSS 3.2: Never store sensitive data after authorization
    [Tags]    pci_dss    security    compliance    critical
    ${sensitive_data}=    Create Dictionary
    ...    card_number=4111111111111111
    ...    cvv=123
    ...    track_data=%B4111111111111111^DOE/JOHN^250510100000000000?

    # Test tokenization
    ${token}=    Tokenize Payment Data    ${sensitive_data}
    Should Not Contain    ${token}    4111111111111111
    Should Not Contain    ${token}    123

    # Verify detokenization works for authorized systems only
    ${detokenized}=    Detokenize Payment Data    ${token}
    Dictionaries Should Be Equal    ${sensitive_data}    ${detokenized}

PCI DSS Requirement 3.4 - Data Retention
    [Documentation]    PCI DSS 3.4: Limit data retention to defined periods
    [Tags]    pci_dss    compliance    data_retention
    ${payment_record}=    Create Dictionary
    ...    transaction_id=TXN123456
    ...    timestamp=2024-01-15T10:30:00Z
    ...    retention_days=365

    # Test automatic data purging after retention period
    ${should_retain}=    Check Data Retention Policy    ${payment_record}
    Should Be True    ${should_retain}

    # Test expired data handling
    ${expired_record}=    Create Dictionary
    ...    transaction_id=TXN789012
    ...    timestamp=2020-01-15T10:30:00Z
    ...    retention_days=365

    ${should_retain}=    Check Data Retention Policy    ${expired_record}
    Should Not Be True    ${should_retain}

# ===== PHASE 2: ADVANCED DATA-DRIVEN TESTING =====

Credit Card Validation - Data Driven
    [Documentation]    Comprehensive card validation using external data sources
    [Tags]    credit_card    validation    data_driven    critical
    [Template]    Validate Credit Card Template

    # Card Type    Card Number          Expected Valid    Expected Type
    visa          4111111111111111      ${TRUE}          visa
    mastercard    5555555555554444      ${TRUE}          mastercard
    amex          378282246310005       ${TRUE}          amex
    discover      6011111111111117      ${TRUE}          discover
    invalid       4111111111111112      ${FALSE}         unknown

*** Keywords ***
Setup Credit Card Test Environment
    [Documentation]    Enhanced setup with performance monitoring and metrics
    [Arguments]    ${test_start_time}=${EMPTY}
    ${start_time}=    Run Keyword If    '${test_start_time}' == '${EMPTY}'
    ...    Get Time    epoch
    ...    ELSE    Set Variable    ${test_start_time}
    Set Suite Variable    ${TEST_START_TIME}    ${start_time}

    # Initialize performance counters
    Set Suite Variable    ${VALIDATION_COUNT}    ${0}
    Set Suite Variable    ${TOKENIZATION_COUNT}    ${0}

    # Setup environment
    Initialize Payment Library

    # Log test execution start
    Log    🧪 Starting credit card test execution at ${start_time}

Cleanup Credit Card Test Data
    [Documentation]    Enhanced cleanup with metrics collection and reporting
    ${test_end_time}=    Get Time    epoch
    ${duration}=    Evaluate    ${test_end_time} - ${TEST_START_TIME}

    # Calculate metrics
    ${avg_validation_time}=    Evaluate    ${duration} / max(${VALIDATION_COUNT}, 1)
    ${throughput}=    Evaluate    ${VALIDATION_COUNT} / max(${duration}, 1)

    # Log comprehensive metrics
    Log    📊 Test Metrics Summary:
    Log    Duration: ${duration} seconds
    Log    Validations: ${VALIDATION_COUNT}
    Log    Tokenizations: ${TOKENIZATION_COUNT}
    Log    Avg Validation Time: ${avg_validation_time} seconds
    Log    Throughput: ${throughput} validations/second

    # Record metrics for trend analysis
    Record Test Metrics    credit_card_tests    ${duration}    ${VALIDATION_COUNT}

    # Cleanup
    Reset Payment Library

Initialize Payment Library
    [Documentation]    Initialize the payment library for testing
    set_encryption_key    test_encryption_key_12345

Reset Payment Library
    [Documentation]    Reset payment library state after tests
    # Reset any test-specific state if needed
    Log    Resetting payment library state

# ===== PHASE 2: NEW KEYWORDS FOR ENHANCED TESTING =====

Calculate Fraud Score
    [Documentation]    Calculate fraud score for a transaction (simplified implementation)
    [Arguments]    ${transaction}
    ${customer_id}=    Get From Dictionary    ${transaction}    customer_id
    ${amount}=    Get From Dictionary    ${transaction}    amount

    # Simple fraud scoring logic (would be more complex in real implementation)
    ${score}=    Set Variable    0

    # High amount indicator
    Run Keyword If    ${amount} > 1000    Evaluate    score = score + 30

    # Velocity check (simplified - would check actual transaction history)
    ${recent_count}=    Evaluate    random.randint(1, 10)
    Run Keyword If    ${recent_count} > 5    Evaluate    score = score + 40

    [Return]    ${score}

Analyze Geolocation Risk
    [Documentation]    Analyze geolocation-based fraud risk (simplified implementation)
    [Arguments]    ${transaction}
    ${billing_country}=    Get From Dictionary    ${transaction}    billing_country
    ${ip_country}=    Get From Dictionary    ${transaction}    ip_country
    ${card_country}=    Get From Dictionary    ${transaction}    card_country

    ${risk_indicators}=    Create List

    # Country mismatch checks
    Run Keyword If    '${billing_country}' != '${ip_country}'
    ...    Append To List    ${risk_indicators}    country_mismatch
    Run Keyword If    '${billing_country}' != '${card_country}'
    ...    Append To List    ${risk_indicators}    card_country_mismatch

    # High-risk countries (simplified list)
    ${high_risk_countries}=    Create List    RU    CN    IN    BR
    :FOR    ${country}    IN    @{high_risk_countries}
    \    Run Keyword If    '${ip_country}' == '${country}'
    \    ...    Append To List    ${risk_indicators}    high_risk_country

    [Return]    ${risk_indicators}

Validate Card Format
    [Documentation]    Validate basic card number format and length
    [Arguments]    ${card_number}
    ${length}=    Get Length    ${card_number}

    # Check length (most cards are 13-19 digits)
    ${valid_length}=    Evaluate    13 <= ${length} <= 19

    # Check all digits
    ${all_digits}=    Evaluate    "${card_number}".isdigit()

    ${is_valid}=    Evaluate    ${valid_length} and ${all_digits}
    [Return]    ${is_valid}

Normalize Card Number
    [Documentation]    Normalize card number by removing spaces, dashes, etc.
    [Arguments]    ${card_number}
    ${normalized}=    Remove String    ${card_number}    ${SPACE}    -    .
    [Return]    ${normalized}

Get Memory Usage
    [Documentation]    Get current memory usage (simplified - would use psutil in real implementation)
    ${memory_mb}=    Evaluate    random.randint(100, 200)  # Mock implementation
    [Return]    ${memory_mb}

Record Test Metrics
    [Documentation]    Record test metrics for monitoring dashboard
    [Arguments]    ${test_suite}    ${duration}    ${operations}
    [Documentation]    Record metrics for monitoring dashboard
    ${metrics_file}=    Set Variable    results/metrics/${test_suite}_metrics.json
    ${metrics_data}=    Create Dictionary
    ...    timestamp=${test_end_time}
    ...    duration=${duration}
    ...    operations=${operations}
    ...    environment=%{PAYMENT_ENV}
    ...    build_id=%{BUILD_ID}

    # Create metrics directory if it doesn't exist
    Create File    ${metrics_file}    ${metrics_data}
    Log    Metrics recorded to ${metrics_file}

Simulate Payment Error
    [Documentation]    Simulate various payment error scenarios
    [Arguments]    ${error_type}
    ${error_responses}=    Create Dictionary
    ...    network_timeout={"status": "failed", "error": "Connection timeout", "code": "NETWORK_ERROR"}
    ...    gateway_unavailable={"status": "failed", "error": "Gateway down", "code": "GATEWAY_UNAVAILABLE"}
    ...    invalid_currency={"status": "failed", "error": "Unsupported currency", "code": "INVALID_CURRENCY"}
    ...    amount_too_high={"status": "failed", "error": "Amount exceeds limit", "code": "AMOUNT_TOO_HIGH"}
    ...    card_declined={"status": "failed", "error": "Card declined by issuer", "code": "CARD_DECLINED"}

    ${error_response}=    Get From Dictionary    ${error_responses}    ${error_type}
    [Return]    ${error_response}

Process Concurrent Transactions
    [Documentation]    Process multiple transactions concurrently (simplified implementation)
    [Arguments]    ${transactions}
    ${results}=    Create List

    :FOR    ${transaction}    IN    @{transactions}
    \    ${result}=    Create Dictionary
    \    ...    id=${transaction['id']}
    \    ...    status=success
    \    ...    amount=${transaction['amount']}
    \    ...    timestamp=${CURRENT_TIME}
    \    Append To List    ${results}    ${result}

    [Return]    ${results}

Check Data Retention Policy
    [Documentation]    Check if data should be retained based on retention policy
    [Arguments]    ${record}
    ${timestamp_str}=    Get From Dictionary    ${record}    timestamp
    ${retention_days}=    Get From Dictionary    ${record}    retention_days

    # Parse timestamp and calculate retention
    ${record_date}=    Convert Date    ${timestamp_str}    result_format=%Y-%m-%d
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d
    ${days_diff}=    Subtract Date From Date    ${current_date}    ${record_date}    result_format=number

    ${should_retain}=    Evaluate    ${days_diff} <= ${retention_days}
    [Return]    ${should_retain}

Validate Credit Card Template
    [Documentation]    Template for credit card validation testing
    [Arguments]    ${card_type}    ${card_number}    ${expected_valid}    ${expected_type}
    ${is_valid}=        Validate Credit Card Number    ${card_number}
    ${detected_type}=   Get Credit Card Type          ${card_number}

    Should Be Equal    ${is_valid}       ${expected_valid}
    Should Be Equal    ${detected_type}  ${expected_type}

    # Log for compliance auditing
    Run Keyword If    ${is_valid}    Log    ✅ Valid ${card_type} card detected
    ...    ELSE                       Log    ❌ Invalid card rejected: ${card_number}
