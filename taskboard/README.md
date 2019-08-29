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
1. The task will be added to the list. It will also be set as the active task, denoted by the `*`.
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

### Apps
TaskBoard can automatically open windows of integrated apps when you start a new task, show and hide them when you switch tasks, and close them when you close a task.
1. To enable or disable an app, press A to open the Apps menu and E to Enable/Disable apps. Enabled apps are denoted by a `*`.
1. Once an app is enabled, it will appear in the Apps menu. Select it to open a new window for the currently selected task. When a new task is created, enabled apps will open new windows automatically.
1. Switching tasks will hide all windows for the previous task and show all windows for the new task.
1. Closing a task with X will also close all apps for that task.
1. To change the size and position of new app windows, arrange the windows of the active task how you want them, then select Save Window Position in the Apps menu to save the size and position of the selected app.

## How to Write App Plugins

You can write your own plugins to integrate more apps. Here are the steps to add a plugin:
1. Create a new folder in `taskboard/apps/`. The name of the folder needs to be the same as the name of the .app file in your Applications directory, without ".app".
1. Create a file named "new.sh" in your new app folder. Make it executable. One way to do this is with the command `chmod +x [APP_FOLDER]/new.sh`.
1. `new.sh` is the script run to create a new window of the app. There are 4 arguments given: the active item's directory, the active JIRA number, the active repo, the requested position of the window in the format '[LEFT], [TOP]', and the requested size of the window in the format '[WIDTH], [HEIGHT]'. Repo, position, and size may be empty strings.
1. Create a file named "selector.txt" in your new app folder. The contents of the file should be an AppleScript selector that identifies every window of the app for the JIRA number of a task. In the selector, use "%s" in place of the JIRA number. See the "Target" section of [AppleScript Language Guide](https://nathangrigg.com/images/2012/AppleScriptLanguageGuide.pdf) (page 38) to learn about target selectors.
1. Done! Your app can now be enabled in the Apps menu.
