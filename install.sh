#!/bin/bash

# WordMate Robot Framework QA Automation - Installation Script for macOS
# This script automates the installation process for the test automation framework

set -e  # Exit on any error

echo "🚀 WordMate Robot Framework QA Automation - Installation Script"
echo "================================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${BLUE}➜${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if Homebrew is installed
print_status "Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for M1 Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_success "Homebrew is already installed"
fi

# Update Homebrew
print_status "Updating Homebrew..."
brew update

# Install Python 3.11 if not already installed
print_status "Checking Python installation..."
if ! command -v python3 &> /dev/null || [[ $(python3 -c "import sys; print(sys.version_info >= (3, 8))") == "False" ]]; then
    print_warning "Python 3.8+ not found. Installing Python 3.11..."
    brew install python@3.11
    
    # Create symlink if needed
    if ! command -v python3 &> /dev/null; then
        ln -sf /opt/homebrew/bin/python3.11 /opt/homebrew/bin/python3
    fi
else
    PYTHON_VERSION=$(python3 --version)
    print_success "Python is installed: $PYTHON_VERSION"
fi

# Install Git if not already installed
print_status "Checking Git installation..."
if ! command -v git &> /dev/null; then
    print_warning "Git not found. Installing Git..."
    brew install git
else
    print_success "Git is already installed"
fi

# Install browsers
print_status "Installing browsers..."

# Chrome
if ! brew list --cask google-chrome &> /dev/null; then
    print_status "Installing Google Chrome..."
    brew install --cask google-chrome
else
    print_success "Google Chrome is already installed"
fi

# Firefox
if ! brew list --cask firefox &> /dev/null; then
    print_status "Installing Firefox..."
    brew install --cask firefox
else
    print_success "Firefox is already installed"
fi

# Install Visual Studio Code if not already installed
print_status "Checking Visual Studio Code installation..."
if ! brew list --cask visual-studio-code &> /dev/null; then
    print_warning "Visual Studio Code not found. Installing..."
    brew install --cask visual-studio-code
else
    print_success "Visual Studio Code is already installed"
fi

# Create virtual environment
print_status "Creating Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    print_success "Virtual environment created"
else
    print_success "Virtual environment already exists"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install Python dependencies
print_status "Installing Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    print_success "Dependencies installed from requirements.txt"
else
    print_warning "requirements.txt not found. Installing basic dependencies..."
    pip install robotframework robotframework-seleniumlibrary robotframework-requests selenium webdriver-manager
fi

# Setup WebDrivers
print_status "Setting up WebDrivers..."
if [ -f "scripts/setup_environment.py" ]; then
    python scripts/setup_environment.py
else
    print_status "Installing WebDrivers using webdriver-manager..."
    python -c "
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
print('Installing ChromeDriver...')
ChromeDriverManager().install()
print('Installing GeckoDriver...')
GeckoDriverManager().install()
print('WebDrivers installed successfully!')
"
fi

# Install VS Code extensions
print_status "Installing VS Code extensions..."
EXTENSIONS=(
    "robocorp.robotframework-lsp"
    "ms-python.python"
    "ms-python.debugpy"
    "redhat.vscode-yaml"
    "donjayamanne.githistory"
)

for extension in "${EXTENSIONS[@]}"; do
    if code --list-extensions | grep -q "$extension"; then
        print_success "$extension is already installed"
    else
        print_status "Installing $extension..."
        code --install-extension "$extension"
    fi
done

# Create necessary directories
print_status "Creating project directories..."
mkdir -p {reports,logs,drivers,docs}
mkdir -p reports/{html,xml,screenshots}
mkdir -p config/{environments,test_data}
mkdir -p resources/{keywords,libraries,locators,variables}
mkdir -p tests/{api,ui,integration,smoke}

# Validate installation
print_status "Validating installation..."

# Check Python and Robot Framework
if python --version &> /dev/null && robot --version &> /dev/null; then
    print_success "Python and Robot Framework are working"
else
    print_error "Python or Robot Framework validation failed"
fi

# Check browsers
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
FIREFOX_PATH="/Applications/Firefox.app/Contents/MacOS/firefox"

if [ -f "$CHROME_PATH" ]; then
    print_success "Google Chrome is available"
else
    print_warning "Google Chrome not found at expected location"
fi

if [ -f "$FIREFOX_PATH" ]; then
    print_success "Firefox is available"
else
    print_warning "Firefox not found at expected location"
fi

# Create activation script
print_status "Creating activation script..."
cat > activate_env.sh << 'EOF'
#!/bin/bash
echo "🚀 Activating WordMate Test Environment..."
source venv/bin/activate
echo "✅ Environment activated"
echo ""
echo "Available commands:"
echo "  robot --version                              # Check Robot Framework version"
echo "  python scripts/run_tests.py --help          # View test runner options"
echo "  python scripts/setup_environment.py --help  # View setup options"
echo "  python scripts/generate_report.py --help    # View report generator options"
echo ""
echo "Quick start:"
echo "  python scripts/run_tests.py --env dev --suite smoke"
echo ""
EOF

chmod +x activate_env.sh

print_success "Installation completed successfully!"
echo ""
echo "================================================================"
echo "🎉 WordMate Robot Framework QA Automation is ready!"
echo "================================================================"
echo ""
echo "Next steps:"
echo "1. Activate the environment: source activate_env.sh"
echo "2. Open VS Code: code ."
echo "3. Create your configuration files (environments, test data)"
echo "4. Run validation: python scripts/setup_environment.py --validate-only"
echo "5. Run smoke tests: python scripts/run_tests.py --env dev --suite smoke"
echo ""
echo "For more information, check the README.md file"
echo ""