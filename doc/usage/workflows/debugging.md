# Debugging Workflow

> **Systematic approach to finding and fixing issues**

## Initial Assessment

### 1. Reproduce the Issue

```bash
# Get latest code
gco main
gl

# Check issue details
gh issue view 456
gh issue comments 456

# Try to reproduce
npm run dev
# Follow steps from issue
```

### 2. Gather Information

```bash
# Check logs
tail -f logs/app.log
npm run logs

# System state
btop  # CPU/Memory usage
duf   # Disk space
ps aux | grep node

# Network
netstat -an | grep LISTEN
lsof -i :3000
```

### 3. Isolate the Problem

```bash
# Git bisect to find breaking commit
git bisect start
git bisect bad HEAD
git bisect good abc123  # Last known good

# Test each commit
npm test
git bisect good  # or bad

# When found
git bisect reset
git show <bad-commit>
```

## Debugging Tools

### 4. Editor Debugging (Neovim)

#### JavaScript/TypeScript

```vim
" Install DAP (Debug Adapter Protocol)
:PackerInstall nvim-dap
:PackerInstall nvim-dap-ui

" Set breakpoint
<leader>db  " Toggle breakpoint
<leader>dB  " Conditional breakpoint

" Start debugging
<leader>dc  " Continue
<leader>di  " Step into
<leader>do  " Step over
<leader>dr  " Open REPL
```

#### Python

```vim
" Using pdb
:!python -m pdb %

" Or insert breakpoint in code
import pdb; pdb.set_trace()

" Neovim DAP
<leader>dc  " Start/Continue
<leader>dn  " Step over
<leader>ds  " Step into
```

### 5. Terminal Debugging

#### Node.js

```bash
# Start with inspector
node --inspect app.js
node --inspect-brk app.js  # Break on first line

# With npm script
npm run debug

# Chrome DevTools
# Open chrome://inspect
```

#### Python

```bash
# Basic debugging
python -m pdb script.py

# IPython debugger
pip install ipdb
python -m ipdb script.py

# In code
import ipdb; ipdb.set_trace()
```

### 6. Network Debugging

```bash
# Monitor HTTP traffic
# Install mitmproxy
mitmproxy -p 8888

# Or use browser tools
open -a "Chrome" --args --proxy-server="localhost:8888"

# API testing
http --verbose GET api.example.com/users
curl -v https://api.example.com/users

# DNS issues
dig example.com
nslookup example.com
```

## Logging and Tracing

### 7. Enhanced Logging

```javascript
// JavaScript
console.log('User:', { id: user.id, name: user.name });
console.trace('Stack trace here');
console.time('operation');
// ... code ...
console.timeEnd('operation');
```

```python
# Python
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

logger.debug(f"User: {user.id}")
logger.error("Failed to connect", exc_info=True)
```

### 8. Search Through Logs

```bash
# Find errors
rg ERROR logs/
rg -i "exception|error|fail" logs/

# Time-based search
rg "2024-01-15 14:" logs/app.log

# Context around errors
rg -B5 -A5 "ERROR" logs/app.log

# Follow logs with filtering
tail -f logs/app.log | grep -i error
```

## Performance Debugging

### 9. Profiling

#### JavaScript

```bash
# Node.js profiling
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# Chrome DevTools
node --inspect app.js
# Open Performance tab
```

#### Python

```bash
# cProfile
python -m cProfile -o profile.out script.py
python -m pstats profile.out

# Line profiler
pip install line_profiler
kernprof -l -v script.py
```

### 10. Memory Debugging

```bash
# Node.js heap snapshots
node --inspect app.js
# Chrome DevTools > Memory > Take Snapshot

# Python memory profiling
pip install memory-profiler
python -m memory_profiler script.py

# System level
htop
ps aux --sort=-%mem | head
```

## Database Debugging

### 11. Query Analysis

```sql
-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Show slow queries
SELECT query, calls, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

```bash
# Monitor queries in real-time
# PostgreSQL
tail -f /var/log/postgresql/postgresql.log

# MySQL
tail -f /var/log/mysql/mysql.log

# Via application
DEBUG=knex:query npm run dev
```

### 12. Connection Issues

```bash
# Test database connection
psql -h localhost -U username -d database

# Check connections
SELECT * FROM pg_stat_activity;

# Network connectivity
telnet localhost 5432
nc -zv localhost 5432
```

## Frontend Debugging

### 13. Browser DevTools

```javascript
// Breakpoints in code
debugger;

// Conditional breakpoints
if (user.role === 'admin') debugger;

// Console methods
console.log('%c Important! ', 'color: red; font-size: 20px');
console.table(users);
console.group('User Details');
console.log(user);
console.groupEnd();
```

### 14. React DevTools

```bash
# Install extension
# Chrome: React Developer Tools

# In console
$r  # Selected component instance
$r.props
$r.state

# Find components
document.querySelector('[data-testid="user-profile"]')
```

## Debugging Strategies

### 15. Binary Search

```bash
# Comment out half the code
# If bug persists, it's in uncommented half
# Repeat until found

# Or with git
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
```

### 16. Rubber Duck Debugging

```markdown
## Problem Description

The user authentication fails when...

## What I've Tried

1. Checked the API endpoint - returns 200
2. Verified token is sent - yes, in headers
3. ...

## Current Understanding

The issue seems to be...

## Next Steps

- Check token expiration
- Verify CORS settings
- ...
```

### 17. Minimal Reproduction

```bash
# Create minimal test case
mkdir bug-reproduction
cd bug-reproduction
npm init -y

# Add only necessary code
cat > index.js << 'EOF'
// Minimal code that reproduces the issue
const problematicFunction = () => {
  // ...
};
EOF

# Test
node index.js
```

## Common Issues and Solutions

### 18. Environment Issues

```bash
# Compare environments
diff .env .env.example

# Check environment variables
env | grep API
printenv | sort

# Node version issues
node --version
nvm use 18
```

### 19. Dependency Issues

```bash
# Clear caches
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# Check for conflicts
npm ls
npm outdated
npm audit

# Python
pip freeze > requirements.txt
pip install -r requirements.txt --force-reinstall
```

### 20. Permission Issues

```bash
# File permissions
ls -la problem-file
chmod 644 file
chmod 755 directory

# Process permissions
sudo lsof -i :80
ps aux | grep process-name

# Fix npm permissions
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

## Post-Debugging

### 21. Document the Fix

```bash
# Create fix commit
gaa
gcmsg "fix: resolve authentication issue

The problem was caused by expired JWT tokens not being
refreshed properly. Added token refresh logic in the
auth middleware.

Fixes #456"

# Add test to prevent regression
v tests/test_auth_token_refresh.py
```

### 22. Prevention

```javascript
// Add assertions
console.assert(user.id, 'User must have ID');

// Add validation
if (!isValidEmail(email)) {
  throw new Error(`Invalid email: ${email}`);
}

// Add monitoring
logger.info('Auth attempt', { email, ip: req.ip });
```

## Quick Debug Checklist

```markdown
## Immediate Checks

- [ ] Can reproduce the issue?
- [ ] Check error messages/logs
- [ ] Recent changes (git log)
- [ ] Environment variables correct?

## Investigation

- [ ] Add debug logging
- [ ] Use debugger/breakpoints
- [ ] Check network requests
- [ ] Verify data flow

## Resolution

- [ ] Identify root cause
- [ ] Implement fix
- [ ] Add test for regression
- [ ] Document solution
```

## Debug Commands Reference

```bash
# Quick commands
npm run debug         # Start with debugger
<leader>db           # Toggle breakpoint (Neovim)
console.trace()      # Stack trace
debugger;            # JS breakpoint
import ipdb; ipdb.set_trace()  # Python breakpoint
rg ERROR logs/       # Search errors
git bisect          # Find breaking commit
EXPLAIN ANALYZE     # SQL query analysis
```

---

<p align="center">
  <a href="README.md">← Back to Workflows</a>
</p>
