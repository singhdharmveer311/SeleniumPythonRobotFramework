*** Settings ***

Documentation    Demo test suite for Robot Framework
Library          SeleniumLibrary

*** Test Cases ***
Validate Successful Login
    Open The Browser With Url





*** Keywords ***
open the browser with url
    Create Webdriver    Chrome
    Go To   https://opensource-demo.orangehrmlive.com/web/index.php/auth/login

Fill the login form
    Input Text    id:username    Admin
    Input Text    id:password    admin123
    Click Button    id:submit
    Wait Until Page Contains Element    xpath://h6[@class='oxd-text oxd-text--h6 oxd-topbar-header-breadcrumb-module']    10s
    Element Should Contain    id:welcomeMessage    Welcome, testuser!
    [Teardown]    Close Browser

Verify login failure
    ${result} =    Get Text    css:alert-error
    Should be equal as strings    ${result}    Invalid credentials for username and password.
    [Teardown]    Close Browser





