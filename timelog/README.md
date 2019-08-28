# TimeLog
*Log time spent on items, see time logs over a date range, and submit time to JIRA*

TimeLog has two components:
- **TimeLog**: Record time worked on an item
- **TimeReport**: Summarize logs on a day or over a date range

Each component has a shortcut. See [Shortcuts](../README.md#shortcuts) for more information.

### TimeLog
*Shortcut: tl*
- Command line tool to log time
- Logs are saved in `appdata/timelog/logs/`. The `appdata` folder is created in the root of this repo.
- Run `tl [ITEM] start` and `tl [ITEM] end` to indicate that you've started or stopped working on an item. Replace `[ITEM]` with the item's JIRA number.
- Run `tl -h` for additional usage information.

### TimeReport
*Shortcut: tlr*
- Tool to view a summary of time logs created by TimeLog and submit them to JIRA, logging time on each item
- Run `tlr` to see today's time report.
- Run `tlr [DATE]` to see the time report for the given date, in `yyyy-mm-dd` format, such as 2006-01-02
- Run `tlr [START_DATE] [END_DATE]` to see the time report for all dates between the two given dates, inclusive. Time for each item is added up over all days.
- After printing the report, TimeReport gives the option to submit to JIRA. Doing so will log time to each individual item on JIRA. If reporting a date range, it will log time separately for each day.
- To submit time to JIRA, you need to create a JIRA API token for your account. [Create one here](https://id.atlassian.com/manage/api-tokens) and enter it into TimeReport when prompted.
