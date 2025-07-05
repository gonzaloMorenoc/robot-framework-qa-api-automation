#!/usr/bin/env python3
"""
Environment Configuration Script

This script helps configure and validate the test environments
for WordMate application without exposing sensitive data.
"""

import os
import sys
import time
from pathlib import Path
from typing import Any, Dict, Optional

import requests
import yaml

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))


class EnvironmentConfigurator:
    """Manages environment configuration and validation"""

    def __init__(self):
        self.project_root = project_root
        self.config_dir = self.project_root / "config" / "environments"

        self.environments = {
            "dev": {
                "name": "Development",
                "base_url": "https://www.wordmate.es/dev",
                "api_base_url": "https://www.wordmate.es/dev/php/api.php",
                "config_file": "dev.yaml",
            },
            "production": {
                "name": "Production",
                "base_url": "https://www.wordmate.es",
                "api_base_url": "https://www.wordmate.es/php/api.php",
                "config_file": "production.yaml",
            },
        }

    def load_environment_config(self, env_name: str) -> Optional[Dict[str, Any]]:
        """Load environment configuration"""
        if env_name not in self.environments:
            print(f"❌ Unknown environment: {env_name}")
            return None

        config_file = self.config_dir / self.environments[env_name]["config_file"]

        if not config_file.exists():
            print(f"❌ Config file not found: {config_file}")
            return None

        try:
            with open(config_file, "r") as f:
                # Expand environment variables in YAML
                content = f.read()
                # Simple environment variable substitution
                import re

                def replace_env_var(match):
                    var_name = match.group(1)
                    default_value = match.group(2) if match.group(2) else ""
                    return os.getenv(var_name, default_value)

                # Replace ${VAR:-default} patterns
                content = re.sub(
                    r"\$\{([^}:]+)(?::(-[^}]*))?\}", replace_env_var, content
                )
                # Replace ${VAR} patterns
                content = re.sub(
                    r"\$\{([^}]+)\}", lambda m: os.getenv(m.group(1), ""), content
                )

                config = yaml.safe_load(content)
                return config

        except Exception as e:
            print(f"❌ Error loading config: {e}")
            return None

    def check_url_accessibility(self, url: str, timeout: int = 30) -> Dict[str, Any]:
        """Check if URL is accessible"""
        result = {
            "accessible": False,
            "status_code": None,
            "response_time": None,
            "error": None,
        }

        try:
            start_time = time.time()
            response = requests.get(url, timeout=timeout, allow_redirects=True)
            end_time = time.time()

            result["accessible"] = True
            result["status_code"] = response.status_code
            result["response_time"] = round(end_time - start_time, 2)

            # Check if it's a WordMate page
            if "wordmate" in response.text.lower():
                result["is_wordmate"] = True
            else:
                result["is_wordmate"] = False
                result["warning"] = "Page doesn't appear to be WordMate"

        except requests.exceptions.Timeout:
            result["error"] = "Timeout"
        except requests.exceptions.ConnectionError:
            result["error"] = "Connection failed"
        except requests.exceptions.RequestException as e:
            result["error"] = str(e)
        except Exception as e:
            result["error"] = f"Unexpected error: {e}"

        return result

    def check_api_health(self, api_url: str) -> Dict[str, Any]:
        """Check API health endpoint"""
        health_url = f"{api_url}?endpoint=health"

        result = {
            "healthy": False,
            "status_code": None,
            "response_time": None,
            "error": None,
        }

        try:
            start_time = time.time()
            response = requests.get(health_url, timeout=10)
            end_time = time.time()

            result["status_code"] = response.status_code
            result["response_time"] = round(end_time - start_time, 2)

            if response.status_code == 200:
                try:
                    data = response.json()
                    result["healthy"] = True
                    result["api_data"] = data
                except:
                    result["healthy"] = True  # 200 is good enough

        except Exception as e:
            result["error"] = str(e)

        return result

    def test_environment_connectivity(self, env_name: str) -> Dict[str, Any]:
        """Test connectivity to environment"""
        if env_name not in self.environments:
            return {"error": f"Unknown environment: {env_name}"}

        env_info = self.environments[env_name]
        config = self.load_environment_config(env_name)

        if not config:
            return {"error": "Could not load environment configuration"}

        results = {
            "environment": env_name,
            "name": env_info["name"],
            "base_url_check": {},
            "api_health_check": {},
        }

        # Check base URL
        base_url = config["environment"]["base_url"]
        print(f"🌐 Checking {env_info['name']} base URL: {base_url}")
        results["base_url_check"] = self.check_url_accessibility(base_url)

        # Check API health
        api_url = config["environment"]["api_base_url"]
        print(f"🔗 Checking {env_info['name']} API: {api_url}")
        results["api_health_check"] = self.check_api_health(api_url)

        return results

    def validate_environment_config(self, env_name: str) -> Dict[str, Any]:
        """Validate environment configuration"""
        config = self.load_environment_config(env_name)

        if not config:
            return {"valid": False, "error": "Could not load configuration"}

        validation_result = {
            "valid": True,
            "errors": [],
            "warnings": [],
            "config_sections": {},
        }

        # Check required sections
        required_sections = [
            "environment",
            "web",
            "database",
            "authentication",
            "test_data",
        ]

        for section in required_sections:
            if section not in config:
                validation_result["errors"].append(f"Missing section: {section}")
                validation_result["valid"] = False
            else:
                validation_result["config_sections"][section] = "present"

        # Validate URLs
        if "environment" in config:
            base_url = config["environment"].get("base_url")
            api_url = config["environment"].get("api_base_url")

            if not base_url:
                validation_result["errors"].append("Missing base_url")
                validation_result["valid"] = False
            elif not base_url.startswith("https://"):
                validation_result["warnings"].append("base_url should use HTTPS")

            if not api_url:
                validation_result["errors"].append("Missing api_base_url")
                validation_result["valid"] = False
            elif not api_url.startswith("https://"):
                validation_result["warnings"].append("api_base_url should use HTTPS")

        # Check for placeholder values
        config_str = str(config)
        if "your_" in config_str.lower() or "example" in config_str.lower():
            validation_result["warnings"].append(
                "Configuration contains placeholder values"
            )

        return validation_result

    def print_environment_status(self, results: Dict[str, Any]) -> None:
        """Print environment status in a readable format"""
        env_name = results["environment"]
        env_display_name = results["name"]

        print(f"\n{'='*60}")
        print(f"🌍 {env_display_name.upper()} ENVIRONMENT STATUS")
        print(f"{'='*60}")

        # Base URL check
        base_check = results["base_url_check"]
        print(f"\n🌐 Base URL Accessibility:")
        if base_check.get("accessible"):
            print(f"  ✅ Status: Accessible ({base_check['status_code']})")
            print(f"  ⏱️  Response Time: {base_check['response_time']}s")
            if base_check.get("is_wordmate"):
                print(f"  ✅ WordMate Detection: Confirmed")
            else:
                print(f"  ⚠️  WordMate Detection: Not detected")
        else:
            print(f"  ❌ Status: Not accessible")
            print(f"  🚫 Error: {base_check.get('error', 'Unknown error')}")

        # API health check
        api_check = results["api_health_check"]
        print(f"\n🔗 API Health:")
        if api_check.get("healthy"):
            print(f"  ✅ Status: Healthy ({api_check['status_code']})")
            print(f"  ⏱️  Response Time: {api_check['response_time']}s")
            if api_check.get("api_data"):
                print(f"  📊 API Data: Available")
        else:
            print(f"  ❌ Status: Unhealthy")
            if api_check.get("status_code"):
                print(f"  📟 HTTP Status: {api_check['status_code']}")
            if api_check.get("error"):
                print(f"  🚫 Error: {api_check['error']}")

    def run_full_validation(self, env_name: str = None) -> bool:
        """Run full validation for environment(s)"""
        environments_to_check = (
            [env_name] if env_name else list(self.environments.keys())
        )
        all_healthy = True

        print("🔍 WordMate Environment Validation")
        print("=" * 60)

        for env in environments_to_check:
            print(f"\n📋 Validating {env} configuration...")

            # Validate configuration
            config_validation = self.validate_environment_config(env)
            if not config_validation["valid"]:
                print(f"❌ Configuration validation failed for {env}")
                for error in config_validation["errors"]:
                    print(f"   • {error}")
                all_healthy = False
                continue

            if config_validation["warnings"]:
                print(f"⚠️  Configuration warnings for {env}:")
                for warning in config_validation["warnings"]:
                    print(f"   • {warning}")

            # Test connectivity
            connectivity_results = self.test_environment_connectivity(env)
            if "error" in connectivity_results:
                print(
                    f"❌ Connectivity test failed for {env}: {connectivity_results['error']}"
                )
                all_healthy = False
                continue

            self.print_environment_status(connectivity_results)

            # Determine if environment is healthy
            base_accessible = connectivity_results["base_url_check"].get(
                "accessible", False
            )
            api_healthy = connectivity_results["api_health_check"].get("healthy", False)

            if not (base_accessible and api_healthy):
                all_healthy = False

        # Summary
        print(f"\n{'='*60}")
        print("📊 VALIDATION SUMMARY")
        print(f"{'='*60}")

        if all_healthy:
            print("🎉 All environments are healthy and ready for testing!")
        else:
            print("⚠️  Some environments have issues that need attention.")
            print("\n💡 Troubleshooting tips:")
            print("  1. Check your internet connection")
            print("  2. Verify environment variables are set correctly")
            print("  3. Ensure WordMate servers are running")
            print("  4. Contact WordMate team if servers are down")

        return all_healthy

    def list_environments(self) -> None:
        """List available environments"""
        print("🌍 Available Environments:")
        print("-" * 30)

        for env_key, env_info in self.environments.items():
            print(f"  {env_key:<12} - {env_info['name']}")
            print(f"  {'':>12}   {env_info['base_url']}")
            print()


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(
        description="Configure and validate WordMate environments"
    )
    parser.add_argument(
        "--environment",
        "-e",
        choices=["dev", "production"],
        help="Specific environment to validate",
    )
    parser.add_argument(
        "--list", action="store_true", help="List available environments"
    )
    parser.add_argument(
        "--connectivity-only",
        action="store_true",
        help="Test connectivity only, skip config validation",
    )

    args = parser.parse_args()

    configurator = EnvironmentConfigurator()

    if args.list:
        configurator.list_environments()
        return 0

    try:
        success = configurator.run_full_validation(args.environment)
        return 0 if success else 1
    except KeyboardInterrupt:
        print("\n⚠️  Validation interrupted by user")
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
