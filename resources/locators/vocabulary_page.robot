*** Settings ***
Documentation    Page locators for WordMate vocabulary pages

*** Variables ***
# Main Vocabulary Container
${VOCABULARY_CONTAINER}             css:.vocabulary-container
${VOCABULARY_HEADER}                css:.vocabulary-header
${VOCABULARY_TITLE}                 css:h1.vocabulary-title

# Word List Elements
${WORD_LIST_CONTAINER}              css:.word-list
${WORD_ITEM}                        css:.word-item
${WORD_CARD}                        css:.word-card
${WORD_TEXT}                        css:.word-text
${WORD_DEFINITION}                  css:.word-definition
${WORD_PRONUNCIATION}               css:.word-pronunciation
${WORD_EXAMPLE}                     css:.word-example

# Search and Filter Elements
${SEARCH_CONTAINER}                 css:.search-container
${SEARCH_INPUT_FIELD}               css:#wordSearch
${SEARCH_BUTTON}                    css:#searchBtn
${SEARCH_CLEAR_BUTTON}              css:#clearSearchBtn
${ADVANCED_SEARCH_TOGGLE}           css:#advancedSearchToggle
${ADVANCED_SEARCH_PANEL}            css:.advanced-search-panel

# Filter Controls
${FILTER_CONTAINER}                 css:.filter-container
${DIFFICULTY_FILTER}                css:#difficultyFilter
${CATEGORY_FILTER}                  css:#categoryFilter
${LENGTH_FILTER}                    css:#lengthFilter
${ALPHABETICAL_FILTER}              css:#alphabeticalFilter
${FILTER_APPLY_BUTTON}              css:#applyFiltersBtn
${FILTER_RESET_BUTTON}              css:#resetFiltersBtn

# Pagination Elements
${PAGINATION_WRAPPER}               css:.pagination-wrapper
${PAGINATION_INFO}                  css:.pagination-info
${PAGINATION_CONTROLS}              css:.pagination-controls
${FIRST_PAGE_BUTTON}                css:#firstPageBtn
${PREVIOUS_PAGE_BUTTON}             css:#prevPageBtn
${NEXT_PAGE_BUTTON}                 css:#nextPageBtn
${LAST_PAGE_BUTTON}                 css:#lastPageBtn
${PAGE_NUMBER_INPUT}                css:#pageNumberInput
${ITEMS_PER_PAGE_SELECT}            css:#itemsPerPageSelect

# Word Actions
${FAVORITE_BUTTON}                  css:.favorite-btn
${UNFAVORITE_BUTTON}                css:.unfavorite-btn
${LEARNED_BUTTON}                   css:.learned-btn
${UNLEARNED_BUTTON}                 css:.unlearned-btn
${AUDIO_PLAY_BUTTON}                css:.audio-play-btn
${SHARE_WORD_BUTTON}                css:.share-word-btn

# Vocabulary Statistics
${STATS_CONTAINER}                  css:.vocabulary-stats
${TOTAL_WORDS_COUNT}                css:.total-words
${LEARNED_WORDS_COUNT}              css:.learned-words
${FAVORITE_WORDS_COUNT}             css:.favorite-words
${PROGRESS_BAR}                     css:.progress-bar
${PROGRESS_PERCENTAGE}              css:.progress-percentage

# Custom Vocabulary Elements
${CUSTOM_VOCAB_SECTION}             css:.custom-vocabulary
${ADD_CUSTOM_WORD_BUTTON}           css:#addCustomWordBtn
${CUSTOM_WORD_FORM}                 css:#customWordForm
${CUSTOM_WORD_INPUT}                css:#customWordInput
${CUSTOM_DEFINITION_INPUT}          css:#customDefinitionInput
${CUSTOM_PRONUNCIATION_INPUT}       css:#customPronunciationInput
${SAVE_CUSTOM_WORD_BUTTON}          css:#saveCustomWordBtn
${CANCEL_CUSTOM_WORD_BUTTON}        css:#cancelCustomWordBtn

# Import/Export Elements
${IMPORT_EXPORT_SECTION}            css:.import-export
${IMPORT_VOCABULARY_BUTTON}         css:#importVocabBtn
${EXPORT_VOCABULARY_BUTTON}         css:#exportVocabBtn
${FILE_UPLOAD_INPUT}                css:#vocabFileUpload
${DOWNLOAD_LINK}                    css:#downloadVocabLink

# Folder Management
${FOLDERS_SIDEBAR}                  css:.folders-sidebar
${FOLDER_LIST}                      css:.folder-list
${FOLDER_ITEM}                      css:.folder-item
${FOLDER_NAME}                      css:.folder-name
${FOLDER_WORD_COUNT}                css:.folder-word-count
${CREATE_FOLDER_BUTTON}             css:#createFolderBtn
${EDIT_FOLDER_BUTTON}               css:.edit-folder-btn
${DELETE_FOLDER_BUTTON}             css:.delete-folder-btn

# Folder Modal Elements
${FOLDER_MODAL}                     css:#folderModal
${FOLDER_NAME_INPUT}                css:#folderNameInput
${FOLDER_COLOR_PICKER}              css:#folderColorPicker
${FOLDER_ICON_SELECTOR}             css:#folderIconSelector
${SAVE_FOLDER_BUTTON}               css:#saveFolderBtn
${CANCEL_FOLDER_BUTTON}             css:#cancelFolderBtn

# Multi-select Actions
${SELECT_ALL_CHECKBOX}              css:#selectAllWords
${SELECTED_WORDS_COUNT}             css:.selected-count
${BULK_ACTIONS_BAR}                 css:.bulk-actions
${MOVE_TO_FOLDER_BUTTON}            css:#moveToFolderBtn
${DELETE_SELECTED_BUTTON}           css:#deleteSelectedBtn
${MARK_AS_LEARNED_BUTTON}           css:#markAsLearnedBtn

# Word Details Modal
${WORD_DETAILS_MODAL}               css:#wordDetailsModal
${WORD_DETAILS_TITLE}               css:.word-details-title
${WORD_DETAILS_PRONUNCIATION}       css:.word-details-pronunciation
${WORD_DETAILS_DEFINITION}          css:.word-details-definition
${WORD_DETAILS_EXAMPLES}            css:.word-details-examples
${WORD_DETAILS_ETYMOLOGY}           css:.word-details-etymology
${WORD_DETAILS_SYNONYMS}            css:.word-details-synonyms
${WORD_DETAILS_ANTONYMS}            css:.word-details-antonyms
${CLOSE_WORD_DETAILS}               css:#closeWordDetailsBtn

# Loading and Error States
${VOCABULARY_LOADING}               css:.vocabulary-loading
${LOADING_SPINNER}                  css:.loading-spinner
${ERROR_MESSAGE_CONTAINER}          css:.error-message
${NO_RESULTS_MESSAGE}               css:.no-results
${EMPTY_STATE_CONTAINER}            css:.empty-state

# Toast Notifications
${TOAST_CONTAINER}                  css:.toast-container
${SUCCESS_TOAST}                    css:.toast-success
${ERROR_TOAST}                      css:.toast-error
${WARNING_TOAST}                    css:.toast-warning
${INFO_TOAST}                       css:.toast-info

# Responsive Elements
${MOBILE_WORD_CARD}                 css:.mobile-word-card
${TABLET_WORD_GRID}                 css:.tablet-word-grid
${DESKTOP_WORD_TABLE}               css:.desktop-word-table
${RESPONSIVE_NAVIGATION}            css:.responsive-nav

# Accessibility Elements
${WORD_LIST_ARIA_LABEL}             css:[aria-label*="word list"]
${SEARCH_ARIA_LABEL}                css:[aria-label*="search"]
${FILTER_ARIA_LABEL}                css:[aria-label*="filter"]
${PAGINATION_ARIA_LABEL}            css:[aria-label*="pagination"]

# Audio Elements
${AUDIO_PLAYER}                     css:.audio-player
${AUDIO_CONTROLS}                   css:.audio-controls
${VOLUME_SLIDER}                    css:.volume-slider
${PLAYBACK_SPEED}                   css:.playback-speed

# Study Mode Elements
${STUDY_MODE_TOGGLE}                css:#studyModeToggle
${FLASHCARD_VIEW}                   css:.flashcard-view
${FLASHCARD_FRONT}                  css:.flashcard-front
${FLASHCARD_BACK}                   css:.flashcard-back
${FLIP_CARD_BUTTON}                 css:#flipCardBtn
${NEXT_CARD_BUTTON}                 css:#nextCardBtn
${PREVIOUS_CARD_BUTTON}             css:#prevCardBtn

# Quiz Elements
${START_QUIZ_BUTTON}                css:#startQuizBtn
${QUIZ_CONTAINER}                   css:.quiz-container
${QUIZ_QUESTION}                    css:.quiz-question
${QUIZ_OPTIONS}                     css:.quiz-options
${QUIZ_OPTION}                      css:.quiz-option
${SUBMIT_ANSWER_BUTTON}             css:#submitAnswerBtn
${QUIZ_RESULTS}                     css:.quiz-results
${QUIZ_SCORE}                       css:.quiz-score

# Settings and Preferences
${VOCABULARY_SETTINGS}              css:.vocabulary-settings
${DISPLAY_PREFERENCES}              css:.display-preferences
${FONT_SIZE_SELECTOR}               css:#fontSizeSelector
${THEME_SELECTOR}                   css:#themeSelector
${AUTO_PLAY_AUDIO}                  css:#autoPlayAudio
${SHOW_PRONUNCIATION}               css:#showPronunciation

# Sorting Elements
${SORT_CONTAINER}                   css:.sort-container
${SORT_BY_SELECT}                   css:#sortBySelect
${SORT_ORDER_TOGGLE}                css:#sortOrderToggle
${SORT_ALPHABETICAL}                css:#sortAlphabetical
${SORT_BY_DATE}                     css:#sortByDate
${SORT_BY_DIFFICULTY}               css:#sortByDifficulty

# Keyboard Navigation
${KEYBOARD_SHORTCUTS_HELP}          css:.keyboard-shortcuts
${SHORTCUT_KEY_INDICATOR}           css:.shortcut-key
${NAVIGATION_HINT}                  css:.navigation-hint

# Performance Elements
${VIRTUAL_SCROLL_CONTAINER}         css:.virtual-scroll
${LAZY_LOAD_TRIGGER}                css:.lazy-load-trigger
${INFINITE_SCROLL_LOADER}           css:.infinite-scroll-loader