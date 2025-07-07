*** Settings ***
Documentation    Common variables for WordMate test automation

*** Variables ***
# Environment Configuration
${ENVIRONMENT}           %{ENVIRONMENT=dev}
${BASE_URL}              %{${ENVIRONMENT}_BASE_URL}
${API_BASE_URL}          %{${ENVIRONMENT}_API_BASE_URL}

# Browser Configuration
${BROWSER}               %{${ENVIRONMENT}_BROWSER}
${HEADLESS}              %{${ENVIRONMENT}_HEADLESS}
${WINDOW_WIDTH}          %{${ENVIRONMENT}_WINDOW_WIDTH}
${WINDOW_HEIGHT}         %{${ENVIRONMENT}_WINDOW_HEIGHT}

# Timeout Configuration
${IMPLICIT_WAIT}         %{${ENVIRONMENT}_IMPLICIT_WAIT}
${EXPLICIT_WAIT}         %{${ENVIRONMENT}_EXPLICIT_WAIT}
${PAGE_LOAD_TIMEOUT}     %{${ENVIRONMENT}_PAGE_LOAD_TIMEOUT}
${API_TIMEOUT}           %{${ENVIRONMENT}_API_TIMEOUT}

# Test Data Configuration - Using Environment Variables
${VALID_USERNAME}        %{${ENVIRONMENT}_TEST_USER}
${VALID_PASSWORD}        %{${ENVIRONMENT}_TEST_PASSWORD}
${INVALID_USERNAME}      %{${ENVIRONMENT}_INVALID_USER}
${INVALID_PASSWORD}      %{${ENVIRONMENT}_INVALID_PASSWORD}
${ADMIN_USERNAME}        %{${ENVIRONMENT}_ADMIN_USER}
${ADMIN_PASSWORD}        %{${ENVIRONMENT}_ADMIN_PASSWORD}

# Authentication Variables
${AUTH_TOKEN}            ${EMPTY}
${REFRESH_TOKEN}         ${EMPTY}
${AUTH_HEADERS}          ${EMPTY}

# Database Configuration
${DB_HOST}               %{${ENVIRONMENT}_DB_HOST}
${DB_PORT}               %{${ENVIRONMENT}_DB_PORT}
${DB_NAME}               %{${ENVIRONMENT}_DB_NAME}
${DB_USERNAME}           %{${ENVIRONMENT}_DB_USERNAME}
${DB_PASSWORD}           %{${ENVIRONMENT}_DB_PASSWORD}

# File Paths
${SCREENSHOTS_DIR}       %{SCREENSHOTS_DIR=reports/screenshots}
${LOGS_DIR}              %{LOGS_DIR=logs}
${TEST_DATA_DIR}         %{TEST_DATA_DIR=config/test_data}
${REPORTS_DIR}           %{REPORTS_DIR=reports}

# Application Specific
${APP_NAME}              %{APP_NAME=WordMate}
${APP_VERSION}           %{APP_VERSION=1.0.0}
${COPYRIGHT_TEXT}        %{COPYRIGHT_TEXT=© 2024 WordMate}

# Page Indicators
${HOME_PAGE_INDICATOR}          css:body.home-page
${VOCABULARY_PAGE_INDICATOR}    css:body.vocab-page
${GRAMMAR_PAGE_INDICATOR}       css:body.grammar-page
${PROFILE_PAGE_INDICATOR}       css:.profile-container
${MY_WORDS_PAGE_INDICATOR}      css:.my-words-container
${CUSTOM_VOCAB_PAGE_INDICATOR}  css:.custom-vocab-container
${GAME_SESSION_PAGE_INDICATOR}  css:.game-session-container

# Navigation Menu Locators
${HOME_MENU_LINK}               css:a#nav-home
${VOCABULARY_MENU_LINK}         css:a#nav-listado
${GRAMMAR_MENU_LINK}            css:a[href*="grammar"]
${PROFILE_MENU_LINK}            css:a#nav-profile
${MY_WORDS_MENU_LINK}           css:a#nav-my-words
${CUSTOM_VOCAB_MENU_LINK}       css:a[href*="custom-vocab"]
${GAME_SESSION_MENU_LINK}       css:a#nav-game-session

# Mobile Navigation
${MOBILE_MENU_TOGGLE}           css:.navbar-toggler
${MOBILE_NAVIGATION_MENU}       css:.navbar-collapse

# Breadcrumb Navigation
${BREADCRUMB_CONTAINER}         css:.breadcrumb
${BREADCRUMB_ITEMS}             css:.breadcrumb-item

# User Interface Elements
${USER_PROFILE_INDICATOR}       css:.user-profile
${LOGOUT_BUTTON}                css:a[href*="logout"]
${LOADING_SPINNER}              css:.loading-spinner
${ERROR_MESSAGE_CONTAINER}      css:.alert-danger
${SUCCESS_MESSAGE_CONTAINER}    css:.alert-success
${WARNING_MESSAGE_CONTAINER}    css:.alert-warning

# Form Elements
${SUBMIT_BUTTON}                css:button[type="submit"]
${CANCEL_BUTTON}                css:button[type="button"]:contains("Cancel")
${SAVE_BUTTON}                  css:button:contains("Save")
${DELETE_BUTTON}                css:button:contains("Delete")
${EDIT_BUTTON}                  css:button:contains("Edit")

# Modal Elements
${MODAL_CONTAINER}              css:.modal
${MODAL_TITLE}                  css:.modal-title
${MODAL_BODY}                   css:.modal-body
${MODAL_FOOTER}                 css:.modal-footer
${MODAL_CLOSE_BUTTON}           css:.modal .close

# Pagination Elements
${PAGINATION_CONTAINER}         css:.pagination
${PAGINATION_NEXT}              css:.pagination .page-next
${PAGINATION_PREVIOUS}          css:.pagination .page-prev
${PAGINATION_FIRST}             css:.pagination .page-first
${PAGINATION_LAST}              css:.pagination .page-last

# Search Elements
${SEARCH_INPUT}                 css:input[type="search"]
${SEARCH_BUTTON}                css:button:contains("Search")
${SEARCH_CLEAR_BUTTON}          css:button:contains("Clear")
${SEARCH_RESULTS_CONTAINER}     css:.search-results

# Filter Elements
${FILTER_CONTAINER}             css:.filters
${FILTER_DROPDOWN}              css:.filter-dropdown
${FILTER_APPLY_BUTTON}          css:button:contains("Apply")
${FILTER_RESET_BUTTON}          css:button:contains("Reset")

# Table Elements
${TABLE_CONTAINER}              css:.table-responsive
${TABLE_HEADER}                 css:thead
${TABLE_BODY}                   css:tbody
${TABLE_ROW}                    css:tr
${TABLE_CELL}                   css:td
${TABLE_SORT_BUTTON}            css:.sort-button

# Vocabulary Specific
${WORD_LIST_CONTAINER}          css:.word-list
${WORD_ITEM}                    css:.word-item
${WORD_DEFINITION}              css:.word-definition
${WORD_PRONUNCIATION}           css:.word-pronunciation
${FAVORITE_BUTTON}              css:.favorite-btn
${LEARNED_BUTTON}               css:.learned-btn

# Grammar Specific
${EXERCISE_CONTAINER}           css:.exercise-container
${EXERCISE_QUESTION}            css:.exercise-question
${EXERCISE_OPTIONS}             css:.exercise-options
${EXERCISE_SUBMIT}              css:.exercise-submit
${EXERCISE_RESULT}              css:.exercise-result

# File Upload
${FILE_UPLOAD_INPUT}            css:input[type="file"]
${FILE_UPLOAD_BUTTON}           css:.file-upload-btn
${FILE_UPLOAD_PROGRESS}         css:.upload-progress

# Toast Messages
${TOAST_CONTAINER}              css:.toast-container
${TOAST_SUCCESS}                css:.toast.success
${TOAST_ERROR}                  css:.toast.error
${TOAST_WARNING}                css:.toast.warning
${TOAST_INFO}                   css:.toast.info

# API Response Status Codes
${HTTP_OK}                  200
${HTTP_CREATED}             201
${HTTP_ACCEPTED}            202
${HTTP_NO_CONTENT}          204
${HTTP_BAD_REQUEST}         400
${HTTP_UNAUTHORIZED}        401
${HTTP_FORBIDDEN}           403
${HTTP_NOT_FOUND}           404
${HTTP_METHOD_NOT_ALLOWED}  405
${HTTP_CONFLICT}            409
${HTTP_UNPROCESSABLE}       422
${HTTP_TOO_MANY_REQUESTS}   429
${HTTP_INTERNAL_ERROR}      500
${HTTP_BAD_GATEWAY}         502
${HTTP_SERVICE_UNAVAILABLE} 503

# Test Tags
${TAG_SMOKE}                    smoke
${TAG_REGRESSION}               regression
${TAG_CRITICAL}                 critical
${TAG_API}                      api
${TAG_UI}                       ui
${TAG_AUTH}                     auth
${TAG_VOCABULARY}               vocabulary
${TAG_GRAMMAR}                  grammar
${TAG_PROFILE}                  profile
${TAG_NEGATIVE}                 negative