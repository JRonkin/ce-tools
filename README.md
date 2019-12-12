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
  - [Bash Scripts](#bash-scripts)
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

### [Bash Scripts](scripts#bash-scripts)
- Various scripts for automating tasks

### [Tampermonkey Scripts](https://github.com/JRonkin/tampermonkey-ce)
*Tampermonkey Scripts have been moved to their own repo: https://github.com/JRonkin/tampermonkey-ce*
- Userscripts for the browser plugin [Tampermonkey](https://www.tampermonkey.net)
- Automate logins and improve experience on some websites

## Shortcuts
- **tb**: TaskBoard -- [taskboard.sh](taskboard/taskboard.sh)
- **tl**: TimeLog -- [timelog.sh](timelog/timelog.sh)
- **tlr**: TimeLog -- [timereport.sh](timelog/timereport.sh)
- **trash**: Scripts -- [trash.sh](scripts/trash.sh)
