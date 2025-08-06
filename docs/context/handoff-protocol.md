# Rylo OS - AI Context Handoff Protocol

**Version**: 1.0
**Status**: Active

## 1.0 Purpose

This document defines the mandatory protocol for preserving and transferring project context between development sessions, especially when switching between different AI models or assistants. Adherence to this protocol is critical to mitigate context loss and ensure the long-term coherence of the Rylo OS project.

## 2.0 Protocol Procedure

### 2.1 Session Shutdown (Handoff)

The following steps **must** be performed by the AI at the conclusion of every development session:

1.  **Update `docs/context/current-context.md`**: The AI must update this file to reflect the absolute latest state of the project, including:
    -   Current phase and completion percentage.
    -   Summary of the last major accomplishment.
    -   Any newly identified blockers.
    -   A prioritized list of immediate next steps.
    -   The current working directory and any relevant environment variables.

2.  **Generate a Session Summary**: The AI must run the `tools/documentation/update-docs.ps1 -GenerateSummary` script. The output of this script provides a concise summary of recent commits and new architectural decisions.

3.  **Update the Daily Journal**: The AI must append the auto-generated summary from the previous step to the current day's journal file located in `docs/journal/`. The AI should also add a brief, human-readable narrative of the session's key events, challenges, and outcomes.

4.  **Commit All Changes**: The AI must stage and commit all modified and new files to the Git repository. The commit message must be descriptive and follow conventional commit standards (e.g., `feat:`, `fix:`, `docs:`).

5.  **Push to Remote**: After committing, the AI must push the changes to the `origin` remote to ensure the central repository is always up to date.

### 2.2 Session Startup (Hand-on)

The following steps **must** be performed by any AI at the beginning of a new development session:

1.  **Read `docs/context/current-context.md`**: This is the authoritative source of the project's current state. The AI must parse this file to understand its starting point.

2.  **Read the Latest Journal Entry**: The AI must read the most recent entry in the `docs/journal/` directory to understand the narrative context and detailed outcomes of the previous session.

3.  **Review the Project Roadmap**: The AI must read `docs/architecture/roadmap.md` to re-familiarize itself with the current phase's objectives and deliverables.

4.  **Verify the Development Environment**: The AI should run a quick check (e.g., `nasm --version`, `gcc --version`) to ensure the necessary development tools are available and configured correctly.

5.  **Acknowledge Readiness**: After completing these steps, the AI must signal to the user that it has successfully ingested the project context and is ready to proceed.

## 3.0 Emergency Recovery Procedure

In the event of a significant context loss or a corrupted context file, the following steps should be taken to recover the project state:

1.  **Consult Git History**: The commit log is the ultimate source of truth for code changes. Use `git log` to review recent activity.
2.  **Review ADRs**: The `docs/decisions/` directory contains the immutable history of all major architectural decisions.
3.  **Re-read Journal Entries**: The journals provide the narrative thread of the project's history.
4.  **Rebuild Context**: From these sources, the AI should be able to reconstruct a new `current-context.md` file.

---
*This protocol is non-negotiable and must be followed in all development sessions to ensure project success.*

