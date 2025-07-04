*** Settings ***
Documentation    Grammar exercises UI tests for WordMate application
Library          SeleniumLibrary
Library          Collections
Library          String
Resource         ../../../resources/keywords/common/authentication_keywords.robot
Resource         ../../../resources/keywords/common/navigation_keywords.robot
Resource         ../../../resources/keywords/ui/grammar_keywords.robot
Variables        ../../../resources/variables/common_variables.robot
Variables        ../../../config/test_data/grammar.yaml
Test Setup       Setup Grammar UI Test
Test Teardown    Teardown Grammar UI Test
Test Tags        ui    grammar    exercises

*** Variables ***
${TEST_BROWSER}    ${BROWSER}

*** Test Cases ***
Load Grammar Exercises Successfully
    [Documentation]    Test successful loading of grammar exercises page
    [Tags]    positive    smoke    critical
    Given User Is Logged In
    When User Navigates To Grammar Section
    Then Grammar Page Should Be Displayed
    And Exercise Categories Should Be Visible
    And Exercise Navigation Should Be Available

Select Grammar Category
    [Documentation]    Test selecting different grammar categories
    [Tags]    positive    category
    Given User Is On Grammar Page
    When User Selects Grammar Category    Verb Tenses
    Then Verb Tenses Exercises Should Be Loaded
    And Category Should Be Highlighted
    And Appropriate Exercises Should Be Displayed

Start Multiple Choice Exercise
    [Documentation]    Test starting and completing multiple choice exercise
    [Tags]    positive    exercise    multiple_choice
    Given User Is On Grammar Page
    When User Starts Exercise    Multiple Choice
    Then Exercise Question Should Be Displayed
    And Multiple Choice Options Should Be Available
    When User Answers Multiple Choice Question    2
    Then Exercise Result Should Be Shown
    And Feedback Should Be Provided

Complete Fill In The Blank Exercise
    [Documentation]    Test fill in the blank exercise completion
    [Tags]    positive    exercise    fill_blank
    Given User Is On Grammar Page
    When User Starts Exercise    Fill in the Blank
    Then Fill In The Blank Question Should Be Displayed
    When User Answers Fill In The Blank    went
    Then Exercise Result Should Be Shown
    And Correct Answer Should Be Highlighted

Handle Multiple Fill In The Blank
    [Documentation]    Test multiple fill in the blank exercise
    [Tags]    positive    exercise    fill_blank
    Given User Is On Grammar Page
    When User Starts Exercise    Multiple Fill in the Blank
    Then Multiple Input Fields Should Be Displayed
    When User Answers Multiple Fill In The Blank    had    been    studying
    Then Exercise Result Should Be Shown
    And All Answers Should Be Validated

Complete Drag And Drop Exercise
    [Documentation]    Test drag and drop exercise functionality
    [Tags]    positive    exercise    drag_drop
    Given User Is On Grammar Page
    When User Starts Exercise    Drag and Drop
    Then Draggable Elements Should Be Available
    And Drop Zones Should Be Visible
    When User Drags Word To Position    yesterday    1
    Then Word Should Be Placed Correctly
    And Exercise Should Allow Completion

Solve Matching Exercise
    [Documentation]    Test matching exercise completion
    [Tags]    positive    exercise    matching
    Given User Is On Grammar Page
    When User Starts Exercise    Matching
    Then Matching Columns Should Be Displayed
    When User Matches Items    Present Simple    Used for habits
    Then Match Should Be Highlighted
    And Score Should Be Updated

Access Exercise Hints
    [Documentation]    Test exercise hint functionality
    [Tags]    positive    exercise    hints
    Given User Is On Grammar Page
    And User Starts Exercise    Multiple Choice
    When User Clicks Hint Button
    Then Hint Should Be Displayed
    And Hint Should Provide Guidance
    And Exercise Should Remain Answerable

View Exercise Explanation
    [Documentation]    Test detailed exercise explanation
    [Tags]    positive    exercise    explanation
    Given User Is On Grammar Page
    And User Completes Exercise
    When User Views Exercise Explanation
    Then Detailed Explanation Should Be Shown
    And Grammar Rule Should Be Explained
    And Examples Should Be Provided

Navigate Exercise Sequence
    [Documentation]    Test navigation through exercise sequence
    [Tags]    positive    exercise    navigation
    Given User Is On Grammar Page
    And User Starts Exercise Set
    When User Completes Current Exercise
    And User Continues To Next Exercise
    Then Next Exercise Should Load
    And Progress Should Be Updated
    When User Returns To Previous Exercise
    Then Previous Exercise Should Load

Set Exercise Difficulty
    [Documentation]    Test setting exercise difficulty level
    [Tags]    positive    exercise    difficulty
    Given User Is On Grammar Page
    When User Sets Exercise Difficulty    Advanced
    Then Advanced Exercises Should Be Loaded
    And Difficulty Indicator Should Show Advanced
    And Exercise Complexity Should Match Level

Filter Exercises By Topic
    [Documentation]    Test filtering exercises by grammar topic
    [Tags]    positive    exercise    filter
    Given User Is On Grammar Page
    When User Filters Exercises By Topic    Conditionals
    Then Only Conditional Exercises Should Be Shown
    And Filter Should Be Active
    And Exercise Count Should Update

Complete Timed Exercise
    [Documentation]    Test timed exercise functionality
    [Tags]    positive    exercise    timed
    Given User Is On Grammar Page
    When User Starts Timed Exercise    300
    Then Timer Should Be Displayed
    And Timer Should Count Down
    When User Completes Exercise Within Time
    Then Exercise Should Be Submitted Successfully
    And Time Bonus Should Be Applied

Handle Exercise Timeout
    [Documentation]    Test exercise timeout handling
    [Tags]    edge_case    exercise    timeout
    Given User Is On Grammar Page
    When User Starts Timed Exercise    5
    And User Waits For Timer To Expire
    Then Exercise Should Auto Submit
    And Timeout Message Should Be Displayed
    And Partial Score Should Be Calculated

Pause And Resume Exercise
    [Documentation]    Test pause and resume functionality in timed exercise
    [Tags]    positive    exercise    timer
    Given User Is On Grammar Page
    When User Starts Timed Exercise    300
    And User Pauses Exercise Timer
    Then Timer Should Be Paused
    And Exercise Should Be Frozen
    When User Resumes Exercise Timer
    Then Timer Should Continue
    And Exercise Should Be Interactive

Track Exercise Progress
    [Documentation]    Test exercise progress tracking
    [Tags]    positive    exercise    progress
    Given User Is On Grammar Page
    When User Completes Multiple Exercises
    Then Progress Bar Should Update
    And Completed Exercise Count Should Increase
    And Accuracy Rate Should Be Calculated
    And Progress Should Be Saved

View Exercise Results Summary
    [Documentation]    Test exercise results summary display
    [Tags]    positive    exercise    results
    Given User Has Completed Exercise Set
    When User Views Results Summary
    Then Overall Score Should Be Displayed
    And Individual Exercise Results Should Be Shown
    And Performance Analysis Should Be Available
    And Improvement Suggestions Should Be Provided

Bookmark Grammar Exercise
    [Documentation]    Test bookmarking grammar exercises
    [Tags]    positive    exercise    bookmark
    Given User Is On Grammar Page
    When User Bookmarks Current Exercise
    Then Exercise Should Be Added To Bookmarks
    And Bookmark Indicator Should Be Active
    And Exercise Should Appear In Bookmarks List

Share Exercise Results
    [Documentation]    Test sharing exercise results
    [Tags]    positive    exercise    sharing
    Given User Has Completed Exercise
    When User Shares Exercise Results    Email
    Then Sharing Dialog Should Open
    And Email Option Should Be Selected
    And Results Should Be Prepared For Sharing

Access Grammar Reference
    [Documentation]    Test accessing grammar reference material
    [Tags]    positive    reference
    Given User Is On Grammar Page
    When User Accesses Grammar Reference    Verb Tenses
    Then Reference Modal Should Open
    And Verb Tenses Information Should Be Displayed
    And Examples Should Be Included
    And Modal Should Be Closeable

Create Custom Exercise
    [Documentation]    Test creating custom grammar exercise
    [Tags]    positive    exercise    custom
    Given User Is On Grammar Page
    When User Creates Custom Exercise    Multiple Choice    What is the past tense of 'go'?    went
    Then Exercise Creator Should Open
    And Exercise Details Should Be Entered
    And Custom Exercise Should Be Saved
    And Exercise Should Be Available For Practice

Handle Incorrect Answers
    [Documentation]    Test handling of incorrect exercise answers
    [Tags]    negative    exercise
    Given User Is On Grammar Page
    When User Starts Exercise    Multiple Choice
    And User Provides Incorrect Answer
    Then Exercise Should Show Incorrect Result
    And Feedback Should Explain Error
    And Correct Answer Should Be Highlighted
    And User Should Be Able To Try Again

Exercise Responsive Design
    [Documentation]    Test exercise responsive design on different devices
    [Tags]    responsive    exercise
    Given User Is On Grammar Page
    When User Resizes Browser To Mobile Size
    Then Exercise Should Adapt To Mobile Layout
    And All Interaction Elements Should Be Accessible
    When User Resizes Browser To Tablet Size
    Then Exercise Should Adapt To Tablet Layout
    And Navigation Should Remain Functional

Exercise Accessibility Features
    [Documentation]    Test exercise accessibility features
    [Tags]    accessibility    exercise
    Given User Is On Grammar Page
    When User Navigates Using Keyboard
    Then All Exercise Elements Should Be Focusable
    And Focus Indicators Should Be Visible
    And Screen Reader Labels Should Be Present
    When User Uses Enter Key To Submit Answer
    Then Exercise Should Respond Appropriately

Exercise Performance
    [Documentation]    Test exercise loading and response performance
    [Tags]    performance    exercise
    Given User Is Logged In
    When User Navigates To Grammar Section And Measures Load Time
    Then Grammar Page Should Load Within Performance Threshold
    And Exercise Interactions Should Be Responsive
    When User Completes Exercise Quickly
    Then Response Time Should Be Acceptable

Handle Exercise Errors
    [Documentation]    Test handling of exercise errors and edge cases
    [Tags]    error_handling    exercise
    Given User Is On Grammar Page
    When User Submits Empty Answer
    Then Validation Error Should Be Displayed
    And User Should Be Prompted To Provide Answer
    When User Submits Answer With Special Characters
    Then System Should Handle Characters Gracefully

Multiple Exercise Sessions
    [Documentation]    Test multiple concurrent exercise sessions
    [Tags]    edge_case    exercise    sessions
    Given User Is On Grammar Page
    When User Opens Multiple Exercise Tabs
    Then Each Session Should Work Independently
    And Progress Should Be Tracked Separately
    And No Cross-Session Interference Should Occur

*** Keywords ***
Setup Grammar UI Test
    [Documentation]    Setup browser for grammar UI tests
    Open Browser    ${BASE_URL}    ${TEST_BROWSER}
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}

Teardown Grammar UI Test
    [Documentation]    Clean up after grammar UI tests
    Close All Browsers

User Is Logged In
    [Documentation]    Ensure user is logged in before test
    Login Via UI    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify User Is Logged In

User Is On Grammar Page
    [Documentation]    Navigate to grammar page and verify
    User Is Logged In
    Navigate To Grammar Section
    Verify Grammar Page Elements

User Navigates To Grammar Section
    [Documentation]    Navigate to grammar section
    Navigate To Grammar Section

Grammar Page Should Be Displayed
    [Documentation]    Verify grammar page is properly displayed
    Element Should Be Visible    ${GRAMMAR_PAGE_INDICATOR}
    Element Should Be Visible    ${EXERCISE_CONTAINER}

Exercise Categories Should Be Visible
    [Documentation]    Verify exercise categories are visible
    Element Should Be Visible    css:.category-list
    ${category_count}=    Get Element Count    css:.category-item
    Should Be True    ${category_count} > 0

Exercise Navigation Should Be Available
    [Documentation]    Verify exercise navigation is available
    Element Should Be Visible    css:.exercise-navigation
    Element Should Be Visible    css:.difficulty-selector

User Selects Grammar Category
    [Arguments]    ${category}
    [Documentation]    Select specific grammar category
    Select Grammar Category    ${category}

Verb Tenses Exercises Should Be Loaded
    [Documentation]    Verify verb tenses exercises are loaded
    Element Should Be Visible    css:.verb-tenses-exercises
    Element Should Contain    css:.category-title    Verb Tenses

Category Should Be Highlighted
    [Documentation]    Verify selected category is highlighted
    Element Should Have Class    css:.category-item.active    active

Appropriate Exercises Should Be Displayed
    [Documentation]    Verify appropriate exercises are displayed for category
    ${exercise_count}=    Get Element Count    css:.exercise-item
    Should Be True    ${exercise_count} > 0

User Starts Exercise
    [Arguments]    ${exercise_type}
    [Documentation]    Start specific type of exercise
    Start Grammar Exercise    ${exercise_type}

Exercise Question Should Be Displayed
    [Documentation]    Verify exercise question is displayed
    Element Should Be Visible    ${EXERCISE_QUESTION}
    Element Should Not Be Empty    ${EXERCISE_QUESTION}

Multiple Choice Options Should Be Available
    [Documentation]    Verify multiple choice options are available
    Element Should Be Visible    ${EXERCISE_OPTIONS}
    ${option_count}=    Get Element Count    ${EXERCISE_OPTIONS} input[type="radio"]
    Should Be True    ${option_count} >= 2

User Answers Multiple Choice Question
    [Arguments]    ${option_index}
    [Documentation]    Answer multiple choice question
    Answer Multiple Choice Question    ${option_index}

Exercise Result Should Be Shown
    [Documentation]    Verify exercise result is shown
    Element Should Be Visible    ${EXERCISE_RESULT}
    Element Should Not Be Empty    ${EXERCISE_RESULT}

Feedback Should Be Provided
    [Documentation]    Verify feedback is provided
    Element Should Be Visible    css:.exercise-feedback
    Element Should Not Be Empty    css:.exercise-feedback

Fill In The Blank Question Should Be Displayed
    [Documentation]    Verify fill in the blank question is displayed
    Element Should Be Visible    ${EXERCISE_QUESTION}
    Element Should Be Visible    css:input[type="text"]

User Answers Fill In The Blank
    [Arguments]    ${answer}
    [Documentation]    Answer fill in the blank question
    Answer Fill In The Blank    ${answer}

Correct Answer Should Be Highlighted
    [Documentation]    Verify correct answer is highlighted
    Element Should Be Visible    css:.correct-answer

Multiple Input Fields Should Be Displayed
    [Documentation]    Verify multiple input fields are displayed
    ${input_count}=    Get Element Count    css:input[type="text"]
    Should Be True    ${input_count} > 1

User Answers Multiple Fill In The Blank
    [Arguments]    @{answers}
    [Documentation]    Answer multiple fill in the blank questions
    Answer Multiple Fill In The Blank    @{answers}

All Answers Should Be Validated
    [Documentation]    Verify all answers are validated
    ${result_elements}=    Get WebElements    css:.answer-result
    FOR    ${element}    IN    @{result_elements}
        Element Should Not Be Empty    ${element}
    END

Draggable Elements Should Be Available
    [Documentation]    Verify draggable elements are available
    Element Should Be Visible    css:.draggable-words
    ${draggable_count}=    Get Element Count    css:.draggable
    Should Be True    ${draggable_count} > 0

Drop Zones Should Be Visible
    [Documentation]    Verify drop zones are visible
    Element Should Be Visible    css:.drop-zones
    ${zone_count}=    Get Element Count    css:.drop-zone
    Should Be True    ${zone_count} > 0

User Drags Word To Position
    [Arguments]    ${word}    ${position}
    [Documentation]    Drag word to specific position
    Drag And Drop Answer    ${word}    ${position}

Word Should Be Placed Correctly
    [Documentation]    Verify word is placed correctly
    Element Should Be Visible    css:.drop-zone.filled

Exercise Should Allow Completion
    [Documentation]    Verify exercise can be completed
    Element Should Be Visible    ${EXERCISE_SUBMIT}
    Element Should Be Enabled    ${EXERCISE_SUBMIT}

Matching Columns Should Be Displayed
    [Documentation]    Verify matching columns are displayed
    Element Should Be Visible    css:.left-column
    Element Should Be Visible    css:.right-column

User Matches Items
    [Arguments]    ${left_item}    ${right_item}
    [Documentation]    Match items in exercise
    Match Exercise Items    ${left_item}    ${right_item}

Match Should Be Highlighted
    [Documentation]    Verify match is highlighted
    Element Should Be Visible    css:.matched-pair

Score Should Be Updated
    [Documentation]    Verify score is updated
    Element Should Be Visible    css:.current-score

User Clicks Hint Button
    [Documentation]    Click hint button
    Access Exercise Hints

Hint Should Be Displayed
    [Documentation]    Verify hint is displayed
    Element Should Be Visible    css:.exercise-hint
    Element Should Not Be Empty    css:.exercise-hint

Hint Should Provide Guidance
    [Documentation]    Verify hint provides useful guidance
    ${hint_text}=    Get Text    css:.exercise-hint
    Should Not Be Empty    ${hint_text}

Exercise Should Remain Answerable
    [Documentation]    Verify exercise can still be answered after hint
    Element Should Be Visible    ${EXERCISE_SUBMIT}
    Element Should Be Enabled    ${EXERCISE_SUBMIT}

User Completes Exercise
    [Documentation]    Complete current exercise
    Submit Exercise Answer
    Exercise Result Should Be Shown

User Views Exercise Explanation
    [Documentation]    View exercise explanation
    View Exercise Explanation

Detailed Explanation Should Be Shown
    [Documentation]    Verify detailed explanation is shown
    Element Should Be Visible    css:.exercise-explanation
    Element Should Not Be Empty    css:.exercise-explanation

Grammar Rule Should Be Explained
    [Documentation]    Verify grammar rule is explained
    Element Should Be Visible    css:.grammar-rule
    Element Should Not Be Empty    css:.grammar-rule

Examples Should Be Provided
    [Documentation]    Verify examples are provided
    Element Should Be Visible    css:.grammar-examples
    ${example_count}=    Get Element Count    css:.example-item
    Should Be True    ${example_count} > 0

User Starts Exercise Set
    [Documentation]    Start exercise set
    Click Button    css:#startExerciseSetBtn
    Wait Until Element Is Visible    ${EXERCISE_QUESTION}    timeout=${EXPLICIT_WAIT}

User Completes Current Exercise
    [Documentation]    Complete current exercise
    Submit Exercise Answer

User Continues To Next Exercise
    [Documentation]    Continue to next exercise
    Continue To Next Exercise

Next Exercise Should Load
    [Documentation]    Verify next exercise loads
    Element Should Be Visible    ${EXERCISE_QUESTION}

Progress Should Be Updated
    [Documentation]    Verify progress is updated
    Element Should Be Visible    css:.progress-bar
    ${progress}=    Get Exercise Progress
    Should Be True    ${progress} > 0

User Returns To Previous Exercise
    [Documentation]    Return to previous exercise
    Return To Previous Exercise

Previous Exercise Should Load
    [Documentation]    Verify previous exercise loads
    Element Should Be Visible    ${EXERCISE_QUESTION}

User Sets Exercise Difficulty
    [Arguments]    ${difficulty}
    [Documentation]    Set exercise difficulty
    Set Exercise Difficulty    ${difficulty}

Advanced Exercises Should Be Loaded
    [Documentation]    Verify advanced exercises are loaded
    Element Should Contain    css:.difficulty-indicator    Advanced

Difficulty Indicator Should Show Advanced
    [Documentation]    Verify difficulty indicator shows advanced
    Element Should Contain    css:.difficulty-level    Advanced

Exercise Complexity Should Match Level
    [Documentation]    Verify exercise complexity matches level
    # This would need specific implementation based on how complexity is determined
    Log    Exercise complexity verification would be implemented here

User Filters Exercises By Topic
    [Arguments]    ${topic}
    [Documentation]    Filter exercises by topic
    Filter Exercises By Topic    ${topic}

Only Conditional Exercises Should Be Shown
    [Documentation]    Verify only conditional exercises are shown
    Element Should Contain    css:.topic-indicator    Conditionals

Filter Should Be Active
    [Documentation]    Verify filter is active
    Element Should Have Class    css:.topic-filter    active

Exercise Count Should Update
    [Documentation]    Verify exercise count updates
    Element Should Be Visible    css:.exercise-count

User Starts Timed Exercise
    [Arguments]    ${time_limit}
    [Documentation]    Start timed exercise
    Start Timed Exercise    ${time_limit}

Timer Should Be Displayed
    [Documentation]    Verify timer is displayed
    Element Should Be Visible    css:.timer-display

Timer Should Count Down
    [Documentation]    Verify timer counts down
    ${initial_time}=    Get Remaining Time
    Sleep    2s
    ${current_time}=    Get Remaining Time
    Should Not Be Equal    ${initial_time}    ${current_time}

User Completes Exercise Within Time
    [Documentation]    Complete exercise within time limit
    Submit Exercise Answer

Exercise Should Be Submitted Successfully
    [Documentation]    Verify exercise is submitted successfully
    Element Should Be Visible    ${EXERCISE_RESULT}

Time Bonus Should Be Applied
    [Documentation]    Verify time bonus is applied
    Element Should Be Visible    css:.time-bonus

User Waits For Timer To Expire
    [Documentation]    Wait for timer to expire
    Wait Until Element Is Visible    css:.timer-expired    timeout=10s

Exercise Should Auto Submit
    [Documentation]    Verify exercise auto submits
    Element Should Be Visible    ${EXERCISE_RESULT}

Timeout Message Should Be Displayed
    [Documentation]    Verify timeout message is displayed
    Element Should Be Visible    css:.timeout-message

Partial Score Should Be Calculated
    [Documentation]    Verify partial score is calculated
    Element Should Be Visible    css:.partial-score

User Pauses Exercise Timer
    [Documentation]    Pause exercise timer
    Pause Exercise Timer

Timer Should Be Paused
    [Documentation]    Verify timer is paused
    Element Should Be Visible    css:.timer-paused

Exercise Should Be Frozen
    [Documentation]    Verify exercise is frozen
    Element Should Be Disabled    ${EXERCISE_SUBMIT}

User Resumes Exercise Timer
    [Documentation]    Resume exercise timer
    Resume Exercise Timer

Timer Should Continue
    [Documentation]    Verify timer continues
    Element Should Not Be Visible    css:.timer-paused

Exercise Should Be Interactive
    [Documentation]    Verify exercise is interactive
    Element Should Be Enabled    ${EXERCISE_SUBMIT}

User Completes Multiple Exercises
    [Documentation]    Complete multiple exercises for progress tracking
    FOR    ${i}    IN RANGE    3
        Submit Exercise Answer
        Continue To Next Exercise
    END

Progress Bar Should Update
    [Documentation]    Verify progress bar updates
    Element Should Be Visible    css:.progress-bar
    ${progress}=    Get Exercise Progress
    Should Be True    ${progress} > 0

Completed Exercise Count Should Increase
    [Documentation]    Verify completed exercise count increases
    ${count}=    Get Text    css:.completed-count
    Should Not Be Equal    ${count}    0

Accuracy Rate Should Be Calculated
    [Documentation]    Verify accuracy rate is calculated
    Element Should Be Visible    css:.accuracy-rate

Progress Should Be Saved
    [Documentation]    Verify progress is saved
    Reload Page
    ${saved_progress}=    Get Exercise Progress
    Should Be True    ${saved_progress} > 0

User Has Completed Exercise Set
    [Documentation]    Ensure user has completed exercise set
    User Completes Multiple Exercises
    Click Button    css:#finishExerciseSetBtn

User Views Results Summary
    [Documentation]    View results summary
    View Exercise Results Summary

Overall Score Should Be Displayed
    [Documentation]    Verify overall score is displayed
    Element Should Be Visible    css:.overall-score
    Element Should Not Be Empty    css:.overall-score

Individual Exercise Results Should Be Shown
    [Documentation]    Verify individual exercise results are shown
    Element Should Be Visible    css:.individual-results
    ${result_count}=    Get Element Count    css:.exercise-result-item
    Should Be True    ${result_count} > 0

Performance Analysis Should Be Available
    [Documentation]    Verify performance analysis is available
    Element Should Be Visible    css:.performance-analysis

Improvement Suggestions Should Be Provided
    [Documentation]    Verify improvement suggestions are provided
    Element Should Be Visible    css:.improvement-suggestions

User Bookmarks Current Exercise
    [Documentation]    Bookmark current exercise
    Bookmark Grammar Exercise

Exercise Should Be Added To Bookmarks
    [Documentation]    Verify exercise is added to bookmarks
    Element Should Be Visible    css:.bookmark-success

Bookmark Indicator Should Be Active
    [Documentation]    Verify bookmark indicator is active
    Element Should Have Class    css:.bookmark-btn    active

Exercise Should Appear In Bookmarks List
    [Documentation]    Verify exercise appears in bookmarks list
    Click Element    css:#bookmarksBtn
    Element Should Be Visible    css:.bookmarked-exercise

User Has Completed Exercise
    [Documentation]    Ensure user has completed exercise
    User Completes Exercise

User Shares Exercise Results
    [Arguments]    ${method}
    [Documentation]    Share exercise results
    Share Exercise Results    ${method}

Sharing Dialog Should Open
    [Documentation]    Verify sharing dialog opens
    Element Should Be Visible    css:.share-modal

Email Option Should Be Selected
    [Documentation]    Verify email option is selected
    Element Should Have Class    css:.share-email    selected

Results Should Be Prepared For Sharing
    [Documentation]    Verify results are prepared for sharing
    Element Should Be Visible    css:.share-content

User Accesses Grammar Reference
    [Arguments]    ${topic}
    [Documentation]    Access grammar reference
    Access Grammar Reference    ${topic}

Reference Modal Should Open
    [Documentation]    Verify reference modal opens
    Element Should Be Visible    css:.reference-modal

Verb Tenses Information Should Be Displayed
    [Documentation]    Verify verb tenses information is displayed
    Element Should Contain    css:.reference-content    Verb Tenses

Examples Should Be Included
    [Documentation]    Verify examples are included
    Element Should Be Visible    css:.reference-examples

Modal Should Be Closeable
    [Documentation]    Verify modal can be closed
    Element Should Be Visible    css:.modal-close

User Creates Custom Exercise
    [Arguments]    ${type}    ${question}    ${answer}
    [Documentation]    Create custom exercise
    Create Custom Exercise    ${type}    ${question}    ${answer}

Exercise Creator Should Open
    [Documentation]    Verify exercise creator opens
    Element Should Be Visible    css:.exercise-creator

Exercise Details Should Be Entered
    [Documentation]    Verify exercise details are entered
    Element Should Not Be Empty    css:#questionInput
    Element Should Not Be Empty    css:#answerInput

Custom Exercise Should Be Saved
    [Documentation]    Verify custom exercise is saved
    Element Should Be Visible    css:.save-success

Exercise Should Be Available For Practice
    [Documentation]    Verify exercise is available for practice
    Element Should Be Visible    css:.custom-exercise-item

User Provides Incorrect Answer
    [Documentation]    Provide incorrect answer to exercise
    Answer Multiple Choice Question    1  # Assuming this is incorrect

Exercise Should Show Incorrect Result
    [Documentation]    Verify exercise shows incorrect result
    Element Should Contain    ${EXERCISE_RESULT}    Incorrect

Feedback Should Explain Error
    [Documentation]    Verify feedback explains the error
    ${feedback}=    Get Exercise Feedback
    Should Not Be Empty    ${feedback}
    Should Contain    ${feedback}    explanation

User Should Be Able To Try Again
    [Documentation]    Verify user can try again
    Element Should Be Visible    css:#tryAgainBtn

User Resizes Browser To Mobile Size
    [Documentation]    Resize browser to mobile size
    Set Window Size    375    667

Exercise Should Adapt To Mobile Layout
    [Documentation]    Verify exercise adapts to mobile layout
    Element Should Be Visible    ${EXERCISE_CONTAINER}

All Interaction Elements Should Be Accessible
    [Documentation]    Verify all interaction elements are accessible
    Element Should Be Visible    ${EXERCISE_SUBMIT}

User Resizes Browser To Tablet Size
    [Documentation]    Resize browser to tablet size
    Set Window Size    768    1024

Exercise Should Adapt To Tablet Layout
    [Documentation]    Verify exercise adapts to tablet layout
    Element Should Be Visible    ${EXERCISE_CONTAINER}

Navigation Should Remain Functional
    [Documentation]    Verify navigation remains functional
    Element Should Be Visible    css:.exercise-navigation

User Navigates Using Keyboard
    [Documentation]    Navigate using keyboard
    Press Keys    body    TAB

All Exercise Elements Should Be Focusable
    [Documentation]    Verify all exercise elements are focusable
    Element Should Be Visible    ${EXERCISE_SUBMIT}

Focus Indicators Should Be Visible
    [Documentation]    Verify focus indicators are visible
    ${focused_element}=    Get WebElement    css:*:focus
    Should Not Be Empty    ${focused_element}

Screen Reader Labels Should Be Present
    [Documentation]    Verify screen reader labels are present
    Element Should Have Attribute    ${EXERCISE_QUESTION}    aria-label

User Uses Enter Key To Submit Answer
    [Documentation]    Use enter key to submit answer
    Press Keys    None    RETURN

Exercise Should Respond Appropriately
    [Documentation]    Verify exercise responds appropriately
    Sleep    1s  # Allow time for response

User Navigates To Grammar Section And Measures Load Time
    [Documentation]    Navigate to grammar section and measure load time
    ${start_time}=    Get Time    epoch
    Navigate To Grammar Section
    ${end_time}=    Get Time    epoch
    ${load_time}=    Evaluate    ${end_time} - ${start_time}
    Set Test Variable    ${GRAMMAR_LOAD_TIME}    ${load_time}

Grammar Page Should Load Within Performance Threshold
    [Documentation]    Verify grammar page loads within performance threshold
    Should Be True    ${GRAMMAR_LOAD_TIME} < 5

Exercise Interactions Should Be Responsive
    [Documentation]    Verify exercise interactions are responsive
    Element Should Be Visible    ${EXERCISE_SUBMIT}

User Completes Exercise Quickly
    [Documentation]    Complete exercise quickly
    ${start_time}=    Get Time    epoch
    Submit Exercise Answer
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    Set Test Variable    ${EXERCISE_RESPONSE_TIME}    ${response_time}

Response Time Should Be Acceptable
    [Documentation]    Verify response time is acceptable
    Should Be True    ${EXERCISE_RESPONSE_TIME} < 3

User Submits Empty Answer
    [Documentation]    Submit empty answer
    Click Button    ${EXERCISE_SUBMIT}

Validation Error Should Be Displayed
    [Documentation]    Verify validation error is displayed
    Element Should Be Visible    css:.validation-error

User Should Be Prompted To Provide Answer
    [Documentation]    Verify user is prompted to provide answer
    Element Should Contain    css:.validation-error    required

User Submits Answer With Special Characters
    [Arguments]    ${special_answer}=test!@#$%
    [Documentation]    Submit answer with special characters
    Answer Fill In The Blank    ${special_answer}

System Should Handle Characters Gracefully
    [Documentation]    Verify system handles special characters gracefully
    Page Should Not Contain    Error

User Opens Multiple Exercise Tabs
    [Documentation]    Open multiple exercise tabs
    Execute Javascript    window.open('${BASE_URL}/grammar.html', '_blank')
    Execute Javascript    window.open('${BASE_URL}/grammar.html', '_blank')

Each Session Should Work Independently
    [Documentation]    Verify each session works independently
    # This would require switching between tabs and verifying independence
    Log    Multiple session verification would be implemented here

Progress Should Be Tracked Separately
    [Documentation]    Verify progress is tracked separately
    # This would require checking progress in each tab
    Log    Separate progress tracking verification would be implemented here

No Cross-Session Interference Should Occur
    [Documentation]    Verify no cross-session interference occurs
    # This would require specific checks for session isolation
    Log    Cross-session interference verification would be implemented here