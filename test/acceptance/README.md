# /test/acceptance - User Acceptance Tests

## What's in this directory

Acceptance tests validate that the dotfiles meet user requirements and work as expected from an end-user perspective. These tests simulate real user workflows and verify the system behaves correctly.

### Test Scenarios:
- **New user setup** - Fresh installation workflow
- **Daily development** - Common coding tasks
- **Theme switching** - User preference changes
- **Tool integration** - Editor, terminal, shell working together
- **Error recovery** - Handling user mistakes

## Why this exists

Acceptance tests ensure the dotfiles actually solve user problems, not just pass technical tests. They validate the "why" behind features and confirm the user experience is smooth.

## Lessons Learned

### User Pain Points Discovered
1. **Setup took 45 minutes** - Now under 5 minutes
2. **Theme switching was manual** - Now one command
3. **Keybindings conflicted** - Now properly namespaced
4. **Updates broke configs** - Now tested before release

### What NOT to Do
- **Don't test implementation** - Test outcomes
- **Don't assume workflows** - Observe real usage
- **Don't skip edge cases** - Users find them

### Workflow Improvements
- Setup script now has --dry-run mode
- All commands have help text
- Error messages are actionable
- Rollback is always possible