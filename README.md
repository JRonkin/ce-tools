# Yext CE Tools
*A repository for scripts and automation tools related to Yext Consulting Engineering*

### INSTALL INSTRUCTIONS:
1. Clone this repo
2. Run install.sh (or 'source' it to skip step 3)
3. Restart your terminal
4. Shortcuts are now installed and ready to run

## Contents

### TaskBoard
*Shortcut: tb.sh*
- Easily create and switch between tasks through a terminal GUI
- Automatically track time per item with option to submit to JIRA
- Assign tasks a JIRA number and GitHub repo or message
- Automatically clone repo and install node modules
- Open Atom to repo and Chrome to JIRA, GitHub, and Storm for the site
- Integration with TimeLog to track time spent on each task
- Integration with TimeReport to submit time to JIRA

### TimeLog
*Shortcut: tl.sh*
- Keep track of time spent on a task
- Supports multiple tasks running concurrently
- Log time using commands "start" and "end" with matching messages
- Or log time using commands "from" and "to" to log a duration from a start time or to an end time

### TimeReport
*Shortcut: tr.sh*
- Get a report of time spent on each task
- See time on a single day or in a range of days
- Submit time to JIRA, logged individually for each item on each day

### Scripts
- add-dns.sh: step-through automation of adding a yext-cdn DNS entry (bridge domain)
- bulku-pr-checker: created to partially automate checking of bulku PRs during Crumbageddon
- deactivate-site: step through the process of deactivating a Pages site
- fix-yarn-modernizr: fix yarn install errors by correcting bad modernizr hash in yarn.lock
- reset-alpha.sh: reset the local repo of alpha by re-cloning, re-installing, and re-making binaries
- sites-pager-helper: start sites-pager for a site
- update.sh: update alpha, generator-ysp, pages-builder, pages-tools, yext-ce-tools, and homebrew
