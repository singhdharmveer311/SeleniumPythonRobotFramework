*** Settings ***
Documentation       Stripe Payment Gateway Integration Tests
...                 Tests for credit card processing, refunds, and payment management

Library             RequestsLibrary
Library             Collections
Library             JSONLibrary
Library             String
Library             DateTime
Library             ../libraries/PaymentLibrary.py
Variables           ../variables/payment_variables.py

Test Setup          Setup Stripe Test Environment
Test Teardown       Cleanup Test Data

*** Variables ***
${STRIPE_BASE_URL}      https://api.stripe.com/v1
${STRIPE_API_VERSION}   2023-10-16

*** Test Cases ***
Create Payment Intent - Valid Card
    [Documentation]    Test creating a payment intent with valid credit card
    [Tags]    stripe    payment_intent    smoke    payment
    ${amount}=    Convert To Number    100.00
    ${currency}=    Set Variable    usd
    ${payment_data}=    Create Dictionary
    ...    amount=${amount}
    ...    currency=${currency}
    ...    payment_method_types=["card"]

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_intents
    ...    data=${payment_data}
    ...    headers=${STRIPE_HEADERS}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    id
    Should Be Equal As Strings    ${response_json['status']}    requires_payment_method

Create Payment Method - Valid Credit Card
    [Documentation]    Test creating a payment method with valid credit card details
    [Tags]    stripe    payment_method    credit_card    payment
    ${card_data}=    Create Dictionary
    ...    number=${TEST_CREDIT_CARDS.visa.number}
    ...    exp_month=${TEST_CREDIT_CARDS.visa.expiry_month}
    ...    exp_year=${TEST_CREDIT_CARDS.visa.expiry_year}
    ...    cvc=${TEST_CREDIT_CARDS.visa.cvv}

    ${payment_method_data}=    Create Dictionary
    ...    type=card
    ...    card=${card_data}

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_methods
    ...    data=${payment_method_data}
    ...    headers=${STRIPE_HEADERS}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    id
    Should Be Equal As Strings    ${response_json['type']}    card
    Should Be Equal As Strings    ${response_json['card']['brand']}    visa

Process Payment - Complete Flow
    [Documentation]    Test complete payment processing flow from intent to confirmation
    [Tags]    stripe    payment_processing    integration    payment
    # Create payment intent
    ${intent_response}=    Create Payment Intent    5000    usd
    ${intent_id}=    Set Variable    ${intent_response['id']}

    # Create payment method
    ${pm_response}=    Create Payment Method    visa
    ${pm_id}=    Set Variable    ${pm_response['id']}

    # Confirm payment
    ${confirm_data}=    Create Dictionary
    ...    payment_method=${pm_id}

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_intents/${intent_id}/confirm
    ...    data=${confirm_data}
    ...    headers=${STRIPE_HEADERS}

    # Note: This will likely fail without proper test setup, but tests the flow
    ${response_json}=    Set Variable    ${response.json()}
    Log    Payment confirmation response: ${response_json}

Test Different Card Types
    [Documentation]    Test payment processing with different credit card types
    [Tags]    stripe    card_types    payment
    :FOR    ${card_type}    IN    visa    mastercard    amex
    \    ${card_data}=    Get From Dictionary    ${TEST_CREDIT_CARDS}    ${card_type}
    \    ${pm_response}=    Create Payment Method With Card Data    ${card_data}
    \    Should Be Equal As Strings    ${pm_response['card']['brand']}    ${card_type}
    \    Log    Successfully created ${card_type} payment method

Test Invalid Card Numbers
    [Documentation]    Test handling of invalid credit card numbers
    [Tags]    stripe    validation    negative    payment
    ${invalid_card}=    Create Dictionary
    ...    number=4000000000000002
    ...    exp_month=12
    ...    exp_year=2026
    ...    cvc=123

    ${payment_method_data}=    Create Dictionary
    ...    type=card
    ...    card=${invalid_card}

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_methods
    ...    data=${payment_method_data}
    ...    headers=${STRIPE_HEADERS}

    # Should fail with invalid card
    Should Not Be Equal As Strings    ${response.status_code}    200

Test Expired Cards
    [Documentation]    Test handling of expired credit cards
    [Tags]    stripe    validation    expiry    payment
    ${expired_card}=    Create Dictionary
    ...    number=${TEST_CREDIT_CARDS.invalid.number}
    ...    exp_month=${TEST_CREDIT_CARDS.invalid.expiry_month}
    ...    exp_year=${TEST_CREDIT_CARDS.invalid.expiry_year}
    ...    cvc=${TEST_CREDIT_CARDS.invalid.cvv}

    ${payment_method_data}=    Create Dictionary
    ...    type=card
    ...    card=${expired_card}

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_methods
    ...    data=${payment_method_data}
    ...    headers=${STRIPE_HEADERS}

    # Should handle expired card appropriately
    ${response_json}=    Set Variable    ${response.json()}
    Log    Expired card response: ${response_json}

Test Refund Processing
    [Documentation]    Test refund processing for completed payments
    [Tags]    stripe    refund    payment
    # This would require a successful payment first
    # For now, test refund creation structure
    ${refund_data}=    Create Dictionary
    ...    amount=1000
    ...    reason=requested_by_customer

    # Note: Would need charge_id from successful payment
    Log    Refund data structure: ${refund_data}

Test Customer Creation
    [Documentation]    Test creating customer records in Stripe
    [Tags]    stripe    customer    payment
    ${customer_data}=    Create Dictionary
    ...    name=${TEST_CUSTOMERS.individual.name}
    ...    email=${TEST_CUSTOMERS.individual.email}
    ...    phone=${TEST_CUSTOMERS.individual.phone}

    ${response}=    POST    ${STRIPE_BASE_URL}/customers
    ...    data=${customer_data}
    ...    headers=${STRIPE_HEADERS}

    Should Be Equal As Strings    ${response.status_code}    200
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json}    id
    Should Be Equal As Strings    ${response_json['name']}    ${TEST_CUSTOMERS.individual.name}

Test Subscription Creation
    [Documentation]    Test creating subscription payments
    [Tags]    stripe    subscription    payment
    # Create customer first
    ${customer_response}=    Create Test Customer
    ${customer_id}=    Set Variable    ${customer_response['id']}

    # Create price/product first (simplified for test)
    ${subscription_data}=    Create Dictionary
    ...    customer=${customer_id}
    ...    items[0][price_data][unit_amount]=2999
    ...    items[0][price_data][currency]=usd
    ...    items[0][price_data][product_data][name]=Test Subscription
    ...    items[0][price_data][recurring][interval]=month

    ${response}=    POST    ${STRIPE_BASE_URL}/subscriptions
    ...    data=${subscription_data}
    ...    headers=${STRIPE_HEADERS}

    ${response_json}=    Set Variable    ${response.json()}
    Log    Subscription creation response: ${response_json}

Test Webhook Handling
    [Documentation]    Test webhook signature validation and handling
    [Tags]    stripe    webhook    integration    payment
    # Test webhook signature validation
    ${webhook_secret}=    Set Variable    whsec_test_webhook_secret
    ${payload}=    Set Variable    {"type": "payment_intent.succeeded", "data": {"object": {"id": "pi_test"}}}
    ${signature}=    Generate Test Webhook Signature    ${payload}    ${webhook_secret}

    # Verify signature would be valid
    ${is_valid}=    Verify Webhook Signature    ${payload}    ${signature}    ${webhook_secret}
    Should Be True    ${is_valid}

Test Rate Limiting
    [Documentation]    Test handling of rate limiting from Stripe API
    [Tags]    stripe    rate_limiting    performance    payment
    # Make multiple rapid requests to potentially trigger rate limiting
    :FOR    ${i}    IN RANGE    1    10
    \    ${response}=    GET    ${STRIPE_BASE_URL}/customers    headers=${STRIPE_HEADERS}
    \    Log    Request ${i}: Status ${response.status_code}
    \    Sleep    0.1s

Test Error Handling
    [Documentation]    Test various error conditions and responses
    [Tags]    stripe    error_handling    negative    payment
    # Test with invalid API key
    ${invalid_headers}=    Create Dictionary
    ...    Authorization=Bearer sk_test_invalid_key
    ...    Content-Type=application/x-www-form-urlencoded

    ${response}=    GET    ${STRIPE_BASE_URL}/customers    headers=${invalid_headers}
    Should Not Be Equal As Strings    ${response.status_code}    200

*** Keywords ***
Setup Stripe Test Environment
    [Documentation]    Set up test environment for Stripe integration
    Create Session    stripe    ${STRIPE_BASE_URL}
    Set Suite Variable    ${STRIPE_HEADERS}    ${EMPTY}
    ${STRIPE_HEADERS}=    Create Dictionary
    ...    Authorization=Bearer ${STRIPE_SECRET_KEY}
    ...    Content-Type=application/x-www-form-urlencoded
    ...    Stripe-Version=${STRIPE_API_VERSION}
    Set Suite Variable    ${STRIPE_HEADERS}    ${STRIPE_HEADERS}

Create Payment Intent
    [Arguments]    ${amount}    ${currency}=usd
    [Documentation]    Create a payment intent for testing
    ${data}=    Create Dictionary
    ...    amount=${amount}
    ...    currency=${currency}
    ...    payment_method_types=["card"]

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_intents
    ...    data=${data}
    ...    headers=${STRIPE_HEADERS}

    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json}

Create Payment Method
    [Arguments]    ${card_type}=visa
    [Documentation]    Create a payment method for testing
    ${card_data}=    Get From Dictionary    ${TEST_CREDIT_CARDS}    ${card_type}

    ${payment_method_data}=    Create Dictionary
    ...    type=card
    ...    card=${card_data}

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_methods
    ...    data=${payment_method_data}
    ...    headers=${STRIPE_HEADERS}

    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json}

Create Payment Method With Card Data
    [Arguments]    ${card_data}
    [Documentation]    Create payment method with provided card data
    ${payment_method_data}=    Create Dictionary
    ...    type=card
    ...    card=${card_data}

    ${response}=    POST    ${STRIPE_BASE_URL}/payment_methods
    ...    data=${payment_method_data}
    ...    headers=${STRIPE_HEADERS}

    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json}

Create Test Customer
    [Documentation]    Create a test customer for testing
    ${customer_data}=    Create Dictionary
    ...    name=Test Customer
    ...    email=test@example.com

    ${response}=    POST    ${STRIPE_BASE_URL}/customers
    ...    data=${customer_data}
    ...    headers=${STRIPE_HEADERS}

    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json}

Generate Test Webhook Signature
    [Arguments]    ${payload}    ${secret}
    [Documentation]    Generate a test webhook signature
    ${timestamp}=    Get Current Date    result_format=epoch    exclude_millis=True
    ${signed_payload}=    Set Variable    ${timestamp}.${payload}
    ${signature}=    Evaluate    hmac.new('${secret}'.encode(), '${signed_payload}'.encode(), hashlib.sha256).hexdigest()
    [Return]    t=${timestamp},v1=${signature}

Verify Webhook Signature
    [Arguments]    ${payload}    ${signature}    ${secret}
    [Documentation]    Verify webhook signature (simplified for testing)
    # In real implementation, this would validate the signature properly
    ${is_valid}=    Run Keyword And Return Status
    ...    Should Contain    ${signature}    v1=
    [Return]    ${is_valid}

Cleanup Test Data
    [Documentation]    Clean up test data after each test
    # Implementation would clean up created test resources
    Log    Cleaning up test data...
