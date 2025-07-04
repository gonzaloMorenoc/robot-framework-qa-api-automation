*** Settings ***
Documentation    UI keywords for folder management functionality in WordMate application
Library          SeleniumLibrary
Library          Collections
Library          String
Library          ../../libraries/WordmateAPI.py
Variables        ../../variables/common_variables.robot
Variables        ../../locators/vocabulary_page.robot

*** Variables ***
${FOLDER_OPERATION_TIMEOUT}    10s
${FOLDER_COLORS}    #007bff,#28a745,#dc3545,#ffc107,#17a2b8,#6c757d,#6f42c1,#fd7e14,#20c997,#e83e8c
${FOLDER_ICONS}     folder,book,graduation-cap,briefcase,utensils,plane,home,heart,star,music

*** Keywords ***
Open Folder Management
    [Documentation]    Open folder management interface
    [Tags]    folder    navigation
    Click Element    ${FOLDERS_SIDEBAR}
    Wait Until Element Is Visible    ${FOLDER_LIST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Create New Folder
    [Arguments]    ${folder_name}    ${color}=${EMPTY}    ${icon}=${EMPTY}
    [Documentation]    Create a new folder with specified properties
    [Tags]    folder    create
    Click Button    ${CREATE_FOLDER_BUTTON}
    Wait Until Element Is Visible    ${FOLDER_MODAL}    timeout=${FOLDER_OPERATION_TIMEOUT}
    
    Input Text    ${FOLDER_NAME_INPUT}    ${folder_name}
    
    Run Keyword If    '${color}' != '${EMPTY}'    Select Folder Color    ${color}
    Run Keyword If    '${icon}' != '${EMPTY}'    Select Folder Icon    ${icon}
    
    Click Button    ${SAVE_FOLDER_BUTTON}
    Wait Until Element Is Not Visible    ${FOLDER_MODAL}    timeout=${FOLDER_OPERATION_TIMEOUT}
    Wait Until Element Is Visible    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]

Select Folder Color
    [Arguments]    ${color}
    [Documentation]    Select color for folder
    [Tags]    folder    color
    Click Element    ${FOLDER_COLOR_PICKER}
    Click Element    xpath://div[@class='color-option' and @data-color='${color}']

Select Folder Icon
    [Arguments]    ${icon}
    [Documentation]    Select icon for folder
    [Tags]    folder    icon
    Click Element    ${FOLDER_ICON_SELECTOR}
    Click Element    xpath://div[@class='icon-option' and @data-icon='${icon}']

Edit Folder
    [Arguments]    ${folder_name}    ${new_name}=${EMPTY}    ${new_color}=${EMPTY}    ${new_icon}=${EMPTY}
    [Documentation]    Edit existing folder properties
    [Tags]    folder    edit
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${edit_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'edit-folder-btn')]
    Click Element    ${edit_button}
    
    Wait Until Element Is Visible    ${FOLDER_MODAL}    timeout=${FOLDER_OPERATION_TIMEOUT}
    
    Run Keyword If    '${new_name}' != '${EMPTY}'    Update Folder Name    ${new_name}
    Run Keyword If    '${new_color}' != '${EMPTY}'    Select Folder Color    ${new_color}
    Run Keyword If    '${new_icon}' != '${EMPTY}'    Select Folder Icon    ${new_icon}
    
    Click Button    ${SAVE_FOLDER_BUTTON}
    Wait Until Element Is Not Visible    ${FOLDER_MODAL}    timeout=${FOLDER_OPERATION_TIMEOUT}

Update Folder Name
    [Arguments]    ${new_name}
    [Documentation]    Update folder name in edit modal
    [Tags]    folder    edit
    Clear Element Text    ${FOLDER_NAME_INPUT}
    Input Text    ${FOLDER_NAME_INPUT}    ${new_name}

Delete Folder
    [Arguments]    ${folder_name}
    [Documentation]    Delete specified folder
    [Tags]    folder    delete
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${delete_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'delete-folder-btn')]
    Click Element    ${delete_button}
    
    Handle Folder Deletion Confirmation
    Wait Until Element Is Not Visible    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]

Handle Folder Deletion Confirmation
    [Documentation]    Handle folder deletion confirmation dialog
    [Tags]    folder    confirmation
    Wait Until Element Is Visible    css:.delete-confirmation    timeout=${FOLDER_OPERATION_TIMEOUT}
    Click Button    css:.confirm-delete-btn
    Wait Until Element Is Not Visible    css:.delete-confirmation    timeout=${FOLDER_OPERATION_TIMEOUT}

Open Folder
    [Arguments]    ${folder_name}
    [Documentation]    Open folder to view its contents
    [Tags]    folder    navigation
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    Click Element    ${folder_element}
    Wait Until Element Is Visible    ${FOLDER_WORDS_CONTAINER}    timeout=${FOLDER_OPERATION_TIMEOUT}

Move Words To Folder
    [Arguments]    ${folder_name}    @{word_indices}
    [Documentation]    Move selected words to specified folder
    [Tags]    folder    move_words
    # First select the words
    FOR    ${index}    IN    @{word_indices}
        ${checkbox}=    Set Variable    ${WORD_ITEM}:nth-child(${index}) input[type="checkbox"]
        Click Element    ${checkbox}
    END
    
    # Open move to folder dialog
    Click Button    ${MOVE_TO_FOLDER_BUTTON}
    Wait Until Element Is Visible    css:.folder-selection-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    
    # Select target folder
    Click Element    xpath://div[@class='folder-option' and contains(text(), '${folder_name}')]
    Click Button    css:.confirm-move-btn
    
    Wait Until Element Is Not Visible    css:.folder-selection-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Copy Words To Folder
    [Arguments]    ${folder_name}    @{word_indices}
    [Documentation]    Copy selected words to specified folder
    [Tags]    folder    copy_words
    # First select the words
    FOR    ${index}    IN    @{word_indices}
        ${checkbox}=    Set Variable    ${WORD_ITEM}:nth-child(${index}) input[type="checkbox"]
        Click Element    ${checkbox}
    END
    
    # Open copy to folder dialog
    Click Button    css:#copyToFolderBtn
    Wait Until Element Is Visible    css:.folder-selection-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    
    # Select target folder
    Click Element    xpath://div[@class='folder-option' and contains(text(), '${folder_name}')]
    Click Button    css:.confirm-copy-btn
    
    Wait Until Element Is Not Visible    css:.folder-selection-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Remove Words From Folder
    [Arguments]    @{word_indices}
    [Documentation]    Remove selected words from current folder
    [Tags]    folder    remove_words
    # First select the words
    FOR    ${index}    IN    @{word_indices}
        ${checkbox}=    Set Variable    ${WORD_ITEM}:nth-child(${index}) input[type="checkbox"]
        Click Element    ${checkbox}
    END
    
    # Remove from folder
    Click Button    css:#removeFromFolderBtn
    Handle Confirmation Dialog
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Empty Folder
    [Arguments]    ${folder_name}
    [Documentation]    Remove all words from specified folder
    [Tags]    folder    empty
    Open Folder    ${folder_name}
    Click Button    css:#emptyFolderBtn
    Handle Empty Folder Confirmation
    Wait Until Element Is Visible    ${NO_WORDS_IN_FOLDER_MESSAGE}    timeout=${FOLDER_OPERATION_TIMEOUT}

Handle Empty Folder Confirmation
    [Documentation]    Handle empty folder confirmation dialog
    [Tags]    folder    confirmation
    Wait Until Element Is Visible    css:.empty-folder-confirmation    timeout=${FOLDER_OPERATION_TIMEOUT}
    Click Button    css:.confirm-empty-btn
    Wait Until Element Is Not Visible    css:.empty-folder-confirmation    timeout=${FOLDER_OPERATION_TIMEOUT}

Get Folder Word Count
    [Arguments]    ${folder_name}
    [Documentation]    Get number of words in specified folder
    [Tags]    folder    count
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${count_element}=    Get WebElement    ${folder_element}/..//span[@class='folder-word-count']
    ${count_text}=    Get Text    ${count_element}
    ${count}=    Extract Numbers    ${count_text}
    [Return]    ${count}

Verify Folder Exists
    [Arguments]    ${folder_name}
    [Documentation]    Verify that folder exists in folder list
    [Tags]    verification    folder
    Element Should Be Visible    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]

Verify Folder Does Not Exist
    [Arguments]    ${folder_name}
    [Documentation]    Verify that folder does not exist in folder list
    [Tags]    verification    folder
    Element Should Not Be Visible    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]

Verify Folder Color
    [Arguments]    ${folder_name}    ${expected_color}
    [Documentation]    Verify folder has expected color
    [Tags]    verification    folder    color
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${folder_icon}=    Get WebElement    ${folder_element}/..//i[@class='folder-icon']
    ${style}=    Get Element Attribute    ${folder_icon}    style
    Should Contain    ${style}    ${expected_color}

Verify Folder Icon
    [Arguments]    ${folder_name}    ${expected_icon}
    [Documentation]    Verify folder has expected icon
    [Tags]    verification    folder    icon
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${folder_icon}=    Get WebElement    ${folder_element}/..//i[@class='folder-icon']
    ${icon_class}=    Get Element Attribute    ${folder_icon}    class
    Should Contain    ${icon_class}    ${expected_icon}

Search Folders
    [Arguments]    ${search_term}
    [Documentation]    Search for folders by name
    [Tags]    folder    search
    Input Text    css:#folderSearchInput    ${search_term}
    Wait Until Element Is Visible    css:.folder-search-results    timeout=${FOLDER_OPERATION_TIMEOUT}

Clear Folder Search
    [Documentation]    Clear folder search and show all folders
    [Tags]    folder    search
    Click Element    css:#clearFolderSearchBtn
    Wait Until Element Is Visible    ${FOLDER_LIST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Sort Folders By Name
    [Documentation]    Sort folders alphabetically by name
    [Tags]    folder    sort
    Click Element    css:#sortFoldersByNameBtn
    Wait Until Element Is Visible    ${FOLDER_LIST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Sort Folders By Date
    [Documentation]    Sort folders by creation date
    [Tags]    folder    sort
    Click Element    css:#sortFoldersByDateBtn
    Wait Until Element Is Visible    ${FOLDER_LIST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Sort Folders By Word Count
    [Documentation]    Sort folders by word count
    [Tags]    folder    sort
    Click Element    css:#sortFoldersByCountBtn
    Wait Until Element Is Visible    ${FOLDER_LIST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Export Folder Contents
    [Arguments]    ${folder_name}    ${format}=csv
    [Documentation]    Export folder contents to specified format
    [Tags]    folder    export
    Open Folder    ${folder_name}
    Click Button    css:#exportFolderBtn
    Wait Until Element Is Visible    css:.export-options    timeout=${FOLDER_OPERATION_TIMEOUT}
    Select From List By Label    css:#exportFormatSelect    ${format}
    Click Button    css:#confirmExportBtn

Import Words To Folder
    [Arguments]    ${folder_name}    ${file_path}
    [Documentation]    Import words to specified folder
    [Tags]    folder    import
    Open Folder    ${folder_name}
    Click Button    css:#importToFolderBtn
    Choose File    ${FILE_UPLOAD_INPUT}    ${file_path}
    Click Button    css:#confirmImportBtn
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=${FOLDER_OPERATION_TIMEOUT}

Rename Folder
    [Arguments]    ${old_name}    ${new_name}
    [Documentation]    Rename existing folder
    [Tags]    folder    rename
    Edit Folder    ${old_name}    new_name=${new_name}
    Verify Folder Exists    ${new_name}
    Verify Folder Does Not Exist    ${old_name}

Duplicate Folder
    [Arguments]    ${original_folder}    ${new_folder_name}
    [Documentation]    Create duplicate of existing folder
    [Tags]    folder    duplicate
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${original_folder}')]
    ${duplicate_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'duplicate-folder-btn')]
    Click Element    ${duplicate_button}
    
    Wait Until Element Is Visible    css:.duplicate-folder-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    Input Text    css:#duplicateFolderNameInput    ${new_folder_name}
    Click Button    css:#confirmDuplicateBtn
    
    Wait Until Element Is Not Visible    css:.duplicate-folder-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    Verify Folder Exists    ${new_folder_name}

Share Folder
    [Arguments]    ${folder_name}    ${sharing_method}
    [Documentation]    Share folder via specified method
    [Tags]    folder    share
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${share_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'share-folder-btn')]
    Click Element    ${share_button}
    
    Wait Until Element Is Visible    css:.share-folder-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    Click Element    xpath://button[contains(@class, 'share-option') and contains(text(), '${sharing_method}')]

Archive Folder
    [Arguments]    ${folder_name}
    [Documentation]    Archive specified folder
    [Tags]    folder    archive
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${archive_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'archive-folder-btn')]
    Click Element    ${archive_button}
    
    Handle Confirmation Dialog
    Wait Until Element Is Not Visible    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]

Restore Archived Folder
    [Arguments]    ${folder_name}
    [Documentation]    Restore folder from archive
    [Tags]    folder    restore
    Click Element    css:#showArchivedFoldersBtn
    Wait Until Element Is Visible    css:.archived-folders    timeout=${FOLDER_OPERATION_TIMEOUT}
    
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'archived-folder-item') and contains(text(), '${folder_name}')]
    ${restore_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'restore-folder-btn')]
    Click Element    ${restore_button}
    
    Wait Until Element Is Visible    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]

Set Folder Access Permissions
    [Arguments]    ${folder_name}    ${permission_level}
    [Documentation]    Set access permissions for folder
    [Tags]    folder    permissions
    ${folder_element}=    Get WebElement    xpath://div[contains(@class, 'folder-item') and contains(text(), '${folder_name}')]
    ${settings_button}=    Get WebElement    ${folder_element}/..//button[contains(@class, 'folder-settings-btn')]
    Click Element    ${settings_button}
    
    Wait Until Element Is Visible    css:.folder-settings-modal    timeout=${FOLDER_OPERATION_TIMEOUT}
    Select From List By Label    css:#permissionLevelSelect    ${permission_level}
    Click Button    css:#savePermissionsBtn

Add Folder Description
    [Arguments]    ${folder_name}    ${description}
    [Documentation]    Add description to folder
    [Tags]    folder    description
    Edit Folder    ${folder_name}
    Input Text    css:#folderDescriptionInput    ${description}
    Click Button    ${SAVE_FOLDER_BUTTON}

Get Folder List
    [Documentation]    Get list of all folder names
    [Tags]    folder    utility
    ${folder_elements}=    Get WebElements    ${FOLDER_NAME}
    ${folder_names}=    Create List
    
    FOR    ${element}    IN    @{folder_elements}
        ${name}=    Get Text    ${element}
        Append To List    ${folder_names}    ${name}
    END
    
    [Return]    ${folder_names}

Verify Folder Order
    [Arguments]    @{expected_order}
    [Documentation]    Verify folders are in expected order
    [Tags]    verification    folder    order
    ${actual_order}=    Get Folder List
    Lists Should Be Equal    ${actual_order}    ${expected_order}

Check Folder Accessibility
    [Documentation]    Check folder accessibility features
    [Tags]    verification    folder    accessibility
    Element Should Have Attribute    ${FOLDER_LIST}    role    list
    ${folder_elements}=    Get WebElements    ${FOLDER_ITEM}
    FOR    ${element}    IN    @{folder_elements}
        Element Should Have Attribute    ${element}    role    listitem
        Element Should Have Attribute    ${element}    tabindex
    END

Verify Folder Responsive Design
    [Documentation]    Verify folder interface responsive design
    [Tags]    verification    folder    responsive
    # Mobile view
    Set Window Size    375    667
    Element Should Be Visible    ${FOLDERS_SIDEBAR}
    
    # Tablet view  
    Set Window Size    768    1024
    Element Should Be Visible    ${FOLDERS_SIDEBAR}
    Element Should Be Visible    ${FOLDER_LIST}
    
    # Desktop view
    Set Window Size    1920    1080
    Element Should Be Visible    ${FOLDERS_SIDEBAR}
    Element Should Be Visible    ${FOLDER_LIST}

Extract Numbers
    [Arguments]    ${text}
    [Documentation]    Extract numeric value from text string
    [Tags]    utility
    ${numbers}=    Get Regexp Matches    ${text}    \\d+
    ${number}=    Get From List    ${numbers}    0
    [Return]    ${number}

Handle Confirmation Dialog
    [Documentation]    Handle generic confirmation dialog
    [Tags]    folder    confirmation
    Wait Until Element Is Visible    css:.confirmation-dialog    timeout=${FOLDER_OPERATION_TIMEOUT}
    Click Button    css:.confirm-button
    Wait Until Element Is Not Visible    css:.confirmation-dialog    timeout=${FOLDER_OPERATION_TIMEOUT}