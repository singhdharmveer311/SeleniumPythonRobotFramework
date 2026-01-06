*** Settings ***
Documentation    Sample test suite for web automation using Robot Framework and Selenium
Library          SeleniumLibrary
Resource         ../resources/common.robot
Suite Setup      Open Browser To Start Page
Suite Teardown   Close Browser

*** Test Cases ***
Sample Web Test - Google Search
    [Documentation]    This is a sample test that searches for "Robot Framework" on Google
    [Tags]    smoke    web
    Navigate To Google
    Search For Text    Robot Framework
    Verify Search Results

Sample Form Test
    [Documentation]    Test form interaction capabilities
    [Tags]    forms    web
    Go To    https://www.w3schools.com/html/html_forms.asp
    Wait Until Page Contains Element    //input[@type='text']    10s
    Input Text    //input[@type='text']    Test User
    Click Element    //input[@type='submit']

*** Keywords ***
Navigate To Google
    Go To    https://www.google.com
    Wait Until Page Contains Element    name=q    10s

Search For Text
    [Arguments]    ${search_text}
    Input Text    name=q    ${search_text}
    Press Keys    name=q    ENTER

Verify Search Results
    Wait Until Page Contains    Robot Framework    10s
    Page Should Contain    Robot Framework