*** Settings ***
Documentation    Authentication API keywords for WordMate application
Library          RequestsLibrary
Library          Collections
Library          String
Library          ../../libraries/WordmateAPI.py
Variables        ../../variables/common_variables.robot
Variables        ../../variables/api_endpoints.robot

*** Keywords ***
Setup API Test Suite
    [Documentation]    Setup for API test suite
    Log    Starting API test suite
    WordmateAPI.Set API Base URL    ${API_BASE_URL}

Teardown API Test Suite
    [Documentation]    Cleanup after API test suite
    Delete All Sessions
    Log    API test suite completed

API Session Is Created
    [Documentation]    Create API session for testing
    Create Session    ${API_SESSION}    ${API_BASE_URL}

User Logs In With Valid Credentials
    [Arguments]    ${username}    ${password}
    [Documentation]    Login user with valid credentials
    ${login_data}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

Login Response Should Be Successful
    [Documentation]    Verify login response is successful
    Should Be Equal As Strings    ${LOGIN_RESPONSE.status_code}    ${HTTP_OK}

JWT Token Should Be Present In Response
    [Documentation]    Verify JWT token is present in response
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Dictionary Should Contain Key    ${response_json}    token
    ${token}=    Get From Dictionary    ${response_json}    token
    Set Test Variable    ${JWT_TOKEN}    ${token}

Token Should Be Valid
    [Documentation]    Verify JWT token is valid
    ${is_valid}=    WordmateAPI.Validate JWT Token    ${JWT_TOKEN}
    Should Be True    ${is_valid}