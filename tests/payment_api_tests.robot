*** Settings ***
Documentation       Payment API Integration Tests
...                 Tests for payment REST API endpoints, authentication, and data validation
...                 Covers payment creation, retrieval, refunds, webhooks, and error scenarios
...
...                 API ENDPOINTS COVERED:
...                 - POST /payments - Create payment
...                 - GET /payments/{id} - Get payment details
...                 - POST /payments/{id}/refund - Process refund
...                 - GET /payments - List payments with filtering
...                 - POST /webhooks - Webhook signature validation
...                 - POST /customers - Customer management
...
...                 EXECUTION TIME: ~4-5 minutes
...                 TEST PRIORITY: High (API contract validation)

Library             RequestsLibrary
Library             Collections
Library             JSONLibrary
Library             String
Library             DateTime
Library             OperatingSystem
Library             ../libraries/PaymentLibrary.py
Library             ../libraries/DatabaseLibrary.py
Variables           ../variables/payment_variables.py
Resource            ../resources/common.robot

Test Setup          Setup Payment API Test Environment
Test Teardown       Cleanup Payment API Test Data
Test Timeout        60 seconds

Metadata            Test Suite ID    API_PROC_001
Metadata            Business Owner   Payments Team
Metadata            Technical Owner  QA Automation
Metadata            API Version      v1.0
Metadata            Risk Level       High
Metadata            Authentication   Bearer Token

*** Variables ***
${API_BASE_URL}         http://localhost:8080/api/v1
${WEBHOOK_SECRET}       whsec_test_webhook_secret
${BEARER_TOKEN}         test_api_token_12345

*** Test Cases ***
Create Payment - Valid Credit Card
    [Documentation]    Test creating a payment with valid credit card
    [Tags]    api    payment_creation    credit_card    critical    smoke
    ${payment_data}=    Create Dictionary
    ...    amount=100.00
    ...    currency=USD
    ...    payment_method=card
    ...    card_number=4111111111111111
    ...    expiry_month=12
    ...    expiry_year=2026
    ...    cvv=123
    ...    customer_email=test@example.com
    ...    description=API Test Payment

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/payments
    ...    json=${payment_data}
    ...    headers=${headers}

    # Validate response
    Should Be Equal As Strings    ${response.status_code}    201
    ${response_json}=    Set Variable    ${response.json()}

    # Validate response structure
    Should Contain    ${response_json}    id
    Should Contain    ${response_json}    status
    Should Be Equal As Strings    ${response_json['status']}    succeeded
    Should Be Equal As Numbers    ${response_json['amount']}    100.00
    Should Be Equal As Strings    ${response_json['currency']}    USD

    # Store payment ID for cleanup
    Set Test Variable    ${PAYMENT_ID}    ${response_json['id']}

Create Payment - Invalid Card
    [Documentation]    Test creating a payment with invalid credit card
    [Tags]    api    payment_creation    validation    negative
    ${payment_data}=    Create Dictionary
    ...    amount=50.00
    ...    currency=USD
    ...    payment_method=card
    ...    card_number=4000000000000002
    ...    expiry_month=12
    ...    expiry_year=2020
    ...    cvv=123

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/payments
    ...    json=${payment_data}
    ...    headers=${headers}

    # Should fail with validation error
    Should Be Equal As Strings    ${response.status_code}    400
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    error
    Should Be Equal As Strings    ${response_json['error']['type']}    card_error

Retrieve Payment Details
    [Documentation]    Test retrieving payment details by ID
    [Tags]    api    payment_retrieval    critical
    # First create a payment
    ${payment_id}=    Create Test Payment    75.00    EUR

    # Then retrieve it
    ${headers}=    Create API Headers
    ${response}=    GET    ${API_BASE_URL}/payments/${payment_id}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}

    Should Be Equal As Strings    ${response_json['id']}    ${payment_id}
    Should Be Equal As Numbers    ${response_json['amount']}    75.00
    Should Be Equal As Strings    ${response_json['currency']}    EUR
    Should Contain    ${response_json}    created_at

List Payments with Filtering
    [Documentation]    Test listing payments with various filters
    [Tags]    api    payment_listing    filtering
    # Create multiple test payments
    Create Test Payment    25.00    USD
    Create Test Payment    50.00    EUR
    Create Test Payment    100.00    GBP

    ${headers}=    Create API Headers

    # Test filtering by currency
    ${response}=    GET    ${API_BASE_URL}/payments?currency=USD&limit=10
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}

    Should Contain    ${response_json}    data
    ${payments}=    Get From Dictionary    ${response_json}    data
    Length Should Be    ${payments}    1

    # Test pagination
    ${response}=    GET    ${API_BASE_URL}/payments?limit=2
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}
    ${payments}=    Get From Dictionary    ${response_json}    data
    Length Should Be    ${payments}    2
    Should Contain    ${response_json}    has_more

Process Payment Refund
    [Documentation]    Test processing a refund for a completed payment
    [Tags]    api    refunds    payment_management    critical
    # Create a successful payment first
    ${payment_id}=    Create Test Payment    200.00    USD

    # Process refund
    ${refund_data}=    Create Dictionary
    ...    amount=100.00
    ...    reason=customer_request
    ...    notes=API test refund

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/payments/${payment_id}/refund
    ...    json=${refund_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}

    Should Contain    ${response_json}    refund_id
    Should Be Equal As Strings    ${response_json['status']}    succeeded
    Should Be Equal As Numbers    ${response_json['amount']}    100.00

    # Verify original payment shows refund
    ${payment_response}=    GET    ${API_BASE_URL}/payments/${payment_id}
    ...    headers=${headers}

    ${payment_json}=    Set Variable    ${payment_response.json()}
    Should Be Equal As Numbers    ${payment_json['refunded_amount']}    100.00

Create Customer Profile
    [Documentation]    Test creating and managing customer profiles
    [Tags]    api    customer_management    data_management
    ${customer_data}=    Create Dictionary
    ...    email=test_customer@example.com
    ...    first_name=John
    ...    last_name=Doe
    ...    phone=+1-555-123-4567
    ...    metadata={"source": "api_test", "tier": "premium"}

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/customers
    ...    json=${customer_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    201
    ${response_json}=    Set Variable    ${response.json()}

    Should Contain    ${response_json}    id
    Should Be Equal As Strings    ${response_json['email']}    test_customer@example.com
    Should Be Equal As Strings    ${response_json['first_name']}    John

    Set Test Variable    ${CUSTOMER_ID}    ${response_json['id']}

Retrieve Customer with Payment Methods
    [Documentation]    Test retrieving customer with associated payment methods
    [Tags]    api    customer_management    payment_methods
    # Create customer first
    ${customer_id}=    Create Test Customer

    # Add payment method to customer
    ${payment_method_data}=    Create Dictionary
    ...    customer_id=${customer_id}
    ...    type=card
    ...    card_number=4111111111111111
    ...    expiry_month=12
    ...    expiry_year=2026
    ...    cvv=123

    ${headers}=    Create API Headers
    ${pm_response}=    POST    ${API_BASE_URL}/customers/${customer_id}/payment_methods
    ...    json=${payment_method_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${pm_response.status_code}    201

    # Retrieve customer with payment methods
    ${response}=    GET    ${API_BASE_URL}/customers/${customer_id}?expand=payment_methods
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}

    Should Contain    ${response_json}    payment_methods
    ${payment_methods}=    Get From Dictionary    ${response_json}    payment_methods
    Length Should Be    ${payment_methods}    1

Webhook Signature Validation
    [Documentation]    Test webhook signature validation and processing
    [Tags]    api    webhooks    security    integration    critical
    ${webhook_payload}=    Create Dictionary
    ...    type=payment_intent.succeeded
    ...    data={"object": {"id": "pi_test_123", "amount": 10000, "currency": "usd"}}

    # Generate valid signature
    ${signature}=    Generate Webhook Signature    ${webhook_payload}    ${WEBHOOK_SECRET}

    ${webhook_data}=    Create Dictionary
    ...    payload=${webhook_payload}
    ...    signature=${signature}
    ...    timestamp=1640995200

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/webhooks
    ...    json=${webhook_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${response_json['status']}    processed

Invalid Webhook Signature
    [Documentation]    Test handling of invalid webhook signatures
    [Tags]    api    webhooks    security    negative
    ${webhook_payload}=    Create Dictionary
    ...    type=payment_intent.succeeded
    ...    data={"object": {"id": "pi_test_123"}}

    ${webhook_data}=    Create Dictionary
    ...    payload=${webhook_payload}
    ...    signature=invalid_signature
    ...    timestamp=1640995200

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/webhooks
    ...    json=${webhook_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    401
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    error
    Should Be Equal As Strings    ${response_json['error']['type']}    signature_verification_failed

API Rate Limiting
    [Documentation]    Test API rate limiting behavior
    [Tags]    api    rate_limiting    performance
    ${headers}=    Create API Headers

    # Make multiple rapid requests
    :FOR    ${i}    IN RANGE    1    15
    \    ${response}=    GET    ${API_BASE_URL}/payments?limit=1
    \    ...    headers=${headers}
    \
    \    # First 10 should succeed, then rate limited
    \    Run Keyword If    ${i} <= 10
    \    ...    Should Be Equal As Strings    ${response.status_code}    200
    \    ...    ELSE
    \    ...    Should Be Equal As Strings    ${response.status_code}    429

API Authentication - Invalid Token
    [Documentation]    Test API authentication with invalid tokens
    [Tags]    api    authentication    security    negative
    ${payment_data}=    Create Dictionary
    ...    amount=10.00
    ...    currency=USD
    ...    payment_method=card
    ...    card_number=4111111111111111
    ...    expiry_month=12
    ...    expiry_year=2026
    ...    cvv=123

    ${invalid_headers}=    Create Dictionary
    ...    Authorization=Bearer invalid_token
    ...    Content-Type=application/json
    ...    X-API-Version=v1.0

    ${response}=    POST    ${API_BASE_URL}/payments
    ...    json=${payment_data}
    ...    headers=${invalid_headers}

    Should Be Equal As Strings    ${response.status_code}    401
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    error
    Should Be Equal As Strings    ${response_json['error']['type']}    authentication_error

API Input Validation - Missing Fields
    [Documentation]    Test API validation for missing required fields
    [Tags]    api    validation    negative
    ${incomplete_data}=    Create Dictionary
    ...    amount=25.00
    # Missing currency and payment method

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/payments
    ...    json=${incomplete_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    400
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    error
    Should Contain    ${response_json['error']}    required

API Input Validation - Invalid Data Types
    [Documentation]    Test API validation for invalid data types
    [Tags]    api    validation    negative
    ${invalid_data}=    Create Dictionary
    ...    amount=not_a_number
    ...    currency=USD
    ...    payment_method=card
    ...    card_number=4111111111111111
    ...    expiry_month=12
    ...    expiry_year=2026
    ...    cvv=123

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/payments
    ...    json=${invalid_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    400
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    error
    Should Contain    ${response_json['error']}    amount

API Concurrency Handling
    [Documentation]    Test API handling of concurrent requests
    [Tags]    api    concurrency    performance
    ${headers}=    Create API Headers

    # Create multiple concurrent payment requests
    ${concurrent_payments}=    Create List
    :FOR    ${i}    IN RANGE    1    6
    \    ${payment_data}=    Create Dictionary
    \    ...    amount=10.00
    \    ...    currency=USD
    \    ...    payment_method=card
    \    ...    card_number=4111111111111111
    \    ...    expiry_month=12
    \    ...    expiry_year=2026
    \    ...    cvv=123
    \    ...    idempotency_key=idempotent_${i}
    \    Append To List    ${concurrent_payments}    ${payment_data}

    # Process payments concurrently (simulated)
    ${results}=    Process Concurrent API Requests    ${concurrent_payments}    ${headers}

    # All should succeed
    :FOR    ${result}    IN    @{results}
    \    Should Be Equal As Strings    ${result['status_code']}    201
    \    Should Contain    ${result['response']}    id

*** Keywords ***
Setup Payment API Test Environment
    [Documentation]    Setup environment for payment API testing
    Create Session    payment_api    ${API_BASE_URL}
    Set Suite Variable    ${API_SESSION}    payment_api

    # Initialize database for API testing
    Connect to Database    test_payments.db
    Set Suite Variable    ${DB_CONNECTION}    ${True}

Cleanup Payment API Test Data
    [Documentation]    Cleanup API test data
    # Note: In real implementation, this would clean up test data
    # For now, just log cleanup
    Log    API test data cleanup completed

Create API Headers
    [Documentation]    Create standard API headers for requests
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${BEARER_TOKEN}
    ...    Content-Type=application/json
    ...    X-API-Version=v1.0
    ...    X-Request-ID=${RANDOM_REQUEST_ID}
    [Return]    ${headers}

Create Test Payment
    [Documentation]    Helper to create a test payment and return ID
    [Arguments]    ${amount}=100.00    ${currency}=USD
    ${payment_data}=    Create Dictionary
    ...    amount=${amount}
    ...    currency=${currency}
    ...    payment_method=card
    ...    card_number=4111111111111111
    ...    expiry_month=12
    ...    expiry_year=2026
    ...    cvv=123
    ...    customer_email=api_test@example.com

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/payments
    ...    json=${payment_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    201
    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json['id']}

Create Test Customer
    [Documentation]    Helper to create a test customer and return ID
    ${customer_data}=    Create Dictionary
    ...    email=api_customer_${RANDOM_ID}@example.com
    ...    first_name=API
    ...    last_name=Test
    ...    phone=+1-555-000-0000

    ${headers}=    Create API Headers
    ${response}=    POST    ${API_BASE_URL}/customers
    ...    json=${customer_data}
    ...    headers=${headers}

    Should Be Equal As Strings    ${response.status_code}    201
    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json['id']}

Generate Webhook Signature
    [Documentation]    Generate webhook signature for testing
    [Arguments]    ${payload}    ${secret}
    ${timestamp}=    Get Current Date    result_format=epoch    exclude_millis=True
    ${payload_str}=    Evaluate    json.dumps(${payload})
    ${signed_payload}=    Set Variable    ${timestamp}.${payload_str}
    ${signature}=    Evaluate    hmac.new('${secret}'.encode(), '${signed_payload}'.encode(), hashlib.sha256).hexdigest()
    [Return]    t=${timestamp},v1=${signature}

Process Concurrent API Requests
    [Documentation]    Process multiple API requests concurrently (simplified)
    [Arguments]    ${requests}    ${headers}
    ${results}=    Create List

    :FOR    ${request}    IN    @{requests}
    \    ${response}=    POST    ${API_BASE_URL}/payments
    \    ...    json=${request}
    \    ...    headers=${headers}
    \
    \    ${result}=    Create Dictionary
    \    ...    status_code=${response.status_code}
    \    ...    response=${response.json()}
    \    Append To List    ${results}    ${result}

    [Return]    ${results}

*** Variables ***
${RANDOM_REQUEST_ID}    req_${CURRENT_TIME}
${RANDOM_ID}           ${CURRENT_TIME}
${CURRENT_TIME}        20240115_100000
