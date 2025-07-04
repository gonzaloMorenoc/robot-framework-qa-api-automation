#!/usr/bin/env python3
"""
Dependency Installation Script for WordMate Robot Framework

This script handles compatible installation of dependencies
based on the Python version and platform.
"""

import sys
import subprocess
import platform
from pathlib import Path

def get_python_version():
    """Get Python version info"""
    return sys.version_info

def run_pip_command(command, package_name=""):
    """Run pip command with error handling"""
    try:
        print(f"Installing {package_name}...")
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        print(f"✅ {package_name} installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install {package_name}")
        print(f"Error: {e.stderr}")
        return False

def install_core_dependencies():
    """Install core Robot Framework dependencies"""
    python_version = get_python_version()
    print(f"Python version: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    # Upgrade pip first
    run_pip_command([sys.executable, "-m", "pip", "install", "--upgrade", "pip"], "pip")
    
    # Define compatible versions based on Python version
    if python_version >= (3, 12):
        # Python 3.12+
        packages = [
            "robotframework>=7.0",
            "selenium>=4.16.0", 
            "robotframework-seleniumlibrary>=6.1.0",
            "robotframework-requests>=0.9.0",
            "webdriver-manager>=4.0.0",
            "requests>=2.28.0",
            "pyyaml>=6.0"
        ]
    elif python_version >= (3, 9):
        # Python 3.9-3.11
        packages = [
            "robotframework>=6.0,<7.0",
            "selenium>=4.10.0,<4.16.0",
            "robotframework-seleniumlibrary>=6.0.0,<6.6.0",
            "robotframework-requests>=0.9.0", 
            "webdriver-manager>=3.8.0",
            "requests>=2.28.0",
            "pyyaml>=6.0"
        ]
    else:
        # Python 3.8
        packages = [
            "robotframework>=5.0,<6.0",
            "selenium>=4.5.0,<4.10.0",
            "robotframework-seleniumlibrary>=5.1.0,<6.0.0",
            "robotframework-requests>=0.9.0",
            "webdriver-manager>=3.5.0",
            "requests>=2.25.0",
            "pyyaml>=5.4"
        ]
    
    # Install packages one by one
    failed_packages = []
    for package in packages:
        package_name = package.split(">=")[0].split("==")[0]
        if not run_pip_command([sys.executable, "-m", "pip", "install", package], package_name):
            failed_packages.append(package_name)
    
    return failed_packages

def install_optional_dependencies():
    """Install optional dependencies"""
    optional_packages = [
        ("robotframework-pabot", "Parallel test execution"),
        ("jsonschema", "JSON validation"),
        ("faker", "Test data generation"),
        ("pandas", "Data manipulation"),
        ("openpyxl", "Excel file handling"),
        ("python-dotenv", "Environment variables")
    ]
    
    print("\nInstalling optional dependencies...")
    for package, description in optional_packages:
        if not run_pip_command([sys.executable, "-m", "pip", "install", package], f"{package} ({description})"):
            print(f"⚠️  Optional package {package} failed to install, continuing...")

def install_development_dependencies():
    """Install development dependencies"""
    dev_packages = [
        ("black", "Code formatting"),
        ("flake8", "Code linting"), 
        ("isort", "Import sorting"),
        ("pytest", "Testing framework")
    ]
    
    print("\nInstalling development dependencies...")
    for package, description in dev_packages:
        if not run_pip_command([sys.executable, "-m", "pip", "install", package], f"{package} ({description})"):
            print(f"⚠️  Development package {package} failed to install, continuing...")

def verify_installation():
    """Verify that key packages are working"""
    print("\nVerifying installation...")
    
    try:
        import robot
        print(f"✅ Robot Framework {robot.__version__} is working")
    except ImportError as e:
        print(f"❌ Robot Framework import failed: {e}")
        return False
    
    try:
        import selenium
        print(f"✅ Selenium {selenium.__version__} is working")
    except ImportError as e:
        print(f"❌ Selenium import failed: {e}")
        return False
    
    try:
        from SeleniumLibrary import SeleniumLibrary
        print("✅ SeleniumLibrary is working")
    except ImportError as e:
        print(f"❌ SeleniumLibrary import failed: {e}")
        return False
    
    try:
        import requests
        print(f"✅ Requests {requests.__version__} is working")
    except ImportError as e:
        print(f"❌ Requests import failed: {e}")
        return False
    
    return True

def main():
    """Main installation process"""
    print("🚀 WordMate Robot Framework - Dependency Installation")
    print("=" * 60)
    
    # Check if we're in a virtual environment
    if sys.prefix == sys.base_prefix:
        print("⚠️  Warning: Not in a virtual environment")
        response = input("Continue anyway? (y/N): ")
        if response.lower() != 'y':
            print("Please activate your virtual environment and try again")
            return 1
    
    # Install core dependencies
    print("\n📦 Installing core dependencies...")
    failed_core = install_core_dependencies()
    
    if failed_core:
        print(f"\n❌ Failed to install core packages: {', '.join(failed_core)}")
        print("Please try installing these manually:")
        for package in failed_core:
            print(f"  pip install {package}")
        return 1
    
    # Install optional dependencies
    install_optional_dependencies()
    
    # Ask about development dependencies
    response = input("\nInstall development dependencies? (y/N): ")
    if response.lower() == 'y':
        install_development_dependencies()
    
    # Verify installation
    if verify_installation():
        print("\n🎉 Installation completed successfully!")
        print("\nNext steps:")
        print("1. Run: python scripts/setup_environment.py")
        print("2. Validate: robot --version")
        print("3. Test: python scripts/run_tests.py --list-tests")
        return 0
    else:
        print("\n❌ Installation verification failed")
        print("Please check the errors above and try manual installation")
        return 1

if __name__ == "__main__":
    sys.exit(main())