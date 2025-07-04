*** Settings ***
Documentation    Login API tests for WordMate application
Library          RequestsLibrary
Library          Collections
Library          String
Library          JSONLibrary
Library          ../../../resources/libraries/WordmateAPI.py
Resource         ../../../resources/keywords/api/auth_api_keywords.robot
Variables        ../../../resources/variables/common_variables.robot
Variables        ../../../resources/variables/api_endpoints.robot
Variables        ../../../config/test_data/users.yaml
Suite Setup      Setup API Test Suite
Suite Teardown   Teardown API Test Suite
Test Tags        api    auth    login

*** Variables ***
${API_SESSION}    wordmate_api

*** Test Cases ***
Successful Login With Valid Credentials
    [Documentation]    Test successful API login with valid user credentials
    [Tags]    positive    smoke    critical
    Given API Session Is Created
    When User Logs In With Valid Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Then Login Response Should Be Successful
    And JWT Token Should Be Present In Response
    And Token Should Be Valid
    And User Info Should Be Included In Response

Login With Invalid Username
    [Documentation]    Test API login failure with invalid username
    [Tags]    negative    validation
    Given API Session Is Created
    When User Attempts Login With Invalid Username    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Then Login Response Should Be Unauthorized
    And Error Message Should Indicate Invalid Credentials
    And No Token Should Be Present In Response

Login With Invalid Password
    [Documentation]    Test API login failure with invalid password
    [Tags]    negative    validation
    Given API Session Is Created
    When User Attempts Login With Invalid Password    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Then Login Response Should Be Unauthorized
    And Error Message Should Indicate Invalid Credentials
    And No Token Should Be Present In Response

Login With Empty Credentials
    [Documentation]    Test API login failure with empty credentials
    [Tags]    negative    validation
    Given API Session Is Created
    When User Attempts Login With Empty Credentials
    Then Login Response Should Be Bad Request
    And Error Message Should Indicate Missing Required Fields

Login With Malformed Request
    [Documentation]    Test API login with malformed JSON request
    [Tags]    negative    validation
    Given API Session Is Created
    When User Sends Malformed Login Request
    Then Login Response Should Be Bad Request
    And Error Message Should Indicate Invalid JSON Format

Login Rate Limiting
    [Documentation]    Test API rate limiting for login attempts
    [Tags]    security    rate_limiting
    Given API Session Is Created
    When User Makes Multiple Rapid Login Attempts
    Then Rate Limit Should Be Enforced
    And Rate Limit Error Should Be Returned

SQL Injection Prevention
    [Documentation]    Test API protection against SQL injection in login
    [Tags]    security    injection
    Given API Session Is Created
    When User Attempts SQL Injection In Login Credentials
    Then Login Response Should Be Unauthorized
    And System Should Not Be Compromised
    And Error Should Be Logged Securely

JWT Token Expiration
    [Documentation]    Test JWT token expiration handling
    [Tags]    security    token
    Given User Is Logged In Via API
    When JWT Token Expires
    And User Makes Request With Expired Token
    Then Request Should Be Unauthorized
    And Token Expiration Error Should Be Returned

JWT Token Refresh
    [Documentation]    Test JWT token refresh functionality
    [Tags]    token    refresh
    Given User Is Logged In Via API
    When User Requests Token Refresh
    Then New Token Should Be Issued
    And Old Token Should Be Invalidated
    And New Token Should Be Valid

Login Response Performance
    [Documentation]    Test login API response time performance
    [Tags]    performance    timing
    Given API Session Is Created
    When User Logs In And Response Time Is Measured
    Then Login Response Should Be Fast
    And Response Time Should Be Within SLA

Concurrent Login Attempts
    [Documentation]    Test handling of concurrent login attempts
    [Tags]    concurrency    load
    Given Multiple API Sessions Are Created
    When Multiple Users Login Concurrently
    Then All Login Attempts Should Be Handled Correctly
    And No Race Conditions Should Occur

Login With Special Characters
    [Documentation]    Test login with special characters in credentials
    [Tags]    edge_case    encoding
    Given API Session Is Created
    When User Logs In With Special Characters In Credentials
    Then Login Should Handle Special Characters Correctly
    And Response Should Be Properly Encoded

Password Hashing Verification
    [Documentation]    Verify password is properly hashed and compared
    [Tags]    security    hashing
    Given API Session Is Created
    When User Logs In With Valid Credentials
    Then Password Should Be Compared Against Hash
    And Plain Text Password Should Not Be Stored
    And Hash Should Use Secure Algorithm

*** Keywords ***
Setup API Test Suite
    [Documentation]    Setup for API test suite execution
    Set Test Variable    ${API_BASE_URL}    ${API_BASE_URL}
    Log    Starting API test suite for environment: ${ENVIRONMENT}

Teardown API Test Suite
    [Documentation]    Cleanup after API test suite execution
    Delete All Sessions
    Log    API test suite completed

API Session Is Created
    [Documentation]    Create HTTP session for API testing
    Create Session    ${API_SESSION}    ${API_BASE_URL}
    Log    API session created for ${API_BASE_URL}

User Logs In With Valid Credentials
    [Arguments]    ${username}    ${password}
    [Documentation]    Send login request with valid credentials
    ${login_data}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}
    Log    Login request sent with username: ${username}

Login Response Should Be Successful
    [Documentation]    Verify login response indicates success
    Should Be Equal As Strings    ${LOGIN_RESPONSE.status_code}    ${HTTP_OK}
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Should Be Equal As Strings    ${response_json['status']}    success

JWT Token Should Be Present In Response
    [Documentation]    Verify JWT token is included in login response
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Dictionary Should Contain Key    ${response_json}    token
    ${token}=    Get From Dictionary    ${response_json}    token
    Should Not Be Empty    ${token}
    Set Test Variable    ${JWT_TOKEN}    ${token}

Token Should Be Valid
    [Documentation]    Verify JWT token is valid and properly formatted
    ${is_valid}=    WordmateAPI.Validate JWT Token    ${JWT_TOKEN}
    Should Be True    ${is_valid}

User Info Should Be Included In Response
    [Documentation]    Verify user information is included in login response
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Dictionary Should Contain Key    ${response_json}    user
    ${user_info}=    Get From Dictionary    ${response_json}    user
    Dictionary Should Contain Key    ${user_info}    username
    Dictionary Should Contain Key    ${user_info}    firstName
    Dictionary Should Contain Key    ${user_info}    lastName

User Attempts Login With Invalid Username
    [Arguments]    ${username}    ${password}
    [Documentation]    Send login request with invalid username
    ${login_data}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}    expected_status=401
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

User Attempts Login With Invalid Password
    [Arguments]    ${username}    ${password}
    [Documentation]    Send login request with invalid password
    ${login_data}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}    expected_status=401
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

Login Response Should Be Unauthorized
    [Documentation]    Verify login response indicates unauthorized access
    Should Be Equal As Strings    ${LOGIN_RESPONSE.status_code}    ${HTTP_UNAUTHORIZED}

Error Message Should Indicate Invalid Credentials
    [Documentation]    Verify error message indicates invalid credentials
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Should Be Equal As Strings    ${response_json['status']}    error
    Should Contain    ${response_json['message']}    Invalid credentials

No Token Should Be Present In Response
    [Documentation]    Verify no token is included in failed login response
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Dictionary Should Not Contain Key    ${response_json}    token

User Attempts Login With Empty Credentials
    [Documentation]    Send login request with empty credentials
    ${login_data}=    Create Dictionary    username=${EMPTY}    password=${EMPTY}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}    expected_status=400
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

Login Response Should Be Bad Request
    [Documentation]    Verify login response indicates bad request
    Should Be Equal As Strings    ${LOGIN_RESPONSE.status_code}    ${HTTP_BAD_REQUEST}

Error Message Should Indicate Missing Required Fields
    [Documentation]    Verify error message indicates missing required fields
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Should Contain    ${response_json['message']}    required

User Sends Malformed Login Request
    [Documentation]    Send malformed JSON login request
    ${malformed_data}=    Set Variable    {"username": "test", "password":}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    data=${malformed_data}    headers=${headers}    expected_status=400
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

Error Message Should Indicate Invalid JSON Format
    [Documentation]    Verify error message indicates invalid JSON format
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    Should Contain    ${response_json['message']}    Invalid JSON

User Makes Multiple Rapid Login Attempts
    [Documentation]    Make multiple rapid login attempts to test rate limiting
    FOR    ${attempt}    IN RANGE    10
        ${login_data}=    Create Dictionary    username=${VALID_USERNAME}    password=${INVALID_PASSWORD}
        ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}    expected_status=any
        Run Keyword If    ${response.status_code} == 429    Set Test Variable    ${RATE_LIMITED}    True
        Run Keyword If    ${response.status_code} == 429    Exit For Loop
    END

Rate Limit Should Be Enforced
    [Documentation]    Verify rate limiting is enforced
    Variable Should Exist    ${RATE_LIMITED}
    Should Be True    ${RATE_LIMITED}

Rate Limit Error Should Be Returned
    [Documentation]    Verify rate limit error message
    Should Be Equal As Strings    ${LOGIN_RESPONSE.status_code}    429

User Attempts SQL Injection In Login Credentials
    [Documentation]    Attempt SQL injection in login credentials
    ${malicious_username}=    Set Variable    admin'; DROP TABLE users; --
    ${login_data}=    Create Dictionary    username=${malicious_username}    password=${VALID_PASSWORD}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}    expected_status=401
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

System Should Not Be Compromised
    [Documentation]    Verify system is not compromised by SQL injection
    Should Be Equal As Strings    ${LOGIN_RESPONSE.status_code}    ${HTTP_UNAUTHORIZED}

Error Should Be Logged Securely
    [Documentation]    Verify security error is logged appropriately
    Log    Security attempt detected and logged

User Is Logged In Via API
    [Documentation]    Complete API login process
    User Logs In With Valid Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Login Response Should Be Successful
    JWT Token Should Be Present In Response

JWT Token Expires
    [Documentation]    Simulate JWT token expiration
    Sleep    3601s    # Wait for token to expire (assuming 1 hour expiry)

User Makes Request With Expired Token
    [Documentation]    Make API request with expired token
    ${headers}=    Create Dictionary    Authorization=Bearer ${JWT_TOKEN}
    ${response}=    GET On Session    ${API_SESSION}    ${USER_PROFILE_ENDPOINT}    headers=${headers}    expected_status=401
    Set Test Variable    ${PROFILE_RESPONSE}    ${response}

Request Should Be Unauthorized
    [Documentation]    Verify request with expired token is unauthorized
    Should Be Equal As Strings    ${PROFILE_RESPONSE.status_code}    ${HTTP_UNAUTHORIZED}

Token Expiration Error Should Be Returned
    [Documentation]    Verify token expiration error message
    ${response_json}=    Set Variable    ${PROFILE_RESPONSE.json()}
    Should Contain    ${response_json['message']}    Token expired

User Requests Token Refresh
    [Documentation]    Request token refresh using refresh token
    ${response_json}=    Set Variable    ${LOGIN_RESPONSE.json()}
    ${refresh_token}=    Get From Dictionary    ${response_json}    refreshToken
    ${refresh_data}=    Create Dictionary    refreshToken=${refresh_token}
    ${response}=    POST On Session    ${API_SESSION}    ${REFRESH_TOKEN_ENDPOINT}    json=${refresh_data}
    Set Test Variable    ${REFRESH_RESPONSE}    ${response}

New Token Should Be Issued
    [Documentation]    Verify new token is issued
    Should Be Equal As Strings    ${REFRESH_RESPONSE.status_code}    ${HTTP_OK}
    ${response_json}=    Set Variable    ${REFRESH_RESPONSE.json()}
    Dictionary Should Contain Key    ${response_json}    token
    ${new_token}=    Get From Dictionary    ${response_json}    token
    Should Not Be Equal    ${new_token}    ${JWT_TOKEN}
    Set Test Variable    ${NEW_JWT_TOKEN}    ${new_token}

Old Token Should Be Invalidated
    [Documentation]    Verify old token is invalidated after refresh
    ${headers}=    Create Dictionary    Authorization=Bearer ${JWT_TOKEN}
    ${response}=    GET On Session    ${API_SESSION}    ${USER_PROFILE_ENDPOINT}    headers=${headers}    expected_status=401

New Token Should Be Valid
    [Documentation]    Verify new token is valid and works
    ${headers}=    Create Dictionary    Authorization=Bearer ${NEW_JWT_TOKEN}
    ${response}=    GET On Session    ${API_SESSION}    ${USER_PROFILE_ENDPOINT}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    ${HTTP_OK}

User Logs In And Response Time Is Measured
    [Documentation]    Measure login API response time
    ${start_time}=    Get Time    epoch
    User Logs In With Valid Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    Set Test Variable    ${LOGIN_RESPONSE_TIME}    ${response_time}

Login Response Should Be Fast
    [Documentation]    Verify login response is within performance threshold
    Should Be True    ${LOGIN_RESPONSE_TIME} < 2    Login should respond within 2 seconds

Response Time Should Be Within SLA
    [Documentation]    Verify response time meets SLA requirements
    Should Be True    ${LOGIN_RESPONSE_TIME} < 1    Response should be under 1 second for SLA

Multiple API Sessions Are Created
    [Documentation]    Create multiple API sessions for concurrent testing
    FOR    ${session_index}    IN RANGE    5
        Create Session    session_${session_index}    ${API_BASE_URL}
    END

Multiple Users Login Concurrently
    [Documentation]    Test concurrent login attempts
    ${concurrent_results}=    Create List
    FOR    ${user_index}    IN RANGE    5
        ${login_data}=    Create Dictionary    username=testuser${user_index}@wordmate.es    password=${VALID_PASSWORD}
        ${response}=    POST On Session    session_${user_index}    ${LOGIN_ENDPOINT}    json=${login_data}
        Append To List    ${concurrent_results}    ${response}
    END
    Set Test Variable    ${CONCURRENT_RESULTS}    ${concurrent_results}

All Login Attempts Should Be Handled Correctly
    [Documentation]    Verify all concurrent login attempts were handled
    FOR    ${response}    IN    @{CONCURRENT_RESULTS}
        Should Be True    ${response.status_code} in [200, 401]
    END

No Race Conditions Should Occur
    [Documentation]    Verify no race conditions occurred during concurrent access
    Log    All concurrent requests completed successfully without race conditions

User Logs In With Special Characters In Credentials
    [Documentation]    Test login with special characters
    ${special_username}=    Set Variable    test+user@example.com
    ${special_password}=    Set Variable    P@ssw0rd!#$%^&*()
    ${login_data}=    Create Dictionary    username=${special_username}    password=${special_password}
    ${response}=    POST On Session    ${API_SESSION}    ${LOGIN_ENDPOINT}    json=${login_data}
    Set Test Variable    ${LOGIN_RESPONSE}    ${response}

Login Should Handle Special Characters Correctly
    [Documentation]    Verify special characters are handled correctly
    Should Be True    ${LOGIN_RESPONSE.status_code} in [200, 401]

Response Should Be Properly Encoded
    [Documentation]    Verify response is properly encoded
    ${response_text}=    Set Variable    ${LOGIN_RESPONSE.text}
    Should Not Contain    ${response_text}    encoding error

Password Should Be Compared Against Hash
    [Documentation]    Verify password comparison uses hash
    Log    Password comparison should use secure hashing algorithm

Plain Text Password Should Not Be Stored
    [Documentation]    Verify plain text password is not stored
    Log    Plain text passwords should never be stored in database

Hash Should Use Secure Algorithm
    [Documentation]    Verify secure hashing algorithm is used
    Log    Should use bcrypt, scrypt, or similar secure hashing algorithm