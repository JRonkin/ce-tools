# CE Tools
*A repository for scripts and automation tools related to Consulting Engineering*

### INSTALL INSTRUCTIONS:
1. Clone this repo.
2. In Terminal, `cd` to this directory and run `source install.sh`
3. Done! To use, run shortcuts in Terminal (see [Shortcuts](#shortcuts)).

## Contents
- [Tools](#tools)
  - [TaskBoard](#taskboard)
  - [TimeLog](#timelog)
- [Scripts](#scripts)
  - [CE Scripts](#ce-scripts)
  - [Git Flow 2](#git-flow-2)
  - [Tampermonkey Scripts](#tampermonkey-scripts)
- [Shortcuts](#shortcuts)

## Tools

### [TaskBoard](taskboard#taskboard)
- Easily create and switch between tasks through a terminal GUI
- Assign tasks a JIRA number and GitHub repo
- Automatically track time per item with option to submit to JIRA
- Automatically clone repo and run a setup script
- Switch between windows of integrated apps -- Atom, Chrome, and Terminal

### [TimeLog](timelog#timelog)
- Keep track of time spent on a task
- Save logs for each day
- Get a report of time spent on each task with TimeReport
- See time reports for a single day or a range of days
- Submit time to JIRA, logged individually for each item on each day

## Scripts

### [CE Scripts](scripts#ce-scripts)
- Various scripts for automating tasks

### [Git Flow 2](flow2#git-flow-2)
- Shortcuts for common git commands
- Smart shortcuts for branches grouped by JIRA number, such as automatically adding the JIRA number to the commit message and switching between branches in a group without typing the JIRA number
- Based on Git Flow from pages-tools

### [Tampermonkey Scripts](https://github.com/JRonkin/tampermonkey-ce)
*Tampermonkey Scripts have been moved to their own repo: https://github.com/JRonkin/tampermonkey-ce*
- Userscripts for the browser plugin [Tampermonkey](https://www.tampermonkey.net)
- Automate logins and improve experience on some websites

## Shortcuts
- **ce**: Run `ce [SCRIPT_NAME]` to run the named script ('.sh' not needed) with any given args. See [Scripts](scripts#scripts).
- **gbp**: Git Flow 2 -- [phase-build.sh](flow2/phase-build.sh)
- **gci**: Git Flow 2 -- [phase-commit.sh](flow2/phase-commit.sh)
- **gco**: Git Flow 2 -- [phase-checkout.sh](flow2/phase-checkout.sh)
- **gf**: Git Flow 2 -- [finish.sh](flow2/finish.sh)
- **gpl**: Git Flow 2 -- [pull.sh](flow2/pull.sh)
- **gps**: Git Flow 2 -- [push-set-upstream.sh](flow2/push-set-upstream.sh)
- **gpub**: Git Flow 2 -- [publish-build.sh](flow2/publish-build.sh)
- **tb**: TaskBoard -- [taskboard.sh](taskboard/taskboard.sh)
- **tl**: TimeLog -- [timelog.sh](timelog/timelog.sh)
- **tlr**: TimeLog -- [timereport.sh](timelog/timereport.sh)
- **trash**: Scripts -- [trash.sh](scripts/trash.sh)
