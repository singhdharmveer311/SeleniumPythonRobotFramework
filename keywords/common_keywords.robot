*** Settings ***
Documentation    Custom keywords for common test operations
Library          ../libraries/CustomLibrary.py
Library          DateTime
Library          OperatingSystem

*** Keywords ***
Generate Test Data
    [Documentation]    Generates random test data for forms
    ${email}=    Generate Random Email
    ${username}=    Generate Random String    8
    ${password}=    Generate Random String    12
    ${test_data}=    Create Dictionary    email=${email}    username=${username}    password=${password}
    [Return]    ${test_data}

Create Test Report Directory
    [Documentation]    Creates directory for test reports with timestamp
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${report_dir}=    Set Variable    results/run_${timestamp}
    Create Directory    ${report_dir}
    [Return]    ${report_dir}

Log Test Environment Info
    [Documentation]    Logs information about the test environment
    ${os}=    Evaluate    platform.system()    platform
    ${python_version}=    Evaluate    sys.version    sys
    Log    Operating System: ${os}
    Log    Python Version: ${python_version}

Wait And Retry
    [Arguments]    ${keyword}    ${max_retries}=3    ${delay}=2s    @{args}
    [Documentation]    Retries a keyword until it succeeds or max retries reached
    FOR    ${i}    IN RANGE    ${max_retries}
        ${status}=    Run Keyword And Return Status    ${keyword}    @{args}
        Run Keyword If    ${status}    Return From Keyword
        Run Keyword If    ${i} < ${max_retries - 1}    Sleep    ${delay}
    END
    Fail    Keyword '${keyword}' failed after ${max_retries} retries