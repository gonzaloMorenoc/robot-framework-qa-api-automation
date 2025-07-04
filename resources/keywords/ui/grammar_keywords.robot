*** Settings ***
Documentation    UI keywords for grammar functionality in WordMate application
Library          SeleniumLibrary
Library          Collections
Library          String
Library          ../../libraries/WordmateAPI.py
Variables        ../../variables/common_variables.robot
Resource         ../../locators/grammar_page.robot

*** Variables ***
${GRAMMAR_LOAD_TIMEOUT}    15s
${EXERCISE_TIMEOUT}        10s

*** Keywords ***
Navigate To Grammar Section
    [Documentation]    Navigate to grammar section and wait for load
    [Tags]    navigation    grammar
    Click Element    ${GRAMMAR_MENU_LINK}
    Wait Until Element Is Visible    ${GRAMMAR_PAGE_INDICATOR}    timeout=${GRAMMAR_LOAD_TIMEOUT}
    Wait Until Element Is Visible    ${EXERCISE_CONTAINER}    timeout=${GRAMMAR_LOAD_TIMEOUT}

Verify Grammar Page Elements
    [Documentation]    Verify all essential grammar page elements are present
    [Tags]    verification    grammar
    Element Should Be Visible    ${GRAMMAR_PAGE_INDICATOR}
    Element Should Be Visible    ${EXERCISE_CONTAINER}
    Element Should Be Visible    css:.grammar-navigation
    Element Should Be Visible    css:.progress-indicator

Select Grammar Category
    [Arguments]    ${category}
    [Documentation]    Select specific grammar category
    [Tags]    grammar    category
    Click Element    xpath://a[contains(@class, 'category-link') and contains(text(), '${category}')]
    Wait Until Element Is Visible    ${EXERCISE_CONTAINER}    timeout=${EXERCISE_TIMEOUT}

Start Grammar Exercise
    [Arguments]    ${exercise_type}
    [Documentation]    Start specific type of grammar exercise
    [Tags]    grammar    exercise
    Click Element    xpath://button[contains(@class, 'start-exercise') and contains(text(), '${exercise_type}')]
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXERCISE_TIMEOUT}

Answer Multiple Choice Question
    [Arguments]    ${option_index}
    [Documentation]    Answer multiple choice question by option index
    [Tags]    grammar    exercise    multiple_choice
    ${option_selector}=    Set Variable    ${EXERCISE_OPTIONS} input[type="radio"]:nth-child(${option_index})
    Click Element    ${option_selector}
    Click Button    ${EXERCISE_SUBMIT}

Answer Fill In The Blank
    [Arguments]    ${answer_text}
    [Documentation]    Answer fill in the blank question
    [Tags]    grammar    exercise    fill_blank
    ${input_field}=    Get WebElement    ${EXERCISE_CONTAINER} input[type="text"]
    Clear Element Text    ${input_field}
    Input Text    ${input_field}    ${answer_text}
    Click Button    ${EXERCISE_SUBMIT}

Answer Multiple Fill In The Blank
    [Arguments]    @{answers}
    [Documentation]    Answer multiple fill in the blank questions
    [Tags]    grammar    exercise    fill_blank
    ${input_fields}=    Get WebElements    ${EXERCISE_CONTAINER} input[type="text"]
    
    FOR    ${index}    ${answer}    IN ENUMERATE    @{answers}
        Clear Element Text    ${input_fields}[${index}]
        Input Text    ${input_fields}[${index}]    ${answer}
    END
    
    Click Button    ${EXERCISE_SUBMIT}

Drag And Drop Answer
    [Arguments]    ${source_text}    ${target_position}
    [Documentation]    Perform drag and drop action for grammar exercise
    [Tags]    grammar    exercise    drag_drop
    ${source_element}=    Get WebElement    xpath://span[contains(@class, 'draggable') and text()='${source_text}']
    ${target_element}=    Get WebElement    xpath://div[contains(@class, 'drop-zone')][${target_position}]
    Drag And Drop    ${source_element}    ${target_element}
    Click Button    ${EXERCISE_SUBMIT}

Match Exercise Items
    [Arguments]    ${left_item}    ${right_item}
    [Documentation]    Match items in matching exercise
    [Tags]    grammar    exercise    matching
    ${left_element}=    Get WebElement    xpath://div[@class='left-column']//div[text()='${left_item}']
    ${right_element}=    Get WebElement    xpath://div[@class='right-column']//div[text()='${right_item}']
    Click Element    ${left_element}
    Click Element    ${right_element}

Submit Exercise Answer
    [Documentation]    Submit current exercise answer
    [Tags]    grammar    exercise
    Click Button    ${EXERCISE_SUBMIT}
    Wait Until Element Is Visible    ${EXERCISE_RESULT}    timeout=${EXERCISE_TIMEOUT}

Verify Exercise Result
    [Arguments]    ${expected_result}
    [Documentation]    Verify exercise result (correct/incorrect)
    [Tags]    verification    grammar    exercise
    ${result_element}=    Get WebElement    ${EXERCISE_RESULT}
    ${result_text}=    Get Text    ${result_element}
    Should Contain    ${result_text}    ${expected_result}

Get Exercise Feedback
    [Documentation]    Get feedback text from completed exercise
    [Tags]    grammar    exercise    feedback
    ${feedback_element}=    Get WebElement    css:.exercise-feedback
    ${feedback_text}=    Get Text    ${feedback_element}
    [Return]    ${feedback_text}

Continue To Next Exercise
    [Documentation]    Continue to next exercise in sequence
    [Tags]    grammar    exercise    navigation
    Click Button    css:#nextExerciseBtn
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXERCISE_TIMEOUT}

Return To Previous Exercise
    [Documentation]    Return to previous exercise in sequence
    [Tags]    grammar    exercise    navigation
    Click Button    css:#prevExerciseBtn
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXERCISE_TIMEOUT}

Complete Exercise Set
    [Documentation]    Complete entire exercise set
    [Tags]    grammar    exercise    completion
    ${exercise_count}=    Get Element Count    css:.exercise-indicator
    
    FOR    ${index}    IN RANGE    1    ${exercise_count + 1}
        # This would depend on specific exercise logic
        Submit Exercise Answer
        Run Keyword If    ${index} < ${exercise_count}    Continue To Next Exercise
    END

View Exercise Results Summary
    [Documentation]    View summary of completed exercises
    [Tags]    grammar    exercise    results
    Click Button    css:#viewResultsBtn
    Wait Until Element Is Visible    css:.results-summary    timeout=${EXERCISE_TIMEOUT}

Get Exercise Score
    [Documentation]    Get current exercise score
    [Tags]    grammar    exercise    score
    ${score_element}=    Get WebElement    css:.exercise-score
    ${score_text}=    Get Text    ${score_element}
    ${score}=    Extract Numbers    ${score_text}
    [Return]    ${score}

Get Exercise Progress
    [Documentation]    Get current exercise progress percentage
    [Tags]    grammar    exercise    progress
    ${progress_element}=    Get WebElement    css:.progress-percentage
    ${progress_text}=    Get Text    ${progress_element}
    ${progress}=    Extract Numbers    ${progress_text}
    [Return]    ${progress}

Reset Exercise Progress
    [Documentation]    Reset exercise progress and start over
    [Tags]    grammar    exercise    reset
    Click Button    css:#resetProgressBtn
    Handle Confirmation Dialog
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXERCISE_TIMEOUT}

Access Exercise Hints
    [Documentation]    Access hints for current exercise
    [Tags]    grammar    exercise    hints
    Click Button    css:#hintBtn
    Wait Until Element Is Visible    css:.exercise-hint    timeout=${EXERCISE_TIMEOUT}

View Exercise Explanation
    [Documentation]    View detailed explanation for exercise
    [Tags]    grammar    exercise    explanation
    Click Button    css:#explanationBtn
    Wait Until Element Is Visible    css:.exercise-explanation    timeout=${EXERCISE_TIMEOUT}

Set Exercise Difficulty
    [Arguments]    ${difficulty_level}
    [Documentation]    Set exercise difficulty level
    [Tags]    grammar    exercise    difficulty
    Select From List By Label    css:#difficultySelect    ${difficulty_level}
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXERCISE_TIMEOUT}

Filter Exercises By Topic
    [Arguments]    ${topic}
    [Documentation]    Filter exercises by grammar topic
    [Tags]    grammar    exercise    filter
    Select From List By Label    css:#topicFilter    ${topic}
    Wait Until Element Is Visible    ${EXERCISE_CONTAINER}    timeout=${EXERCISE_TIMEOUT}

Start Timed Exercise
    [Arguments]    ${time_limit}
    [Documentation]    Start timed exercise with specified time limit
    [Tags]    grammar    exercise    timed
    Input Text    css:#timeLimitInput    ${time_limit}
    Click Button    css:#startTimedExerciseBtn
    Wait Until Element Is Visible    css:.timer-display    timeout=${EXERCISE_TIMEOUT}

Pause Exercise Timer
    [Documentation]    Pause exercise timer
    [Tags]    grammar    exercise    timer
    Click Button    css:#pauseTimerBtn
    Element Should Be Visible    css:.timer-paused

Resume Exercise Timer
    [Documentation]    Resume exercise timer
    [Tags]    grammar    exercise    timer
    Click Button    css:#resumeTimerBtn
    Element Should Not Be Visible    css:.timer-paused

Get Remaining Time
    [Documentation]    Get remaining time in timed exercise
    [Tags]    grammar    exercise    timer
    ${timer_element}=    Get WebElement    css:.timer-display
    ${time_text}=    Get Text    ${timer_element}
    [Return]    ${time_text}

Verify Grammar Rule Display
    [Arguments]    ${expected_rule}
    [Documentation]    Verify grammar rule is displayed correctly
    [Tags]    verification    grammar    rules
    ${rule_element}=    Get WebElement    css:.grammar-rule
    ${rule_text}=    Get Text    ${rule_element}
    Should Contain    ${rule_text}    ${expected_rule}

Access Grammar Reference
    [Arguments]    ${topic}
    [Documentation]    Access grammar reference material for topic
    [Tags]    grammar    reference
    Click Element    css:#grammarReferenceBtn
    Wait Until Element Is Visible    css:.reference-modal    timeout=${EXERCISE_TIMEOUT}
    Click Element    xpath://a[contains(@class, 'reference-link') and contains(text(), '${topic}')]

Bookmark Grammar Exercise
    [Documentation]    Bookmark current grammar exercise
    [Tags]    grammar    exercise    bookmark
    Click Button    css:#bookmarkBtn
    Wait Until Element Is Visible    css:.bookmark-success    timeout=${EXERCISE_TIMEOUT}

Share Exercise Results
    [Arguments]    ${sharing_method}
    [Documentation]    Share exercise results via specified method
    [Tags]    grammar    exercise    sharing
    Click Button    css:#shareResultsBtn
    Wait Until Element Is Visible    css:.share-modal    timeout=${EXERCISE_TIMEOUT}
    Click Element    xpath://button[contains(@class, 'share-option') and contains(text(), '${sharing_method}')]

Print Exercise Results
    [Documentation]    Print exercise results
    [Tags]    grammar    exercise    print
    Click Button    css:#printResultsBtn
    # Note: This would typically open print dialog

Create Custom Exercise
    [Arguments]    ${exercise_type}    ${question_text}    ${correct_answer}
    [Documentation]    Create custom grammar exercise
    [Tags]    grammar    exercise    custom
    Click Button    css:#createExerciseBtn
    Wait Until Element Is Visible    css:.exercise-creator    timeout=${EXERCISE_TIMEOUT}
    Select From List By Label    css:#exerciseTypeSelect    ${exercise_type}
    Input Text    css:#questionInput    ${question_text}
    Input Text    css:#answerInput    ${correct_answer}
    Click Button    css:#saveExerciseBtn

Verify Exercise Accessibility
    [Documentation]    Verify exercise accessibility features
    [Tags]    verification    grammar    accessibility
    Element Should Have Attribute    ${EXERCISE_QUESTION}    role    heading
    Element Should Have Attribute    ${EXERCISE_SUBMIT}    aria-label
    ${input_elements}=    Get WebElements    ${EXERCISE_CONTAINER} input
    FOR    ${element}    IN    @{input_elements}
        Element Should Have Attribute    ${element}    aria-label
    END

Check Exercise Responsive Design
    [Documentation]    Check exercise responsive design
    [Tags]    verification    grammar    responsive
    # Mobile view
    Set Window Size    375    667
    Element Should Be Visible    ${EXERCISE_CONTAINER}
    Element Should Be Visible    ${EXERCISE_SUBMIT}
    
    # Tablet view
    Set Window Size    768    1024
    Element Should Be Visible    ${EXERCISE_CONTAINER}
    Element Should Be Visible    ${EXERCISE_SUBMIT}
    
    # Desktop view
    Set Window Size    1920    1080
    Element Should Be Visible    ${EXERCISE_CONTAINER}
    Element Should Be Visible    ${EXERCISE_SUBMIT}

Measure Exercise Load Time
    [Documentation]    Measure time taken to load exercise
    [Tags]    performance    grammar    exercise
    ${start_time}=    Get Time    epoch
    Navigate To Grammar Section
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXERCISE_TIMEOUT}
    ${end_time}=    Get Time    epoch
    ${load_time}=    Evaluate    ${end_time} - ${start_time}
    [Return]    ${load_time}

Extract Numbers
    [Arguments]    ${text}
    [Documentation]    Extract numeric value from text string
    [Tags]    utility
    ${numbers}=    Get Regexp Matches    ${text}    \\d+
    ${number}=    Get From List    ${numbers}    0
    [Return]    ${number}

Handle Confirmation Dialog
    [Documentation]    Handle confirmation dialog for actions
    [Tags]    grammar    confirmation
    Wait Until Element Is Visible    css:.confirmation-dialog    timeout=${EXERCISE_TIMEOUT}
    Click Button    css:.confirm-button
    Wait Until Element Is Not Visible    css:.confirmation-dialog    timeout=${EXERCISE_TIMEOUT}