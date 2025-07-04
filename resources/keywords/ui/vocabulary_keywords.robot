*** Settings ***
Documentation    UI keywords for vocabulary functionality in WordMate application
Library          SeleniumLibrary
Library          Collections
Library          String
Library          ../../libraries/WordmateAPI.py
Variables        ../../variables/common_variables.robot
Resource         ../../locators/vocabulary_page.robot

*** Variables ***
${VOCABULARY_LOAD_TIMEOUT}    15s
${SEARCH_DELAY}              2s

*** Keywords ***
Navigate To Vocabulary Section
    [Documentation]    Navigate to vocabulary section and wait for load
    [Tags]    navigation    vocabulary
    Click Element    ${VOCABULARY_MENU_LINK}
    Wait Until Element Is Visible    ${VOCABULARY_CONTAINER}    timeout=${VOCABULARY_LOAD_TIMEOUT}
    Wait Until Element Is Visible    ${WORD_LIST_CONTAINER}    timeout=${VOCABULARY_LOAD_TIMEOUT}

Verify Vocabulary Page Elements
    [Documentation]    Verify all essential vocabulary page elements are present
    [Tags]    verification    vocabulary
    Element Should Be Visible    ${VOCABULARY_HEADER}
    Element Should Be Visible    ${SEARCH_CONTAINER}
    Element Should Be Visible    ${WORD_LIST_CONTAINER}
    Element Should Be Visible    ${PAGINATION_WRAPPER}
    Element Should Be Visible    ${FILTER_CONTAINER}

Search For Vocabulary Word
    [Arguments]    ${search_term}
    [Documentation]    Search for a specific vocabulary word
    [Tags]    search    vocabulary
    Clear Element Text    ${SEARCH_INPUT_FIELD}
    Input Text    ${SEARCH_INPUT_FIELD}    ${search_term}
    Click Button    ${SEARCH_BUTTON}
    Sleep    ${SEARCH_DELAY}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Clear Vocabulary Search
    [Documentation]    Clear the vocabulary search input
    [Tags]    search    vocabulary
    Click Element    ${SEARCH_CLEAR_BUTTON}
    Wait Until Element Is Not Visible    ${SEARCH_CLEAR_BUTTON}    timeout=${EXPLICIT_WAIT}
    Element Text Should Be    ${SEARCH_INPUT_FIELD}    ${EMPTY}

Apply Difficulty Filter
    [Arguments]    ${difficulty_level}
    [Documentation]    Apply difficulty filter to vocabulary list
    [Tags]    filter    vocabulary
    Click Element    ${DIFFICULTY_FILTER}
    Select From List By Label    ${DIFFICULTY_FILTER}    ${difficulty_level}
    Click Button    ${FILTER_APPLY_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Apply Category Filter
    [Arguments]    ${category}
    [Documentation]    Apply category filter to vocabulary list
    [Tags]    filter    vocabulary
    Click Element    ${CATEGORY_FILTER}
    Select From List By Label    ${CATEGORY_FILTER}    ${category}
    Click Button    ${FILTER_APPLY_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Reset All Filters
    [Documentation]    Reset all applied filters
    [Tags]    filter    vocabulary
    Click Button    ${FILTER_RESET_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Add Word To Favorites By Index
    [Arguments]    ${word_index}
    [Documentation]    Add specific word to favorites by index
    [Tags]    favorites    vocabulary
    ${favorite_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${FAVORITE_BUTTON}
    Click Element    ${favorite_button}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Remove Word From Favorites By Index
    [Arguments]    ${word_index}
    [Documentation]    Remove specific word from favorites by index
    [Tags]    favorites    vocabulary
    ${unfavorite_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${UNFAVORITE_BUTTON}
    Click Element    ${unfavorite_button}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Mark Word As Learned By Index
    [Arguments]    ${word_index}
    [Documentation]    Mark specific word as learned by index
    [Tags]    learned    vocabulary    progress
    ${learned_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${LEARNED_BUTTON}
    Click Element    ${learned_button}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Mark Word As Unlearned By Index
    [Arguments]    ${word_index}
    [Documentation]    Mark specific word as unlearned by index
    [Tags]    learned    vocabulary    progress
    ${unlearned_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${UNLEARNED_BUTTON}
    Click Element    ${unlearned_button}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Play Word Pronunciation By Index
    [Arguments]    ${word_index}
    [Documentation]    Play pronunciation for specific word by index
    [Tags]    audio    vocabulary
    ${audio_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${AUDIO_PLAY_BUTTON}
    Click Element    ${audio_button}
    Sleep    2s    # Allow time for audio to play

Get Word Text By Index
    [Arguments]    ${word_index}
    [Documentation]    Get word text by index
    [Tags]    vocabulary    utility
    ${word_element}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${WORD_TEXT}
    ${word_text}=    Get Text    ${word_element}
    [Return]    ${word_text}

Get Word Definition By Index
    [Arguments]    ${word_index}
    [Documentation]    Get word definition by index
    [Tags]    vocabulary    utility
    ${definition_element}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${WORD_DEFINITION}
    ${definition_text}=    Get Text    ${definition_element}
    [Return]    ${definition_text}

Verify Word Is Favorite
    [Arguments]    ${word_index}
    [Documentation]    Verify word is marked as favorite
    [Tags]    verification    favorites
    ${favorite_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${FAVORITE_BUTTON}
    Element Should Have Class    ${favorite_button}    active

Verify Word Is Not Favorite
    [Arguments]    ${word_index}
    [Documentation]    Verify word is not marked as favorite
    [Tags]    verification    favorites
    ${favorite_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${FAVORITE_BUTTON}
    Element Should Not Have Class    ${favorite_button}    active

Verify Word Is Learned
    [Arguments]    ${word_index}
    [Documentation]    Verify word is marked as learned
    [Tags]    verification    learned
    ${learned_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${LEARNED_BUTTON}
    Element Should Have Class    ${learned_button}    active

Verify Word Is Not Learned
    [Arguments]    ${word_index}
    [Documentation]    Verify word is not marked as learned
    [Tags]    verification    learned
    ${learned_button}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${LEARNED_BUTTON}
    Element Should Not Have Class    ${learned_button}    active

Navigate To Next Vocabulary Page
    [Documentation]    Navigate to next page in vocabulary pagination
    [Tags]    pagination    vocabulary
    Click Element    ${NEXT_PAGE_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Navigate To Previous Vocabulary Page
    [Documentation]    Navigate to previous page in vocabulary pagination
    [Tags]    pagination    vocabulary
    Click Element    ${PREVIOUS_PAGE_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Navigate To Specific Vocabulary Page
    [Arguments]    ${page_number}
    [Documentation]    Navigate to specific page number in vocabulary
    [Tags]    pagination    vocabulary
    Clear Element Text    ${PAGE_NUMBER_INPUT}
    Input Text    ${PAGE_NUMBER_INPUT}    ${page_number}
    Press Keys    ${PAGE_NUMBER_INPUT}    RETURN
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Change Items Per Page
    [Arguments]    ${items_count}
    [Documentation]    Change number of items displayed per page
    [Tags]    pagination    vocabulary
    Select From List By Value    ${ITEMS_PER_PAGE_SELECT}    ${items_count}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Get Current Page Number
    [Documentation]    Get current page number from pagination
    [Tags]    pagination    vocabulary    utility
    ${page_number}=    Get Value    ${PAGE_NUMBER_INPUT}
    [Return]    ${page_number}

Get Total Word Count
    [Documentation]    Get total word count from vocabulary statistics
    [Tags]    vocabulary    statistics    utility
    ${total_count}=    Get Text    ${TOTAL_WORDS_COUNT}
    ${count_number}=    Extract Numbers    ${total_count}
    [Return]    ${count_number}

Get Learned Word Count
    [Documentation]    Get learned word count from vocabulary statistics
    [Tags]    vocabulary    statistics    utility
    ${learned_count}=    Get Text    ${LEARNED_WORDS_COUNT}
    ${count_number}=    Extract Numbers    ${learned_count}
    [Return]    ${count_number}

Get Favorite Word Count
    [Documentation]    Get favorite word count from vocabulary statistics
    [Tags]    vocabulary    statistics    utility
    ${favorite_count}=    Get Text    ${FAVORITE_WORDS_COUNT}
    ${count_number}=    Extract Numbers    ${favorite_count}
    [Return]    ${count_number}

Open Word Details Modal
    [Arguments]    ${word_index}
    [Documentation]    Open word details modal for specific word
    [Tags]    vocabulary    modal
    ${word_element}=    Set Variable    ${WORD_ITEM}:nth-child(${word_index}) ${WORD_TEXT}
    Click Element    ${word_element}
    Wait Until Element Is Visible    ${WORD_DETAILS_MODAL}    timeout=${EXPLICIT_WAIT}

Close Word Details Modal
    [Documentation]    Close word details modal
    [Tags]    vocabulary    modal
    Click Element    ${CLOSE_WORD_DETAILS}
    Wait Until Element Is Not Visible    ${WORD_DETAILS_MODAL}    timeout=${EXPLICIT_WAIT}

Verify Word Details Content
    [Arguments]    ${expected_word}
    [Documentation]    Verify content in word details modal
    [Tags]    verification    vocabulary    modal
    Element Should Be Visible    ${WORD_DETAILS_TITLE}
    Element Should Be Visible    ${WORD_DETAILS_DEFINITION}
    Element Should Be Visible    ${WORD_DETAILS_PRONUNCIATION}
    ${modal_title}=    Get Text    ${WORD_DETAILS_TITLE}
    Should Contain    ${modal_title}    ${expected_word}

Select Multiple Words
    [Arguments]    @{word_indices}
    [Documentation]    Select multiple words for bulk operations
    [Tags]    vocabulary    selection    bulk
    FOR    ${index}    IN    @{word_indices}
        ${checkbox}=    Set Variable    ${WORD_ITEM}:nth-child(${index}) input[type="checkbox"]
        Click Element    ${checkbox}
    END

Select All Words On Page
    [Documentation]    Select all words on current page
    [Tags]    vocabulary    selection    bulk
    Click Element    ${SELECT_ALL_CHECKBOX}

Move Selected Words To Folder
    [Arguments]    ${folder_name}
    [Documentation]    Move selected words to specified folder
    [Tags]    vocabulary    folders    bulk
    Click Element    ${MOVE_TO_FOLDER_BUTTON}
    Wait Until Element Is Visible    ${FOLDER_MODAL}    timeout=${EXPLICIT_WAIT}
    Click Element    xpath://div[@class='folder-option'][contains(text(),'${folder_name}')]
    Click Button    ${SAVE_FOLDER_BUTTON}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Delete Selected Words
    [Documentation]    Delete selected words
    [Tags]    vocabulary    deletion    bulk
    Click Element    ${DELETE_SELECTED_BUTTON}
    Handle Confirmation Dialog
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Mark Selected Words As Learned
    [Documentation]    Mark selected words as learned
    [Tags]    vocabulary    learned    bulk
    Click Element    ${MARK_AS_LEARNED_BUTTON}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${EXPLICIT_WAIT}

Sort Vocabulary By
    [Arguments]    ${sort_option}
    [Documentation]    Sort vocabulary list by specified option
    [Tags]    vocabulary    sorting
    Click Element    ${SORT_BY_SELECT}
    Select From List By Label    ${SORT_BY_SELECT}    ${sort_option}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Toggle Sort Order
    [Documentation]    Toggle sort order between ascending and descending
    [Tags]    vocabulary    sorting
    Click Element    ${SORT_ORDER_TOGGLE}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Verify Vocabulary List Is Sorted
    [Arguments]    ${sort_field}    ${order}=ascending
    [Documentation]    Verify vocabulary list is sorted correctly
    [Tags]    verification    vocabulary    sorting
    ${word_elements}=    Get WebElements    ${WORD_TEXT}
    ${word_texts}=    Create List
    
    FOR    ${element}    IN    @{word_elements}
        ${text}=    Get Text    ${element}
        Append To List    ${word_texts}    ${text}
    END
    
    ${sorted_list}=    Copy List    ${word_texts}
    Run Keyword If    '${order}' == 'ascending'    Sort List    ${sorted_list}
    Run Keyword If    '${order}' == 'descending'    Reverse List    ${sorted_list}
    
    Lists Should Be Equal    ${word_texts}    ${sorted_list}

Open Advanced Search
    [Documentation]    Open advanced search panel
    [Tags]    vocabulary    search    advanced
    Click Element    ${ADVANCED_SEARCH_TOGGLE}
    Wait Until Element Is Visible    ${ADVANCED_SEARCH_PANEL}    timeout=${EXPLICIT_WAIT}

Set Advanced Search Criteria
    [Arguments]    ${word_length}=${EMPTY}    ${starts_with}=${EMPTY}    ${ends_with}=${EMPTY}
    [Documentation]    Set advanced search criteria
    [Tags]    vocabulary    search    advanced
    Run Keyword If    '${word_length}' != '${EMPTY}'    
    ...    Select From List By Value    ${LENGTH_FILTER}    ${word_length}
    Run Keyword If    '${starts_with}' != '${EMPTY}'    
    ...    Input Text    css:#startsWithInput    ${starts_with}
    Run Keyword If    '${ends_with}' != '${EMPTY}'    
    ...    Input Text    css:#endsWithInput    ${ends_with}

Apply Advanced Search
    [Documentation]    Apply advanced search with current criteria
    [Tags]    vocabulary    search    advanced
    Click Button    ${FILTER_APPLY_BUTTON}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${EXPLICIT_WAIT}

Verify Search Results Count
    [Arguments]    ${expected_count}
    [Documentation]    Verify number of search results
    [Tags]    verification    vocabulary    search
    ${word_count}=    Get Element Count    ${WORD_ITEM}
    Should Be Equal As Numbers    ${word_count}    ${expected_count}

Verify No Results Message
    [Documentation]    Verify no results message is displayed
    [Tags]    verification    vocabulary    search
    Element Should Be Visible    ${NO_RESULTS_MESSAGE}
    Element Should Contain    ${NO_RESULTS_MESSAGE}    No results found

Wait For Vocabulary List To Load
    [Documentation]    Wait for vocabulary list to completely load
    [Tags]    vocabulary    loading
    Wait Until Element Is Visible    ${VOCABULARY_CONTAINER}    timeout=${VOCABULARY_LOAD_TIMEOUT}
    Wait Until Element Is Visible    ${WORD_ITEM}    timeout=${VOCABULARY_LOAD_TIMEOUT}
    Wait Until Element Is Not Visible    ${VOCABULARY_LOADING}    timeout=${VOCABULARY_LOAD_TIMEOUT}

Verify Vocabulary Statistics
    [Documentation]    Verify vocabulary statistics are displayed correctly
    [Tags]    verification    vocabulary    statistics
    Element Should Be Visible    ${STATS_CONTAINER}
    Element Should Be Visible    ${TOTAL_WORDS_COUNT}
    Element Should Be Visible    ${LEARNED_WORDS_COUNT}
    Element Should Be Visible    ${FAVORITE_WORDS_COUNT}
    Element Should Be Visible    ${PROGRESS_BAR}

Check Vocabulary List Accessibility
    [Documentation]    Check vocabulary list accessibility features
    [Tags]    accessibility    vocabulary
    Element Should Have Attribute    ${WORD_LIST_CONTAINER}    role    list
    ${word_elements}=    Get WebElements    ${WORD_ITEM}
    FOR    ${element}    IN    @{word_elements}
        Element Should Have Attribute    ${element}    role    listitem
    END

Handle Confirmation Dialog
    [Documentation]    Handle confirmation dialog for destructive actions
    [Tags]    vocabulary    confirmation
    Wait Until Element Is Visible    css:.confirmation-dialog    timeout=${EXPLICIT_WAIT}
    Click Button    css:.confirm-button
    Wait Until Element Is Not Visible    css:.confirmation-dialog    timeout=${EXPLICIT_WAIT}

Extract Numbers
    [Arguments]    ${text}
    [Documentation]    Extract numeric value from text string
    [Tags]    utility
    ${numbers}=    Get Regexp Matches    ${text}    \\d+
    ${number}=    Get From List    ${numbers}    0
    [Return]    ${number}

Verify Responsive Layout
    [Arguments]    ${layout_type}
    [Documentation]    Verify vocabulary list responsive layout
    [Tags]    verification    responsive    vocabulary
    Run Keyword If    '${layout_type}' == 'mobile'    
    ...    Element Should Be Visible    ${MOBILE_WORD_CARD}
    Run Keyword If    '${layout_type}' == 'tablet'    
    ...    Element Should Be Visible    ${TABLET_WORD_GRID}
    Run Keyword If    '${layout_type}' == 'desktop'    
    ...    Element Should Be Visible    ${DESKTOP_WORD_TABLE}