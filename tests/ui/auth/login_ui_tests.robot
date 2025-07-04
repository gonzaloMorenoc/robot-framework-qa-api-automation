*** Settings ***
Documentation    Login UI tests for WordMate application
Library          SeleniumLibrary
Library          Collections
Library          String
Resource         ../../../resources/keywords/common/authentication_keywords.robot
Resource         ../../../resources/keywords/common/navigation_keywords.robot
Resource         ../../../resources/keywords/common/ui_keywords.robot
Variables        ../../../resources/variables/common_variables.robot
Variables        ../../../config/test_data/users.yaml
Test Setup       Setup Browser For Testing
Test Teardown    Teardown Browser After Testing
Test Tags        ui    auth    login

*** Variables ***
${TEST_BROWSER}    ${BROWSER}

*** Test Cases ***
Valid User Login
    [Documentation]    Test successful login with valid credentials
    [Tags]    positive    smoke    critical
    Given User Is On Login Page
    When User Enters Valid Credentials
    Then User Should Be Successfully Logged In
    And User Should See Welcome Message
    And User Profile Should Be Accessible

Invalid Username Login
    [Documentation]    Test login failure with invalid username
    [Tags]    negative    validation
    Given User Is On Login Page
    When User Enters Invalid Username    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Then User Should See Invalid Credentials Error
    And User Should Remain On Login Page

Invalid Password Login
    [Documentation]    Test login failure with invalid password
    [Tags]    negative    validation
    Given User Is On Login Page
    When User Enters Invalid Password    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Then User Should See Invalid Credentials Error
    And User Should Remain On Login Page

Empty Credentials Login
    [Documentation]    Test login failure with empty credentials
    [Tags]    negative    validation
    Given User Is On Login Page
    When User Submits Empty Login Form
    Then User Should See Required Field Errors
    And Login Button Should Remain Disabled

Login Form Validation
    [Documentation]    Test login form field validation
    [Tags]    validation    form
    Given User Is On Login Page
    When User Enters Invalid Email Format    invalid-email
    Then User Should See Email Format Error
    When User Enters Short Password    123
    Then User Should See Password Length Error

Login With Special Characters
    [Documentation]    Test login with special characters in credentials
    [Tags]    edge_case    validation
    Given User Is On Login Page
    When User Enters Credentials With Special Characters
    Then System Should Handle Special Characters Correctly

Multiple Failed Login Attempts
    [Documentation]    Test account lockout after multiple failed attempts
    [Tags]    security    negative
    Given User Is On Login Page
    When User Attempts Login Multiple Times With Invalid Credentials
    Then User Account Should Be Temporarily Locked
    And User Should See Account Lockout Message

Remember Me Functionality
    [Documentation]    Test remember me checkbox functionality
    [Tags]    functionality    session
    Given User Is On Login Page
    When User Checks Remember Me Option
    And User Logs In Successfully
    And User Closes Browser
    And User Reopens Browser
    Then User Should Still Be Logged In

Password Visibility Toggle
    [Documentation]    Test password visibility toggle button
    [Tags]    usability    form
    Given User Is On Login Page
    When User Clicks Password Visibility Toggle
    Then Password Field Should Show Plain Text
    When User Clicks Password Visibility Toggle Again
    Then Password Field Should Hide Text

Login Page Responsive Design
    [Documentation]    Test login page responsive design on different screen sizes
    [Tags]    responsive    ui
    Given User Is On Login Page
    When User Views Page On Mobile Device
    Then Login Form Should Be Mobile Friendly
    When User Views Page On Tablet Device
    Then Login Form Should Be Tablet Friendly

Social Login Integration
    [Documentation]    Test social login button presence and functionality
    [Tags]    social    integration
    Given User Is On Login Page
    Then Google Login Button Should Be Present
    And Facebook Login Button Should Be Present
    When User Clicks Google Login Button
    Then User Should Be Redirected To Google Auth

Login Performance Test
    [Documentation]    Test login page loading and form submission performance
    [Tags]    performance    timing
    Given User Measures Page Load Time
    When User Navigates To Login Page
    Then Page Should Load Within Acceptable Time
    When User Submits Login Form
    Then Form Submission Should Complete Within Acceptable Time

*** Keywords ***
Setup Browser For Testing
    [Documentation]    Setup browser configuration for login tests
    Open Browser    ${BASE_URL}    ${TEST_BROWSER}
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}

Teardown Browser After Testing
    [Documentation]    Clean up after test execution
    Clear Authentication Data
    Close All Browsers

User Is On Login Page
    [Documentation]    Navigate to login page and verify elements
    Navigate To Home Page
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=${EXPLICIT_WAIT}
    Page Should Contain Element    ${LOGIN_PASSWORD_INPUT}
    Page Should Contain Element    ${LOGIN_SUBMIT_BUTTON}

User Enters Valid Credentials
    [Documentation]    Enter valid username and password
    Input Text    ${LOGIN_USERNAME_INPUT}    ${VALID_USERNAME}
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${VALID_PASSWORD}
    Click Button    ${LOGIN_SUBMIT_BUTTON}

User Should Be Successfully Logged In
    [Documentation]    Verify successful login
    Verify User Is Logged In
    Location Should Contain    ${BASE_URL}

User Should See Welcome Message
    [Documentation]    Verify welcome message is displayed
    Wait Until Page Contains    ${LOGIN_SUCCESS_MESSAGE}    timeout=${EXPLICIT_WAIT}

User Profile Should Be Accessible
    [Documentation]    Verify user can access profile
    Navigate To Profile Page
    Page Should Contain Element    ${PROFILE_PAGE_INDICATOR}

User Enters Invalid Username
    [Arguments]    ${username}    ${password}
    [Documentation]    Enter invalid username with valid password
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${password}
    Click Button    ${LOGIN_SUBMIT_BUTTON}

User Enters Invalid Password
    [Arguments]    ${username}    ${password}
    [Documentation]    Enter valid username with invalid password
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${password}
    Click Button    ${LOGIN_SUBMIT_BUTTON}

User Should See Invalid Credentials Error
    [Documentation]    Verify invalid credentials error message
    Wait Until Page Contains    ${INVALID_CREDENTIALS_MESSAGE}    timeout=${EXPLICIT_WAIT}

User Should Remain On Login Page
    [Documentation]    Verify user is still on login page
    Element Should Be Visible    ${LOGIN_USERNAME_INPUT}
    Element Should Be Visible    ${LOGIN_PASSWORD_INPUT}

User Submits Empty Login Form
    [Documentation]    Submit login form without entering credentials
    Click Button    ${LOGIN_SUBMIT_BUTTON}

User Should See Required Field Errors
    [Documentation]    Verify required field validation errors
    Wait Until Element Is Visible    css:.field-error    timeout=${EXPLICIT_WAIT}

Login Button Should Remain Disabled
    [Documentation]    Verify login button remains disabled for invalid input
    Element Should Be Disabled    ${LOGIN_SUBMIT_BUTTON}

User Enters Invalid Email Format
    [Arguments]    ${invalid_email}
    [Documentation]    Enter invalid email format
    Input Text    ${LOGIN_USERNAME_INPUT}    ${invalid_email}
    Click Element    ${LOGIN_PASSWORD_INPUT}

User Should See Email Format Error
    [Documentation]    Verify email format validation error
    Wait Until Element Is Visible    css:.email-error    timeout=${EXPLICIT_WAIT}

User Enters Short Password
    [Arguments]    ${short_password}
    [Documentation]    Enter password shorter than minimum length
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${short_password}
    Click Element    ${LOGIN_USERNAME_INPUT}

User Should See Password Length Error
    [Documentation]    Verify password length validation error
    Wait Until Element Is Visible    css:.password-error    timeout=${EXPLICIT_WAIT}

User Enters Credentials With Special Characters
    [Documentation]    Test login with special characters
    Input Text    ${LOGIN_USERNAME_INPUT}    test+user@example.com
    Input Password    ${LOGIN_PASSWORD_INPUT}    P@ssw0rd!#$
    Click Button    ${LOGIN_SUBMIT_BUTTON}

System Should Handle Special Characters Correctly
    [Documentation]    Verify system properly handles special characters
    Page Should Not Contain    Error
    Page Should Not Contain    Invalid characters

User Attempts Login Multiple Times With Invalid Credentials
    [Documentation]    Attempt login multiple times with wrong credentials
    FOR    ${attempt}    IN RANGE    6
        Input Text    ${LOGIN_USERNAME_INPUT}    ${INVALID_USERNAME}
        Input Password    ${LOGIN_PASSWORD_INPUT}    ${INVALID_PASSWORD}
        Click Button    ${LOGIN_SUBMIT_BUTTON}
        Sleep    1s
    END

User Account Should Be Temporarily Locked
    [Documentation]    Verify account lockout mechanism
    Wait Until Page Contains    Account temporarily locked    timeout=${EXPLICIT_WAIT}

User Should See Account Lockout Message
    [Documentation]    Verify lockout message is displayed
    Page Should Contain    too many failed attempts

User Checks Remember Me Option
    [Documentation]    Select remember me checkbox
    Select Checkbox    ${REMEMBER_ME_CHECKBOX}

User Logs In Successfully
    [Documentation]    Complete successful login process
    User Enters Valid Credentials
    User Should Be Successfully Logged In

User Closes Browser
    [Documentation]    Close current browser session
    Close Browser

User Reopens Browser
    [Documentation]    Open new browser session
    Open Browser    ${BASE_URL}    ${TEST_BROWSER}

User Should Still Be Logged In
    [Documentation]    Verify user session is maintained
    Wait Until Element Is Visible    ${USER_PROFILE_INDICATOR}    timeout=${EXPLICIT_WAIT}

User Clicks Password Visibility Toggle
    [Documentation]    Click password visibility toggle button
    Click Element    ${PASSWORD_VISIBILITY_TOGGLE}

Password Field Should Show Plain Text
    [Documentation]    Verify password is visible as plain text
    ${input_type}=    Get Element Attribute    ${LOGIN_PASSWORD_INPUT}    type
    Should Be Equal    ${input_type}    text

User Clicks Password Visibility Toggle Again
    [Documentation]    Click password visibility toggle button again
    Click Element    ${PASSWORD_VISIBILITY_TOGGLE}

Password Field Should Hide Text
    [Documentation]    Verify password is hidden
    ${input_type}=    Get Element Attribute    ${LOGIN_PASSWORD_INPUT}    type
    Should Be Equal    ${input_type}    password

User Views Page On Mobile Device
    [Documentation]    Set viewport to mobile device size
    Set Window Size    375    667

Login Form Should Be Mobile Friendly
    [Documentation]    Verify login form works on mobile
    Element Should Be Visible    ${LOGIN_USERNAME_INPUT}
    Element Should Be Visible    ${LOGIN_PASSWORD_INPUT}
    Element Should Be Visible    ${LOGIN_SUBMIT_BUTTON}

User Views Page On Tablet Device
    [Documentation]    Set viewport to tablet device size
    Set Window Size    768    1024

Login Form Should Be Tablet Friendly
    [Documentation]    Verify login form works on tablet
    Element Should Be Visible    ${LOGIN_USERNAME_INPUT}
    Element Should Be Visible    ${LOGIN_PASSWORD_INPUT}
    Element Should Be Visible    ${LOGIN_SUBMIT_BUTTON}

Google Login Button Should Be Present
    [Documentation]    Verify Google login button exists
    Element Should Be Visible    ${GOOGLE_LOGIN_BUTTON}

Facebook Login Button Should Be Present
    [Documentation]    Verify Facebook login button exists
    Element Should Be Visible    ${FACEBOOK_LOGIN_BUTTON}

User Clicks Google Login Button
    [Documentation]    Click Google login button
    Click Element    ${GOOGLE_LOGIN_BUTTON}

User Should Be Redirected To Google Auth
    [Documentation]    Verify redirect to Google authentication
    Wait Until Location Contains    google.com    timeout=${EXPLICIT_WAIT}

User Measures Page Load Time
    [Documentation]    Start measuring page load performance
    ${start_time}=    Get Time    epoch
    Set Test Variable    ${START_TIME}    ${start_time}

User Navigates To Login Page
    [Documentation]    Navigate to login page
    Go To    ${BASE_URL}

Page Should Load Within Acceptable Time
    [Documentation]    Verify page loads within performance threshold
    ${end_time}=    Get Time    epoch
    ${load_time}=    Evaluate    ${end_time} - ${START_TIME}
    Should Be True    ${load_time} < 3    Page should load within 3 seconds

User Submits Login Form
    [Documentation]    Submit login form and measure performance
    ${start_time}=    Get Time    epoch
    User Enters Valid Credentials
    ${end_time}=    Get Time    epoch
    Set Test Variable    ${FORM_SUBMIT_TIME}    ${end_time} - ${start_time}

Form Submission Should Complete Within Acceptable Time
    [Documentation]    Verify form submission completes quickly
    Should Be True    ${FORM_SUBMIT_TIME} < 2    Form submission should complete within 2 seconds