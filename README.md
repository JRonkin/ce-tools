# CE Tools
*A repository for scripts and automation tools related to Consulting Engineering*

### INSTALL INSTRUCTIONS:
1. Clone this repo.
2. In Terminal, `cd` to this directory and run `source install.sh`
3. Done! To use, run shortcuts in Terminal (see [Shortcuts](#shortcuts)).

### How to Use TaskBoard:
1. After following the install instructions, run tb.sh to launch TaskBoard
2. In TaskBoard, press N to start a new task
3. Enter the JIRA number or the URL of the JIRA item's page
4. Enter the GitHub URL of the repo for the item or a custom message
5. Time is counted for the active task, denoted by *
6. Switch between tasks with arrows and Enter
7. See time worked per item and log to JIRA in More Options > TimeReport
8. Optionally enable automatic Chrome, Terminal, and/or Atom window switching in More Options > Enable/Disable TaskSwap

## Contents

### [Git Flow 2](flow2#git-flow-2)
- Shortcuts for common git commands
- Smart shortcuts for branches grouped by JIRA number, such as automatically adding the JIRA number to the commit message and switching between branches in a group without typing the JIRA number
- Based on Git Flow from pages-tools

### [Scripts](scripts#scripts)
- Various scripts for automating tasks

### [Tampermonkey Scripts](tampermonkey#tampermonkey-scripts)
- Userscripts for the browser plugin [Tampermonkey](https://www.tampermonkey.net)
- Automate logins and improve experience on some websites

### TaskBoard
*Shortcut: tb*
- Easily create and switch between tasks through a terminal GUI
- Automatically track time per item with option to submit to JIRA
- Assign tasks a JIRA number and GitHub repo or message
- Automatically clone repo and install node modules
- Open Atom to repo and Chrome to JIRA, GitHub, and Storm for the site
- Integration with TimeLog to track time spent on each task
- Integration with TimeReport to submit time to JIRA

### TimeLog
*Shortcut: tl*
- Keep track of time spent on a task
- Supports multiple tasks running concurrently
- Log time using commands "start" and "end" with matching messages
- Or log time using commands "from" and "to" to log a duration from a start time or to an end time

### TimeReport
*Shortcut: tr*
- Get a report of time spent on each task
- See time on a single day or in a range of days
- Submit time to JIRA, logged individually for each item on each day

### [Shortcuts](shortcuts)
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
