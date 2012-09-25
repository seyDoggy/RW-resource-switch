# RW resource switch

This is a shell script that will be inserted into our themes that will allow users to switch a themes dependence from CDN files to local files and back again.

It would work something like this:

1. A user drags their theme onto terminal, then appends the path with `switch.sh -l local`:

		```bash
		MacBook-Pro:~/Library/Application\ Support/Themes/seydesign\ alltr.rwtheme/switch.sh -l local
		```
2. To switch back, the user does the same, but this time appends the name with `switch.sh -l cdn`:

		```bash
		MacBook-Pro:~/Library/Application\ Support/Themes/seydesign\ alltr.rwtheme/switch.sh -l cdn
		```

See the usage instructions within the script.