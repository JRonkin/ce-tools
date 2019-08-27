# Flow 2
*Additions and shortcuts for Git Flow from pages-tools*

These tools have shortcuts set for each of them, shown in parentheses. See [Shortcuts](../shortcuts#shortcuts) for more information.

- [finish](finish.sh) (gf): Runs git finish with the argument list as the message. Optionally start the argument list with -t [TAG] to set a tag. Example: `gf -t 1.0.0 This is the message`
- [funcs](funcs.sh): Common functions used by the flow tools.
- [phase-build](phase-build.sh) (gbp): Runs git build -p to build the current branch.
- [phase-checkout](phase-checkout.sh) (gco): Checks out the given phase on the current group branch. Running with no arguments checks out the trunk branch. Example: On branch `PC-123/trunk`, `gco doit` checks out `PC-123/doit`.
- [phase-commit](phase-commit.sh) (gci): Commits with the argument list as the message. If the first argument is `-a`, `git add -A` is run first. If the current branch has a JIRA number as group name, it is added before the start of the message.
- [publish-build](publish-build.sh) (gpub): Calls `pgs publish` with the given arguments. If on a grouped branch, the build branch of the group is used as the ref to publish.
- [pull](pull.sh) (gpl): Runs git pull.
- [push-set-upstream](push-set-upstream.sh) (gps): Pushes the current branch, setting its upstream to the branch of the same name on origin.
