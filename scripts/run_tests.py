#!/usr/bin/env python3
"""
WordMate Test Execution Script

This script provides a convenient way to run Robot Framework tests
for the WordMate application with various configuration options.

Usage:
    python scripts/run_tests.py --env dev --suite ui
    python scripts/run_tests.py --env production --parallel 4
    python scripts/run_tests.py --help
"""

import os
import sys
import argparse
import subprocess
import yaml
from datetime import datetime
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))


class WordMateTestRunner:
    """Test runner for WordMate Robot Framework tests"""

    def __init__(self):
        self.project_root = project_root
        self.config_dir = self.project_root / "config"
        self.reports_dir = self.project_root / "reports"
        self.tests_dir = self.project_root / "tests"

    def load_environment_config(self, environment):
        """Load environment configuration from YAML file"""
        config_file = self.config_dir / "environments" / f"{environment}.yaml"

        if not config_file.exists():
            raise FileNotFoundError(f"Environment config not found: {config_file}")

        with open(config_file, "r") as f:
            return yaml.safe_load(f)

    def create_reports_directory(self, environment):
        """Create reports directory for the environment"""
        env_reports_dir = self.reports_dir / environment
        env_reports_dir.mkdir(parents=True, exist_ok=True)

        # Create subdirectories
        (env_reports_dir / "html").mkdir(exist_ok=True)
        (env_reports_dir / "xml").mkdir(exist_ok=True)
        (env_reports_dir / "screenshots").mkdir(exist_ok=True)

        return env_reports_dir

    def build_robot_command(self, args, config):
        """Build Robot Framework command based on arguments and config"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        reports_dir = self.create_reports_directory(args.environment)

        # Base robot command
        cmd = ["robot"]

        # Output directory and files
        cmd.extend(
            [
                "--outputdir",
                str(reports_dir),
                "--output",
                f"output_{timestamp}.xml",
                "--log",
                f"log_{timestamp}.html",
                "--report",
                f"report_{timestamp}.html",
            ]
        )

        # Environment variables
        cmd.extend(
            [
                "--variable",
                f"ENVIRONMENT:{args.environment}",
                "--variable",
                f"BASE_URL:{config['environment']['base_url']}",
                "--variable",
                f"API_BASE_URL:{config['environment']['api_base_url']}",
                "--variable",
                f"BROWSER:{config['web']['browser']}",
                "--variable",
                f"HEADLESS:{config['web']['headless']}",
            ]
        )

        # Test tags
        if args.include_tags:
            for tag in args.include_tags:
                cmd.extend(["--include", tag])

        if args.exclude_tags:
            for tag in args.exclude_tags:
                cmd.extend(["--exclude", tag])

        # Log level
        if args.log_level:
            cmd.extend(["--loglevel", args.log_level])
        else:
            cmd.extend(["--loglevel", config["logging"]["level"]])

        # Parallel execution
        if args.parallel:
            # Use pabot for parallel execution
            cmd[0] = "pabot"
            cmd.extend(["--processes", str(args.parallel)])

        # Test execution mode
        if args.dryrun:
            cmd.append("--dryrun")

        # Suite selection
        if args.suite:
            test_path = self.tests_dir / args.suite
        elif args.test_file:
            test_path = Path(args.test_file)
        else:
            test_path = self.tests_dir

        cmd.append(str(test_path))

        return cmd

    def run_tests(self, args):
        """Execute Robot Framework tests"""
        try:
            # Load environment configuration
            config = self.load_environment_config(args.environment)

            # Build robot command
            cmd = self.build_robot_command(args, config)

            # Print command for debugging
            if args.verbose:
                print("Executing command:")
                print(" ".join(cmd))
                print("-" * 50)

            # Execute tests
            result = subprocess.run(cmd, cwd=self.project_root)

            # Print results summary
            reports_dir = self.reports_dir / args.environment
            print(f"\nTest execution completed!")
            print(f"Reports available in: {reports_dir}")
            print(f"Return code: {result.returncode}")

            return result.returncode

        except FileNotFoundError as e:
            print(f"Error: {e}")
            return 1
        except Exception as e:
            print(f"Unexpected error: {e}")
            return 1

    def list_available_tests(self):
        """List available test suites and files"""
        print("Available test suites:")
        print("-" * 30)

        for suite_dir in self.tests_dir.iterdir():
            if suite_dir.is_dir() and not suite_dir.name.startswith("."):
                print(f"  {suite_dir.name}/")

                # List test files in suite
                for test_file in suite_dir.rglob("*.robot"):
                    relative_path = test_file.relative_to(self.tests_dir)
                    print(f"    {relative_path}")

        print("\nEnvironments:")
        print("-" * 15)
        env_dir = self.config_dir / "environments"
        for env_file in env_dir.glob("*.yaml"):
            print(f"  {env_file.stem}")


def create_argument_parser():
    """Create command line argument parser"""
    parser = argparse.ArgumentParser(
        description="WordMate Robot Framework Test Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --env dev --suite ui
  %(prog)s --env production --suite api --parallel 4
  %(prog)s --env dev --include-tags smoke --exclude-tags slow
  %(prog)s --env dev --test-file tests/ui/auth/login_ui_tests.robot
  %(prog)s --list-tests
        """,
    )

    # Environment selection
    parser.add_argument(
        "--env",
        "--environment",
        dest="environment",
        default="dev",
        help="Test environment (default: dev)",
    )

    # Test selection
    parser.add_argument(
        "--suite", help="Test suite to run (api, ui, integration, smoke)"
    )

    parser.add_argument("--test-file", help="Specific test file to run")

    # Tag filtering
    parser.add_argument(
        "--include-tags", nargs="+", help="Include tests with specified tags"
    )

    parser.add_argument(
        "--exclude-tags", nargs="+", help="Exclude tests with specified tags"
    )

    # Execution options
    parser.add_argument(
        "--parallel", type=int, help="Number of parallel processes for test execution"
    )

    parser.add_argument(
        "--log-level",
        choices=["TRACE", "DEBUG", "INFO", "WARN", "ERROR"],
        help="Robot Framework log level",
    )

    parser.add_argument(
        "--dryrun", action="store_true", help="Perform dry run without executing tests"
    )

    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")

    # Information commands
    parser.add_argument(
        "--list-tests", action="store_true", help="List available test suites and exit"
    )

    return parser


def main():
    """Main entry point"""
    parser = create_argument_parser()
    args = parser.parse_args()

    runner = WordMateTestRunner()

    # Handle list command
    if args.list_tests:
        runner.list_available_tests()
        return 0

    # Validate environment
    if not args.environment:
        print("Error: Environment must be specified")
        return 1

    # Run tests
    return runner.run_tests(args)


if __name__ == "__main__":
    sys.exit(main())
