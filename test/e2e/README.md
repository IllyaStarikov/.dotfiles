# /test/e2e - End-to-End Tests

## What's in this directory

End-to-end tests validate complete user journeys from start to finish, testing the entire system as users would experience it. These tests ensure all components work together to deliver working features.

### Test Journeys:
- **Setup to coding** - Install → Configure → Write code
- **Git workflow** - Clone → Edit → Commit → Push
- **Development cycle** - Code → Test → Debug → Deploy
- **Configuration update** - Pull → Merge → Reload
- **Problem resolution** - Error → Diagnose → Fix

## Why this exists

E2E tests catch integration issues that unit and integration tests miss. They validate that the complete system delivers value, not just that individual parts work.

## Lessons Learned

### Integration Issues Found
1. **LSP started before plugins loaded** - Race condition
2. **Theme switch broke tmux** - Session state corruption
3. **Update script deleted custom configs** - Poor backup logic
4. **Completion fought with snippets** - Tab key conflict

### What NOT to Do
- **Don't mock anything** - Test real integrations
- **Don't run in parallel** - State conflicts
- **Don't skip slow tests** - They find real issues

### E2E Test Insights
- Most bugs happen at component boundaries
- Timing issues only appear under load
- User paths differ from developer assumptions
- Real-world usage is messier than expected