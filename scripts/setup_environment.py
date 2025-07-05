#!/usr/bin/env python3
"""
WordMate Test Environment Setup Script

This script sets up the test environment by installing necessary
browser drivers, validating dependencies, and configuring the
test execution environment.

Usage:
    python scripts/setup_environment.py
    python scripts/setup_environment.py --update-drivers
    python scripts/setup_environment.py --validate-only
"""

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path
from urllib.parse import urljoin

import requests

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))


class EnvironmentSetup:
    """Environment setup manager for WordMate test automation"""

    def __init__(self):
        self.project_root = project_root
        self.drivers_dir = self.project_root / "drivers"
        self.logs_dir = self.project_root / "logs"
        self.reports_dir = self.project_root / "reports"
        self.system = platform.system().lower()
        self.architecture = platform.machine().lower()

        # Driver download URLs
        self.driver_urls = {
            "chrome": {
                "base_url": "https://chromedriver.storage.googleapis.com/",
                "latest_url": "https://chromedriver.storage.googleapis.com/LATEST_RELEASE",
            },
            "firefox": {
                "base_url": "https://github.com/mozilla/geckodriver/releases/download/",
                "api_url": "https://api.github.com/repos/mozilla/geckodriver/releases/latest",
            },
            "edge": {
                "base_url": "https://msedgedriver.azureedge.net/",
                "api_url": "https://api.github.com/repos/MicrosoftEdge/EdgeWebDriver/releases/latest",
            },
        }

    def setup_directories(self):
        """Create necessary directories for test execution"""
        directories = [
            self.drivers_dir,
            self.logs_dir,
            self.reports_dir,
            self.reports_dir / "html",
            self.reports_dir / "xml",
            self.reports_dir / "screenshots",
        ]

        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"✓ Created directory: {directory}")

    def validate_python_version(self):
        """Validate Python version requirements"""
        required_version = (3, 8)
        current_version = sys.version_info[:2]

        if current_version < required_version:
            print(f"❌ Python {required_version[0]}.{required_version[1]}+ required")
            print(f"   Current version: {current_version[0]}.{current_version[1]}")
            return False

        print(f"✓ Python version: {current_version[0]}.{current_version[1]}")
        return True

    def validate_dependencies(self):
        """Validate required Python packages are installed"""
        required_packages = [
            "robotframework",
            "robotframework-seleniumlibrary",
            "robotframework-requests",
            "selenium",
            "requests",
            "pyyaml",
        ]

        missing_packages = []

        for package in required_packages:
            try:
                __import__(package.replace("-", "_"))
                print(f"✓ {package}")
            except ImportError:
                missing_packages.append(package)
                print(f"❌ {package} - Not installed")

        if missing_packages:
            print(f"\nMissing packages: {', '.join(missing_packages)}")
            print("Install with: pip install -r requirements.txt")
            return False

        return True

    def get_chrome_driver_url(self):
        """Get Chrome driver download URL for current platform"""
        try:
            # Get latest version
            response = requests.get(self.driver_urls["chrome"]["latest_url"])
            version = response.text.strip()

            # Determine platform-specific filename
            if self.system == "windows":
                filename = "chromedriver_win32.zip"
            elif self.system == "darwin":  # macOS
                if "arm64" in self.architecture or "m1" in self.architecture:
                    filename = "chromedriver_mac_arm64.zip"
                else:
                    filename = "chromedriver_mac64.zip"
            else:  # Linux
                filename = "chromedriver_linux64.zip"

            url = f"{self.driver_urls['chrome']['base_url']}{version}/{filename}"
            return url, version

        except Exception as e:
            print(f"Failed to get Chrome driver URL: {e}")
            return None, None

    def get_firefox_driver_url(self):
        """Get Firefox driver download URL for current platform"""
        try:
            # Get latest release info
            response = requests.get(self.driver_urls["firefox"]["api_url"])
            release_info = response.json()
            version = release_info["tag_name"]

            # Find platform-specific asset
            for asset in release_info["assets"]:
                name = asset["name"].lower()
                if self.system == "windows" and "win" in name and name.endswith(".zip"):
                    return asset["browser_download_url"], version
                elif (
                    self.system == "darwin"
                    and "macos" in name
                    and name.endswith(".tar.gz")
                ):
                    return asset["browser_download_url"], version
                elif (
                    self.system == "linux"
                    and "linux" in name
                    and name.endswith(".tar.gz")
                ):
                    return asset["browser_download_url"], version

            return None, None

        except Exception as e:
            print(f"Failed to get Firefox driver URL: {e}")
            return None, None

    def download_and_extract_driver(self, url, driver_name, version):
        """Download and extract WebDriver"""
        try:
            print(f"Downloading {driver_name} driver v{version}...")

            # Download file
            response = requests.get(url, stream=True)
            filename = url.split("/")[-1]
            file_path = self.drivers_dir / filename

            with open(file_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

            print(f"✓ Downloaded: {filename}")

            # Extract file
            if filename.endswith(".zip"):
                with zipfile.ZipFile(file_path, "r") as zip_ref:
                    zip_ref.extractall(self.drivers_dir)
            elif filename.endswith(".tar.gz"):
                with tarfile.open(file_path, "r:gz") as tar_ref:
                    tar_ref.extractall(self.drivers_dir)

            # Make executable on Unix systems
            if self.system != "windows":
                driver_executable = self.drivers_dir / driver_name
                if driver_executable.exists():
                    os.chmod(driver_executable, 0o755)

                # Also check for geckodriver
                geckodriver = self.drivers_dir / "geckodriver"
                if geckodriver.exists():
                    os.chmod(geckodriver, 0o755)

            # Clean up downloaded archive
            file_path.unlink()

            print(f"✓ Extracted {driver_name} driver")
            return True

        except Exception as e:
            print(f"❌ Failed to download {driver_name} driver: {e}")
            return False

    def install_chrome_driver(self):
        """Install Chrome WebDriver"""
        url, version = self.get_chrome_driver_url()
        if url and version:
            return self.download_and_extract_driver(url, "chromedriver", version)
        return False

    def install_firefox_driver(self):
        """Install Firefox WebDriver (geckodriver)"""
        url, version = self.get_firefox_driver_url()
        if url and version:
            return self.download_and_extract_driver(url, "geckodriver", version)
        return False

    def check_browser_installation(self):
        """Check if browsers are installed on the system"""
        browsers = {
            "chrome": ["google-chrome", "chrome", "chromium", "google-chrome-stable"],
            "firefox": ["firefox"],
            "edge": ["microsoft-edge", "msedge"],
        }

        installed_browsers = []

        for browser, commands in browsers.items():
            for command in commands:
                try:
                    if self.system == "windows":
                        subprocess.run(
                            ["where", command], capture_output=True, check=True
                        )
                    else:
                        subprocess.run(
                            ["which", command], capture_output=True, check=True
                        )

                    installed_browsers.append(browser)
                    print(f"✓ {browser.title()} browser found")
                    break
                except subprocess.CalledProcessError:
                    continue
            else:
                print(f"⚠ {browser.title()} browser not found")

        return installed_browsers

    def update_path_environment(self):
        """Add drivers directory to PATH environment variable"""
        drivers_path = str(self.drivers_dir.absolute())
        current_path = os.environ.get("PATH", "")

        if drivers_path not in current_path:
            print(f"\n📝 Add to your PATH environment variable:")
            print(f"   {drivers_path}")
            print("\nFor current session:")
            if self.system == "windows":
                print(f"   set PATH=%PATH%;{drivers_path}")
            else:
                print(f"   export PATH=$PATH:{drivers_path}")

    def create_environment_script(self):
        """Create environment activation script"""
        if self.system == "windows":
            script_name = "activate_test_env.bat"
            script_content = f"""@echo off
echo Activating WordMate Test Environment...
set PATH=%PATH%;{self.drivers_dir.absolute()}
echo ✓ Test environment activated
echo.
echo Available commands:
echo   robot --version
echo   python scripts/run_tests.py --help
echo.
"""
        else:
            script_name = "activate_test_env.sh"
            script_content = f"""#!/bin/bash
echo "Activating WordMate Test Environment..."
export PATH=$PATH:{self.drivers_dir.absolute()}
echo "✓ Test environment activated"
echo ""
echo "Available commands:"
echo "  robot --version"
echo "  python scripts/run_tests.py --help"
echo ""
"""

        script_path = self.project_root / script_name
        with open(script_path, "w") as f:
            f.write(script_content)

        if self.system != "windows":
            os.chmod(script_path, 0o755)

        print(f"✓ Created environment script: {script_name}")

    def validate_driver_installation(self):
        """Validate that WebDrivers are properly installed"""
        drivers_to_check = [
            ("chromedriver", "chromedriver"),
            ("geckodriver", "geckodriver"),
        ]

        valid_drivers = []

        for driver_name, executable in drivers_to_check:
            driver_path = self.drivers_dir / executable
            if self.system == "windows":
                driver_path = driver_path.with_suffix(".exe")

            if driver_path.exists() and os.access(driver_path, os.X_OK):
                try:
                    # Test driver execution
                    result = subprocess.run(
                        [str(driver_path), "--version"],
                        capture_output=True,
                        text=True,
                        timeout=10,
                    )

                    if result.returncode == 0:
                        version_info = result.stdout.strip().split("\n")[0]
                        print(f"✓ {driver_name}: {version_info}")
                        valid_drivers.append(driver_name)
                    else:
                        print(f"❌ {driver_name}: Failed to execute")

                except subprocess.TimeoutExpired:
                    print(f"❌ {driver_name}: Execution timeout")
                except Exception as e:
                    print(f"❌ {driver_name}: {e}")
            else:
                print(f"❌ {driver_name}: Not found or not executable")

        return valid_drivers

    def create_config_validation(self):
        """Create configuration validation report"""
        validation_report = {
            "timestamp": str(Path(__file__).stat().st_mtime),
            "system": {
                "platform": platform.platform(),
                "python_version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
                "architecture": platform.architecture()[0],
            },
            "directories": {
                "drivers": str(self.drivers_dir),
                "logs": str(self.logs_dir),
                "reports": str(self.reports_dir),
            },
            "browsers": self.check_browser_installation(),
            "drivers": self.validate_driver_installation(),
        }

        config_file = self.project_root / "environment_validation.json"
        with open(config_file, "w") as f:
            json.dump(validation_report, f, indent=2)

        print(f"✓ Created validation report: environment_validation.json")
        return validation_report

    def run_setup(self, update_drivers=False, validate_only=False):
        """Run complete environment setup"""
        print("🚀 WordMate Test Environment Setup")
        print("=" * 50)

        # Validation steps
        print("\n1. Validating Python environment...")
        if not self.validate_python_version():
            return False

        print("\n2. Validating dependencies...")
        if not self.validate_dependencies():
            return False

        if validate_only:
            print("\n✓ Validation complete!")
            return True

        # Setup steps
        print("\n3. Setting up directories...")
        self.setup_directories()

        print("\n4. Checking browser installations...")
        installed_browsers = self.check_browser_installation()

        if update_drivers or not self.validate_driver_installation():
            print("\n5. Installing WebDrivers...")

            if "chrome" in installed_browsers:
                if self.install_chrome_driver():
                    print("✓ Chrome driver installed")
                else:
                    print("❌ Chrome driver installation failed")

            if "firefox" in installed_browsers:
                if self.install_firefox_driver():
                    print("✓ Firefox driver installed")
                else:
                    print("❌ Firefox driver installation failed")

        print("\n6. Validating driver installations...")
        valid_drivers = self.validate_driver_installation()

        print("\n7. Creating environment scripts...")
        self.create_environment_script()

        print("\n8. Creating validation report...")
        self.create_config_validation()

        print("\n9. Environment configuration...")
        self.update_path_environment()

        print("\n" + "=" * 50)
        print("🎉 Environment setup complete!")
        print(f"   Valid drivers: {', '.join(valid_drivers)}")
        print(f"   Browsers found: {', '.join(installed_browsers)}")
        print("\nNext steps:")
        print("  1. Run validation: python scripts/run_tests.py --list-tests")
        print(
            "  2. Run smoke tests: python scripts/run_tests.py --env dev --suite smoke"
        )

        return True


def create_argument_parser():
    """Create command line argument parser"""
    parser = argparse.ArgumentParser(
        description="WordMate Test Environment Setup",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                          # Full setup
  %(prog)s --update-drivers         # Update WebDrivers
  %(prog)s --validate-only          # Validation only
        """,
    )

    parser.add_argument(
        "--update-drivers",
        action="store_true",
        help="Force update of WebDriver installations",
    )

    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Only validate environment without making changes",
    )

    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")

    return parser


def main():
    """Main entry point"""
    parser = create_argument_parser()
    args = parser.parse_args()

    setup = EnvironmentSetup()

    try:
        success = setup.run_setup(
            update_drivers=args.update_drivers, validate_only=args.validate_only
        )

        return 0 if success else 1

    except KeyboardInterrupt:
        print("\n\n⚠ Setup interrupted by user")
        return 1
    except Exception as e:
        print(f"\n\n❌ Setup failed: {e}")
        if args.verbose:
            import traceback

            traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
