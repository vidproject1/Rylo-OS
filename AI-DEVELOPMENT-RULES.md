# AI Development Rules for Rylo OS Project

## Rule 1: Documentation-First Development
Before making ANY code changes or architectural decisions:
- ALWAYS read the current context snapshot: `docs/context/current-context.md`
- Check today's journal entry: `docs/journal/[current-date].md`
- Review the latest ADRs in `docs/decisions/`
- Update documentation BEFORE and AFTER every significant change

## Rule 2: Phase-Gate Discipline
- NEVER proceed to the next development phase until ALL completion criteria are met
- Each phase must have: objectives completed, deliverables documented, code tested, ADRs recorded, context updated
- If asked to skip ahead, remind the user of phase-gate requirements and current phase status
- Always reference `docs/architecture/roadmap.md` for phase requirements

## Rule 3: Architecture Decision Recording
- ALL significant technical decisions MUST be recorded as ADRs using the template in `docs/decisions/000-adr-template.md`
- Include: context, decision rationale, alternatives considered, consequences, implementation notes
- Number ADRs sequentially (001, 002, etc.)
- Reference related ADRs and link to implementation code

## Rule 4: Context Preservation Protocol
At the end of every development session:
- Update `docs/context/current-context.md` with latest status
- Update today's journal entry with accomplishments and next steps
- Commit all changes to Git with descriptive messages
- Create checkpoint if completing a major milestone

When starting any session:
- Begin by reading the context files to understand current state
- Never assume knowledge from previous sessions without verification

## Rule 5: Educational Code Standards
All code must be:
- Extensively commented explaining WHY, not just what
- Self-documenting with clear variable/function names
- Include module headers explaining purpose, dependencies, status
- Written to teach OS concepts, not just implement functionality
- Simple and understandable over clever or optimized

## Rule 6: Implementation Documentation
For every module or component implemented:
- Create corresponding documentation in `docs/implementation/`
- Include: purpose, interface, dependencies, testing approach, known limitations
- Document design patterns and explain architectural choices
- Provide examples of usage and integration

## Rule 7: Version Control Hygiene
- Commit frequently with descriptive messages
- Never commit broken or untested code
- Include file modification summaries in commit messages
- Tag major milestones and phase completions
- Maintain clean Git history for future reference

## Rule 8: Testing and Validation
- Every component must be testable in QEMU before proceeding
- Document testing procedures in implementation docs
- Create reproducible test cases and expected outcomes
- Never mark phase complete without successful testing

## Rule 9: Long-term Project Continuity
- Design all systems assuming context window limitations
- Write documentation for future AI model transitions
- Avoid assumptions about previous conversation context
- Include all necessary context in documentation files
- Plan for multi-year development timeline

## Rule 10: Structured Problem Solving
When encountering technical challenges:
1. Document the problem in today's journal
2. Research multiple approaches and document in ADR
3. Choose solution based on educational value and simplicity
4. Implement with extensive documentation
5. Test thoroughly and document results
6. Update context with lessons learned

## Rule 11: User Communication Protocol
- Always confirm understanding of requirements before proceeding
- Ask clarifying questions about ambiguous requests
- Provide progress updates referencing documentation
- When completing tasks, confirm success and document next steps
- If blocked, clearly explain issue and propose solutions

## Rule 12: Context Handoff Standards
When ending a session or transitioning models:
- Update all context files with current status
- Document immediate next steps with priorities
- Note any blocking issues or dependencies
- Provide clear continuation instructions
- Ensure all work is committed and documented

---

## Quick Reference Commands for AI

### Starting a Session:
```bash
# Read context
cat docs/context/current-context.md
cat docs/journal/$(date +%Y-%m-%d).md
```

### Before Major Changes:
```bash
# Check current phase status
cat docs/architecture/roadmap.md
# Review recent decisions
ls docs/decisions/
```

### After Completing Work:
```bash
# Update context and create checkpoint
git add . && git commit -m "Description"
# Update documentation as needed
```

### Phase Completion Checklist:
- [ ] All objectives completed
- [ ] All deliverables documented  
- [ ] Code compiles and runs in QEMU
- [ ] Comprehensive testing completed
- [ ] Architecture decisions recorded
- [ ] Context fully documented for AI handoff

---

**These rules ensure project continuity, educational value, and successful completion across the multi-year development timeline.**
