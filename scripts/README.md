# Scripts

- [add-dns](add-dns.sh): Add a DNS entry (bridge domain) to octo-dns.
- [avn](avn.sh): Change node version based on the .node-version file in a directory, like regular avn but runnable from inside a shell script.
- [custom-field-audit](custom-field-audit.sh): Find all the custom fields used in a site (not updated for template version 8).
- [deactivate-site](deactivate-site.sh): Step through the process of deactivating a Pages site.
- [killg](killg.sh): Kill all running processes of grunt and pager.
- [log-condenser](log-condenser.sh): Download site logs from AWS for a given date range. Run `log-condenser.sh -h` for more info.
- [pager](pager.sh): Run old pager (JSON pager).
- [remove-dns](remove-dns.sh): Remove a DNS entry (bridge domain) from octo-dns.
- [repo-fixes](repo-fixes.sh): Fix missing messages directory, README location, yarn install errors, pages.json spacing, and node version < 6.
- [reset-alpha](reset-alpha.sh): Reset the local repo of alpha by re-cloning, re-installing, and re-making binaries.
- [s3-download](s3-download.sh): Download site files from S3. First argument is the domain, second argument is the folder of the root directory to download. Arguments are optional and will prompt as needed.
- [sort-redirects](sort-redirects.sh): Sort all redirects alphabetically in redirects.csv and redirects.\*.csv in a repo, remove duplicate entries, and list all conflicting entries (where one source has multiple destinations).
- [trash](trash.sh): Send a file or folder to the Trash as if it were deleted in Finder.
- [ttitle](ttitle.sh): Set a custom title for the terminal window.
- [update](update.sh): Update generator-ysp, pages-builder, pages-tools, Homebrew, npm, Python, alpha, congo, and ce-tools. Add -p to run updates in parallel.
