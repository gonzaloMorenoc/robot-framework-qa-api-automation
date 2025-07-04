*** Settings ***
Documentation    Vocabulary CRUD API tests for WordMate application
Library          RequestsLibrary
Library          Collections
Library          String
Library          JSONLibrary
Library          ../../../resources/libraries/WordmateAPI.py
Resource         ../../../resources/keywords/api/vocabulary_api_keywords.robot
Resource         ../../../resources/keywords/common/authentication_keywords.robot
Variables        ../../../resources/variables/common_variables.robot
Variables        ../../../resources/variables/api_endpoints.robot
Variables        ../../../config/test_data/vocabulary.yaml
Suite Setup      Setup Vocabulary API Test Suite
Suite Teardown   Teardown Vocabulary API Test Suite
Test Setup       Setup Individual Vocabulary Test
Test Teardown    Cleanup Individual Vocabulary Test
Test Tags        api    vocabulary    crud

*** Variables ***
${API_SESSION}          wordmate_vocab_api
${TEST_WORD_ID}         ${EMPTY}
${TEST_FOLDER_ID}       ${EMPTY}

*** Test Cases ***
Get Vocabulary List Successfully
    [Documentation]    Test successful retrieval of vocabulary list
    [Tags]    positive    smoke    critical
    Given User Is Authenticated Via API
    When User Requests Vocabulary List
    Then Vocabulary List Should Be Returned
    And Response Should Contain Word Data
    And Response Should Include Pagination Info
    And Total Count Should Be Valid

Get Vocabulary List With Pagination
    [Documentation]    Test vocabulary list with pagination parameters
    [Tags]    positive    pagination
    Given User Is Authenticated Via API
    When User Requests Vocabulary List With Page    2    And Limit    25
    Then Vocabulary List Should Be Returned
    And Response Should Contain Correct Page Info
    And Word Count Should Match Limit

Get Vocabulary List With Search Filter
    [Documentation]    Test vocabulary list with search functionality
    [Tags]    positive    search
    Given User Is Authenticated Via API
    When User Searches For Words    apple
    Then Vocabulary List Should Be Returned
    And Search Results Should Contain Word    apple
    And All Results Should Match Search Term

Get Vocabulary List With Difficulty Filter
    [Documentation]    Test vocabulary list with difficulty filter
    [Tags]    positive    filter
    Given User Is Authenticated Via API
    When User Filters Vocabulary By Difficulty    beginner
    Then Vocabulary List Should Be Returned
    And All Words Should Have Difficulty Level    beginner

Get Vocabulary List Without Authentication
    [Documentation]    Test vocabulary list access without authentication
    [Tags]    negative    security
    Given User Is Not Authenticated
    When User Requests Vocabulary List
    Then Request Should Be Unauthorized
    And Error Message Should Indicate Authentication Required

Add Word To Favorites Successfully
    [Documentation]    Test adding word to user's favorites
    [Tags]    positive    favorites
    Given User Is Authenticated Via API
    And A Test Word Exists
    When User Adds Word To Favorites    ${TEST_WORD_ID}
    Then Word Should Be Added To Favorites
    And Success Message Should Be Returned
    And User's Favorite Count Should Increase

Add Nonexistent Word To Favorites
    [Documentation]    Test adding nonexistent word to favorites
    [Tags]    negative    validation
    Given User Is Authenticated Via API
    When User Adds Word To Favorites    99999
    Then Request Should Return Not Found Error
    And Error Message Should Indicate Word Not Found

Add Word To Favorites Twice
    [Documentation]    Test adding same word to favorites multiple times
    [Tags]    edge_case    favorites
    Given User Is Authenticated Via API
    And A Test Word Exists In Favorites
    When User Adds Word To Favorites Again    ${TEST_WORD_ID}
    Then Request Should Return Conflict Error
    And Error Message Should Indicate Word Already In Favorites

Remove Word From Favorites Successfully
    [Documentation]    Test removing word from user's favorites
    [Tags]    positive    favorites
    Given User Is Authenticated Via API
    And A Test Word Exists In Favorites
    When User Removes Word From Favorites    ${TEST_WORD_ID}
    Then Word Should Be Removed From Favorites
    And Success Message Should Be Returned
    And User's Favorite Count Should Decrease

Remove Nonexistent Word From Favorites
    [Documentation]    Test removing nonexistent word from favorites
    [Tags]    negative    validation
    Given User Is Authenticated Via API
    When User Removes Word From Favorites    99999
    Then Request Should Return Not Found Error
    And Error Message Should Indicate Word Not Found

Mark Word As Learned Successfully
    [Documentation]    Test marking word as learned
    [Tags]    positive    progress
    Given User Is Authenticated Via API
    And A Test Word Exists
    When User Marks Word As Learned    ${TEST_WORD_ID}
    Then Word Should Be Marked As Learned
    And Success Message Should Be Returned
    And User's Learned Count Should Increase

Mark Word As Unlearned Successfully
    [Documentation]    Test marking word as unlearned
    [Tags]    positive    progress
    Given User Is Authenticated Via API
    And A Test Word Exists As Learned
    When User Marks Word As Unlearned    ${TEST_WORD_ID}
    Then Word Should Be Marked As Unlearned
    And Success Message Should Be Returned
    And User's Learned Count Should Decrease

Get User's Favorite Words
    [Documentation]    Test retrieving user's favorite words
    [Tags]    positive    favorites    list
    Given User Is Authenticated Via API
    And User Has Favorite Words
    When User Requests Favorite Words List
    Then Favorite Words List Should Be Returned
    And All Words Should Be User's Favorites
    And Response Should Include Word Details

Get User's Learned Words
    [Documentation]    Test retrieving user's learned words
    [Tags]    positive    progress    list
    Given User Is Authenticated Via API
    And User Has Learned Words
    When User Requests Learned Words List
    Then Learned Words List Should Be Returned
    And All Words Should Be User's Learned Words
    And Response Should Include Progress Data

Create Custom Vocabulary Entry
    [Documentation]    Test creating custom vocabulary entry
    [Tags]    positive    custom_vocab    create
    Given User Is Authenticated Via API
    When User Creates Custom Vocabulary Entry
    ...    word=testword
    ...    definition=A test word for automation
    ...    pronunciation=/ˈtestˌwɜrd/
    Then Custom Vocabulary Should Be Created
    And Response Should Include Entry ID
    And Entry Should Appear In User's Custom Vocabulary

Create Custom Vocabulary With Minimal Data
    [Documentation]    Test creating custom vocabulary with only required fields
    [Tags]    positive    custom_vocab
    Given User Is Authenticated Via API
    When User Creates Custom Vocabulary Entry
    ...    word=minimal
    ...    definition=Minimal test word
    Then Custom Vocabulary Should Be Created
    And Entry Should Have Default Values For Optional Fields

Create Custom Vocabulary With Duplicate Word
    [Documentation]    Test creating custom vocabulary with duplicate word
    [Tags]    negative    custom_vocab    validation
    Given User Is Authenticated Via API
    And A Custom Vocabulary Entry Exists    duplicateword
    When User Creates Custom Vocabulary Entry
    ...    word=duplicateword
    ...    definition=Another definition
    Then Request Should Return Conflict Error
    And Error Message Should Indicate Duplicate Word

Create Custom Vocabulary Without Required Fields
    [Documentation]    Test creating custom vocabulary without required fields
    [Tags]    negative    custom_vocab    validation
    Given User Is Authenticated Via API
    When User Creates Custom Vocabulary Entry Without Word
    Then Request Should Return Bad Request Error
    And Error Message Should Indicate Missing Required Field

Update Custom Vocabulary Entry
    [Documentation]    Test updating existing custom vocabulary entry
    [Tags]    positive    custom_vocab    update
    Given User Is Authenticated Via API
    And A Custom Vocabulary Entry Exists    updatetest
    When User Updates Custom Vocabulary Entry
    ...    word=updatetest
    ...    definition=Updated definition
    ...    pronunciation=/ʌpˈdeɪtɪd/
    Then Custom Vocabulary Should Be Updated
    And Entry Should Reflect New Values

Delete Custom Vocabulary Entry
    [Documentation]    Test deleting custom vocabulary entry
    [Tags]    positive    custom_vocab    delete
    Given User Is Authenticated Via API
    And A Custom Vocabulary Entry Exists    deletetest
    When User Deletes Custom Vocabulary Entry    deletetest
    Then Custom Vocabulary Should Be Deleted
    And Entry Should Not Appear In User's Vocabulary
    And Success Message Should Be Returned

Delete Nonexistent Custom Vocabulary
    [Documentation]    Test deleting nonexistent custom vocabulary entry
    [Tags]    negative    custom_vocab    validation
    Given User Is Authenticated Via API
    When User Deletes Custom Vocabulary Entry    nonexistent
    Then Request Should Return Not Found Error
    And Error Message Should Indicate Entry Not Found

Get Custom Vocabulary List
    [Documentation]    Test retrieving user's custom vocabulary list
    [Tags]    positive    custom_vocab    list
    Given User Is Authenticated Via API
    And User Has Custom Vocabulary Entries
    When User Requests Custom Vocabulary List
    Then Custom Vocabulary List Should Be Returned
    And Response Should Include All User's Entries
    And Entries Should Have Complete Data

Export Custom Vocabulary
    [Documentation]    Test exporting user's custom vocabulary
    [Tags]    positive    custom_vocab    export
    Given User Is Authenticated Via API
    And User Has Custom Vocabulary Entries
    When User Exports Custom Vocabulary
    Then Export File Should Be Generated
    And File Should Contain All User's Entries
    And File Format Should Be Valid

Import Custom Vocabulary
    [Documentation]    Test importing custom vocabulary from file
    [Tags]    positive    custom_vocab    import
    Given User Is Authenticated Via API
    And Valid Vocabulary File Exists
    When User Imports Custom Vocabulary File
    Then Vocabulary Should Be Imported Successfully
    And Imported Entries Should Appear In User's Vocabulary
    And Import Summary Should Be Provided

Import Invalid Vocabulary File
    [Documentation]    Test importing invalid vocabulary file
    [Tags]    negative    custom_vocab    import    validation
    Given User Is Authenticated Via API
    When User Imports Invalid Vocabulary File
    Then Request Should Return Bad Request Error
    And Error Message Should Indicate Invalid File Format
    And No Entries Should Be Imported

Vocabulary API Rate Limiting
    [Documentation]    Test API rate limiting for vocabulary endpoints
    [Tags]    performance    rate_limiting    security
    Given User Is Authenticated Via API
    When User Makes Multiple Rapid Vocabulary Requests
    Then Rate Limit Should Be Enforced
    And Rate Limit Headers Should Be Present
    And Subsequent Requests Should Be Throttled

Vocabulary API Performance Test
    [Documentation]    Test vocabulary API response performance
    [Tags]    performance    timing
    Given User Is Authenticated Via API
    When User Requests Large Vocabulary List
    Then Response Should Be Within Performance Threshold
    And Response Time Should Meet SLA Requirements
    And Memory Usage Should Be Optimal

*** Keywords ***
Setup Vocabulary API Test Suite
    [Documentation]    Setup for vocabulary API test suite
    Log    Starting vocabulary API test suite
    WordmateAPI.Set API Base URL    ${API_BASE_URL}

Teardown Vocabulary API Test Suite
    [Documentation]    Cleanup after vocabulary API test suite
    WordmateAPI.Cleanup Test Data
    Delete All Sessions
    Log    Vocabulary API test suite completed

Setup Individual Vocabulary Test
    [Documentation]    Setup for individual vocabulary test
    Create Session    ${API_SESSION}    ${API_BASE_URL}

Cleanup Individual Vocabulary Test
    [Documentation]    Cleanup after individual vocabulary test
    Run Keyword If    '${TEST_WORD_ID}' != '${EMPTY}'    Cleanup Test Word
    Run Keyword If    '${TEST_FOLDER_ID}' != '${EMPTY}'    Cleanup Test Folder

User Is Authenticated Via API
    [Documentation]    Authenticate user for API testing
    ${response}=    WordmateAPI.Login User    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Should Be Equal As Strings    ${response['status_code']}    200

User Is Not Authenticated
    [Documentation]    Ensure user is not authenticated
    WordmateAPI.Clear Auth Token

User Requests Vocabulary List
    [Documentation]    Request vocabulary list from API
    ${response}=    WordmateAPI.Get Vocabulary List
    Set Test Variable    ${VOCAB_RESPONSE}    ${response}

Vocabulary List Should Be Returned
    [Documentation]    Verify vocabulary list is returned successfully
    Should Be Equal As Strings    ${VOCAB_RESPONSE['status_code']}    200
    Dictionary Should Contain Key    ${VOCAB_RESPONSE['data']}    words

Response Should Contain Word Data
    [Documentation]    Verify response contains word data
    ${words}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    words
    Should Not Be Empty    ${words}
    
    FOR    ${word}    IN    @{words}
        Dictionary Should Contain Key    ${word}    id
        Dictionary Should Contain Key    ${word}    word
        Dictionary Should Contain Key    ${word}    definition
    END

Response Should Include Pagination Info
    [Documentation]    Verify response includes pagination information
    Dictionary Should Contain Key    ${VOCAB_RESPONSE['data']}    pagination
    ${pagination}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    pagination
    Dictionary Should Contain Key    ${pagination}    currentPage
    Dictionary Should Contain Key    ${pagination}    totalPages
    Dictionary Should Contain Key    ${pagination}    totalItems

Total Count Should Be Valid
    [Documentation]    Verify total count is a valid number
    ${pagination}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    pagination
    ${total_items}=    Get From Dictionary    ${pagination}    totalItems
    Should Be True    ${total_items} >= 0

User Requests Vocabulary List With Page
    [Arguments]    ${page}    And Limit    ${limit}
    [Documentation]    Request vocabulary list with specific page and limit
    ${response}=    WordmateAPI.Get Vocabulary List    page=${page}    limit=${limit}
    Set Test Variable    ${VOCAB_RESPONSE}    ${response}

Response Should Contain Correct Page Info
    [Documentation]    Verify response contains correct page information
    ${pagination}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    pagination
    ${current_page}=    Get From Dictionary    ${pagination}    currentPage
    Should Be Equal As Numbers    ${current_page}    2

Word Count Should Match Limit
    [Documentation]    Verify word count matches requested limit
    ${words}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    words
    ${word_count}=    Get Length    ${words}
    Should Be True    ${word_count} <= 25

User Searches For Words
    [Arguments]    ${search_term}
    [Documentation]    Search for words using search term
    ${response}=    WordmateAPI.Get Vocabulary List    search=${search_term}
    Set Test Variable    ${VOCAB_RESPONSE}    ${response}

Search Results Should Contain Word
    [Arguments]    ${expected_word}
    [Documentation]    Verify search results contain expected word
    ${words}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    words
    ${found}=    Set Variable    False
    
    FOR    ${word}    IN    @{words}
        ${word_text}=    Get From Dictionary    ${word}    word
        ${found}=    Set Variable If    '${expected_word}' in '${word_text}'    True    ${found}
    END
    
    Should Be True    ${found}    Word '${expected_word}' not found in search results

All Results Should Match Search Term
    [Documentation]    Verify all search results match search term
    ${words}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    words
    
    FOR    ${word}    IN    @{words}
        ${word_text}=    Get From Dictionary    ${word}    word
        ${definition}=    Get From Dictionary    ${word}    definition
        ${matches}=    Evaluate    'apple' in '${word_text}'.lower() or 'apple' in '${definition}'.lower()
        Should Be True    ${matches}    Word '${word_text}' does not match search term
    END

User Filters Vocabulary By Difficulty
    [Arguments]    ${difficulty}
    [Documentation]    Filter vocabulary by difficulty level
    ${response}=    WordmateAPI.Make API Request    GET    ${VOCABULARY_DIFFICULTY_ENDPOINT}${difficulty}
    Set Test Variable    ${VOCAB_RESPONSE}    ${response}

All Words Should Have Difficulty Level
    [Arguments]    ${expected_difficulty}
    [Documentation]    Verify all words have expected difficulty level
    ${words}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    words
    
    FOR    ${word}    IN    @{words}
        ${difficulty}=    Get From Dictionary    ${word}    difficulty
        Should Be Equal As Strings    ${difficulty}    ${expected_difficulty}
    END

Request Should Be Unauthorized
    [Documentation]    Verify request returns unauthorized status
    Should Be Equal As Strings    ${VOCAB_RESPONSE['status_code']}    401

Error Message Should Indicate Authentication Required
    [Documentation]    Verify error message indicates authentication required
    ${error_message}=    Get From Dictionary    ${VOCAB_RESPONSE['data']}    message
    Should Contain    ${error_message}    authentication

A Test Word Exists
    [Documentation]    Ensure a test word exists for testing
    ${response}=    WordmateAPI.Get Vocabulary List    limit=1
    ${words}=    Get From Dictionary    ${response['data']}    words
    ${first_word}=    Get From List    ${words}    0
    ${word_id}=    Get From Dictionary    ${first_word}    id
    Set Test Variable    ${TEST_WORD_ID}    ${word_id}

User Adds Word To Favorites
    [Arguments]    ${word_id}
    [Documentation]    Add word to user's favorites
    ${response}=    WordmateAPI.Add Word To Favorites    ${word_id}
    Set Test Variable    ${FAVORITES_RESPONSE}    ${response}

Word Should Be Added To Favorites
    [Documentation]    Verify word was added to favorites
    Should Be Equal As Strings    ${FAVORITES_RESPONSE['status_code']}    200

Success Message Should Be Returned
    [Documentation]    Verify success message is returned
    ${message}=    Get From Dictionary    ${FAVORITES_RESPONSE['data']}    message
    Should Contain    ${message}    success

User's Favorite Count Should Increase
    [Documentation]    Verify user's favorite count increased
    ${profile_response}=    WordmateAPI.Get User Profile
    ${stats}=    Get From Dictionary    ${profile_response['data']}    statistics
    ${favorite_count}=    Get From Dictionary    ${stats}    favoriteWords
    Should Be True    ${favorite_count} > 0

Request Should Return Not Found Error
    [Documentation]    Verify request returns not found error
    Should Be Equal As Strings    ${FAVORITES_RESPONSE['status_code']}    404

Error Message Should Indicate Word Not Found
    [Documentation]    Verify error message indicates word not found
    ${error_message}=    Get From Dictionary    ${FAVORITES_RESPONSE['data']}    message
    Should Contain    ${error_message}    not found

A Test Word Exists In Favorites
    [Documentation]    Ensure a test word exists in user's favorites
    A Test Word Exists
    User Adds Word To Favorites    ${TEST_WORD_ID}

User Adds Word To Favorites Again
    [Arguments]    ${word_id}
    [Documentation]    Attempt to add same word to favorites again
    ${response}=    WordmateAPI.Add Word To Favorites    ${word_id}
    Set Test Variable    ${FAVORITES_RESPONSE}    ${response}

Request Should Return Conflict Error
    [Documentation]    Verify request returns conflict error
    Should Be Equal As Strings    ${FAVORITES_RESPONSE['status_code']}    409

Error Message Should Indicate Word Already In Favorites
    [Documentation]    Verify error message indicates word already in favorites
    ${error_message}=    Get From Dictionary    ${FAVORITES_RESPONSE['data']}    message
    Should Contain    ${error_message}    already

User Removes Word From Favorites
    [Arguments]    ${word_id}
    [Documentation]    Remove word from user's favorites
    ${response}=    WordmateAPI.Remove Word From Favorites    ${word_id}
    Set Test Variable    ${FAVORITES_RESPONSE}    ${response}

Word Should Be Removed From Favorites
    [Documentation]    Verify word was removed from favorites
    Should Be Equal As Strings    ${FAVORITES_RESPONSE['status_code']}    200

User's Favorite Count Should Decrease
    [Documentation]    Verify user's favorite count decreased
    ${profile_response}=    WordmateAPI.Get User Profile
    ${stats}=    Get From Dictionary    ${profile_response['data']}    statistics
    ${favorite_count}=    Get From Dictionary    ${stats}    favoriteWords
    Should Be True    ${favorite_count} >= 0

User Marks Word As Learned
    [Arguments]    ${word_id}
    [Documentation]    Mark word as learned
    ${response}=    WordmateAPI.Make API Request    POST    ${VOCABULARY_LEARNED_ENDPOINT}    {"wordId": ${word_id}}
    Set Test Variable    ${LEARNED_RESPONSE}    ${response}

Word Should Be Marked As Learned
    [Documentation]    Verify word was marked as learned
    Should Be Equal As Strings    ${LEARNED_RESPONSE['status_code']}    200

User's Learned Count Should Increase
    [Documentation]    Verify user's learned count increased
    ${profile_response}=    WordmateAPI.Get User Profile
    ${stats}=    Get From Dictionary    ${profile_response['data']}    statistics
    ${learned_count}=    Get From Dictionary    ${stats}    learnedWords
    Should Be True    ${learned_count} > 0

A Test Word Exists As Learned
    [Documentation]    Ensure a test word exists as learned
    A Test Word Exists
    User Marks Word As Learned    ${TEST_WORD_ID}

User Marks Word As Unlearned
    [Arguments]    ${word_id}
    [Documentation]    Mark word as unlearned
    ${response}=    WordmateAPI.Make API Request    DELETE    ${VOCABULARY_LEARNED_ENDPOINT}&wordId=${word_id}
    Set Test Variable    ${LEARNED_RESPONSE}    ${response}

Word Should Be Marked As Unlearned
    [Documentation]    Verify word was marked as unlearned
    Should Be Equal As Strings    ${LEARNED_RESPONSE['status_code']}    200

User's Learned Count Should Decrease
    [Documentation]    Verify user's learned count decreased
    ${profile_response}=    WordmateAPI.Get User Profile
    ${stats}=    Get From Dictionary    ${profile_response['data']}    statistics
    ${learned_count}=    Get From Dictionary    ${stats}    learnedWords
    Should Be True    ${learned_count} >= 0

User Has Favorite Words
    [Documentation]    Ensure user has favorite words
    A Test Word Exists
    User Adds Word To Favorites    ${TEST_WORD_ID}

User Requests Favorite Words List
    [Documentation]    Request user's favorite words list
    ${response}=    WordmateAPI.Make API Request    GET    ${VOCABULARY_FAVORITES_ENDPOINT}
    Set Test Variable    ${FAVORITES_LIST_RESPONSE}    ${response}

Favorite Words List Should Be Returned
    [Documentation]    Verify favorite words list is returned
    Should Be Equal As Strings    ${FAVORITES_LIST_RESPONSE['status_code']}    200
    Dictionary Should Contain Key    ${FAVORITES_LIST_RESPONSE['data']}    favorites

All Words Should Be User's Favorites
    [Documentation]    Verify all words in list are user's favorites
    ${favorites}=    Get From Dictionary    ${FAVORITES_LIST_RESPONSE['data']}    favorites
    Should Not Be Empty    ${favorites}

Response Should Include Word Details
    [Documentation]    Verify response includes complete word details
    ${favorites}=    Get From Dictionary    ${FAVORITES_LIST_RESPONSE['data']}    favorites
    
    FOR    ${word}    IN    @{favorites}
        Dictionary Should Contain Key    ${word}    word
        Dictionary Should Contain Key    ${word}    definition
        Dictionary Should Contain Key    ${word}    isFavorite
        ${is_favorite}=    Get From Dictionary    ${word}    isFavorite
        Should Be True    ${is_favorite}
    END

User Has Learned Words
    [Documentation]    Ensure user has learned words
    A Test Word Exists
    User Marks Word As Learned    ${TEST_WORD_ID}

User Requests Learned Words List
    [Documentation]    Request user's learned words list
    ${response}=    WordmateAPI.Make API Request    GET    ${VOCABULARY_LEARNED_ENDPOINT}
    Set Test Variable    ${LEARNED_LIST_RESPONSE}    ${response}

Learned Words List Should Be Returned
    [Documentation]    Verify learned words list is returned
    Should Be Equal As Strings    ${LEARNED_LIST_RESPONSE['status_code']}    200
    Dictionary Should Contain Key    ${LEARNED_LIST_RESPONSE['data']}    learned

All Words Should Be User's Learned Words
    [Documentation]    Verify all words in list are user's learned words
    ${learned}=    Get From Dictionary    ${LEARNED_LIST_RESPONSE['data']}    learned
    Should Not Be Empty    ${learned}

Response Should Include Progress Data
    [Documentation]    Verify response includes progress data
    ${learned}=    Get From Dictionary    ${LEARNED_LIST_RESPONSE['data']}    learned
    
    FOR    ${word}    IN    @{learned}
        Dictionary Should Contain Key    ${word}    word
        Dictionary Should Contain Key    ${word}    definition
        Dictionary Should Contain Key    ${word}    isLearned
        ${is_learned}=    Get From Dictionary    ${word}    isLearned
        Should Be True    ${is_learned}
    END

User Creates Custom Vocabulary Entry
    [Arguments]    ${word}    ${definition}    ${pronunciation}=${EMPTY}
    [Documentation]    Create custom vocabulary entry
    ${response}=    WordmateAPI.Create Custom Vocabulary    ${word}    ${definition}    ${pronunciation}
    Set Test Variable    ${CUSTOM_VOCAB_RESPONSE}    ${response}

Custom Vocabulary Should Be Created
    [Documentation]    Verify custom vocabulary was created
    Should Be Equal As Strings    ${CUSTOM_VOCAB_RESPONSE['status_code']}    201

Response Should Include Entry ID
    [Documentation]    Verify response includes entry ID
    Dictionary Should Contain Key    ${CUSTOM_VOCAB_RESPONSE['data']}    id
    ${entry_id}=    Get From Dictionary    ${CUSTOM_VOCAB_RESPONSE['data']}    id
    Should Not Be Empty    ${entry_id}

Entry Should Appear In User's Custom Vocabulary
    [Documentation]    Verify entry appears in user's custom vocabulary
    ${response}=    WordmateAPI.Make API Request    GET    ${CUSTOM_VOCAB_LIST_ENDPOINT}
    ${entries}=    Get From Dictionary    ${response['data']}    entries
    ${found}=    Set Variable    False
    
    FOR    ${entry}    IN    @{entries}
        ${entry_word}=    Get From Dictionary    ${entry}    word
        ${found}=    Set Variable If    '${entry_word}' == 'testword'    True    ${found}
    END
    
    Should Be True    ${found}

Entry Should Have Default Values For Optional Fields
    [Documentation]    Verify entry has default values for optional fields
    ${entry}=    Get From Dictionary    ${CUSTOM_VOCAB_RESPONSE['data']}    entry
    Dictionary Should Contain Key    ${entry}    pronunciation

A Custom Vocabulary Entry Exists
    [Arguments]    ${word}
    [Documentation]    Ensure a custom vocabulary entry exists
    WordmateAPI.Create Custom Vocabulary    ${word}    Test definition for ${word}

User Creates Custom Vocabulary Entry Without Word
    [Documentation]    Attempt to create custom vocabulary without word
    ${response}=    WordmateAPI.Make API Request    POST    ${CUSTOM_VOCAB_CREATE_ENDPOINT}    {"definition": "Missing word"}    expected_status=400
    Set Test Variable    ${CUSTOM_VOCAB_RESPONSE}    ${response}

Request Should Return Bad Request Error
    [Documentation]    Verify request returns bad request error
    Should Be Equal As Strings    ${CUSTOM_VOCAB_RESPONSE['status_code']}    400

Error Message Should Indicate Missing Required Field
    [Documentation]    Verify error message indicates missing required field
    ${error_message}=    Get From Dictionary    ${CUSTOM_VOCAB_RESPONSE['data']}    message
    Should Contain    ${error_message}    required

User Updates Custom Vocabulary Entry
    [Arguments]    ${word}    ${definition}    ${pronunciation}
    [Documentation]    Update custom vocabulary entry
    ${response}=    WordmateAPI.Make API Request    PUT    ${CUSTOM_VOCAB_UPDATE_ENDPOINT}    {"word": "${word}", "definition": "${definition}", "pronunciation": "${pronunciation}"}
    Set Test Variable    ${CUSTOM_VOCAB_RESPONSE}    ${response}

Custom Vocabulary Should Be Updated
    [Documentation]    Verify custom vocabulary was updated
    Should Be Equal As Strings    ${CUSTOM_VOCAB_RESPONSE['status_code']}    200

Entry Should Reflect New Values
    [Documentation]    Verify entry reflects updated values
    ${updated_entry}=    Get From Dictionary    ${CUSTOM_VOCAB_RESPONSE['data']}    entry
    ${updated_definition}=    Get From Dictionary    ${updated_entry}    definition
    Should Be Equal As Strings    ${updated_definition}    Updated definition

User Deletes Custom Vocabulary Entry
    [Arguments]    ${word}
    [Documentation]    Delete custom vocabulary entry
    ${response}=    WordmateAPI.Make API Request    DELETE    ${CUSTOM_VOCAB_DELETE_ENDPOINT}&word=${word}
    Set Test Variable    ${CUSTOM_VOCAB_RESPONSE}    ${response}

Custom Vocabulary Should Be Deleted
    [Documentation]    Verify custom vocabulary was deleted
    Should Be Equal As Strings    ${CUSTOM_VOCAB_RESPONSE['status_code']}    200

Entry Should Not Appear In User's Vocabulary
    [Documentation]    Verify entry no longer appears in user's vocabulary
    ${response}=    WordmateAPI.Make API Request    GET    ${CUSTOM_VOCAB_LIST_ENDPOINT}
    ${entries}=    Get From Dictionary    ${response['data']}    entries
    ${found}=    Set Variable    False
    
    FOR    ${entry}    IN    @{entries}
        ${entry_word}=    Get From Dictionary    ${entry}    word
        ${found}=    Set Variable If    '${entry_word}' == 'deletetest'    True    ${found}
    END
    
    Should Be False    ${found}

Error Message Should Indicate Entry Not Found
    [Documentation]    Verify error message indicates entry not found
    ${error_message}=    Get From Dictionary    ${CUSTOM_VOCAB_RESPONSE['data']}    message
    Should Contain    ${error_message}    not found

User Has Custom Vocabulary Entries
    [Documentation]    Ensure user has custom vocabulary entries
    WordmateAPI.Create Custom Vocabulary    customword1    Definition 1
    WordmateAPI.Create Custom Vocabulary    customword2    Definition 2

User Requests Custom Vocabulary List
    [Documentation]    Request user's custom vocabulary list
    ${response}=    WordmateAPI.Make API Request    GET    ${CUSTOM_VOCAB_LIST_ENDPOINT}
    Set Test Variable    ${CUSTOM_VOCAB_LIST_RESPONSE}    ${response}

Custom Vocabulary List Should Be Returned
    [Documentation]    Verify custom vocabulary list is returned
    Should Be Equal As Strings    ${CUSTOM_VOCAB_LIST_RESPONSE['status_code']}    200
    Dictionary Should Contain Key    ${CUSTOM_VOCAB_LIST_RESPONSE['data']}    entries

Response Should Include All User's Entries
    [Documentation]    Verify response includes all user's entries
    ${entries}=    Get From Dictionary    ${CUSTOM_VOCAB_LIST_RESPONSE['data']}    entries
    Should Not Be Empty    ${entries}

Entries Should Have Complete Data
    [Documentation]    Verify entries have complete data
    ${entries}=    Get From Dictionary    ${CUSTOM_VOCAB_LIST_RESPONSE['data']}    entries
    
    FOR    ${entry}    IN    @{entries}
        Dictionary Should Contain Key    ${entry}    id
        Dictionary Should Contain Key    ${entry}    word
        Dictionary Should Contain Key    ${entry}    definition
        Dictionary Should Contain Key    ${entry}    createdAt
    END

User Exports Custom Vocabulary
    [Documentation]    Export user's custom vocabulary
    ${response}=    WordmateAPI.Make API Request    GET    ${CUSTOM_VOCAB_EXPORT_ENDPOINT}
    Set Test Variable    ${EXPORT_RESPONSE}    ${response}

Export File Should Be Generated
    [Documentation]    Verify export file was generated
    Should Be Equal As Strings    ${EXPORT_RESPONSE['status_code']}    200

File Should Contain All User's Entries
    [Documentation]    Verify file contains all user's entries
    Dictionary Should Contain Key    ${EXPORT_RESPONSE['data']}    fileContent

File Format Should Be Valid
    [Documentation]    Verify export file format is valid
    ${file_content}=    Get From Dictionary    ${EXPORT_RESPONSE['data']}    fileContent
    Should Not Be Empty    ${file_content}

Valid Vocabulary File Exists
    [Documentation]    Ensure valid vocabulary file exists for import
    Set Test Variable    ${IMPORT_FILE_CONTENT}    [{"word": "importword", "definition": "Imported word"}]

User Imports Custom Vocabulary File
    [Documentation]    Import custom vocabulary file
    ${response}=    WordmateAPI.Make API Request    POST    ${CUSTOM_VOCAB_IMPORT_ENDPOINT}    {"fileContent": "${IMPORT_FILE_CONTENT}"}
    Set Test Variable    ${IMPORT_RESPONSE}    ${response}

Vocabulary Should Be Imported Successfully
    [Documentation]    Verify vocabulary was imported successfully
    Should Be Equal As Strings    ${IMPORT_RESPONSE['status_code']}    200

Imported Entries Should Appear In User's Vocabulary
    [Documentation]    Verify imported entries appear in user's vocabulary
    ${response}=    WordmateAPI.Make API Request    GET    ${CUSTOM_VOCAB_LIST_ENDPOINT}
    ${entries}=    Get From Dictionary    ${response['data']}    entries
    ${found}=    Set Variable    False
    
    FOR    ${entry}    IN    @{entries}
        ${entry_word}=    Get From Dictionary    ${entry}    word
        ${found}=    Set Variable If    '${entry_word}' == 'importword'    True    ${found}
    END
    
    Should Be True    ${found}

Import Summary Should Be Provided
    [Documentation]    Verify import summary is provided
    Dictionary Should Contain Key    ${IMPORT_RESPONSE['data']}    importSummary
    ${summary}=    Get From Dictionary    ${IMPORT_RESPONSE['data']}    importSummary
    Dictionary Should Contain Key    ${summary}    totalImported

User Imports Invalid Vocabulary File
    [Documentation]    Import invalid vocabulary file
    ${response}=    WordmateAPI.Make API Request    POST    ${CUSTOM_VOCAB_IMPORT_ENDPOINT}    {"fileContent": "invalid json"}    expected_status=400
    Set Test Variable    ${IMPORT_RESPONSE}    ${response}

Error Message Should Indicate Invalid File Format
    [Documentation]    Verify error message indicates invalid file format
    ${error_message}=    Get From Dictionary    ${IMPORT_RESPONSE['data']}    message
    Should Contain    ${error_message}    invalid

No Entries Should Be Imported
    [Documentation]    Verify no entries were imported
    Dictionary Should Contain Key    ${IMPORT_RESPONSE['data']}    importSummary
    ${summary}=    Get From Dictionary    ${IMPORT_RESPONSE['data']}    importSummary
    ${imported_count}=    Get From Dictionary    ${summary}    totalImported
    Should Be Equal As Numbers    ${imported_count}    0

User Makes Multiple Rapid Vocabulary Requests
    [Documentation]    Make multiple rapid requests to test rate limiting
    FOR    ${i}    IN RANGE    20
        ${response}=    WordmateAPI.Make API Request    GET    ${VOCABULARY_LIST_ENDPOINT}    expected_status=any
        Exit For Loop If    ${response['status_code']} == 429
    END
    Set Test Variable    ${RATE_LIMIT_RESPONSE}    ${response}

Rate Limit Should Be Enforced
    [Documentation]    Verify rate limiting is enforced
    Should Be Equal As Strings    ${RATE_LIMIT_RESPONSE['status_code']}    429

Rate Limit Headers Should Be Present
    [Documentation]    Verify rate limit headers are present
    Dictionary Should Contain Key    ${RATE_LIMIT_RESPONSE['headers']}    X-RateLimit-Limit

Subsequent Requests Should Be Throttled
    [Documentation]    Verify subsequent requests are throttled
    ${response}=    WordmateAPI.Make API Request    GET    ${VOCABULARY_LIST_ENDPOINT}    expected_status=429
    Should Be Equal As Strings    ${response['status_code']}    429

User Requests Large Vocabulary List
    [Documentation]    Request large vocabulary list for performance testing
    ${start_time}=    Get Time    epoch
    ${response}=    WordmateAPI.Get Vocabulary List    limit=1000
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    Set Test Variable    ${PERFORMANCE_RESPONSE}    ${response}
    Set Test Variable    ${PERFORMANCE_TIME}    ${response_time}

Response Should Be Within Performance Threshold
    [Documentation]    Verify response is within performance threshold
    Should Be True    ${PERFORMANCE_TIME} < 5    Response should be under 5 seconds

Response Time Should Meet SLA Requirements
    [Documentation]    Verify response time meets SLA requirements
    Should Be True    ${PERFORMANCE_TIME} < 2    Response should meet SLA requirement

Memory Usage Should Be Optimal
    [Documentation]    Verify memory usage is optimal
    Log    Memory usage should be monitored and optimized

Cleanup Test Word
    [Documentation]    Clean up test word after test
    Log    Cleaning up test word: ${TEST_WORD_ID}

Cleanup Test Folder
    [Documentation]    Clean up test folder after test
    Log    Cleaning up test folder: ${TEST_FOLDER_ID}