# Robot Framework QA API Automation - WordMate

Comprehensive test automation framework for WordMate application using Robot Framework, covering both API and UI testing across multiple environments.

## Features

- **Multi-Environment Support**: Development and Production environments
- **API Testing**: RESTful API testing with comprehensive coverage
- **UI Testing**: Cross-browser web interface testing
- **Parallel Execution**: Fast test execution using Pabot
- **Detailed Reporting**: HTML reports with screenshots and logs
- **CI/CD Integration**: GitHub Actions workflows
- **Database Testing**: MySQL database validation
- **Test Data Management**: YAML-based test data configuration

## Prerequisites

- Python 3.8 or higher
- pip (Python package installer)
- Git
- Chrome/Firefox/Edge browser
- Access to WordMate environments

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/wordmate/robot-framework-qa-api-automation.git
cd robot-framework-qa-api-automation
```

### 2. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Install Browser Drivers

```bash
python -m scripts.setup_environment
```

## Configuration

### Environment Configuration

Configure test environments in `config/environments/`:

- `dev.yaml` - Development environment settings
- `production.yaml` - Production environment settings

### Test Data Configuration

Modify test data files in `config/test_data/`:

- `users.yaml` - User credentials and test data
- `vocabulary.yaml` - Vocabulary test data
- `grammar.yaml` - Grammar exercise test data

## Usage

### Running Tests

#### Run All Tests

```bash
# Development environment
python scripts/run_tests.py --env dev

# Production environment
python scripts/run_tests.py --env production
```

#### Run Specific Test Suites

```bash
# API tests only
python scripts/run_tests.py --env dev --suite api

# UI tests only
python scripts/run_tests.py --env dev --suite ui

# Smoke tests
python scripts/run_tests.py --env dev --suite smoke
```

#### Run Tests by Tags

```bash
# Critical tests
robot --include critical tests/

# Authentication tests
robot --include auth tests/

# Regression tests
robot --include regression tests/
```

#### Parallel Execution

```bash
# Run tests in parallel (4 processes)
pabot --processes 4 --outputdir reports tests/
```

### Test Execution Examples

```bash
# Run login tests on development
robot --variable ENVIRONMENT:dev tests/ui/auth/login_ui_tests.robot

# Run API tests with specific browser
robot --variable BROWSER:chrome --variable ENVIRONMENT:dev tests/api/

# Run tests with custom report name
robot --outputdir reports --output custom_output.xml tests/
```

## Test Structure

### API Tests
- Authentication (login, registration, social login)
- Vocabulary management (CRUD operations, search)
- Grammar exercises and progress tracking
- User profile and preferences

### UI Tests
- User interface interactions
- Navigation and responsive design
- Cross-browser compatibility
- End-to-end user journeys

### Integration Tests
- Complete user workflows
- Database integration
- Performance validation

## Reporting

Test results are generated in multiple formats:

- **HTML Report**: `reports/html/report.html`
- **XML Output**: `reports/xml/output.xml`
- **Log Files**: `reports/html/log.html`
- **Screenshots**: `reports/screenshots/`

### Viewing Reports

```bash
# Generate and open HTML report
python scripts/generate_report.py --open

# View latest test results
open reports/html/report.html
```

## Development

### Adding New Tests

1. Create test file in appropriate directory
2. Follow naming convention: `*_tests.robot`
3. Use existing keywords from `resources/keywords/`
4. Add test data to `config/test_data/` if needed

### Creating Custom Keywords

1. Add keywords to appropriate files in `resources/keywords/`
2. Use descriptive names and proper documentation
3. Follow Robot Framework best practices

### Custom Libraries

Python libraries are located in `resources/libraries/`:

- `WordmateAPI.py` - API interaction utilities
- `DatabaseHelper.py` - Database operations
- `TestDataGenerator.py` - Dynamic test data generation

## CI/CD Integration

GitHub Actions workflows are configured in `.github/workflows/`:

- `ci.yml` - Continuous integration on pull requests
- `nightly.yml` - Scheduled nightly test runs

## Troubleshooting

### Common Issues

1. **Browser Driver Issues**
   ```bash
   python scripts/setup_environment.py --update-drivers
   ```

2. **Environment Variable Issues**
   ```bash
   # Check environment configuration
   robot --variable ENVIRONMENT:dev --dryrun tests/
   ```

3. **Database Connection Issues**
   - Verify database credentials in environment configuration
   - Check network connectivity to database server

### Debug Mode

```bash
# Run tests with debug logging
robot --loglevel DEBUG tests/

# Run single test with maximum logging
robot --loglevel TRACE --test "Test Name" tests/
```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request
