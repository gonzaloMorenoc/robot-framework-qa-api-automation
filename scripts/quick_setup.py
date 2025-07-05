#!/usr/bin/env python3
"""
Quick Setup Script for WordMate Test Automation

This script guides users through the initial setup process
and creates necessary configuration files securely.
"""

import os
import sys
import getpass
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))


class QuickSetup:
    """Interactive setup for WordMate test automation"""

    def __init__(self):
        self.project_root = project_root
        self.env_file = self.project_root / ".env"
        self.env_vars = {}

    def print_welcome(self):
        """Print welcome message"""
        print("🚀 WordMate Test Automation - Quick Setup")
        print("=" * 50)
        print()
        print("This script will help you set up your testing environment")
        print("securely by creating a .env file with your credentials.")
        print()
        print("⚠️  IMPORTANT: Never commit the .env file to git!")
        print()

    def check_existing_env(self):
        """Check if .env file already exists"""
        if self.env_file.exists():
            print("⚠️  .env file already exists!")
            response = input("Do you want to overwrite it? (y/N): ")
            if response.lower() != "y":
                print("Setup cancelled.")
                return False
        return True

    def get_database_credentials(self):
        """Get database credentials"""
        print("\n📊 DATABASE CONFIGURATION")
        print("-" * 30)
        print("Enter your WordMate database credentials:")

        self.env_vars["DB_HOST"] = input("Database Host [localhost]: ") or "localhost"
        self.env_vars["DB_PORT"] = input("Database Port [3306]: ") or "3306"
        self.env_vars["DB_NAME"] = (
            input("Database Name [u796724541_englishAppDB]: ")
            or "u796724541_englishAppDB"
        )
        self.env_vars["DB_USERNAME"] = (
            input("Database Username [u796724541_adminGMC]: ") or "u796724541_adminGMC"
        )
        self.env_vars["DB_PASSWORD"] = getpass.getpass("Database Password: ")

    def get_test_credentials(self):
        """Get test user credentials"""
        print("\n👤 TEST USER CREDENTIALS")
        print("-" * 30)

        print("\nDevelopment Environment:")
        self.env_vars["DEV_TEST_USER"] = input("Dev Test User Email: ")
        self.env_vars["DEV_TEST_PASSWORD"] = getpass.getpass("Dev Test User Password: ")
        self.env_vars["DEV_ADMIN_USER"] = input("Dev Admin User Email: ")
        self.env_vars["DEV_ADMIN_PASSWORD"] = getpass.getpass(
            "Dev Admin User Password: "
        )

        print("\nProduction Environment:")
        use_prod = input("Do you want to configure production credentials now? (y/N): ")
        if use_prod.lower() == "y":
            self.env_vars["PROD_TEST_USER"] = input("Prod Test User Email: ")
            self.env_vars["PROD_TEST_PASSWORD"] = getpass.getpass(
                "Prod Test User Password: "
            )
            self.env_vars["PROD_ADMIN_USER"] = input("Prod Admin User Email: ")
            self.env_vars["PROD_ADMIN_PASSWORD"] = getpass.getpass(
                "Prod Admin User Password: "
            )
        else:
            print("⚠️  You can add production credentials later by editing .env")

    def get_jwt_secrets(self):
        """Get JWT secrets"""
        print("\n🔐 JWT CONFIGURATION")
        print("-" * 30)

        use_custom_jwt = input("Do you have custom JWT secrets? (y/N): ")
        if use_custom_jwt.lower() == "y":
            self.env_vars["JWT_SECRET_PROD"] = getpass.getpass(
                "Production JWT Secret: "
            )
            self.env_vars["JWT_REFRESH_SECRET_PROD"] = getpass.getpass(
                "Production Refresh Secret: "
            )
        else:
            print("ℹ️  Using default JWT secrets for development")

    def get_oauth_credentials(self):
        """Get OAuth credentials"""
        print("\n🔗 OAUTH CONFIGURATION")
        print("-" * 30)

        setup_oauth = input("Do you want to configure OAuth credentials? (y/N): ")
        if setup_oauth.lower() == "y":
            print("\nGoogle OAuth:")
            self.env_vars["GOOGLE_CLIENT_ID_PROD"] = input("Google Client ID: ")
            self.env_vars["GOOGLE_CLIENT_SECRET_PROD"] = getpass.getpass(
                "Google Client Secret: "
            )

            print("\nFacebook OAuth:")
            self.env_vars["FACEBOOK_APP_ID_PROD"] = input("Facebook App ID: ")
            self.env_vars["FACEBOOK_APP_SECRET_PROD"] = getpass.getpass(
                "Facebook App Secret: "
            )
        else:
            print("ℹ️  OAuth credentials skipped (can be added later)")

    def get_optional_services(self):
        """Get optional service credentials"""
        print("\n⚙️  OPTIONAL SERVICES")
        print("-" * 30)

        services = {
            "CI/CD": ["GITHUB_TOKEN", "SLACK_WEBHOOK_URL"],
            "BrowserStack": ["BROWSERSTACK_USERNAME", "BROWSERSTACK_ACCESS_KEY"],
            "Email Reports": ["REPORT_EMAIL_SENDER", "REPORT_EMAIL_PASSWORD"],
        }

        for service_name, vars_list in services.items():
            setup_service = input(f"Configure {service_name}? (y/N): ")
            if setup_service.lower() == "y":
                for var in vars_list:
                    if (
                        "password" in var.lower()
                        or "secret" in var.lower()
                        or "token" in var.lower()
                    ):
                        value = getpass.getpass(f"{var}: ")
                    else:
                        value = input(f"{var}: ")

                    if value.strip():
                        self.env_vars[var] = value

    def create_env_file(self):
        """Create .env file"""
        print("\n📝 CREATING .ENV FILE")
        print("-" * 30)

        content = "# WordMate Test Environment Variables\n"
        content += "# Generated by quick_setup.py\n"
        content += f"# Created: {os.popen('date').read().strip()}\n\n"

        # Group variables by category
        categories = {
            "Database Configuration": [
                "DB_HOST",
                "DB_PORT",
                "DB_NAME",
                "DB_USERNAME",
                "DB_PASSWORD",
            ],
            "Development Test Users": [
                "DEV_TEST_USER",
                "DEV_TEST_PASSWORD",
                "DEV_ADMIN_USER",
                "DEV_ADMIN_PASSWORD",
            ],
            "Production Test Users": [
                "PROD_TEST_USER",
                "PROD_TEST_PASSWORD",
                "PROD_ADMIN_USER",
                "PROD_ADMIN_PASSWORD",
            ],
            "JWT Secrets": ["JWT_SECRET_PROD", "JWT_REFRESH_SECRET_PROD"],
            "OAuth Configuration": [
                "GOOGLE_CLIENT_ID_PROD",
                "GOOGLE_CLIENT_SECRET_PROD",
                "FACEBOOK_APP_ID_PROD",
                "FACEBOOK_APP_SECRET_PROD",
            ],
            "CI/CD": ["GITHUB_TOKEN", "SLACK_WEBHOOK_URL"],
            "External Services": ["BROWSERSTACK_USERNAME", "BROWSERSTACK_ACCESS_KEY"],
            "Email Reports": ["REPORT_EMAIL_SENDER", "REPORT_EMAIL_PASSWORD"],
        }

        for category, vars_list in categories.items():
            category_vars = {k: v for k, v in self.env_vars.items() if k in vars_list}
            if category_vars:
                content += f"# {category}\n"
                for var, value in category_vars.items():
                    content += f"{var}={value}\n"
                content += "\n"

        # Write file
        try:
            with open(self.env_file, "w") as f:
                f.write(content)

            # Set restrictive permissions on Unix systems
            if os.name != "nt":  # Not Windows
                os.chmod(self.env_file, 0o600)

            print(f"✅ .env file created successfully: {self.env_file}")
            print("🔒 File permissions set to owner-only access")

        except Exception as e:
            print(f"❌ Error creating .env file: {e}")
            return False

        return True

    def validate_setup(self):
        """Validate the setup"""
        print("\n🔍 VALIDATING SETUP")
        print("-" * 30)

        try:
            # Import and run validation
            from validate_credentials import CredentialsValidator

            validator = CredentialsValidator()
            success = validator.run_validation()

            if success:
                print("✅ Setup validation successful!")
            else:
                print("⚠️  Some issues found during validation")

            return success

        except ImportError:
            print("⚠️  Could not run validation (missing dependencies)")
            return True
        except Exception as e:
            print(f"⚠️  Validation error: {e}")
            return True

    def print_next_steps(self):
        """Print next steps"""
        print("\n🎉 SETUP COMPLETE!")
        print("=" * 30)
        print()
        print("Next steps:")
        print("1. Validate environment:")
        print("   python scripts/validate_credentials.py")
        print()
        print("2. Test environment connectivity:")
        print("   python scripts/configure_environments.py")
        print()
        print("3. Run smoke tests:")
        print("   python scripts/run_tests.py --env dev --suite smoke")
        print()
        print("4. View available tests:")
        print("   python scripts/run_tests.py --list-tests")
        print()
        print("⚠️  IMPORTANT REMINDERS:")
        print("  • Never commit .env file to git")
        print("  • Keep your credentials secure")
        print("  • Use different passwords for dev/prod")
        print("  • Regularly rotate your credentials")

    def run_setup(self):
        """Run complete setup process"""
        try:
            self.print_welcome()

            if not self.check_existing_env():
                return False

            # Collect information
            self.get_database_credentials()
            self.get_test_credentials()
            self.get_jwt_secrets()
            self.get_oauth_credentials()
            self.get_optional_services()

            # Create .env file
            if not self.create_env_file():
                return False

            # Validate setup
            self.validate_setup()

            # Show next steps
            self.print_next_steps()

            return True

        except KeyboardInterrupt:
            print("\n\n⚠️  Setup interrupted by user")
            return False
        except Exception as e:
            print(f"\n❌ Setup failed: {e}")
            return False


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(
        description="Quick setup for WordMate test automation"
    )
    parser.add_argument(
        "--minimal",
        action="store_true",
        help="Minimal setup (database and test users only)",
    )

    args = parser.parse_args()

    setup = QuickSetup()

    if args.minimal:
        print("🚀 Running minimal setup...")
        # Could implement minimal setup logic here

    success = setup.run_setup()
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
