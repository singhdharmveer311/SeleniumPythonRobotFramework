*** Settings ***
Documentation       Payment Web UI Testing Suite - Enhanced with Best Practices
...                 🏆 IMPLEMENTS COMPREHENSIVE BEST PRACTICES:
...                 ✅ Separation of Concerns - Page objects for locators
...                 ✅ Defensive Programming - Robust waits and error handling  
...                 ✅ Maintainability - DRY principles and atomic keywords
...                 ✅ Observability - Detailed logging and performance monitoring
...                 ✅ Reliability - Browser state management and test isolation
...
...                 COVERAGE:
...                 - Payment form validation and submission
...                 - Multi-step checkout process with error recovery
...                 - Payment method selection (credit cards, wallets)
...                 - Comprehensive error handling and user feedback
...                 - Mobile/tablet responsiveness testing
...                 - Accessibility compliance verification
...                 - Performance monitoring and reporting
...
...                 EXECUTION TIME: ~8-10 minutes (with enhanced monitoring)
...                 TEST PRIORITY: Critical (User-facing payment flows)

Library             SeleniumLibrary
Library             Collections
Library             String
Library             DateTime
Library             OperatingSystem
Library             ../libraries/PaymentLibrary.py
Variables           ../variables/payment_variables.py

# Core Resources - Following Best Practices Architecture
Resource            ../resources/checkout_page.robot              # Page Object Model
Resource            ../resources/payment_success_page.robot       # Page Object Model  
Resource            ../resources/defensive_programming.robot      # Robust Error Handling
Resource            ../resources/payment_flow_keywords.robot      # Maintainable Keywords
Resource            ../resources/observability.robot              # Monitoring & Logging
Resource            ../resources/reliability.robot                # Environment Management
Resource            ../resources/common.robot                     # Legacy Support

Test Setup          Enhanced Test Environment Setup
Test Teardown       Enhanced Test Environment Cleanup
Test Timeout        180 seconds

Metadata            Test Suite ID    WEB_UI_PROC_001_ENHANCED
Metadata            Business Owner   Product Team
Metadata            Technical Owner  QA Automation
Metadata            Browsers         Chrome, Firefox, Safari
Metadata            Devices         Desktop, Mobile, Tablet
Metadata            Risk Level       High
Metadata            Architecture    Enhanced with Best Practices
Metadata            Version         2.0

*** Variables ***
# Enhanced Configuration Variables
${BROWSER}                          chrome
${HEADLESS}                         ${TRUE}
${PAYMENT_PAGE_URL}                 http://localhost:3000/payment
${CHECKOUT_URL}                     http://localhost:3000/checkout
${SUCCESS_URL}                      http://localhost:3000/payment/success
${TIMEOUT}                          30s
${IMPLICIT_WAIT}                    10s

# Default Test Data - Following Best Practices
&{DEFAULT_BILLING_INFO}             name=Test User    email=test@example.com    address=123 Test Street    city=Test City    postal_code=12345    country=US
&{DEFAULT_CREDIT_CARD}              number=4111111111111111    expiry_month=12    expiry_year=2026    cvv=123    cardholder_name=Test User

# Mock Response Templates for API Testing
&{MOCK_STRIPE_SUCCESS_RESPONSE}     id=pi_test_success    status=succeeded    amount=9999    currency=usd
&{MOCK_PAYPAL_SUCCESS_RESPONSE}     id=test_order_123    status=APPROVED    intent=CAPTURE

*** Test Cases ***
Complete Credit Card Payment Flow
    [Documentation]    🎯 Test complete credit card payment flow with enhanced reliability
    ...               Uses page objects, defensive programming, and comprehensive monitoring
    [Tags]    web_ui    payment_flow    credit_card    critical    e2e    smoke    enhanced
    
    Log Step Execution    Complete Credit Card Payment Flow    Full end-to-end payment test
    
    # Create test configuration using best practices
    &{config}=    Create Test Payment Configuration    visa
    
    # Execute complete payment flow with enhanced error handling
    Execute Complete Payment Flow    &{config}
    
    Log Step Completion    Complete Credit Card Payment Flow    SUCCESS

Enhanced Credit Card Form Validation
    [Documentation]    🛡️ Test credit card form validation with defensive programming
    ...               Comprehensive validation testing with enhanced error handling
    [Tags]    web_ui    form_validation    credit_card    validation    enhanced    defensive
    
    Log Step Execution    Enhanced Form Validation    Testing all validation scenarios
    
    # Navigate with enhanced page object
    Navigate To Checkout Page
    Monitor Page Load Performance    Checkout Page    3000
    
    # Select payment method with robust handling
    Select And Configure Payment Method    credit_card    ${EMPTY}
    
    # Test empty form submission with retry logic
    Log Step Execution    Empty Form Test
    Robust Click Element    ${SUBMIT_PAYMENT_BUTTON}
    Verify Form Field Error    card_number    Card number is required
    Log Step Completion    Empty Form Test    SUCCESS
    
    # Test invalid card number with enhanced input
    Log Step Execution    Invalid Card Test
    Fill Credit Card Number    1234567890123456
    Submit Payment Form With Validation
    Verify Form Field Error    card_number    Invalid card number
    Log Step Completion    Invalid Card Test    SUCCESS
    
    # Test expired card with date validation
    Log Step Execution    Expired Card Test
    Fill Credit Card Number    ${TEST_CREDIT_CARDS.visa.number}
    Select Credit Card Expiry    01    2020
    Submit Payment Form With Validation
    Verify Form Field Error    expiry    Card has expired
    Log Step Completion    Expired Card Test    SUCCESS
    
    # Test valid card (no errors expected)
    Log Step Execution    Valid Card Test
    Select Credit Card Expiry    12    2026
    Fill Credit Card CVV    123
    Submit Payment Form With Validation
    Verify No Form Errors Present
    Log Step Completion    Valid Card Test    SUCCESS

Enhanced Payment Method Selection
    [Documentation]    🔄 Test payment method selection with robust error handling
    ...               Comprehensive testing of all payment method transitions
    [Tags]    web_ui    payment_methods    selection    enhanced    reliability
    
    Log Step Execution    Payment Method Selection Test
    
    # Navigate with page object and monitoring
    Navigate To Checkout Page
    Verify Checkout Page Elements Are Present
    
    # Test credit card selection with validation
    Log Step Execution    Credit Card Selection
    Select Payment Method With Validation    credit_card
    Verify Payment Form Visible    credit_card
    Log Step Completion    Credit Card Selection    SUCCESS
    Verify Payment Method Selected    credit_card
    Verify Credit Card Form Visible

    # Test switching to PayPal
    Select Payment Method    paypal
    Verify Payment Method Selected    paypal
    Verify PayPal Button Visible

    # Test switching to Apple Pay
    Select Payment Method    apple_pay
    Verify Payment Method Selected    apple_pay
    Verify Apple Pay Button Visible

    # Test switching back to credit card
    Select Payment Method    credit_card
    Verify Payment Method Selected    credit_card

Apple Pay Integration Test
    [Documentation]    Test Apple Pay button and flow integration
    [Tags]    web_ui    apple_pay    wallet    integration
    Navigate To Checkout Page
    Select Payment Method    apple_pay

    # Verify Apple Pay button is displayed
    Verify Apple Pay Button Visible
    Verify Apple Pay Button Enabled

    # Test Apple Pay button click (simulated)
    Click Apple Pay Button
    Verify Apple Pay Modal Opens

    # Test Apple Pay cancellation
    Cancel Apple Pay Payment
    Verify Payment Method Still Selected    apple_pay

Google Pay Integration Test
    [Documentation]    Test Google Pay button and flow integration
    [Tags]    web_ui    google_pay    wallet    integration
    Navigate To Checkout Page
    Select Payment Method    google_pay

    # Verify Google Pay button
    Verify Google Pay Button Visible
    Verify Google Pay Button Enabled

    # Test Google Pay flow
    Click Google Pay Button
    Verify Google Pay Modal Opens

    # Select payment method in Google Pay
    Select Google Pay Card    visa
    Verify Google Pay Card Selected

    # Complete Google Pay payment
    Complete Google Pay Payment
    Verify Payment Success

PayPal Express Checkout
    [Documentation]    Test PayPal Express Checkout integration
    [Tags]    web_ui    paypal    express_checkout    wallet
    Navigate To Checkout Page
    Select Payment Method    paypal

    # Click PayPal button
    Click PayPal Button
    Verify PayPal Login Page Opens

    # Simulate PayPal login and approval
    Complete PayPal Login    test@example.com    testpass123
    Approve PayPal Payment

    # Return to merchant site
    Verify PayPal Payment Approved
    Verify Payment Success

Enhanced Mobile Payment Experience
    [Documentation]    📱 Test mobile payment flow with comprehensive monitoring
    ...               Enhanced responsive testing with performance metrics
    [Tags]    web_ui    mobile    responsive    ux    enhanced    performance
    
    Log Step Execution    Mobile Payment Experience Test
    
    # Set mobile viewport with monitoring
    Set Viewport Size    375    667    # iPhone SE size
    Monitor Page Load Performance    Mobile Checkout    2000
    
    # Navigate with mobile-specific validation
    Navigate To Checkout Page
    Verify Responsive Layout    mobile
    
    # Create mobile-specific test configuration
    &{mobile_config}=    Create Test Payment Configuration    visa
    ${mobile_billing}=    Create Dictionary
    ...    name=Jane Smith    email=jane@example.com    address=456 Mobile Ave
    Set To Dictionary    ${mobile_config}    billing_info=${mobile_billing}
    
    # Execute mobile payment flow with enhanced monitoring
    Execute Complete Payment Flow    &{mobile_config}
    
    Log Step Completion    Mobile Payment Experience Test    SUCCESS

Tablet Payment Experience
    [Documentation]    Test payment flow on tablet devices
    [Tags]    web_ui    tablet    responsive    ux
    Set Viewport Size    768    1024    # iPad size

    Navigate To Checkout Page

    # Verify tablet layout
    Verify Tablet Layout Active
    Verify Payment Form Optimized For Tablet

    # Complete payment flow
    Fill Billing Information    Tablet User    tablet@example.com    789 Tablet Blvd
    Select Payment Method    credit_card
    Fill Credit Card Form    ${TEST_CREDIT_CARDS.mastercard.number}    06    2025    456

    Review Order And Submit
    Verify Payment Success

Enhanced Payment Error Handling
    [Documentation]    🛡️ Test comprehensive error handling with retry mechanisms
    ...               Advanced error handling with defensive programming patterns
    [Tags]    web_ui    error_handling    ux    negative    enhanced    defensive
    
    Log Step Execution    Enhanced Error Handling Test
    
    # Navigate with error monitoring
    Navigate To Checkout Page
    Setup JavaScript Error Monitoring
    
    # Configure declined card scenario
    &{declined_config}=    Create Test Payment Configuration    declined_card
    ${declined_card}=    Create Dictionary    number=4000000000000002    cvv=123
    Set To Dictionary    ${declined_config}    payment_details=${declined_card}
    
    # Test declined card with enhanced error handling
    Log Step Execution    Declined Card Test
    TRY
        Execute Complete Payment Flow    &{declined_config}
        Fail    Expected payment to be declined
    EXCEPT    AS    ${error}
        Log    ✅ Payment declined as expected: ${error}    INFO
        Verify Payment Declined Error
        Take Performance Screenshot    payment_declined
    END
    
    Log Step Completion    Enhanced Error Handling Test    SUCCESS

Payment Form Accessibility
    [Documentation]    Test payment form accessibility compliance
    [Tags]    web_ui    accessibility    a11y    compliance
    Navigate To Checkout Page

    # Test keyboard navigation
    Verify Keyboard Navigation Works
    Verify Tab Order Correct

    # Test screen reader compatibility
    Verify ARIA Labels Present
    Verify Form Labels Associated

    # Test color contrast
    Verify Color Contrast Meets Standards

    # Test focus indicators
    Verify Focus Indicators Visible

International Payment Support
    [Documentation]    Test payment form with international addresses and currencies
    [Tags]    web_ui    internationalization    i18n
    Navigate To Checkout Page

    # Test international billing address
    Fill International Billing Address    München    Germany    80331    DE
    Verify Address Validation Passes For International

    # Test currency display
    Select Currency    EUR
    Verify Prices Display In Euros
    Verify Currency Symbol Correct

    # Complete international payment
    Select Payment Method    credit_card
    Fill Credit Card Form    ${TEST_CREDIT_CARDS.visa.number}    12    2026    123
    Review Order And Submit
    Verify Payment Success In Euros

Payment Security Indicators
    [Documentation]    Test security indicators and trust signals
    [Tags]    web_ui    security    trust_signals
    Navigate To Checkout Page

    # Verify SSL certificate indicator
    Verify SSL Certificate Valid
    Verify Secure Connection Indicator

    # Verify payment security badges
    Verify PCI Compliance Badge Visible
    Verify SSL Security Badge Visible

    # Verify secure form indicators
    Verify Credit Card Fields Masked
    Verify CVV Field Hidden

Checkout Flow Analytics
    [Documentation]    Test checkout flow analytics and conversion tracking
    [Tags]    web_ui    analytics    conversion
    Navigate To Checkout Page

    # Track user interactions
    Verify Analytics Events Fired    checkout_started
    Fill Billing Information    Analytics User    analytics@example.com    123 Data St
    Verify Analytics Events Fired    billing_completed

    Select Payment Method    credit_card
    Verify Analytics Events Fired    payment_method_selected

    Fill Credit Card Form    ${TEST_CREDIT_CARDS.visa.number}    12    2026    123
    Verify Analytics Events Fired    payment_form_completed

    # Complete purchase
    Review Order And Submit
    Verify Analytics Events Fired    purchase_completed
    Verify Conversion Tracking Works

*** Keywords ***
Enhanced Test Environment Setup
    [Documentation]    🚀 Enhanced test environment setup with all best practices
    ...               Implements reliability, observability, and defensive programming
    
    ${test_name}=    Get Variable Value    ${TEST NAME}    Unknown Test
    ${test_tags}=    Get Variable Value    ${TEST TAGS}    ${EMPTY}
    
    # Create enhanced configuration
    &{config}=    Create Dictionary
    ...    headless=${HEADLESS}
    ...    window_size=1920,1080
    
    # Initialize comprehensive test environment
    Initialize Reliable Test Environment    ${test_name}    ${config}
    
    # Verify environment health
    Verify Test Environment Health
    
    Log    🎯 Enhanced test environment ready for: ${test_name}    console=${TRUE}

Enhanced Test Environment Cleanup
    [Documentation]    🧹 Enhanced cleanup with comprehensive reporting and monitoring
    ...               Ensures clean state and generates detailed reports
    
    # Handle any unexpected modals or alerts
    Handle Unexpected Modal
    
    # Check for JavaScript errors
    Check And Log JavaScript Errors
    
    # Take final screenshot if test failed
    Run Keyword If Test Failed    Enhanced Screenshot On Failure
    
    # Comprehensive environment cleanup
    Cleanup Reliable Test Environment
    
    Log    ✅ Enhanced test environment cleanup completed    console=${TRUE}

# Legacy keyword compatibility - now handled by enhanced page objects
# See resources/checkout_page.robot and resources/payment_flow_keywords.robot for implementation

# Legacy keywords have been migrated to enhanced resources:
# - checkout_page.robot: Page object model for checkout functionality  
# - payment_success_page.robot: Page object model for success page
# - defensive_programming.robot: Robust element interactions and error handling
# - payment_flow_keywords.robot: Maintainable, reusable payment flow operations
# - observability.robot: Comprehensive logging and performance monitoring
# - reliability.robot: Browser state management and test isolation
#
# These resources implement the five best practices:
# 1. Separation of Concerns - Page objects isolate locators from business logic
# 2. Defensive Programming - Robust waits, retries, and exception handling
# 3. Maintainability - DRY principles, single responsibility, clear naming
# 4. Observability - Detailed logging, screenshots, performance metrics
# 5. Reliability - Test data isolation, browser state management, API mocking
