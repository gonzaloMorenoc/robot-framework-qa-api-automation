*** Settings ***
Documentation    Common navigation keywords for WordMate application
Library          SeleniumLibrary
Library          Collections
Variables        ../../variables/common_variables.robot
Resource         ../../locators/vocabulary_page.robot
Resource         ../../locators/grammar_page.robot
Resource         ../../locators/profile_page.robot

*** Variables ***
${NAVIGATION_TIMEOUT}    10s
${PAGE_LOAD_TIMEOUT}     30s

*** Keywords ***
Navigate To Home Page
    [Documentation]    Navigate to WordMate home page
    [Tags]    navigation
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    ${HOME_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Title Should Be    WordMate - Learn English Vocabulary and Grammar

Navigate To Vocabulary Page
    [Documentation]    Navigate to vocabulary section
    [Tags]    navigation    vocabulary
    Click Element    ${VOCABULARY_MENU_LINK}
    Wait Until Page Contains Element    ${VOCABULARY_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Location Should Contain    vocabulary

Navigate To Grammar Page
    [Documentation]    Navigate to grammar section
    [Tags]    navigation    grammar
    Click Element    ${GRAMMAR_MENU_LINK}
    Wait Until Page Contains Element    ${GRAMMAR_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Location Should Contain    grammar

Navigate To Profile Page
    [Documentation]    Navigate to user profile page
    [Tags]    navigation    profile
    Click Element    ${PROFILE_MENU_LINK}
    Wait Until Page Contains Element    ${PROFILE_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Location Should Contain    profile

Navigate To Custom Vocabulary Page
    [Documentation]    Navigate to custom vocabulary management page
    [Tags]    navigation    vocabulary
    Click Element    ${CUSTOM_VOCAB_MENU_LINK}
    Wait Until Page Contains Element    ${CUSTOM_VOCAB_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Location Should Contain    custom-vocab

Navigate To My Words Page
    [Documentation]    Navigate to my words collection page
    [Tags]    navigation    vocabulary
    Click Element    ${MY_WORDS_MENU_LINK}
    Wait Until Page Contains Element    ${MY_WORDS_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Location Should Contain    my-words

Navigate To Game Session
    [Documentation]    Navigate to interactive game session
    [Tags]    navigation    game
    Click Element    ${GAME_SESSION_MENU_LINK}
    Wait Until Page Contains Element    ${GAME_SESSION_PAGE_INDICATOR}    timeout=${PAGE_LOAD_TIMEOUT}
    Location Should Contain    game-session

Go Back To Previous Page
    [Documentation]    Navigate back to previous page
    [Tags]    navigation
    Go Back
    Sleep    2s

Refresh Current Page
    [Documentation]    Refresh the current page
    [Tags]    navigation
    Reload Page
    Sleep    2s

Verify Current Page
    [Documentation]    Verify user is on the expected page
    [Arguments]    ${expected_page}
    [Tags]    verification    navigation
    ${current_url}=    Get Location
    Should Contain    ${current_url}    ${expected_page}

Verify Page Title
    [Documentation]    Verify the page title contains expected text
    [Arguments]    ${expected_title}
    [Tags]    verification    navigation
    Title Should Contain    ${expected_title}

Wait For Page To Load
    [Documentation]    Wait for page to completely load
    [Tags]    navigation    wait
    Wait Until Element Is Visible    body    timeout=${PAGE_LOAD_TIMEOUT}
    Execute Javascript    return document.readyState === 'complete'

Check Responsive Navigation
    [Documentation]    Check navigation works on mobile/tablet view
    [Tags]    responsive    navigation
    Set Window Size    768    1024
    Wait Until Element Is Visible    ${MOBILE_MENU_TOGGLE}    timeout=${NAVIGATION_TIMEOUT}
    Click Element    ${MOBILE_MENU_TOGGLE}
    Wait Until Element Is Visible    ${MOBILE_NAVIGATION_MENU}    timeout=${NAVIGATION_TIMEOUT}

Verify All Menu Links Are Present
    [Documentation]    Verify all main navigation links are present and visible
    [Tags]    verification    navigation
    Element Should Be Visible    ${HOME_MENU_LINK}
    Element Should Be Visible    ${VOCABULARY_MENU_LINK}
    Element Should Be Visible    ${GRAMMAR_MENU_LINK}
    Element Should Be Visible    ${PROFILE_MENU_LINK}
    Element Should Be Visible    ${GAME_SESSION_MENU_LINK}

Check External Links
    [Documentation]    Verify external links open in new tabs
    [Arguments]    ${link_locator}
    [Tags]    navigation    external
    ${link_target}=    Get Element Attribute    ${link_locator}    target
    Should Be Equal    ${link_target}    _blank

Navigate Using Breadcrumbs
    [Documentation]    Navigate using breadcrumb navigation
    [Arguments]    ${breadcrumb_item}
    [Tags]    navigation    breadcrumbs
    Wait Until Element Is Visible    ${BREADCRUMB_CONTAINER}    timeout=${NAVIGATION_TIMEOUT}
    Click Element    xpath://nav[@class='breadcrumb']//a[contains(text(),'${breadcrumb_item}')]

Verify Breadcrumb Path
    [Documentation]    Verify breadcrumb shows correct navigation path
    [Arguments]    @{expected_path}
    [Tags]    verification    breadcrumbs
    ${breadcrumb_items}=    Get WebElements    ${BREADCRUMB_ITEMS}
    ${actual_count}=    Get Length    ${breadcrumb_items}
    ${expected_count}=    Get Length    ${expected_path}
    Should Be Equal As Numbers    ${actual_count}    ${expected_count}
    
    FOR    ${index}    IN RANGE    ${expected_count}
        ${expected_text}=    Get From List    ${expected_path}    ${index}
        ${actual_text}=    Get Text    ${breadcrumb_items}[${index}]
        Should Contain    ${actual_text}    ${expected_text}
    END

Handle Navigation Errors
    [Documentation]    Handle common navigation errors
    [Tags]    error_handling    navigation
    ${page_source}=    Get Source
    Run Keyword If    '404' in '''${page_source}'''    Log    Page not found error detected
    Run Keyword If    '500' in '''${page_source}'''    Log    Server error detected
    Run Keyword If    'timeout' in '''${page_source}'''    Log    Timeout error detected

Check Page Loading Performance
    [Documentation]    Check page loading performance metrics
    [Tags]    performance    navigation
    ${start_time}=    Get Time    epoch
    Go To    ${BASE_URL}
    Wait For Page To Load
    ${end_time}=    Get Time    epoch
    ${load_time}=    Evaluate    ${end_time} - ${start_time}
    Should Be True    ${load_time} < 5    Page should load within 5 seconds
    Log    Page loaded in ${load_time} seconds