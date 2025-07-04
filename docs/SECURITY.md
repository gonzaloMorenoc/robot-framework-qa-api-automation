# 🔒 Security Guidelines for WordMate Test Automation

This document outlines security best practices and guidelines for the WordMate Robot Framework test automation project.

## 🚨 CRITICAL: Never Commit Credentials

**NEVER commit any of the following to the repository:**
- Passwords
- API keys
- JWT secrets
- OAuth credentials
- Database connection strings
- Personal access tokens
- Private keys
- `.env` files

## 🛡️ Security Setup Checklist

### ✅ Initial Setup

1. **Install Git Hooks** (Automatic credential detection)
   ```bash
   python scripts/install_git_hooks.py
   ```

2. **Create .env File** (Store credentials locally)
   ```bash
   python scripts/quick_setup.py
   # OR manually copy .env.example to .env and fill values
   cp .env.example .env
   ```

3. **Validate Configuration**
   ```bash
   python scripts/validate_credentials.py
   ```

4. **Test Environment Access**
   ```bash
   python scripts/configure_environments.py
   ```

### ✅ Files That Should NEVER Be Committed

- `.env` (local environment variables)
- `.env.*` (any environment file)
- `config/environments/local.yaml`
- `config/environments/secrets.yaml`
- `config/test_data/sensitive/`
- Any file containing `password`, `secret`, or `token` in the name
- Private keys (`.pem`, `.p12`, `.pfx`, `*_rsa`)

### ✅ Files That Are Safe to Commit

- `.env.example` (template without real values)
- `config/environments/dev.yaml` (using environment variables)
- `config/environments/production.yaml` (using environment variables)
- Test data files with placeholder values

## 🔐 Environment Variable Management

### Local Development (.env file)

Create a `.env` file in the project root:

```bash
# Database Configuration
DB_PASSWORD=<your_database_password>
DB_HOST=<your_database_host>
DB_NAME=<your_database_name>
DB_USERNAME=<your_database_username>

# Test User Credentials
DEV_TEST_USER=<your_dev_user_email>
DEV_TEST_PASSWORD=<your_dev_password>
PROD_TEST_USER=<your_prod_user_email>
PROD_TEST_PASSWORD=<your_prod_password>

# JWT Secrets
JWT_SECRET_PROD=<your_jwt_secret>
JWT_REFRESH_SECRET_PROD=<your_jwt_refresh_secret>

# OAuth Credentials
GOOGLE_CLIENT_ID_PROD=<your_google_client_id>
GOOGLE_CLIENT_SECRET_PROD=<your_google_client_secret>
```

### CI/CD Environments

For GitHub Actions, set secrets in repository settings:
1. Go to repository Settings → Secrets and variables → Actions
2. Add each environment variable as a repository secret
3. Reference in workflows using `${{ secrets.VARIABLE_NAME }}`

### Configuration Files

Use environment variable syntax in YAML files:

```yaml
database:
  password: "${DB_PASSWORD}"
  username: "${DB_USERNAME:-default_username}"
```

## 🔍 Security Validation Tools

### 1. Credential Validator
```bash
# Check if all required environment variables are set
python scripts/validate_credentials.py

# Generate .env template
python scripts/validate_credentials.py --generate-template
```

### 2. Environment Configurator
```bash
# Test connectivity to both environments
python scripts/configure_environments.py

# Test specific environment
python scripts/configure_environments.py --environment dev
```

### 3. Quick Setup
```bash
# Interactive setup for first-time configuration
python scripts/quick_setup.py
```

## 🚫 Git Hooks Protection

Pre-commit hooks automatically scan for:
- Forbidden files (`.env`, `secrets.json`, etc.)
- Hardcoded passwords in code
- API keys and tokens
- Sensitive patterns in file content

### Bypass Hooks (NOT RECOMMENDED)
```bash
# Only use in extreme circumstances
git commit --no-verify
git push --no-verify
```

### Hook Management
```bash
# Install hooks
python scripts/install_git_hooks.py

# Uninstall hooks
python scripts/install_git_hooks.py --uninstall

# Test hooks
python scripts/install_git_hooks.py --test
```

## 🌍 Environment Configuration

### Development Environment
- **URL**: `https://www.wordmate.es/dev`
- **API**: `https://www.wordmate.es/dev/php/api.php`
- **Purpose**: Safe testing with non-production data
- **Credentials**: Use `DEV_*` environment variables

### Production Environment
- **URL**: `https://www.wordmate.es`
- **API**: `https://www.wordmate.es/php/api.php`
- **Purpose**: Final validation before releases
- **Credentials**: Use `PROD_*` environment variables
- **⚠️ CAUTION**: Limited testing only, use readonly accounts when possible

## 🔒 Best Practices

### Password Security
- Use unique passwords for each environment
- Use strong passwords (12+ characters, mixed case, numbers, symbols)
- Never share passwords in plain text
- Rotate passwords regularly
- Use password managers

### API Key Security
- Limit API key permissions to minimum required
- Set expiration dates on keys when possible
- Monitor API key usage
- Revoke unused keys immediately

### Database Security
- Use read-only accounts for tests when possible
- Limit database access to specific IPs
- Use SSL connections
- Monitor database access logs

### Test Data Security
- Never use real customer data in tests
- Anonymize any production data used for testing
- Use synthetic test data generators
- Regularly clean up test data

## 🚨 Incident Response

### If Credentials Are Accidentally Committed:

1. **Immediate Actions**:
   ```bash
   # Remove from latest commit
   git reset HEAD~1
   git add -A
   git commit -m "Remove sensitive data"
   
   # If already pushed, force push (DANGER - coordinate with team)
   git push --force
   ```

2. **Credential Rotation**:
   - Change all exposed passwords immediately
   - Revoke and regenerate API keys
   - Update OAuth applications
   - Notify security team

3. **Repository Cleaning**:
   ```bash
   # Remove from entire git history (NUCLEAR OPTION)
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch .env' \
   --prune-empty --tag-name-filter cat -- --all
   ```

### If Suspicious Activity Detected:

1. Immediately rotate all credentials
2. Review access logs
3. Check for unauthorized changes
4. Notify team and stakeholders
5. Document incident

## 📋 Security Checklist for New Team Members

- [ ] Read this security document completely
- [ ] Install git hooks: `python scripts/install_git_hooks.py`
- [ ] Create `.env` file with proper credentials
- [ ] Verify `.env` is in `.gitignore`
- [ ] Run security validation: `python scripts/validate_credentials.py`
- [ ] Test environment access: `python scripts/configure_environments.py`
- [ ] Never commit real credentials
- [ ] Use environment variables in config files
- [ ] Understand incident response procedures

## 📞 Security Contact

For security-related questions or to report incidents:
- **Email**: security@wordmate.es
- **Slack**: #security-alerts
- **Emergency**: Contact team lead immediately

## 🔄 Regular Security Tasks

### Weekly
- [ ] Validate all environment variables are working
- [ ] Check for new security updates in dependencies
- [ ] Review git commit history for accidental credential commits

### Monthly
- [ ] Rotate test user passwords
- [ ] Review and clean up old API keys
- [ ] Update security documentation
- [ ] Test incident response procedures

### Quarterly
- [ ] Full security audit of test infrastructure
- [ ] Review and update access permissions
- [ ] Security training refresh for team

## 📚 Additional Resources

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [Git Security Best Practices](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Git_Security_Cheat_Sheet.md)
- [Environment Variables Security](https://blog.gitguardian.com/environment-variables/)

---

**Remember**: Security is everyone's responsibility. When in doubt, ask for help rather than risk exposing sensitive data.