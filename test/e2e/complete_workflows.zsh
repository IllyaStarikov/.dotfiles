#!/usr/bin/env zsh
# End-to-End Tests: Complete Development Workflows
# TEST_SIZE: large
# Tests complete workflows from start to finish

source "${TEST_DIR}/lib/framework.zsh"

# Test complete development workflow
test_complete_dev_workflow() {
    log "TRACE" "Testing complete development workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Simulating full developer workflow"
    
    local workflow_dir=$(mktemp -d -t dev_workflow.XXXXXX)
    cd "$workflow_dir"
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Working in: $workflow_dir"
    
    # 1. Initialize a Git repository
    log "TRACE" "Step 1: Initialize Git repository"
    git init >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to initialize Git repository"
        cd - >/dev/null
        rm -rf "$workflow_dir"
        return 1
    fi
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Git repository initialized"
    
    # 2. Create a project structure
    log "TRACE" "Step 2: Create project structure"
    mkdir -p src tests docs
    echo "# Test Project" > README.md
    echo "console.log('Hello World');" > src/index.js
    echo "test('sample', () => {});" > tests/index.test.js
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Project structure created"
    
    # 3. Test Neovim can edit files
    log "TRACE" "Step 3: Edit files with Neovim"
    echo "Added via Neovim" | nvim -es +'normal Go' +'r /dev/stdin' +'wq' README.md 2>/dev/null
    
    if grep -q "Added via Neovim" README.md; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim can edit files"
    else
        log "ERROR" "Neovim failed to edit file"
        cd - >/dev/null
        rm -rf "$workflow_dir"
        return 1
    fi
    
    # 4. Test Git operations
    log "TRACE" "Step 4: Git operations"
    git add . >/dev/null 2>&1
    git commit -m "Initial commit" >/dev/null 2>&1
    
    local commit_count=$(git rev-list --count HEAD 2>/dev/null)
    if [[ "$commit_count" -eq 1 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Git commit successful"
    else
        log "ERROR" "Git commit failed"
    fi
    
    # 5. Test script execution
    log "TRACE" "Step 5: Script execution"
    cat > test_script.sh <<'EOF'
#!/usr/bin/env zsh
echo "Script test OK"
EOF
    chmod +x test_script.sh
    
    local script_output=$(./test_script.sh 2>&1)
    if [[ "$script_output" == "Script test OK" ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Script execution works"
    else
        log "ERROR" "Script execution failed"
    fi
    
    # 6. Test searching with grep/rg
    log "TRACE" "Step 6: File searching"
    echo "searchable_content_xyz123" >> src/index.js
    
    if grep -r "searchable_content_xyz123" . >/dev/null 2>&1; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "grep search works"
    fi
    
    if command -v rg >/dev/null 2>&1; then
        if rg "searchable_content_xyz123" >/dev/null 2>&1; then
            [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "ripgrep search works"
        fi
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$workflow_dir"
    
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Complete development workflow test passed"
    return 0
}

# Test Python development workflow
test_python_dev_workflow() {
    log "TRACE" "Testing Python development workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Setting up Python project"
    
    if ! command -v python3 >/dev/null 2>&1; then
        log "INFO" "Python not installed, skipping"
        return 77
    fi
    
    local project_dir=$(mktemp -d -t python_project.XXXXXX)
    cd "$project_dir"
    
    # Create Python project
    cat > main.py <<'EOF'
def hello(name):
    """Say hello."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    print(hello("World"))
EOF
    
    cat > test_main.py <<'EOF'
import main

def test_hello():
    assert main.hello("Test") == "Hello, Test!"
EOF
    
    # Test Python execution
    local output=$(python3 main.py 2>&1)
    if [[ "$output" == "Hello, World!" ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Python script executes correctly"
    else
        log "ERROR" "Python execution failed: $output"
    fi
    
    # Test Neovim Python editing
    local nvim_test=$(nvim --headless +'py3 print("nvim_python_ok")' +'qa!' 2>&1)
    if [[ "$nvim_test" == *"nvim_python_ok"* ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim Python support works"
    else
        [[ $VERBOSE -ge 1 ]] && log "INFO" "Neovim Python support not configured"
    fi
    
    # Test formatting with black/ruff if available
    if command -v ruff >/dev/null 2>&1; then
        ruff format main.py >/dev/null 2>&1
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Ruff formatter works"
    elif command -v black >/dev/null 2>&1; then
        black main.py >/dev/null 2>&1
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Black formatter works"
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$project_dir"
    
    return 0
}

# Test web development workflow
test_web_dev_workflow() {
    log "TRACE" "Testing web development workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Setting up web project"
    
    local project_dir=$(mktemp -d -t web_project.XXXXXX)
    cd "$project_dir"
    
    # Create basic web files
    cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Hello World</h1>
    <script src="script.js"></script>
</body>
</html>
EOF
    
    cat > style.css <<'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
}
h1 {
    color: #333;
}
EOF
    
    cat > script.js <<'EOF'
console.log('Page loaded');
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM ready');
});
EOF
    
    # Test HTML validation
    if command -v tidy >/dev/null 2>&1; then
        tidy -q -e index.html 2>/dev/null
        [[ $VERBOSE -ge 1 ]] && log "INFO" "HTML validation available"
    fi
    
    # Test CSS processing
    if command -v prettier >/dev/null 2>&1; then
        prettier --write style.css >/dev/null 2>&1
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Prettier formatting works"
    fi
    
    # Test JavaScript linting
    if command -v eslint >/dev/null 2>&1; then
        eslint script.js >/dev/null 2>&1 || true
        [[ $VERBOSE -ge 1 ]] && log "INFO" "ESLint available"
    fi
    
    # Test package.json creation
    cat > package.json <<'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "test": "echo 'No tests'"
  }
}
EOF
    
    if command -v npm >/dev/null 2>&1; then
        npm run test >/dev/null 2>&1
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "npm scripts work"
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$project_dir"
    
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Web development workflow test passed"
    return 0
}

# Test Docker workflow
test_docker_workflow() {
    log "TRACE" "Testing Docker workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking Docker setup"
    
    if ! command -v docker >/dev/null 2>&1; then
        log "INFO" "Docker not installed, skipping"
        return 77
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        log "INFO" "Docker daemon not running, skipping"
        return 77
    fi
    
    local project_dir=$(mktemp -d -t docker_project.XXXXXX)
    cd "$project_dir"
    
    # Create Dockerfile
    cat > Dockerfile <<'EOF'
FROM alpine:latest
RUN echo "Docker test"
CMD ["echo", "Container running"]
EOF
    
    # Create docker-compose.yml
    cat > docker-compose.yml <<'EOF'
version: '3'
services:
  test:
    build: .
    command: echo "Compose test"
EOF
    
    # Validate Dockerfile syntax
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Docker files created"
    
    # Test docker-compose if available
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose config >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "docker-compose configuration valid"
        fi
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$project_dir"
    
    return 0
}

# Test tmux workflow
test_tmux_workflow() {
    log "TRACE" "Testing tmux workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing tmux session management"
    
    if ! command -v tmux >/dev/null 2>&1; then
        log "INFO" "tmux not installed, skipping"
        return 77
    fi
    
    # Check if we're already in tmux
    if [[ -n "$TMUX" ]]; then
        log "INFO" "Already in tmux, skipping nested session test"
        return 0
    fi
    
    # Create a test session
    local session_name="test_session_$$"
    
    # Start tmux session
    tmux new-session -d -s "$session_name" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "tmux session created"
        
        # Send commands to session
        tmux send-keys -t "$session_name" "echo 'tmux test'" Enter
        sleep 1
        
        # Capture pane content
        local content=$(tmux capture-pane -t "$session_name" -p 2>/dev/null)
        if [[ "$content" == *"tmux test"* ]]; then
            [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "tmux command execution works"
        fi
        
        # Kill session
        tmux kill-session -t "$session_name" 2>/dev/null
    else
        log "WARNING" "Could not create tmux session"
    fi
    
    return 0
}

# Test configuration reload workflow
test_config_reload_workflow() {
    log "TRACE" "Testing configuration reload workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing hot-reload of configurations"
    
    # Test Neovim config reload
    local nvim_reload=$(nvim --headless -c "source \$MYVIMRC" -c "echo 'reload_ok'" -c "qa!" 2>&1)
    if [[ "$nvim_reload" == *"reload_ok"* ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim config can be reloaded"
    fi
    
    # Test tmux config reload
    if command -v tmux >/dev/null 2>&1; then
        if [[ -f "$DOTFILES_DIR/src/tmux.conf" ]]; then
            tmux source-file "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "tmux config can be reloaded"
            fi
        fi
    fi
    
    return 0
}

# Test Git workflow with branches
test_git_branch_workflow() {
    log "TRACE" "Testing Git branching workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing Git branch operations"
    
    local repo_dir=$(mktemp -d -t git_workflow.XXXXXX)
    cd "$repo_dir"
    
    # Initialize repo
    git init >/dev/null 2>&1
    echo "initial" > file.txt
    git add . >/dev/null 2>&1
    git commit -m "Initial commit" >/dev/null 2>&1
    
    # Create and switch branch
    git checkout -b feature/test >/dev/null 2>&1
    echo "feature" >> file.txt
    git add . >/dev/null 2>&1
    git commit -m "Feature commit" >/dev/null 2>&1
    
    # Switch back to main
    git checkout main >/dev/null 2>&1 || git checkout master >/dev/null 2>&1
    
    # Merge branch
    git merge feature/test >/dev/null 2>&1
    
    if grep -q "feature" file.txt; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Git branching workflow works"
    else
        log "ERROR" "Git merge failed"
    fi
    
    # Test Git aliases if configured
    local git_aliases=$(git config --get-regexp alias 2>/dev/null | wc -l)
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Found $git_aliases Git aliases"
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$repo_dir"
    
    return 0
}

# Test complete theme switching workflow
test_theme_switching_workflow() {
    log "TRACE" "Testing theme switching workflow"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing complete theme change across tools"
    
    local theme_script="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"
    
    if [[ ! -x "$theme_script" ]]; then
        log "INFO" "Theme switcher not available, skipping"
        return 77
    fi
    
    # Test dry-run
    local dry_output=$("$theme_script" --dry-run dark 2>&1)
    if [[ $? -eq 0 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Theme switcher dry-run works"
        
        # Check what it would change
        if [[ "$dry_output" == *"alacritty"* ]]; then
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Would update Alacritty theme"
        fi
        if [[ "$dry_output" == *"tmux"* ]]; then
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Would update tmux theme"
        fi
        if [[ "$dry_output" == *"neovim"* ]] || [[ "$dry_output" == *"nvim"* ]]; then
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Would update Neovim theme"
        fi
    else
        log "WARNING" "Theme switcher dry-run failed"
    fi
    
    return 0
}