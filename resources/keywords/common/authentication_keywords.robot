*** Settings ***
Documentation    Common authentication keywords for WordMate application
Library          SeleniumLibrary
Library          RequestsLibrary
Library          Collections
Library          String
Library          ../../libraries/WordmateAPI.py
Variables        ../../variables/common_variables.robot
Variables        ../../variables/api_endpoints.robot
Resource         ../locators/login_page.robot

*** Variables ***
${LOGIN_SUCCESS_MESSAGE}    Welcome back
${LOGOUT_SUCCESS_MESSAGE}   You have been logged out
${INVALID_CREDENTIALS_MESSAGE}    Invalid credentials

*** Keywords ***
Login Via UI
    [Documentation]    Login to WordMate application via web interface
    [Arguments]    ${username}    ${password}
    [Tags]    ui    auth
    Go To    ${BASE_URL}
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=${EXPLICIT_WAIT}
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${password}
    Click Button    ${LOGIN_SUBMIT_BUTTON}
    Wait Until Page Contains    ${LOGIN_SUCCESS_MESSAGE}    timeout=${EXPLICIT_WAIT}
    ${current_url}=    Get Location
    Should Contain    ${current_url}    ${BASE_URL}

Login Via API
    [Documentation]    Login to WordMate application via API
    [Arguments]    ${username}    ${password}
    [Tags]    api    auth
    Create Session    wordmate    ${API_BASE_URL}
    ${login_data}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    wordmate    ${LOGIN_ENDPOINT}    json=${login_data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${token}=    Get From Dictionary    ${response.json()}    token
    Set Global Variable    ${AUTH_TOKEN}    ${token}
    [Return]    ${token}

Logout Via UI
    [Documentation]    Logout from WordMate application via web interface
    [Tags]    ui    auth
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=${EXPLICIT_WAIT}
    Click Element    ${LOGOUT_BUTTON}
    Wait Until Page Contains    ${LOGOUT_SUCCESS_MESSAGE}    timeout=${EXPLICIT_WAIT}
    Location Should Be    ${BASE_URL}

Register New User Via API
    [Documentation]    Register a new user via API
    [Arguments]    ${username}    ${password}    ${first_name}    ${last_name}
    [Tags]    api    auth    registration
    Create Session    wordmate    ${API_BASE_URL}
    ${registration_data}=    Create Dictionary    
    ...    username=${username}    
    ...    password=${password}
    ...    firstName=${first_name}
    ...    lastName=${last_name}
    ${response}=    POST On Session    wordmate    ${REGISTER_ENDPOINT}    json=${registration_data}
    Should Be Equal As Strings    ${response.status_code}    201
    ${user_id}=    Get From Dictionary    ${response.json()}    userId
    [Return]    ${user_id}

Verify User Is Logged In
    [Documentation]    Verify that user is successfully logged in
    [Tags]    verification
    Wait Until Element Is Visible    ${USER_PROFILE_INDICATOR}    timeout=${EXPLICIT_WAIT}
    Element Should Be Visible    ${LOGOUT_BUTTON}

Verify User Is Logged Out
    [Documentation]    Verify that user is successfully logged out
    [Tags]    verification
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=${EXPLICIT_WAIT}
    Element Should Be Visible    ${LOGIN_SUBMIT_BUTTON}

Attempt Invalid Login
    [Documentation]    Attempt login with invalid credentials
    [Arguments]    ${username}    ${password}
    [Tags]    negative    auth
    Go To    ${BASE_URL}
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=${EXPLICIT_WAIT}
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${password}
    Click Button    ${LOGIN_SUBMIT_BUTTON}
    Wait Until Page Contains    ${INVALID_CREDENTIALS_MESSAGE}    timeout=${EXPLICIT_WAIT}

Setup Authentication Headers
    [Documentation]    Setup authentication headers for API requests
    [Arguments]    ${token}
    [Tags]    api    setup
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    Set Global Variable    ${AUTH_HEADERS}    ${headers}
    [Return]    ${headers}

Verify JWT Token
    [Documentation]    Verify JWT token is valid and not expired
    [Arguments]    ${token}
    [Tags]    api    verification
    Create Session    wordmate    ${API_BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    wordmate    ${VERIFY_TOKEN_ENDPOINT}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200

Refresh JWT Token
    [Documentation]    Refresh JWT token using refresh token
    [Arguments]    ${refresh_token}
    [Tags]    api    auth
    Create Session    wordmate    ${API_BASE_URL}
    ${refresh_data}=    Create Dictionary    refreshToken=${refresh_token}
    ${response}=    POST On Session    wordmate    ${REFRESH_TOKEN_ENDPOINT}    json=${refresh_data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${new_token}=    Get From Dictionary    ${response.json()}    token
    Set Global Variable    ${AUTH_TOKEN}    ${new_token}
    [Return]    ${new_token}

Social Login Setup
    [Documentation]    Setup for social login testing
    [Arguments]    ${provider}    ${redirect_url}
    [Tags]    social    auth    setup
    ${oauth_url}=    WordmateAPI.Generate OAuth URL    ${provider}    ${redirect_url}
    [Return]    ${oauth_url}

Clear Authentication Data
    [Documentation]    Clear all authentication data and sessions
    [Tags]    cleanup    auth
    Delete All Sessions
    ${AUTH_TOKEN}=    Set Variable    ${EMPTY}
    ${AUTH_HEADERS}=    Set Variable    ${EMPTY}
    Execute Javascript    localStorage.clear()
    Execute Javascript    sessionStorage.clear()
    Delete All Cookies