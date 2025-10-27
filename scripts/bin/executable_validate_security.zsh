#!/usr/bin/env zsh

# Security validation script for dotfiles
# This script checks for common security issues in dotfiles configuration

set -e

echo "🔍 Running security validation..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status_type=$1
    local message=$2
    if [ "$status_type" = "error" ]; then
        echo -e "${RED}❌ $message${NC}"
    elif [ "$status_type" = "warning" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    elif [ "$status_type" = "success" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    else
        echo -e "ℹ️  $message"
    fi
}

# Check for hardcoded secrets or sensitive information
print_status info "Checking for hardcoded secrets..."
if grep -r "password\|secret\|key\|token" . --include="*.sh" --include="*.zsh" --include="*.yml" --include="*.yaml" --exclude-dir=.git 2>/dev/null | grep -v "export.*=" | grep -v "#.*password\|secret\|key\|token"; then
    print_status warning "Potential hardcoded secrets found. Please use environment variables or secret management."
else
    print_status success "No obvious hardcoded secrets found."
fi

# Check for unsafe file permissions
print_status info "Checking file permissions..."
find . -name "*.sh" -o -name "*.zsh" | while read -r file; do
    if [ -x "$file" ]; then
        print_status warning "Executable script found: $file"
    fi
done

# Check for unsafe shell patterns
print_status info "Checking for unsafe shell patterns..."
if grep -r "eval.*\$" . --include="*.sh" --include="*.zsh" --exclude-dir=.git 2>/dev/null; then
    print_status warning "Found dynamic eval usage. Please review for safety."
fi

if grep -r "sudo.*\$" . --include="*.sh" --include="*.zsh" --exclude-dir=.git 2>/dev/null; then
    print_status warning "Found dynamic sudo usage. Please review for safety."
fi

# Check for proper input validation
print_status info "Checking input validation..."
if grep -r "read.*\$" . --include="*.sh" --include="*.zsh" --exclude-dir=.git 2>/dev/null | grep -v "read -r"; then
    print_status warning "Found 'read' without '-r' flag. Consider using 'read -r' for safety."
fi

# Check for proper quoting
print_status info "Checking variable quoting..."
if grep -r '\$[A-Za-z_][A-Za-z0-9_]*' . --include="*.sh" --include="*.zsh" --exclude-dir=.git 2>/dev/null | grep -v '"$'; then
    print_status warning "Found unquoted variables. Please use proper quoting."
fi

# Check GitHub Actions workflow
print_status info "Checking GitHub Actions workflow..."
if [ -f ".github/workflows/openai-review.yml" ]; then
    if ! grep -q "permissions:" .github/workflows/openai-review.yml; then
        print_status error "GitHub Actions workflow missing permissions block!"
    else
        print_status success "GitHub Actions workflow has proper permissions."
    fi

    if grep -q "secrets\." .github/workflows/openai-review.yml; then
        print_status success "GitHub Actions workflow properly uses secrets."
    fi
else
    print_status warning "No GitHub Actions workflow found."
fi

# Check for proper error handling
print_status info "Checking error handling..."
if grep -r "set -e" . --include="*.sh" --include="*.zsh" --exclude-dir=.git 2>/dev/null; then
    print_status success "Found proper error handling with 'set -e'."
fi

# Check for chezmoi configuration
print_status info "Checking chezmoi configuration..."
if [ -f ".chezmoidot.toml" ]; then
    print_status success "Found chezmoi configuration file."
else
    print_status error "Missing .chezmoidot.toml file!"
fi

if [ -f ".chezmoiignore" ]; then
    print_status success "Found .chezmoiignore file."
else
    print_status warning "Missing .chezmoiignore file!"
fi

# Check for proper ignore patterns
print_status info "Checking ignore patterns..."
if [ -f ".gitignore" ]; then
    print_status success "Found .gitignore file."
    # Check for common sensitive patterns
    if grep -q ".*_local" .gitignore; then
        print_status success ".gitignore properly excludes local override files."
    else
        print_status warning ".gitignore should exclude *_local files."
    fi
else
    print_status warning "Missing .gitignore file!"
fi

# Check for shell script validation
print_status info "Validating shell scripts..."
if command -v shellcheck >/dev/null 2>&1; then
    shell_scripts=$(find . -name "*.sh" -o -name "*.zsh" | grep -v ".git")
    if [ -n "$shell_scripts" ]; then
        echo "Running shellcheck on scripts..."
        if shellcheck $shell_scripts 2>/dev/null; then
            print_status success "All shell scripts passed shellcheck validation."
        else
            print_status warning "Some shell scripts have linting issues. Run 'shellcheck' for details."
        fi
    fi
else
    print_status warning "shellcheck not available for script validation."
fi

print_status info "Security validation complete!"

echo ""
echo "Security recommendations:"
echo "1. Always use 'read -r' when reading user input"
echo "2. Quote all variable expansions: \"\$variable\""
echo "3. Use 'set -e' for proper error handling"
echo "4. Avoid dynamic eval and sudo when possible"
echo "5. Store secrets in environment variables or secure vaults"
echo "6. Regularly audit and update dependencies"
echo "7. Use proper ignore patterns to avoid committing sensitive files"
