*** Settings ***
Documentation    API endpoints for WordMate application

*** Variables ***
# Authentication Endpoints
${LOGIN_ENDPOINT}               ?endpoint=login
${REGISTER_ENDPOINT}            ?endpoint=register
${LOGOUT_ENDPOINT}              ?endpoint=logout
${REFRESH_TOKEN_ENDPOINT}       ?endpoint=refreshToken
${VERIFY_TOKEN_ENDPOINT}        ?endpoint=verifyToken
${SOCIAL_LOGIN_ENDPOINT}        ?endpoint=socialLogin
${PASSWORD_RESET_ENDPOINT}      ?endpoint=passwordReset
${PASSWORD_CHANGE_ENDPOINT}     ?endpoint=changePassword

# User Management Endpoints
${USER_PROFILE_ENDPOINT}        ?endpoint=profile
${UPDATE_PROFILE_ENDPOINT}      ?endpoint=updateProfile
${DELETE_ACCOUNT_ENDPOINT}      ?endpoint=deleteAccount
${USER_PREFERENCES_ENDPOINT}    ?endpoint=preferences
${USER_STATISTICS_ENDPOINT}     ?endpoint=userStats

# Vocabulary Endpoints
${VOCABULARY_LIST_ENDPOINT}     ?endpoint=vocabulario
${VOCABULARY_SEARCH_ENDPOINT}   ?endpoint=vocabulario&search=
${VOCABULARY_FAVORITES_ENDPOINT}   ?endpoint=favoritos
${VOCABULARY_LEARNED_ENDPOINT}  ?endpoint=aprendidas
${VOCABULARY_DIFFICULTY_ENDPOINT}   ?endpoint=vocabulario&difficulty=

# Custom Vocabulary Endpoints
${CUSTOM_VOCAB_LIST_ENDPOINT}   ?endpoint=customVocabulary
${CUSTOM_VOCAB_CREATE_ENDPOINT} ?endpoint=customVocabulary
${CUSTOM_VOCAB_UPDATE_ENDPOINT} ?endpoint=customVocabulary
${CUSTOM_VOCAB_DELETE_ENDPOINT} ?endpoint=customVocabulary
${CUSTOM_VOCAB_IMPORT_ENDPOINT} ?endpoint=importVocabulary
${CUSTOM_VOCAB_EXPORT_ENDPOINT} ?endpoint=exportVocabulary

# My Words Endpoints
${MY_WORDS_LIST_ENDPOINT}       ?endpoint=myWords
${MY_WORDS_ADD_ENDPOINT}        ?endpoint=myWords
${MY_WORDS_REMOVE_ENDPOINT}     ?endpoint=myWords
${MY_WORDS_UPDATE_ENDPOINT}     ?endpoint=myWords
${MY_WORDS_SEARCH_ENDPOINT}     ?endpoint=myWords&search=

# Folder Management Endpoints
${FOLDERS_LIST_ENDPOINT}        ?endpoint=folders
${FOLDERS_CREATE_ENDPOINT}      ?endpoint=folders
${FOLDERS_UPDATE_ENDPOINT}      ?endpoint=folders
${FOLDERS_DELETE_ENDPOINT}      ?endpoint=folders
${FOLDERS_MOVE_WORDS_ENDPOINT}  ?endpoint=folders/moveWords
${FOLDERS_EMPTY_ENDPOINT}       ?endpoint=folders/empty

# Grammar Endpoints
${GRAMMAR_EXERCISES_ENDPOINT}   ?endpoint=grammarExercises
${GRAMMAR_SUBMIT_ENDPOINT}      ?endpoint=grammarSubmit
${GRAMMAR_PROGRESS_ENDPOINT}    ?endpoint=grammarProgress
${GRAMMAR_RESULTS_ENDPOINT}     ?endpoint=grammarResults
${GRAMMAR_CATEGORIES_ENDPOINT}  ?endpoint=grammarCategories

# Game Session Endpoints
${GAME_START_ENDPOINT}          ?endpoint=gameStart
${GAME_ANSWER_ENDPOINT}         ?endpoint=gameAnswer
${GAME_END_ENDPOINT}            ?endpoint=gameEnd
${GAME_STATISTICS_ENDPOINT}     ?endpoint=gameStats
${GAME_LEADERBOARD_ENDPOINT}    ?endpoint=leaderboard

# Content Management Endpoints
${CONTENT_SEARCH_ENDPOINT}      ?endpoint=search
${CONTENT_FILTER_ENDPOINT}      ?endpoint=filter
${CONTENT_CATEGORIES_ENDPOINT}  ?endpoint=categories
${CONTENT_TAGS_ENDPOINT}        ?endpoint=tags

# Admin Endpoints
${ADMIN_USERS_ENDPOINT}         ?endpoint=admin/users
${ADMIN_CONTENT_ENDPOINT}       ?endpoint=admin/content
${ADMIN_STATISTICS_ENDPOINT}    ?endpoint=admin/statistics
${ADMIN_LOGS_ENDPOINT}          ?endpoint=admin/logs

# System Endpoints
${HEALTH_CHECK_ENDPOINT}        ?endpoint=health
${VERSION_ENDPOINT}             ?endpoint=version
${CONFIG_ENDPOINT}              ?endpoint=config
${MAINTENANCE_ENDPOINT}         ?endpoint=maintenance

# File Upload Endpoints
${UPLOAD_AVATAR_ENDPOINT}       ?endpoint=uploadAvatar
${UPLOAD_VOCABULARY_ENDPOINT}   ?endpoint=uploadVocabulary
${UPLOAD_AUDIO_ENDPOINT}        ?endpoint=uploadAudio

# Export/Import Endpoints
${EXPORT_DATA_ENDPOINT}         ?endpoint=exportData
${IMPORT_DATA_ENDPOINT}         ?endpoint=importData
${BACKUP_ENDPOINT}              ?endpoint=backup
${RESTORE_ENDPOINT}             ?endpoint=restore

# Notification Endpoints
${NOTIFICATIONS_ENDPOINT}       ?endpoint=notifications
${MARK_READ_ENDPOINT}           ?endpoint=markNotificationRead
${NOTIFICATION_SETTINGS_ENDPOINT}   ?endpoint=notificationSettings

# Analytics Endpoints
${ANALYTICS_EVENTS_ENDPOINT}    ?endpoint=analytics/events
${ANALYTICS_USAGE_ENDPOINT}     ?endpoint=analytics/usage
${ANALYTICS_PERFORMANCE_ENDPOINT}   ?endpoint=analytics/performance

# Third Party Integration Endpoints
${GOOGLE_AUTH_ENDPOINT}         ?endpoint=auth/google
${FACEBOOK_AUTH_ENDPOINT}       ?endpoint=auth/facebook
${GOOGLE_TRANSLATE_ENDPOINT}    ?endpoint=translate
${DICTIONARY_API_ENDPOINT}      ?endpoint=dictionary

# Rate Limiting Endpoints
${RATE_LIMIT_STATUS_ENDPOINT}   ?endpoint=rateLimitStatus
${RATE_LIMIT_RESET_ENDPOINT}    ?endpoint=rateLimitReset

# Cache Management Endpoints
${CACHE_CLEAR_ENDPOINT}         ?endpoint=clearCache
${CACHE_STATUS_ENDPOINT}        ?endpoint=cacheStatus

# API Documentation Endpoints
${API_DOCS_ENDPOINT}            ?endpoint=docs
${API_SCHEMA_ENDPOINT}          ?endpoint=schema
${API_HEALTH_ENDPOINT}          ?endpoint=api/health

# Webhook Endpoints
${WEBHOOK_REGISTER_ENDPOINT}    ?endpoint=webhook/register
${WEBHOOK_UNREGISTER_ENDPOINT}  ?endpoint=webhook/unregister
${WEBHOOK_LIST_ENDPOINT}        ?endpoint=webhook/list

# Pagination Parameters
${PAGE_PARAM}                   &page=
${LIMIT_PARAM}                  &limit=
${OFFSET_PARAM}                 &offset=
${SORT_PARAM}                   &sort=
${ORDER_PARAM}                  &order=

# Filter Parameters
${SEARCH_PARAM}                 &search=
${CATEGORY_PARAM}               &category=
${TAG_PARAM}                    &tag=
${DIFFICULTY_PARAM}             &difficulty=
${LANGUAGE_PARAM}               &language=
${STATUS_PARAM}                 &status=

# Common Query Parameters
${FORMAT_PARAM}                 &format=
${INCLUDE_PARAM}                &include=
${EXCLUDE_PARAM}                &exclude=
${FIELDS_PARAM}                 &fields=
${EXPAND_PARAM}                 &expand=