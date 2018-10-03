A repository for scripts and automation tools related to Yext Consulting Engineering

TaskBoard
- Easily create and switch between tasks through a terminal GUI
- Assign tasks a JIRA number and GitHub repo
- Automatically clone repo and install node modules
- Open Atom to repo and Chrome to JIRA, GitHub, and Storm for the site
- Close tasks when finished
- Integration with TimeLog to track time spent on each task

TimeLog
- Keep track of time spent on a task
- Supports multiple tasks running concurrently
- Log time using commands "start" and "end" with matching messages
- Or log time using commands "from" and "to" to log a duration from a start time or to an end time
- Get a report of time spent on each task with timereport.sh

Scripts
- add-dns.sh: step-through automation of adding a yext-cdn DNS entry (bridge domain)
- bulku-pr-checker: created to partially automate checking of bulku PRs during Crumbageddon
- fix-yarn-modernizr: fix yarn install errors by correcting bad modernizr hash in yarn.lock
- reset-alpha.sh: reset the local repo of alpha by re-cloning, re-installing, and re-making binaries
