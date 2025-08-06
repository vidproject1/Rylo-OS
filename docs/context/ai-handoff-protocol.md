# AI Handoff Protocol for Rylo OS

## Overview
This document provides a standardized protocol for transitioning between AI models or sessions during Rylo OS development.

## Pre-Handoff Checklist
Before ending any development session, ensure:

- [ ] Current context file is updated (`docs/context/current-context.md`)
- [ ] Today's journal entry is complete (`docs/journal/YYYY-MM-DD.md`)
- [ ] All changes are committed to Git
- [ ] Any blocking issues are documented
- [ ] Next steps are clearly outlined

## Handoff Information Template

### Current Status
- **Date**: [Current date]
- **Phase**: [Current development phase]
- **Progress**: [Percentage complete within phase]
- **Last Major Accomplishment**: [Brief description]
- **Current Working Directory**: [Path]

### Environment Status
- **Development Environment**: Working/Needs Setup/Issues
- **Build System**: Working/Needs Setup/Issues  
- **Testing Environment**: Working/Needs Setup/Issues
- **Documentation**: Up to date/Needs updates/Issues

### Immediate Actions Required
1. [Priority 1 action]
2. [Priority 2 action]
3. [Priority 3 action]

### Current Blockers
- **Blocker 1**: [Description and proposed solution]
- **Blocker 2**: [Description and proposed solution]

### Context for Next Session
[Critical information needed to continue development effectively]

### Files Recently Modified
- `file1.ext` - [Brief description of changes]
- `file2.ext` - [Brief description of changes]

### Tools and Commands Used
- **Build**: `command used`
- **Test**: `command used`
- **Debug**: `command used`

### Important Notes
[Any warnings, gotchas, or important context for continuation]

## New Session Startup Protocol

### For New AI Model/Session
1. **Read** `docs/context/current-context.md`
2. **Review** latest journal entry in `docs/journal/`
3. **Check** recent ADRs in `docs/decisions/`
4. **Verify** environment by running `tools/env-setup.ps1`
5. **Confirm** current phase requirements from `docs/architecture/roadmap.md`
6. **Update** current context with session start info

### Verification Commands
```powershell
# Verify location and tools
Get-Location
gcc --version
nasm --version  
make --version
qemu-system-x86_64 --version

# Check Git status
git status
git log --oneline -5

# Verify build system
.\tools\build-test.ps1
```

## Emergency Recovery
If context is lost or corrupted:

1. **Check Git History**: `git log --oneline --graph -20`
2. **Read Latest Checkpoint**: `checkpoints/[latest-date]/checkpoint.json`
3. **Review ADR History**: All decisions in `docs/decisions/`
4. **Rebuild Context**: From journal entries and documentation

## Standard Responses

### When Starting Session
"I'm ready to continue Rylo OS development. Let me check the current context..."

### When Ending Session  
"Updating context for handoff. All changes committed and documented."

### When Uncertain
"Let me review the current context and recent documentation before proceeding."

---
*This protocol ensures continuity across AI model transitions and development sessions*
