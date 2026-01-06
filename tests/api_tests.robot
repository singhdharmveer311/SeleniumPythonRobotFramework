*** Settings ***
Documentation       API testing examples using Robot Framework

Library             RequestsLibrary
Library             Collections
Library             JSONLibrary



*** Variables ***
${API_BASE_URL}     https://jsonplaceholder.typicode.com


*** Test Cases ***
GET Request Test
    [Documentation]    Test GET request to fetch user data
    [Tags]    api    get
    Create Session    jsonplaceholder    ${API_BASE_URL}
    ${response}=    GET On Session    jsonplaceholder    /users/1
    Should Be Equal As Strings    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json_response['name']}    Leanne Graham

POST Request Test
    [Documentation]    Test POST request to create new post
    [Tags]    api    post
    Create Session    jsonplaceholder    ${API_BASE_URL}
    ${post_data}=    Create Dictionary    title=Test Post    body=This is a test post    userId=1
    ${response}=    POST On Session    jsonplaceholder    /posts    json=${post_data}
    Should Be Equal As Strings    ${response.status_code}    201
    ${json_response}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json_response['title']}    Test Post
