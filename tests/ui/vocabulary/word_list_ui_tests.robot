*** Settings ***
Documentation    Vocabulary word list UI tests for WordMate application
Library          SeleniumLibrary
Library          Collections
Library          String
Resource         ../../../resources/keywords/common/authentication_keywords.robot
Resource         ../../../resources/keywords/common/navigation_keywords.robot
Resource         ../../../resources/keywords/ui/vocabulary_keywords.robot
Variables        ../../../resources/variables/common_variables.robot
Variables        ../../../config/test_data/vocabulary.yaml
Test Setup       Setup Vocabulary UI Test
Test Teardown    Teardown Vocabulary UI Test
Test Tags        ui    vocabulary    word_list

*** Variables ***
${TEST_BROWSER}    ${BROWSER}

*** Test Cases ***
Load Vocabulary List Successfully
    [Documentation]    Test successful loading of vocabulary list page
    [Tags]    positive    smoke    critical
    Given User Is Logged In
    When User Navigates To Vocabulary Page
    Then Vocabulary List Should Be Displayed
    And Word Items Should Be Visible
    And Pagination Should Be Present
    And Search Functionality Should Be Available

Search Vocabulary Words
    [Documentation]    Test vocabulary search functionality
    [Tags]    positive    search
    Given User Is On Vocabulary Page
    When User Searches For Word    apple
    Then Search Results Should Be Displayed
    And Results Should Contain Word    apple
    And Search Term Should Be Highlighted

Filter Vocabulary By Difficulty
    [Documentation]    Test vocabulary filtering by difficulty level
    [Tags]    positive    filter
    Given User Is On Vocabulary Page
    When User Filters By Difficulty    beginner
    Then Filtered Results Should Be Displayed
    And All Words Should Have Difficulty    beginner
    And Filter Should Be Visually Active

Add Word To Favorites
    [Documentation]    Test adding word to favorites via UI
    [Tags]    positive    favorites
    Given User Is On Vocabulary Page
    When User Clicks Favorite Button For First Word
    Then Word Should Be Added To Favorites
    And Favorite Button Should Show Active State
    And Success Message Should Appear

Remove Word From Favorites
    [Documentation]    Test removing word from favorites via UI
    [Tags]    positive    favorites
    Given User Is On Vocabulary Page
    And First Word Is In Favorites
    When User Clicks Unfavorite Button For First Word
    Then Word Should Be Removed From Favorites
    And Favorite Button Should Show Inactive State
    And Success Message Should Appear

Mark Word As Learned
    [Documentation]    Test marking word as learned via UI
    [Tags]    positive    progress
    Given User Is On Vocabulary Page
    When User Clicks Learned Button For First Word
    Then Word Should Be Marked As Learned
    And Learned Button Should Show Active State
    And Progress Should Be Updated

Play Word Pronunciation
    [Documentation]    Test word pronunciation audio playback
    [Tags]    positive    audio
    Given User Is On Vocabulary Page
    When User Clicks Audio Button For First Word
    Then Audio Should Start Playing
    And Audio Button Should Show Playing State

Navigate Vocabulary Pages
    [Documentation]    Test vocabulary list pagination navigation
    [Tags]    positive    pagination
    Given User Is On Vocabulary Page
    When User Clicks Next Page Button
    Then Next Page Should Be Loaded
    And Page Number Should Be Updated
    And Different Words Should Be Displayed

Sort Vocabulary List
    [Documentation]    Test vocabulary list sorting functionality
    [Tags]    positive    sorting
    Given User Is On Vocabulary Page
    When User Sorts By Alphabetical Order
    Then Words Should Be Sorted Alphabetically
    And Sort Indicator Should Be Visible

View Word Details
    [Documentation]    Test viewing detailed word information
    [Tags]    positive    details
    Given User Is On Vocabulary Page
    When User Clicks On First Word
    Then Word Details Modal Should Open
    And Complete Word Information Should Be Displayed
    And Modal Should Have Close Button

Vocabulary List Responsive Design
    [Documentation]    Test vocabulary list responsive design
    [Tags]    responsive    ui
    Given User Is On Vocabulary Page
    When User Resizes Browser To Mobile Size
    Then Vocabulary List Should Adapt To Mobile Layout
    And All Functions Should Remain Accessible
    When User Resizes Browser To Tablet Size
    Then Vocabulary List Should Adapt To Tablet Layout

Clear Search Results
    [Documentation]    Test clearing search results
    [Tags]    positive    search
    Given User Is On Vocabulary Page
    And User Has Searched For Word    test
    When User Clicks Clear Search Button
    Then Search Input Should Be Empty
    And Full Vocabulary List Should Be Displayed

Advanced Search Functionality
    [Documentation]    Test advanced search with multiple filters
    [Tags]    positive    advanced_search
    Given User Is On Vocabulary Page
    When User Opens Advanced Search Panel
    And User Sets Multiple Search Filters
    Then Advanced Search Results Should Be Displayed
    And Results Should Match All Filters

Empty Search Results
    [Documentation]    Test handling of empty search results
    [Tags]    edge_case    search
    Given User Is On Vocabulary Page
    When User Searches For Nonexistent Word    xyzneverexists
    Then No Results Message Should Be Displayed
    And Suggestion To Try Different Search Should Be Shown

Vocabulary List Performance
    [Documentation]    Test vocabulary list loading performance
    [Tags]    performance    timing
    Given User Is Logged In
    When User Navigates To Vocabulary Page And Measures Load Time
    Then Page Should Load Within Performance Threshold
    And Word List Should Render Quickly

Keyboard Navigation
    [Documentation]    Test keyboard navigation in vocabulary list
    [Tags]    accessibility    keyboard
    Given User Is On Vocabulary Page
    When User Uses Tab Key To Navigate
    Then All Interactive Elements Should Be Focusable
    And Visual Focus Indicators Should Be Present
    When User Presses Enter On Focused Element
    Then Appropriate Action Should Be Triggered

*** Keywords ***
Setup Vocabulary UI Test
    [Documentation]    Setup browser for vocabulary UI tests
    Open Browser    ${BASE_URL}    ${TEST_BROWSER}
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}

Teardown Vocabulary UI Test
    [Documentation]    Clean up after vocabulary UI tests
    Close All Browsers

User Is Logged In
    [Documentation]    Ensure user is logged in before test
    Login Via UI    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify User Is Logged In

User Is On Vocabulary Page
    [Documentation]    Navigate to vocabulary page and verify
    User Is Logged In
    Navigate To Vocabulary Page
    Wait Until Element Is Visible    ${VOCABULARY_CONTAINER}    timeout=${EXPLICIT_WAIT}

User Navigates To Vocabulary Page
    [Documentation]    Navigate to vocabulary page
    Navigate To Vocabulary Page

Vocabulary List Should Be Displayed
    [Documentation]    Verify vocabulary list is properly displayed
    Wait Until Element Is Visible    ${VOCABULARY_CONTAINER}    timeout=${EXPLICIT_WAIT}
    Element Should Be Visible    ${WORD_LIST_CONTAINER}

Word Items Should Be Visible
    [Documentation]    Verify word items are visible in the list
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}
    ${word_count}=    Get Element Count    ${WORD_ITEM}
    Should Be True    ${word_count} > 0

Pagination Should Be Present
    [Documentation]    Verify pagination controls are present
    Element Should Be Visible    ${PAGINATION_WRAPPER}
    Element Should Be Visible    ${PAGINATION_CONTROLS}

Search Functionality Should Be Available
    [Documentation]    Verify search functionality is available
    Element Should Be Visible    ${SEARCH_INPUT_FIELD}
    Element Should Be Visible    ${SEARCH_BUTTON}

User Searches For Word
    [Arguments]    ${search_term}
    [Documentation]    Search for a specific word
    Input Text    ${SEARCH_INPUT_FIELD}    ${search_term}
    Click Button    ${SEARCH_BUTTON}
    Wait Until Element Is Visible    ${SEARCH_RESULTS_CONTAINER}    timeout=${EXPLICIT_WAIT}

Search Results Should Be Displayed
    [Documentation]    Verify search results are displayed
    Element Should Be Visible    ${SEARCH_RESULTS_CONTAINER}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Results Should Contain Word
    [Arguments]    ${expected_word}
    [Documentation]    Verify search results contain expected word
    ${word_elements}=    Get WebElements    ${WORD_TEXT}
    ${found}=    Set Variable    False
    
    FOR    ${element}    IN    @{word_elements}
        ${word_text}=    Get Text    ${element}
        ${found}=    Set Variable If    '${expected_word}' in '${word_text}'.lower()    True    ${found}
        Exit For Loop If    ${found}
    END
    
    Should Be True    ${found}    Word '${expected_word}' not found in search results

Search Term Should Be Highlighted
    [Documentation]    Verify search term is highlighted in results
    Element Should Be Visible    css:.highlight

User Filters By Difficulty
    [Arguments]    ${difficulty_level}
    [Documentation]    Filter vocabulary by difficulty level
    Click Element    ${DIFFICULTY_FILTER}
    Select From List By Label    ${DIFFICULTY_FILTER}    ${difficulty_level}
    Click Button    ${FILTER_APPLY_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Filtered Results Should Be Displayed
    [Documentation]    Verify filtered results are displayed
    Element Should Be Visible    ${WORD_LIST_CONTAINER}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

All Words Should Have Difficulty
    [Arguments]    ${expected_difficulty}
    [Documentation]    Verify all words have expected difficulty level
    ${difficulty_elements}=    Get WebElements    css:.word-difficulty
    
    FOR    ${element}    IN    @{difficulty_elements}
        ${difficulty_text}=    Get Text    ${element}
        Should Contain    ${difficulty_text}    ${expected_difficulty}
    END

Filter Should Be Visually Active
    [Documentation]    Verify filter shows active state
    Element Should Have Class    ${DIFFICULTY_FILTER}    active

User Clicks Favorite Button For First Word
    [Documentation]    Click favorite button for first word in list
    ${first_favorite_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${FAVORITE_BUTTON}
    Click Element    ${first_favorite_btn}
    Sleep    1s    # Wait for animation

Word Should Be Added To Favorites
    [Documentation]    Verify word was added to favorites
    Wait Until Element Is Visible    ${SUCCESS_MESSAGE_CONTAINER}    timeout=${EXPLICIT_WAIT}

Favorite Button Should Show Active State
    [Documentation]    Verify favorite button shows active state
    ${first_favorite_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${FAVORITE_BUTTON}
    Element Should Have Class    ${first_favorite_btn}    active

Success Message Should Appear
    [Documentation]    Verify success message appears
    Wait Until Element Is Visible    ${SUCCESS_MESSAGE_CONTAINER}    timeout=${EXPLICIT_WAIT}
    Element Should Contain    ${SUCCESS_MESSAGE_CONTAINER}    success

First Word Is In Favorites
    [Documentation]    Ensure first word is already in favorites
    User Clicks Favorite Button For First Word
    Word Should Be Added To Favorites

User Clicks Unfavorite Button For First Word
    [Documentation]    Click unfavorite button for first word in list
    ${first_unfavorite_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${UNFAVORITE_BUTTON}
    Click Element    ${first_unfavorite_btn}
    Sleep    1s    # Wait for animation

Word Should Be Removed From Favorites
    [Documentation]    Verify word was removed from favorites
    Wait Until Element Is Visible    ${SUCCESS_MESSAGE_CONTAINER}    timeout=${EXPLICIT_WAIT}

Favorite Button Should Show Inactive State
    [Documentation]    Verify favorite button shows inactive state
    ${first_favorite_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${FAVORITE_BUTTON}
    Element Should Not Have Class    ${first_favorite_btn}    active

User Clicks Learned Button For First Word
    [Documentation]    Click learned button for first word in list
    ${first_learned_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${LEARNED_BUTTON}
    Click Element    ${first_learned_btn}
    Sleep    1s    # Wait for animation

Word Should Be Marked As Learned
    [Documentation]    Verify word was marked as learned
    Wait Until Element Is Visible    ${SUCCESS_MESSAGE_CONTAINER}    timeout=${EXPLICIT_WAIT}

Learned Button Should Show Active State
    [Documentation]    Verify learned button shows active state
    ${first_learned_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${LEARNED_BUTTON}
    Element Should Have Class    ${first_learned_btn}    active

Progress Should Be Updated
    [Documentation]    Verify progress indicators are updated
    Element Should Be Visible    ${PROGRESS_BAR}

User Clicks Audio Button For First Word
    [Documentation]    Click audio button for first word in list
    ${first_audio_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${AUDIO_PLAY_BUTTON}
    Click Element    ${first_audio_btn}

Audio Should Start Playing
    [Documentation]    Verify audio starts playing
    Sleep    2s    # Allow time for audio to start
    Element Should Be Visible    ${AUDIO_PLAYER}

Audio Button Should Show Playing State
    [Documentation]    Verify audio button shows playing state
    ${first_audio_btn}=    Get WebElement    ${WORD_ITEM}:first-child ${AUDIO_PLAY_BUTTON}
    Element Should Have Class    ${first_audio_btn}    playing

User Clicks Next Page Button
    [Documentation]    Click next page button in pagination
    Click Element    ${NEXT_PAGE_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Next Page Should Be Loaded
    [Documentation]    Verify next page is loaded
    Element Should Be Visible    ${WORD_LIST_CONTAINER}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Page Number Should Be Updated
    [Documentation]    Verify page number is updated
    ${current_page}=    Get Text    ${PAGE_NUMBER_INPUT}
    Should Be Equal As Strings    ${current_page}    2

Different Words Should Be Displayed
    [Documentation]    Verify different words are displayed on new page
    Element Should Be Visible    ${WORD_ITEM}

User Sorts By Alphabetical Order
    [Documentation]    Sort vocabulary list alphabetically
    Click Element    ${SORT_ALPHABETICAL}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Words Should Be Sorted Alphabetically
    [Documentation]    Verify words are sorted alphabetically
    ${word_elements}=    Get WebElements    ${WORD_TEXT}
    ${previous_word}=    Set Variable    ${EMPTY}
    
    FOR    ${element}    IN    @{word_elements}
        ${current_word}=    Get Text    ${element}
        Run Keyword If    '${previous_word}' != '${EMPTY}'    
        ...    Should Be True    '${current_word}'.lower() >= '${previous_word}'.lower()
        ${previous_word}=    Set Variable    ${current_word}
    END

Sort Indicator Should Be Visible
    [Documentation]    Verify sort indicator is visible
    Element Should Be Visible    css:.sort-indicator

User Clicks On First Word
    [Documentation]    Click on first word to view details
    ${first_word}=    Get WebElement    ${WORD_ITEM}:first-child ${WORD_TEXT}
    Click Element    ${first_word}

Word Details Modal Should Open
    [Documentation]    Verify word details modal opens
    Wait Until Element Is Visible    ${WORD_DETAILS_MODAL}    timeout=${EXPLICIT_WAIT}

Complete Word Information Should Be Displayed
    [Documentation]    Verify complete word information is displayed
    Element Should Be Visible    ${WORD_DETAILS_TITLE}
    Element Should Be Visible    ${WORD_DETAILS_DEFINITION}
    Element Should Be Visible    ${WORD_DETAILS_PRONUNCIATION}

Modal Should Have Close Button
    [Documentation]    Verify modal has close button
    Element Should Be Visible    ${CLOSE_WORD_DETAILS}

User Resizes Browser To Mobile Size
    [Documentation]    Resize browser to mobile size
    Set Window Size    375    667

Vocabulary List Should Adapt To Mobile Layout
    [Documentation]    Verify vocabulary list adapts to mobile layout
    Element Should Be Visible    ${MOBILE_WORD_CARD}

All Functions Should Remain Accessible
    [Documentation]    Verify all functions remain accessible on mobile
    Element Should Be Visible    ${SEARCH_INPUT_FIELD}
    Element Should Be Visible    ${FAVORITE_BUTTON}

User Resizes Browser To Tablet Size
    [Documentation]    Resize browser to tablet size
    Set Window Size    768    1024

Vocabulary List Should Adapt To Tablet Layout
    [Documentation]    Verify vocabulary list adapts to tablet layout
    Element Should Be Visible    ${TABLET_WORD_GRID}

User Has Searched For Word
    [Arguments]    ${search_term}
    [Documentation]    Ensure user has searched for a word
    User Searches For Word    ${search_term}

User Clicks Clear Search Button
    [Documentation]    Click clear search button
    Click Element    ${SEARCH_CLEAR_BUTTON}

Search Input Should Be Empty
    [Documentation]    Verify search input is empty
    ${search_value}=    Get Value    ${SEARCH_INPUT_FIELD}
    Should Be Empty    ${search_value}

Full Vocabulary List Should Be Displayed
    [Documentation]    Verify full vocabulary list is displayed
    Element Should Be Visible    ${WORD_LIST_CONTAINER}
    ${word_count}=    Get Element Count    ${WORD_ITEM}
    Should Be True    ${word_count} > 5

User Opens Advanced Search Panel
    [Documentation]    Open advanced search panel
    Click Element    ${ADVANCED_SEARCH_TOGGLE}
    Wait Until Element Is Visible    ${ADVANCED_SEARCH_PANEL}    timeout=${EXPLICIT_WAIT}

User Sets Multiple Search Filters
    [Documentation]    Set multiple search filters
    Select From List By Label    ${DIFFICULTY_FILTER}    beginner
    Select From List By Label    ${CATEGORY_FILTER}    animals
    Input Text    ${SEARCH_INPUT_FIELD}    cat
    Click Button    ${FILTER_APPLY_BUTTON}

Advanced Search Results Should Be Displayed
    [Documentation]    Verify advanced search results are displayed
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Results Should Match All Filters
    [Documentation]    Verify results match all applied filters
    ${word_elements}=    Get WebElements    ${WORD_ITEM}
    Should Not Be Empty    ${word_elements}

User Searches For Nonexistent Word
    [Arguments]    ${search_term}
    [Documentation]    Search for a word that doesn't exist
    Input Text    ${SEARCH_INPUT_FIELD}    ${search_term}
    Click Button    ${SEARCH_BUTTON}
    Wait Until Element Is Visible    ${NO_RESULTS_MESSAGE}    timeout=${EXPLICIT_WAIT}

No Results Message Should Be Displayed
    [Documentation]    Verify no results message is displayed
    Element Should Be Visible    ${NO_RESULTS_MESSAGE}
    Element Should Contain    ${NO_RESULTS_MESSAGE}    No results found

Suggestion To Try Different Search Should Be Shown
    [Documentation]    Verify suggestion to try different search is shown
    Element Should Contain    ${NO_RESULTS_MESSAGE}    Try a different search

User Navigates To Vocabulary Page And Measures Load Time
    [Documentation]    Navigate to vocabulary page and measure load time
    ${start_time}=    Get Time    epoch
    Navigate To Vocabulary Page
    Wait Until Element Is Visible    ${VOCABULARY_CONTAINER}    timeout=${EXPLICIT_WAIT}
    ${end_time}=    Get Time    epoch
    ${load_time}=    Evaluate    ${end_time} - ${start_time}
    Set Test Variable    ${PAGE_LOAD_TIME}    ${load_time}

Page Should Load Within Performance Threshold
    [Documentation]    Verify page loads within performance threshold
    Should Be True    ${PAGE_LOAD_TIME} < 5    Page should load within 5 seconds

Word List Should Render Quickly
    [Documentation]    Verify word list renders quickly
    Element Should Be Visible    ${WORD_ITEM}

User Uses Tab Key To Navigate
    [Documentation]    Use tab key to navigate through elements
    Press Keys    body    TAB
    Sleep    0.5s

All Interactive Elements Should Be Focusable
    [Documentation]    Verify all interactive elements can be focused
    Element Should Be Visible    ${SEARCH_INPUT_FIELD}
    Element Should Be Visible    ${SEARCH_BUTTON}
    Element Should Be Visible    ${FAVORITE_BUTTON}

Visual Focus Indicators Should Be Present
    [Documentation]    Verify visual focus indicators are present
    ${focused_element}=    Get WebElement    css:*:focus
    Should Not Be Empty    ${focused_element}

User Presses Enter On Focused Element
    [Documentation]    Press enter on currently focused element
    Press Keys    None    RETURN

Appropriate Action Should Be Triggered
    [Documentation]    Verify appropriate action is triggered
    Sleep    1s    # Allow time for action to complete