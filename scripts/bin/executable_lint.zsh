#!/usr/bin/env zsh

# Comprehensive linting script for dotfiles
# This script validates various configuration file formats

set -e

echo "🔍 Running comprehensive linting..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    elif [ "$status_type" = "info" ]; then
        echo -e "${BLUE}ℹ️  $message${NC}"
    else
        echo -e "   $message"
    fi
}

# Track overall status
overall_status=0

# Check YAML files
print_status info "Linting YAML files..."
if command -v yamllint >/dev/null 2>&1; then
    yaml_files=$(find . -name "*.yml" -o -name "*.yaml" | grep -v ".git")
    if [ -n "$yaml_files" ]; then
        if yamllint $yaml_files 2>/dev/null; then
            print_status success "All YAML files passed yamllint validation."
        else
            print_status warning "Some YAML files have linting issues."
            overall_status=1
        fi
    else
        print_status info "No YAML files found to lint."
    fi
else
    print_status warning "yamllint not available for YAML validation."
fi

# Check JSON files
print_status info "Validating JSON files..."
json_files=$(find . -name "*.json" | grep -v ".git" | grep -v "node_modules")
for file in $json_files; do
    if ! jq empty "$file" 2>/dev/null; then
        print_status error "Invalid JSON in $file"
        overall_status=1
    else
        print_status success "Valid JSON: $file"
    fi
done

# Check shell scripts
print_status info "Linting shell scripts..."
if command -v shellcheck >/dev/null 2>&1; then
    shell_files=$(find . -name "*.sh" -o -name "*.zsh" | grep -v ".git")
    if [ -n "$shell_files" ]; then
        echo "Running shellcheck on scripts..."
        if shellcheck $shell_files 2>/dev/null; then
            print_status success "All shell scripts passed shellcheck validation."
        else
            print_status warning "Some shell scripts have linting issues. Run 'shellcheck' for details."
            overall_status=1
        fi
    else
        print_status info "No shell scripts found to lint."
    fi
else
    print_status warning "shellcheck not available for shell script validation."
fi

# Check TOML files
print_status info "Validating TOML files..."
if command -v python3 >/dev/null 2>&1; then
    toml_files=$(find . -name "*.toml" | grep -v ".git")
    for file in $toml_files; do
        if python3 -c "import tomllib; tomllib.load(open('$file', 'rb'))" 2>/dev/null || \
           python3 -c "import toml; toml.load('$file')" 2>/dev/null; then
            print_status success "Valid TOML: $file"
        else
            print_status error "Invalid TOML in $file"
            overall_status=1
        fi
    done
else
    print_status warning "Python not available for TOML validation."
fi

# Check for chezmoi configuration issues
print_status info "Validating chezmoi configuration..."
if [ -f ".chezmoidot.toml" ]; then
    print_status success "Found .chezmoidot.toml"
else
    print_status warning "Missing .chezmoidot.toml"
fi

if [ -f ".chezmoiignore" ]; then
    print_status success "Found .chezmoiignore"
else
    print_status warning "Missing .chezmoiignore"
fi

# Check for common issues in dotfiles
print_status info "Checking for common configuration issues..."

# Check for trailing whitespace
files_with_whitespace=$(find . -name "dot_*" -o -name "*.md" -o -name "*.txt" | xargs grep -l '[[:space:]]$' 2>/dev/null || true)
if [ -n "$files_with_whitespace" ]; then
    print_status warning "Files with trailing whitespace found:"
    echo "$files_with_whitespace"
    overall_status=1
fi

# Check for tabs in files that should use spaces
files_with_tabs=$(find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" | xargs grep -l $'\t' 2>/dev/null || true)
if [ -n "$files_with_tabs" ]; then
    print_status warning "Files with tabs found (should use spaces):"
    echo "$files_with_tabs"
    overall_status=1
fi

# Check for executable permissions on non-scripts
print_status info "Checking file permissions..."
find . -name "dot_*" -type f | while read -r file; do
    if [ -x "$file" ]; then
        print_status warning "Executable dotfile found: $file (should not be executable)"
        overall_status=1
    fi
done

# Check for proper shebangs in scripts
print_status info "Checking script shebangs..."
find . -name "*.sh" -o -name "*.zsh" | grep -v ".git" | while read -r file; do
    if [ -x "$file" ] && ! head -n 1 "$file" | grep -q "^#!/"; then
        print_status warning "Executable script without shebang: $file"
        overall_status=1
    fi
done

# Check README links
print_status info "Checking README links..."
if [ -f "README.md" ]; then
    # Check for broken internal links
    broken_links=$(grep -o '\[.*\](#[^)]*)' README.md | grep -v 'Table of Contents' | while read -r link; do
        target=$(echo "$link" | sed -n 's/.*#\(.*\))/\1/p')
        if ! grep -q "^## $target\|^### $target\|^#### $target" README.md 2>/dev/null; then
            echo "$link -> #$target"
        fi
    done)

    if [ -n "$broken_links" ]; then
        print_status warning "Potentially broken internal links found:"
        echo "$broken_links"
        overall_status=1
    else
        print_status success "All internal links appear to be valid."
    fi
fi

# Check for required tools mentioned in docs
print_status info "Checking for required tools..."
if [ -f "README.md" ]; then
    tools=$(grep -o '`\w*`' README.md | sort | uniq | tr -d '`' | grep -E '^(chezmoi|homebrew|brew|git|gh)$')
    for tool in $tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            print_status warning "Tool mentioned in README but not installed: $tool"
        fi
    done
fi

# Final status
echo ""
if [ $overall_status -eq 0 ]; then
    print_status success "All linting checks passed!"
else
    print_status error "Some linting issues found. Please review and fix."
    exit 1
fi

print_status info "Linting complete!"
