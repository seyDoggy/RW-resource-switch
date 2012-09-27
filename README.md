# RW resource switch

This is a shell script slowly making it's way into our themes that will allow users to switch a themes dependence from CDN files (plus local fall-back) to local files only and back again. It also allows users to update their local script files to be current with the latest CDN files or revert back to the last saved local version.

## Converting to a local only theme

There might be cases where having your site draw from CDN files might not be appropriate for your situation. Some examples include: 

- your site is on an intranet with no outside access. 
- your site is working well as it is.
- you'd rather be in control of your own destiny.


1. To convert to a local only theme, ***drag and drop*** your theme onto ***Terminal.app***, then append the path (removing the space first) with `switch.sh -l local`. For example, the following is what this would look like on my computer with the "alltr" theme:

	```bash
	MacBook-Pro:~/Library/Application\ Support/Themes/seydesign\ alltr.rwtheme/switch.sh -l local
	```

	Notice that there is no space between `...alltr.rwtheme/` and `switch.sh`.

2. To switch back, the user does the same, but this time appends the name with `switch.sh -l cdn`:

	```bash
	MacBook-Pro:~/Library/Application\ Support/Themes/seydesign\ alltr.rwtheme/switch.sh -l cdn
	```

	Again, notice that there is no space between `...alltr.rwtheme/` and `switch.sh`.

## Updating local script files

By serving some of a themes most frequently updated files "from the cloud" we offer continual updates and improvements to themes and sites without the disruption and headache of updating entire themes. If you've decided to internalize your script files then you lose out on these updates, so another feature of the `switch.sh` script allows you to update your local script files to match that of the most current CDN files.

It doesn't matter whether you are using local only or CDN plus local fall-back, this feature will update your local files either way.

1. To update your local script files, ***drag and drop*** your theme onto ***Terminal.app***, then append the path (removing the space first) with `switch.sh -u update`. For example, the following is what this would look like on my computer with the "alltr" theme:

	```bash
	MacBook-Pro:~/Library/Application\ Support/Themes/seydesign\ alltr.rwtheme/switch.sh -u update
	```

	And again (I can't stress this enough), notice that there is no space between `...alltr.rwtheme/` and `switch.sh`.

2. If you're not happy with the updates or if something breaks, you can revert to the last saved backup copies with `switch.sh -u revert`:

	```bash
	MacBook-Pro:~/Library/Application\ Support/Themes/seydesign\ alltr.rwtheme/switch.sh -u revert
	```

	Eh-hem... once again, notice that there is no space between `...alltr.rwtheme/` and `switch.sh`.

## All the commands at a glance

Here some of the possible commands:

```bash
\# switch to local
switch.sh -l local

\# switch to cdn
switch.sh -l cdn

\# update local files
switch.sh -u update

\# revert to last save
switch.sh -u revert

\# check switch.sh version 
switch.sh -V

\# check switch.sh release date
switch.sh -D
```

