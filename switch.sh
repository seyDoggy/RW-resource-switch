#!/bin/bash
set -e

SWITCHVERSION=1.0.0
DATE="September 25, 2012"

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

	switch.sh [-options] [-h] [-l <local/cdn>] [-V] [-D]

The default action is to switch a theme from using CDN files with local fallback to an all local system.


OPTIONS:
	-h	Show this message
	-l	location (local or cdn)
	-V	show the version information
	-D	show date of version
	
	
EXAMPLES:
	
	switch.sh -l local
		This will convert your theme into one that references only local files
		
	switch.sh -l cdn
		This will convert your theme into one that references CDN files with local files used as a fallback.

EOF1
}

#///////#
# LOCAL #
#///////#

local_fn() {
# copy original
if [[ ! -f "$NPATH"/Contents/template/"$THEMENAME"/.index.cdn ]]; then
	cp "$NPATH"/Contents/template/"$THEMENAME"/index.html "$NPATH"/Contents/template/"$THEMENAME"/.index.cdn

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
	' "$NPATH"/Contents/template/"$THEMENAME"/index.html > "$NPATH"/Contents/template/"$THEMENAME"/temp.html;

	# replace the original
	mv "$NPATH"/Contents/template/"$THEMENAME"/temp.html "$NPATH"/Contents/template/"$THEMENAME"/index.html

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
if [[ -f "$NPATH"/Contents/template/"$THEMENAME"/.index.cdn ]]; then
	mv "$NPATH"/Contents/template/"$THEMENAME"/.index.cdn "$NPATH"/Contents/template/"$THEMENAME"/index.html
	# message
	echo "SUCCESS! Your ${THEMENAME} theme now uses CDN files."
	sleep 1
else
	# message
	echo "WARNING! Your ${THEMENAME} theme seems to be using CDN files already."
	sleep 1 
fi

}

#############
# VARIABLES #
#############

NPATH="$(dirname "$0")"
THEMENAME=`ls "$NPATH"/Contents/template/`
LOCATION=

# get arguments
while getopts ":hl:V:D" OPTION
do
	 case $OPTION in
		 h) usage_fn; exit 1;;
		 l) LOCATION=${OPTARG};;
		 V) echo $SWITCHVERSION; exit 1;;
		 D) echo $DATE; exit 1;;
		 ?) usage_fn; exit 1;;
	 esac
done

# test for required arguments
if [[ -z $LOCATION ]]; then
	 usage_fn
	 exit 1

else 
	if [[ $LOCATION == local ]]; then
		local_fn
		exit 1
	elif [[ $LOCATION == cdn ]]; then
		cdn_fn
		exit 1
	else
		usage_fn
		exit 1
	fi
fi

exit 0