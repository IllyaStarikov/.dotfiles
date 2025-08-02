# Development Workflows

> **Step-by-step guides for common development tasks**

## Overview

This section provides detailed workflows for daily development tasks, from morning startup to complex debugging sessions. Each workflow is designed to maximize productivity using our configured tools.

## Available Workflows

### [Daily Development](daily.md)
Complete morning-to-evening workflow:
- System startup and updates
- Project navigation and setup
- Development patterns
- End-of-day procedures

### [Feature Development](features.md)
From idea to deployment:
- Planning and design
- Branch management
- Implementation process
- Testing and deployment

### [Code Review](review.md)
Effective PR and review process:
- Reviewing others' code
- Creating effective PRs
- Responding to feedback
- Merge strategies

### [Debugging](debugging.md)
Systematic troubleshooting:
- Problem reproduction
- Debugging tools and techniques
- Performance analysis
- Issue resolution

## Quick Workflow Examples

### Starting a New Feature

```bash
# 1. Update and branch
gco main && gl
gcb feature/new-widget

# 2. Open editor
v .

# 3. Test-driven development
npm test -- --watch
```

### Quick Bug Fix

```bash
# 1. Create hotfix branch
gco main
gcb hotfix/critical-issue

# 2. Fix and test
v src/problem.js
npm test

# 3. Commit and push
gaa && gcmsg "fix: resolve critical issue" && gpsup
```

### Code Review

```bash
# 1. Check out PR
gh pr checkout 123

# 2. Run tests
npm test

# 3. Review in editor
v .
:DiffviewOpen main...HEAD
```

## Workflow Principles

### Efficiency First
- Use aliases and shortcuts
- Automate repetitive tasks
- Batch similar operations

### Quality Focused
- Test before committing
- Review your own changes
- Document as you go

### Tool Integration
- Leverage editor features
- Use CLI tools effectively
- Integrate AI assistance

## Customizing Workflows

These workflows can be adapted to your needs:

1. **Modify aliases** in `.zshrc`
2. **Create functions** for repeated tasks
3. **Use tmuxinator** for project layouts
4. **Add git hooks** for automation

## Learning Path

1. Start with [Daily Development](daily.md) to learn the basics
2. Practice [Feature Development](features.md) for larger tasks
3. Master [Code Review](review.md) for collaboration
4. Study [Debugging](debugging.md) for problem-solving

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>