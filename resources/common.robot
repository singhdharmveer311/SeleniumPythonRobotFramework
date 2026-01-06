*** Settings ***
Documentation    Resource file with common keywords and configurations
Library          SeleniumLibrary
Library          Collections
Library          String
Variables        ../variables/common_variables.py

*** Variables ***
${BROWSER}              chrome
${HEADLESS}             False
${IMPLICIT_WAIT}        10
${EXPLICIT_WAIT}        30

*** Keywords ***
Open Browser To Start Page
    [Documentation]    Opens browser and sets up common configurations
    Run Keyword If    '${HEADLESS}' == 'True'
    ...    Open Browser    about:blank    ${BROWSER}    options=add_argument("--headless")
    ...    ELSE
    ...    Open Browser    about:blank    ${BROWSER}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Maximize Browser Window

Setup Test Environment
    [Documentation]    Sets up the test environment with necessary configurations
    Set Selenium Speed    0.5
    Set Selenium Timeout    ${EXPLICIT_WAIT}

Capture Screenshot On Failure
    [Documentation]    Captures screenshot when test fails
    Run Keyword If Test Failed    Capture Page Screenshot

Wait For Element And Click
    [Arguments]    ${locator}    ${timeout}=10s
    [Documentation]    Waits for element to be visible and clicks it
    Wait Until Element Is Visible    ${locator}    ${timeout}
    Click Element    ${locator}

Wait For Element And Input Text
    [Arguments]    ${locator}    ${text}    ${timeout}=10s
    [Documentation]    Waits for element to be visible and inputs text
    Wait Until Element Is Visible    ${locator}    ${timeout}
    Input Text    ${locator}    ${text}