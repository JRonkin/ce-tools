# TaskBoard
*Task organizer, window manager, and time tracker for JIRA items*

## How to Use

### Setup & Basics
1. After following the [install instructions](../README.md#install-instructions), run `tb` to launch TaskBoard.
1. When launching the first time, TaskBoard will ask where you would like your items directory to be. Each JIRA item gets its own folder in the items directory. Leave it blank to use the default.
1. In TaskBoard, the menu options are at the top of the window. Press the N key to start a new task.
1. Enter the JIRA number or the URL of the JIRA item's page.
1. Enter the name of the task to show in the tasks list.
1. If the task has an associated Pages site repo, enter the GitHub URL or the name of the repo.
1. The task will be added to the list. It will also be set as the active task, denoted by the \*.
1. Move through the list with the Up and Down arrow keys. To activate or deactivate a task, press Enter. One task can be active at a time.
1. Press X to remove a task from the list and send its item folder to the Trash.

### Time Logging
1. Time spent on each task is recorded while the task is active.
1. To see how much time has been spent on each task, press M for More Options and press T for TimeReport.
1. Enter a start date in the format yyyy-mm-dd or leave blank to use today.
1. Enter an end date in the same format or leave blank to use the same day as start.
1. The time spent on each item will be listed, rounded to the nearest 15 minutes.
1. To log those hours their respective JIRA items, say yes when prompted.
1. Follow the instructions to authorize TimeLog for your JIRA account.
1. Once authorized, time will be logged to each item on JIRA.

**NOTE:** TimeReport will send all hours for a day to JIRA even if those hours have already been logged. *Log your time only once per day!*
