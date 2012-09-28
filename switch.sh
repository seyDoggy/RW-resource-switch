#!/bin/bash
set -e

SWITCHVERSION=1.2.0
DATE="September 28, 2012"

#############
# FUNCTIONS #
#############

#////////////////////#
# USAGE INSTRUCTIONS #
#////////////////////#

usage_fn() {
less << EOF1
Copyright (c) 2012 Adam Merrifield
switch $SWITCHVERSION ($DATE).

Usage:

	switch.sh [-options] [-h] [-l <local/cdn>] [-u <update/revert/update-switch/revert-switch>] [-V] [-D]

The default action is to switch a theme from using CDN files with local fallback to an all local system.


OPTIONS:
	-h	Show this message
	-l	location (local or cdn)
	-u	update (update, revert, update-switch, revert-switch)
	-V	show the version information
	-D	show date of version
	
	
EXAMPLES:
	
	switch.sh -l local
		This will convert your theme into one that references only local files
		
	switch.sh -l cdn
		This will convert your theme into one that references CDN files with local files used as a fallback.

	switch.sh -u update
		This will update your local script files with the code from the current CDN versions.

	switch.sh -u revert
		This will revert your local script files to the last version stored.

	switch.sh -u update-switch
		This will update your switch.sh script with the code from the current CDN versions.

	switch.sh -u revert-switch
		This will revert your switch.sh script with the last version stored.

EOF1
}

#///////#
# LOCAL #
#///////#

local_fn() {
# copy original
if [[ ! -f "$HTMLPATH"/.index.cdn ]]; then
	
	echo "Making a backup copy of index.html..."
	cp "$HTMLPATH"/index.html "$HTMLPATH"/.index.cdn
	echo "Done!"

	# modify the script lines
	echo "Rewriting index.html to use local files only..."
	sed -n '
	# if the first line copy the pattern to the hold buffer
	1h
	# if not the first line then append the pattern to the hold buffer
	1!H
	# if the last line then ...
	$ {
	        # copy from the hold to the pattern buffer
	        g
	        # do the search and replace
	        s#<!-- Theme Libraries.*)</script>#<!-- Theme Libraries -->\
	<script src="%pathto(template/'"$THEMENAME"'/common.local.js)%"></script>#g
	        # print
	        p
	}
	' "$HTMLPATH"/index.html > "$HTMLPATH"/temp.html;

	# replace the original
	mv "$HTMLPATH"/temp.html "$HTMLPATH"/index.html
	echo "Done!"

	# message
	echo "SUCCESS! Your ${THEMENAME} theme has been successfully internalized."
	sleep 1

else
	# message
	echo "WARNING! Your ${THEMENAME} theme seems to be using local files already."
	sleep 1 
fi
}

#/////#
# CDN #
#/////#

cdn_fn() {

# if backup file exists
if [[ -f "$HTMLPATH"/.index.cdn ]]; then
	
	echo "Restoring index.html from latest backup..."
	mv "$HTMLPATH"/.index.cdn "$HTMLPATH"/index.html
	echo "Done!"

	# message
	echo "SUCCESS! Your ${THEMENAME} theme now uses CDN files."
	sleep 1
else
	# message
	echo "WARNING! Your ${THEMENAME} theme seems to be using CDN files already."
	sleep 1 
fi

}

#////////#
# UPDATE #
#////////#

update_fn() {

# UPDATE COMMON.LOCAL.JS #

# backup current common.local.js
echo "Making a backup copy of common.local.js..."
cp "$SCRIPTPATH"/common.local.js "$SCRIPTPATH"/.common.local.cdn
echo "Done!"

# get common.min.js
echo "Getting a fresh copy of common.min.js of from the CDN..."
curl https://d2c8zg9eqwmdau.cloudfront.net/rw/common.min.js > "$SCRIPTPATH"/common.local.js
echo "Done!"

# get theme.min.js
echo "Getting a fresh copy of $THEMENAME.min.js from the CDN..."
echo -e "\n\n/*\n\tTheme scripts\n*/\n" >> "$SCRIPTPATH"/common.local.js
curl https://"$CDN".cloudfront.net/rw/"$THEMENAME".min.js >> "$SCRIPTPATH"/common.local.js
echo "Done!"

# add html5shiv
echo "Getting a fresh copy of HTML5 shiv from the CDN..."
echo -e "\n" >> "$SCRIPTPATH"/common.local.js
curl https://html5shiv.googlecode.com/svn/trunk/html5.js >> "$SCRIPTPATH"/common.local.js
echo "Done!"

# UPDATE PRETTYPHOTO FILES ONLY #

#backup jquery.prettyphoto.css
echo "Making a backup copy of jquery.prettyphoto.css..."
cp "$PRETTYPHOTOPATH"/jquery.prettyphoto.css "$PRETTYPHOTOPATH"/.jquery.prettyphoto.css.cdn
echo "Done!"

#get fresh jquery.prettyphoto.css
echo "Getting a fresh copy of jquery.prettyphoto.css from the CDN..."
curl https://d2c8zg9eqwmdau.cloudfront.net/prettyphoto/jquery.prettyPhoto.css > "$PRETTYPHOTOPATH"/jquery.prettyPhoto.css
echo "Done!"

#backup jquery.prettyphoto.js
echo "Making a backup copy of jquery.prettyphoto.js..."
cp "$PRETTYPHOTOPATH"/jquery.prettyphoto.js "$PRETTYPHOTOPATH"/.jquery.prettyphoto.js.cdn
echo "Done!"

#get fresh jquery.prettyphoto.js
echo "Getting a fresh copy of jquery.prettyphoto.js from the CDN..."
curl https://d2c8zg9eqwmdau.cloudfront.net/prettyphoto/jquery.prettyPhoto.js > "$PRETTYPHOTOPATH"/jquery.prettyPhoto.js
echo "Done!"

# message
echo "SUCCESS! The local script files for your ${THEMENAME} theme have been successfully updated."
sleep 1 

}

#////////#
# REVERT #
#////////#

revert_fn() {
if [[ -f "$SCRIPTPATH"/.common.local.cdn ]]; then
	echo "Restoring common.local.js from latest backup..."
	mv "$SCRIPTPATH"/.common.local.cdn "$SCRIPTPATH"/common.local.js
	echo "Done!"

	echo "Restoring jquery.prettyphoto.js from latest backup..."
	mv "$PRETTYPHOTOPATH"/.jquery.prettyphoto.js.cdn "$PRETTYPHOTOPATH"/jquery.prettyphoto.js
	echo "Done!"

	echo "Restoring jquery.prettyphoto.css from latest backup..."
	mv "$PRETTYPHOTOPATH"/.jquery.prettyphoto.css.cdn "$PRETTYPHOTOPATH"/jquery.prettyphoto.css
	echo "Done!"
	
	# message
	echo "SUCCESS! The local script files for your ${THEMENAME} theme have been reverted to the last backup version."
	sleep 1 
else
	# message
	echo "WARNING! There are no backup versions to revert to."
	sleep 1 
fi
}

#///////////////#
# UPDATE SWITCH #
#///////////////#

update-switch_fn() {
echo "Making a backup copy of switch.sh..."
cp -f "$NPATH"/switch.sh "$NPATH"/.switch.bak
echo "Done!"
echo "Getting a fresh copy switch.sh from the CDN..."
curl https://raw.github.com/seyDoggy/RW-resource-switch/master/switch.sh > "$NPATH"/switch.sh
echo "Done!"
# message
echo "SUCCESS! The local script files for your ${THEMENAME} theme have been reverted to the last backup version."
sleep1
}

#///////////////#
# REVERT SWITCH #
#///////////////#

revert-switch_fn() {
if [[ -f "$NPATH"/.switch.bak ]]; then
	echo "Restoring switch.sh from last backup..."
	mv "$NPATH"/.switch.bak "$NPATH"/switch.sh
	echo "Done!"
	# message
	echo "SUCCESS! switch.sh has been reverted to the last backup version."
	sleep 1
else
	# message
	echo "WARNING! There are no backup versions to revert to."
	sleep 1 
fi
}


#############
# VARIABLES #
#############

NPATH="$(dirname "$0")"
if [[ -d "$NPATH"/Contents/template ]]; then
	THEMENAME=`ls "$NPATH"/Contents/template/`
	SCRIPTPATH="$NPATH"/Contents/template/"$THEMENAME"
	HTMLPATH="$NPATH"/Contents/template/"$THEMENAME"
	PRETTYPHOTOPATH="$NPATH"/Contents/options/prettyphoto
else
	SCRIPTPATH="$NPATH"/Contents/scripts
	HTMLPATH="$NPATH"/Contents
	PRETTYPHOTOPATH="$NPATH"/Contents/css/prettyphoto
fi
if [[ ! -f "$HTMLPATH"/.index.cdn ]]; then
	THISINDEX="$HTMLPATH"/index.html
else
	THISINDEX="$HTMLPATH"/.index.cdn
fi
THEMENAME=`grep -v "common" "$THISINDEX" | grep -F "cloudfront.net/rw/" | sed -e 's#.*cloudfront\.net/rw/\(.*\)\.min\.js.*#\1#'`
CDN=`grep -v "$THEMENAME" "$THISINDEX" | grep -F "cloudfront.net/rw/" | sed -e 's#.*https://\(.*\)\.cloudfront.*#\1#'`
LOCATION=
UPDATE=

# get arguments
while getopts ":hl:u:VD" OPTION
do
	case $OPTION in
		h) usage_fn; exit 1;;
		l) LOCATION=${OPTARG};;
		u) UPDATE=${OPTARG};;
		V) echo $SWITCHVERSION; exit 1;;
		D) echo $DATE; exit 1;;
		?) usage_fn; exit 1;;
	esac
done

if [[ ! -z $LOCATION || ! -z $UPDATE ]]; then
	if [[ ! -z $LOCATION ]]; then
		# test location arg
		if [[ $LOCATION == local ]]; then
			local_fn
		elif [[ $LOCATION == cdn ]]; then
			cdn_fn
		else
			usage_fn
			exit 1
		fi
	fi
	
	if [[ ! -z $UPDATE ]]; then
		# test update arg
		if [[ $UPDATE == update ]]; then
			update_fn
		elif [[ $UPDATE == revert ]]; then
			revert_fn
		elif [[ $UPDATE == update-switch ]]; then
			update-switch_fn
		elif [[ $UPDATE == update-revert ]]; then
			revert-switch_fn
		else
			usage_fn
			exit 1
		fi
	fi
else
	usage_fn
	exit 1
fi

exit 0