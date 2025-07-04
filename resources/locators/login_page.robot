*** Settings ***
Documentation    Page locators for WordMate login page

*** Variables ***
# Login Form Elements
${LOGIN_FORM}                       css:#loginForm
${LOGIN_USERNAME_INPUT}             css:#username
${LOGIN_PASSWORD_INPUT}             css:#password
${LOGIN_SUBMIT_BUTTON}              css:#loginBtn
${LOGIN_CANCEL_BUTTON}              css:.cancel-btn

# Remember Me and Forgot Password
${REMEMBER_ME_CHECKBOX}             css:#rememberMe
${REMEMBER_ME_LABEL}                css:label[for="rememberMe"]
${FORGOT_PASSWORD_LINK}             css:#forgotPasswordLink
${PASSWORD_VISIBILITY_TOGGLE}       css:.password-toggle

# Social Login Elements
${SOCIAL_LOGIN_SECTION}             css:.social-login
${GOOGLE_LOGIN_BUTTON}              css:#googleLoginBtn
${FACEBOOK_LOGIN_BUTTON}            css:#facebookLoginBtn
${SOCIAL_LOGIN_DIVIDER}             css:.social-divider

# Error and Success Messages
${LOGIN_ERROR_MESSAGE}              css:.login-error
${LOGIN_SUCCESS_MESSAGE}            css:.login-success
${FIELD_ERROR_MESSAGE}              css:.field-error
${EMAIL_ERROR_MESSAGE}              css:.email-error
${PASSWORD_ERROR_MESSAGE}           css:.password-error

# Form Validation Elements
${REQUIRED_FIELD_INDICATOR}         css:.required
${INPUT_VALIDATION_ERROR}           css:.is-invalid
${INPUT_VALIDATION_SUCCESS}         css:.is-valid
${VALIDATION_FEEDBACK}              css:.invalid-feedback

# Loading and State Elements
${LOGIN_LOADING_SPINNER}            css:.login-loading
${LOGIN_BUTTON_LOADING}             css:#loginBtn.loading
${FORM_DISABLED_STATE}              css:#loginForm.disabled

# Registration Links
${REGISTER_LINK}                    css:#registerLink
${REGISTER_SECTION}                 css:.register-section
${CREATE_ACCOUNT_BUTTON}            css:#createAccountBtn

# Header and Navigation
${LOGIN_PAGE_HEADER}                css:.login-header
${LOGIN_PAGE_TITLE}                 css:h1.login-title
${WORDMATE_LOGO}                    css:.wordmate-logo
${BACK_TO_HOME_LINK}                css:.back-to-home

# Footer Elements
${LOGIN_PAGE_FOOTER}                css:.login-footer
${TERMS_OF_SERVICE_LINK}            css:#termsLink
${PRIVACY_POLICY_LINK}              css:#privacyLink
${SUPPORT_LINK}                     css:#supportLink

# Mobile Specific Elements
${MOBILE_LOGIN_CONTAINER}           css:.mobile-login
${MOBILE_FORM_WRAPPER}              css:.mobile-form-wrapper
${MOBILE_SOCIAL_BUTTONS}            css:.mobile-social-login

# Accessibility Elements
${SCREEN_READER_LOGIN_HELP}         css:.sr-only-login-help
${LOGIN_FORM_LEGEND}                css:legend.login-legend
${SKIP_TO_CONTENT_LINK}             css:.skip-to-content

# Additional Form Elements
${LOGIN_FORM_GROUP}                 css:.form-group
${INPUT_LABEL}                      css:.form-label
${INPUT_FIELD}                      css:.form-control
${FORM_CHECK}                       css:.form-check

# Security Elements
${CAPTCHA_CONTAINER}                css:.captcha-container
${SECURITY_NOTICE}                  css:.security-notice
${SSL_INDICATOR}                    css:.ssl-indicator

# Language Selection
${LANGUAGE_SELECTOR}                css:#languageSelector
${LANGUAGE_DROPDOWN}                css:.language-dropdown
${LANGUAGE_OPTION}                  css:.language-option

# Theme Elements
${DARK_MODE_TOGGLE}                 css:.dark-mode-toggle
${THEME_SELECTOR}                   css:.theme-selector

# Responsive Breakpoints
${DESKTOP_LOGIN_LAYOUT}             css:.desktop-login
${TABLET_LOGIN_LAYOUT}              css:.tablet-login
${MOBILE_LOGIN_LAYOUT}              css:.mobile-login

# Animation Elements
${FADE_IN_ANIMATION}                css:.fade-in
${SLIDE_IN_ANIMATION}               css:.slide-in
${LOGIN_TRANSITION}                 css:.login-transition

# Modal Elements (if login is in modal)
${LOGIN_MODAL}                      css:#loginModal
${LOGIN_MODAL_BACKDROP}             css:.modal-backdrop
${LOGIN_MODAL_CLOSE}                css:.modal-close

# Third Party Integration
${OAUTH_REDIRECT_CONTAINER}         css:.oauth-redirect
${OAUTH_LOADING}                    css:.oauth-loading
${OAUTH_ERROR}                      css:.oauth-error

# Form State Classes
${FORM_PRISTINE}                    css:.ng-pristine
${FORM_DIRTY}                       css:.ng-dirty
${FORM_VALID}                       css:.ng-valid
${FORM_INVALID}                     css:.ng-invalid

# Custom WordMate Elements
${WORDMATE_BRANDING}                css:.wordmate-branding
${LOGIN_FEATURES_LIST}              css:.login-features
${TESTIMONIAL_SECTION}              css:.login-testimonials
${LOGIN_BENEFITS}                   css:.login-benefits

# Debugging Elements
${DEBUG_INFO}                       css:.debug-info
${CONSOLE_MESSAGES}                 css:.console-messages
${ERROR_BOUNDARY}                   css:.error-boundary