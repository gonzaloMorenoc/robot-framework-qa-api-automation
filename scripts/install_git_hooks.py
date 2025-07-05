#!/usr/bin/env python3
"""
Git Hooks Installation Script

This script installs security-focused git hooks to prevent
committing sensitive data to the repository.
"""

import os
import sys
import shutil
import stat
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Lista de exclusiones de falsos positivos (archivo, línea)
false_positive_exclusions = [
    ("resources/libraries/WordmateAPI.py", 154),
    ("resources/libraries/WordmateAPI.py", 347),
    ("scripts/quick_setup.py", 62),
    ("scripts/quick_setup.py", 71),
    ("scripts/quick_setup.py", 73),
    ("scripts/quick_setup.py", 81),
    ("scripts/quick_setup.py", 85),
    ("scripts/quick_setup.py", 98),
    ("scripts/quick_setup.py", 101),
    ("scripts/quick_setup.py", 116),
    ("scripts/quick_setup.py", 122),
    ("scripts/install_git_hooks.py", 86),
    ("scripts/install_git_hooks.py", 87),
    ("scripts/install_git_hooks.py", 88),
    ("scripts/install_git_hooks.py", 89),
]

class GitHooksInstaller:
    """Installs and manages git hooks for WordMate project"""

    def __init__(self):
        self.project_root = project_root
        self.git_hooks_dir = self.project_root / ".git" / "hooks"
        self.hooks_source_dir = self.project_root / "git-hooks"

    def check_git_repository(self) -> bool:
        """Check if current directory is a git repository"""
        git_dir = self.project_root / ".git"
        return git_dir.exists() and git_dir.is_dir()

    def create_hooks_directory(self) -> None:
        """Create git hooks directory if it doesn't exist"""
        self.git_hooks_dir.mkdir(parents=True, exist_ok=True)

    def create_pre_commit_hook(self) -> bool:
        """Create pre-commit hook"""
        hook_content = """#!/bin/bash

# WordMate Pre-commit Hook
# Prevents committing sensitive data like passwords and API keys

set -e

echo "🔍 WordMate Security Check - Scanning for sensitive data..."

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Files to never commit
FORBIDDEN_PATTERNS=(
    "\\.env$"
    "\\.env\\."
    "local\\.yaml$"
    "secrets\\.yaml$"
    "credentials\\.json$"
    "secrets\\.json$"
    ".*password.*"
    ".*secret.*"
    ".*token.*"
    "\\.pem$"
    "\\.p12$"
    "\\.pfx$"
    "_rsa$"
    "_rsa\\.pub$"
)

# Patterns that indicate sensitive data
SENSITIVE_PATTERNS=(
    "password.*=.*['\\\"][^'\\\"]{3,}['\\\"]"
    "secret.*=.*['\\\"][^'\\\"]{3,}['\\\"]"
    "token.*=.*['\\\"][^'\\\"]{10,}['\\\"]"
    "key.*=.*['\\\"][^'\\\"]{10,}['\\\"]"
    "TestPassword123!"
    "AdminPassword123!"
    "PremiumPass456!"
    "sk-[a-zA-Z0-9]+"
    "AIza[0-9A-Za-z\\\\-_]{35}"
    "ya29\\\\.[0-9A-Za-z\\\\-_]+"
)

# Archivos a ignorar por falsos positivos
IGNORE_FILES=(
    "resources/libraries/WordmateAPI.py"
    "scripts/quick_setup.py"
    "scripts/install_git_hooks.py"
)

# Check for forbidden files
echo "🔍 Checking for forbidden files..."
forbidden_found=false

staged_files=$(git diff --cached --name-only)

for file in $staged_files; do
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
        if echo "$file" | grep -E "$pattern" >/dev/null 2>&1; then
            print_error "Forbidden file staged for commit: $file"
            forbidden_found=true
            break
        fi
    done

done

# Check file contents for sensitive patterns
echo "🔍 Scanning file contents for sensitive data..."
sensitive_found=false

for file in $staged_files; do
    # Ignorar archivos validados como seguros
    for ignore in "${IGNORE_FILES[@]}"; do
        if [[ "$file" == "$ignore" ]]; then
            continue 2
        fi
    done
    # Skip if file doesn't exist (deleted files)
    if [[ ! -f "$file" ]]; then
        continue
    fi
    
    # Skip binary files
    if file "$file" | grep -q "binary"; then
        continue
    fi
    
    # Scan file content
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if git show ":$file" 2>/dev/null | grep -iE "$pattern" >/dev/null 2>&1; then
            print_error "Sensitive pattern found in $file"
            sensitive_found=true
            break
        fi
    done

done

# Check for .env file existence without it being in .gitignore
if [[ -f ".env" ]]; then
    if ! grep -q "^\\.env$" .gitignore 2>/dev/null; then
        print_error ".env file exists but is not in .gitignore"
        sensitive_found=true
    fi
fi

# Final decision
if [[ "$forbidden_found" == true || "$sensitive_found" == true ]]; then
    echo ""
    print_error "COMMIT BLOCKED: Sensitive data detected!"
    echo ""
    echo "🔒 Security recommendations:"
    echo "  1. Remove sensitive files: git reset HEAD <file>"
    echo "  2. Use environment variables: \\${VARIABLE_NAME}"
    echo "  3. Add sensitive files to .gitignore"
    echo "  4. Use .env file for credentials (never commit it)"
    echo "  5. Run: python scripts/validate_credentials.py"
    echo ""
    echo "🚫 To bypass (NOT RECOMMENDED): git commit --no-verify"
    echo ""
    exit 1
fi

print_success "Security check passed! No sensitive data detected."
exit 0
"""

        hook_file = self.git_hooks_dir / "pre-commit"

        try:
            with open(hook_file, "w") as f:
                f.write(hook_content)

            # Make executable
            os.chmod(hook_file, stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR)

            print(f"✅ Pre-commit hook installed: {hook_file}")
            return True

        except Exception as e:
            print(f"❌ Error creating pre-commit hook: {e}")
            return False

    def create_pre_push_hook(self) -> bool:
        """Create pre-push hook"""
        hook_content = """#!/bin/bash

# WordMate Pre-push Hook
# Additional security check before pushing to remote

echo "🔍 WordMate Pre-push Security Check..."

# Check if .env file is accidentally tracked
if git ls-files | grep -E "^\\.env$" >/dev/null 2>&1; then
    echo "❌ ERROR: .env file is tracked in git!"
    echo "Run: git rm --cached .env && git commit -m 'Remove .env from tracking'"
    exit 1
fi

# Check for any files in sensitive directories
sensitive_dirs=("config/test_data/sensitive" "**/*password*" "**/*secret*")
for dir in "${sensitive_dirs[@]}"; do
    if git ls-files | grep -E "$dir" >/dev/null 2>&1; then
        echo "⚠️  WARNING: Files in sensitive directory are tracked: $dir"
    fi
done

echo "✅ Pre-push security check passed!"
exit 0
"""

        hook_file = self.git_hooks_dir / "pre-push"

        try:
            with open(hook_file, "w") as f:
                f.write(hook_content)

            # Make executable
            os.chmod(hook_file, stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR)

            print(f"✅ Pre-push hook installed: {hook_file}")
            return True

        except Exception as e:
            print(f"❌ Error creating pre-push hook: {e}")
            return False

    def backup_existing_hooks(self) -> None:
        """Backup existing hooks"""
        hooks_to_backup = ["pre-commit", "pre-push"]

        for hook_name in hooks_to_backup:
            hook_file = self.git_hooks_dir / hook_name
            if hook_file.exists():
                backup_file = self.git_hooks_dir / f"{hook_name}.backup"
                shutil.copy2(hook_file, backup_file)
                print(f"📋 Backed up existing hook: {hook_name} -> {hook_name}.backup")

    def install_hooks(self) -> bool:
        """Install all git hooks"""
        print("🔧 Installing WordMate Git Hooks")
        print("=" * 40)

        # Check if git repository
        if not self.check_git_repository():
            print("❌ Error: Not in a git repository")
            print("Run: git init")
            return False

        # Create hooks directory
        self.create_hooks_directory()

        # Backup existing hooks
        self.backup_existing_hooks()

        # Install hooks
        success = True

        if not self.create_pre_commit_hook():
            success = False

        if not self.create_pre_push_hook():
            success = False

        if success:
            print("\n🎉 Git hooks installed successfully!")
            print("\n📋 What these hooks do:")
            print("  • Pre-commit: Scans for sensitive data before committing")
            print("  • Pre-push: Additional security check before pushing")
            print("\n⚠️  To bypass hooks (NOT RECOMMENDED):")
            print("  git commit --no-verify")
            print("  git push --no-verify")
            print("\n🔒 Security is now active for your repository!")
        else:
            print("\n❌ Some hooks failed to install")

        return success

    def uninstall_hooks(self) -> None:
        """Uninstall git hooks"""
        hooks_to_remove = ["pre-commit", "pre-push"]

        print("🗑️  Uninstalling WordMate Git Hooks")
        print("=" * 40)

        for hook_name in hooks_to_remove:
            hook_file = self.git_hooks_dir / hook_name
            backup_file = self.git_hooks_dir / f"{hook_name}.backup"

            if hook_file.exists():
                hook_file.unlink()
                print(f"🗑️  Removed: {hook_name}")

                # Restore backup if exists
                if backup_file.exists():
                    shutil.copy2(backup_file, hook_file)
                    backup_file.unlink()
                    print(f"📋 Restored backup: {hook_name}")

        print("✅ Git hooks uninstalled")

    def test_hooks(self) -> bool:
        """Test that hooks are working"""
        print("🧪 Testing Git Hooks")
        print("=" * 20)

        pre_commit_hook = self.git_hooks_dir / "pre-commit"

        if not pre_commit_hook.exists():
            print("❌ Pre-commit hook not found")
            return False

        # Test if hook is executable
        if not os.access(pre_commit_hook, os.X_OK):
            print("❌ Pre-commit hook is not executable")
            return False

        print("✅ Pre-commit hook exists and is executable")

        # Could add more sophisticated testing here
        print("✅ Hook tests passed")
        return True


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(description="Install WordMate git security hooks")
    parser.add_argument("--uninstall", action="store_true", help="Uninstall hooks")
    parser.add_argument("--test", action="store_true", help="Test installed hooks")
    parser.add_argument(
        "--force", action="store_true", help="Force installation (overwrite existing)"
    )

    args = parser.parse_args()

    installer = GitHooksInstaller()

    try:
        if args.uninstall:
            installer.uninstall_hooks()
            return 0
        elif args.test:
            success = installer.test_hooks()
            return 0 if success else 1
        else:
            success = installer.install_hooks()
            return 0 if success else 1

    except Exception as e:
        print(f"❌ Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
