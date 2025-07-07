*** Settings ***
Documentation    Keywords for Vocabulary API testing
Library          RequestsLibrary
Library          Collections
Library          String
Library          ../../../resources/libraries/WordmateAPI.py
Variables        ../../../resources/variables/api_endpoints.robot

*** Keywords ***
User Requests Vocabulary List
    [Documentation]    Send GET request to vocabulary list endpoint
    ${response}=    GET On Session    ${API_SESSION}    ${VOCABULARY_LIST_ENDPOINT}
    Set Test Variable    ${VOCABULARY_RESPONSE}    ${response}

User Requests Vocabulary List With Page
    [Arguments]    ${page}    And Limit    ${limit}
    [Documentation]    Send GET request with pagination parameters
    ${params}=    Create Dictionary    page=${page}    limit=${limit}
    ${response}=    GET On Session    ${API_SESSION}    ${VOCABULARY_LIST_ENDPOINT}    params=${params}
    Set Test Variable    ${VOCABULARY_RESPONSE}    ${response}

User Searches For Words
    [Arguments]    ${search_term}
    [Documentation]    Send GET request with search parameter
    ${params}=    Create Dictionary    search=${search_term}
    ${response}=    GET On Session    ${API_SESSION}    ${VOCABULARY_LIST_ENDPOINT}    params=${params}
    Set Test Variable    ${VOCABULARY_RESPONSE}    ${response}

User Filters Vocabulary By Difficulty
    [Arguments]    ${difficulty}
    [Documentation]    Send GET request with difficulty filter
    ${params}=    Create Dictionary    difficulty=${difficulty}
    ${response}=    GET On Session    ${API_SESSION}    ${VOCABULARY_LIST_ENDPOINT}    params=${params}
    Set Test Variable    ${VOCABULARY_RESPONSE}    ${response}

Vocabulary List Should Be Returned
    [Documentation]    Verify vocabulary list response is successful
    Should Be Equal As Strings    ${VOCABULARY_RESPONSE.status_code}    ${HTTP_OK}
    ${response_json}=    Set Variable    ${VOCABULARY_RESPONSE.json()}
    Dictionary Should Contain Key    ${response_json}    data
    Dictionary Should Contain Key    ${response_json}    status
    Should Be Equal As Strings    ${response_json['status']}    success

Response Should Contain Word Data
    [Documentation]    Verify response contains word data structure
    ${response_json}=    Set Variable    ${VOCABULARY_RESPONSE.json()}
    ${words}=    Get From Dictionary    ${response_json}    data
    Should Not Be Empty    ${words}
    ${first_word}=    Get From List    ${words}    0
    Dictionary Should Contain Key    ${first_word}    id
    Dictionary Should Contain Key    ${first_word}    word
    Dictionary Should Contain Key    ${first_word}    definition

Response Should Include Pagination Info
    [Documentation]    Verify response includes pagination information
    ${response_json}=    Set Variable    ${VOCABULARY_RESPONSE.json()}
    Dictionary Should Contain Key    ${response_json}    pagination
    ${pagination}=    Get From Dictionary    ${response_json}    pagination
    Dictionary Should Contain Key    ${pagination}    page
    Dictionary Should Contain Key    ${pagination}    total_pages
    Dictionary Should Contain Key    ${pagination}    total_count

Total Count Should Be Valid
    [Documentation]    Verify total count is a valid number
    ${response_json}=    Set Variable    ${VOCABULARY_RESPONSE.json()}
    ${pagination}=    Get From Dictionary    ${response_json}    pagination
    ${total_count}=    Get From Dictionary    ${pagination}    total_count
    Should Be True    ${total_count} >= 0