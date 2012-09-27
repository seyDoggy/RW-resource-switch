#!/bin/bash
set -e

SWITCHVERSION=1.1.0
DATE="September 27, 2012"

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

	switch.sh [-options] [-h] [-l <local/cdn>] [-u <update/revert>] [-V] [-D]

The default action is to switch a theme from using CDN files with local fallback to an all local system.


OPTIONS:
	-h	Show this message
	-l	location (local or cdn)
	-u	update (update or revert)
	-V	show the version information
	-D	show date of version
	
	
EXAMPLES:
	
	switch.sh -l local
		This will convert your theme into one that references only local files
		
	switch.sh -l cdn
		This will convert your theme into one that references CDN files with local files used as a fallback.

	switch.sh -u update
		This will update you local script files with the code from the current CDN versions.

	switch.sh -u revert
		This will revert you local script files to the last version stored.

EOF1
}

#///////#
# LOCAL #
#///////#

local_fn() {
# copy original
if [[ ! -f "$HTMLPATH"/.index.cdn ]]; then
	cp "$HTMLPATH"/index.html "$HTMLPATH"/.index.cdn

	# modify the script lines
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
	mv "$HTMLPATH"/.index.cdn "$HTMLPATH"/index.html
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
cp "$SCRIPTPATH"/common.local.js "$SCRIPTPATH"/.common.local.cdn

# get common.min.js
curl https://d2c8zg9eqwmdau.cloudfront.net/rw/common.min.js > "$SCRIPTPATH"/common.local.js

# get theme.min.js
echo -e "\n\n/*\n\tTheme scripts\n*/\n" >> "$SCRIPTPATH"/common.local.js
curl https://"$CDN".cloudfront.net/rw/"$THEMENAME".min.js >> "$SCRIPTPATH"/common.local.js

# add html5shiv
echo -e "\n" >> "$SCRIPTPATH"/common.local.js
curl https://html5shiv.googlecode.com/svn/trunk/html5.js >> "$SCRIPTPATH"/common.local.js

# UPDATE PRETTYPHOTO FILES ONLY #

#backup jquery.prettyphoto.css
cp "$PRETTYPHOTOPATH"/jquery.prettyphoto.css "$PRETTYPHOTOPATH"/.jquery.prettyphoto.css.cdn

#backup fresh jquery.prettyphoto.css
curl https://d2c8zg9eqwmdau.cloudfront.net/prettyphoto/jquery.prettyPhoto.css > "$PRETTYPHOTOPATH"/jquery.prettyPhoto.css

#backup jquery.prettyphoto.js
cp "$PRETTYPHOTOPATH"/jquery.prettyphoto.js "$PRETTYPHOTOPATH"/.jquery.prettyphoto.js.cdn

#backup fresh jquery.prettyphoto.js
curl https://d2c8zg9eqwmdau.cloudfront.net/prettyphoto/jquery.prettyPhoto.js > "$PRETTYPHOTOPATH"/jquery.prettyPhoto.js

# message
echo "SUCCESS! The local script files for your ${THEMENAME} theme have been successfully updated."
sleep 1 

}

#////////#
# UPDATE #
#////////#

revert_fn() {
if [[ -f "$SCRIPTPATH"/.common.local.cdn ]]; then
	mv "$SCRIPTPATH"/.common.local.cdn "$SCRIPTPATH"/common.local.js
	mv "$PRETTYPHOTOPATH"/.jquery.prettyphoto.js.cdn "$PRETTYPHOTOPATH"/jquery.prettyphoto.js
	mv "$PRETTYPHOTOPATH"/.jquery.prettyphoto.css.cdn "$PRETTYPHOTOPATH"/jquery.prettyphoto.css
	
	# message
	echo "SUCCESS! The local script files for your ${THEMENAME} theme have been reverted to the last backup version."
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

# test location arg
if [[ $LOCATION == local ]]; then
	local_fn
elif [[ $LOCATION == cdn ]]; then
	cdn_fn
fi

# test update arg
if [[ $UPDATE == update ]]; then
	update_fn
elif [[ $UPDATE == revert ]]; then
	revert_fn
fi

exit 0