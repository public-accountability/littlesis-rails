#!/bin/bash
#
# Developed by Fred Weinhaus 7/23/2012 .......... 4/15/2015
#
# ------------------------------------------------------------------------------
# 
# Licensing:
# 
# Copyright © Fred Weinhaus
# 
# My scripts are available free of charge for non-commercial use, ONLY.
# 
# For use of my scripts in commercial (for-profit) environments or 
# non-free applications, please contact me (Fred Weinhaus) for 
# licensing arrangements. My email address is fmw at alink dot net.
# 
# If you: 1) redistribute, 2) incorporate any of these scripts into other 
# free applications or 3) reprogram them in another scripting language, 
# then you must contact me for permission, especially if the result might 
# be used in a commercial or for-profit environment.
# 
# My scripts are also subject, in a subordinate manner, to the ImageMagick 
# license, which can be found at: http://www.imagemagick.org/script/license.php
# 
# ------------------------------------------------------------------------------
# 
####
#
# USAGE: sketch [-k kind] [-e edge] [-c con] [-s sat] [-g] infile outfile
# USAGE: sketch [-h or -help]
#
# OPTIONS:
#
# -k     kind     kind of grayscale conversion; options are gray(g) or 
#                 desat(d); default=desat
# -e     edge     edge coarseness; integer>0; default=4 
# -c     con      percent contrast change; integer>=0; default=125
# -s     sat      percent saturation change; integer>=0; default=100
# -g              output grayscale only
#
###
#
# NAME: SKETCH 
# 
# PURPOSE: Applies a sketch like effect to an image.
# 
# DESCRIPTION: SKETCH applies a sketch like effect to an image. If 
# a color image is provided as input, then the output can be either color 
# or grayscale. 
# 
# 
# OPTIONS: 
# 
# -k kind ... KIND of grayscale conversion. Choices are gray(g) or desat(d). 
# The default=desat.
# 
# -e edge ... EDGE coarseness. Values are integers>0. The default=4. 
# 
# -c con ... percent CONTRAST change. Values are integers>=0. The default=125. 
# Note that con=125 for kind=desat is similar to con=0 for kind=gray.
# 
# -s sat ... percent SATURATION change. Values are integers>=0. The default=100.
# 
# -g ... output GRAYSCALE only.
# 
# see http://www.photoshopessentials.com/photo-effects/portrait-to-sketch/
#
# REQUIREMENTS: Results for -k gray will be nearly identical to those of 
# -k desat for IM versions prior to 6.7.8.3. Starting at this version,  
# grayscale images became linear and thus the different look for -k gray.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default values
kind="desat"		# gray or desat
edge=4				# edge width; smaller is finer; larger is coarser; float>0
con=125 			# contrast; 0<=integer<200; con=125 with desat is close to con=0 with gray
sat=100				# percent increase in saturation; integer>=0
gray="no"			# output grayscale sketch; yes/no

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^###/g;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^######/g;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}


# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}


# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 11 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -help|-h)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-k)    # get  kind
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID KIND SPECIFICATION ---"
					   checkMinus "$1"
					   kind=`echo "$1" | tr '[A-Z]' '[a-z]'`
					   case "$kind" in 
					   		gray|g) kind="gray" ;;
					   		desat|d) kind="desat" ;;
					   		*) errMsg "--- KIND=$kind IS AN INVALID VALUE ---" ;;
					   	esac
					   ;;
				-e)    # get edge
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID EDGE SPECIFICATION ---"
					   checkMinus "$1"
					   edge=`expr "$1" : '\([0-9]*\)'`
					   [ "$edge" = "" ] && errMsg "--- EDGE=$edge MUST BE A NON-NEGATIVE INTEGER (with no sign) ---"
					   test1=`echo "$edge < 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- EDGE=$edge MUST BE GREATER THAN 0 ---"
					   ;;
				-c)    # get con
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID CON SPECIFICATION ---"
					   checkMinus "$1"
					   con=`expr "$1" : '\([0-9]*\)'`
					   [ "$con" = "" ] && errMsg "--- CON=$con MUST BE A NON-NEGATIVE INTEGER (with no sign) ---"
					   test1=`echo "$con < 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- CON=$con MUST BE GREATER THAN 0 ---"
					   ;;
				-s)    # get sat
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SAT SPECIFICATION ---"
					   checkMinus "$1"
					   sat=`expr "$1" : '\([0-9]*\)'`
					   [ "$sat" = "" ] && errMsg "--- SAT=$sat MUST BE A NON-NEGATIVE INTEGER (with no sign) ---"
					   test1=`echo "$sat < 0" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- SAT=$sat MUST BE GREATER THAN 0 ---"
					   ;;
				-g)    # get gray
					   #shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID GRAY SPECIFICATION ---"
					   #checkMinus "$1"
					   gray="yes"
					   ;;
			 	-)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile="$1"
	outfile="$2"
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "NO OUTPUT FILE SPECIFIED"


# set up temporaries
tmp1A="$dir/sketch_1_$$.mpc"
tmp1B="$dir/sketch_1_$$.cache"
trap "rm -f $tmp1A $tmp1B;" 0
trap "rm -f $tmp1A $tmp1B; exit 1" 1 2 3 15
trap "rm -f $tmp1A $tmp1B; exit 1" ERR

# test for minimum IM version
im_version=`convert -list configure | \
	sed '/^LIB_VERSION_NUMBER /!d; s//,/;  s/,/,0/g;  s/,0*\([0-9][0-9]\)/\1/g' | head -n 1`

# colorspace RGB and sRGB swapped between 6.7.5.5 and 6.7.6.7 
# though probably not resolved until the latter
# then -colorspace gray changed to linear between 6.7.6.7 and 6.7.8.2 
# then -separate converted to linear gray channels between 6.7.6.7 and 6.7.8.2,
# though probably not resolved until the latter
# so -colorspace HSL/HSB -separate and -colorspace gray became linear
# but we need to use -set colorspace RGB before using them at appropriate times
# so that results stay as in original script
# The following was determined from various version tests using sketch.
# with IM 6.7.4.10, 6.7.6.10, 6.7.8.6
if [ "$im_version" -lt "06070607" -o "$im_version" -gt "06070707" ]; then
	cspace="RGB"
else
	cspace="sRGB"
fi
if [ "$im_version" -lt "06070607" -o "$im_version" -gt "06070707" ]; then
	setcspace="-set colorspace RGB"
else
	setcspace=""
fi
# no need for setcspace for grayscale or channels after 6.8.5.4
if [ "$im_version" -gt "06080504" ]; then
	setcspace=""
	cspace="sRGB"
fi


# test input image
convert -quiet "$infile" +repage "$tmp1A" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE  ---"

if [ "$kind" = "gray" ]; then
	# NOTE: if add $cspace before -colorspace gray, then it will be similar to -modulate
	grayscaling="-colorspace gray"
elif [ "$kind" = "desat" ]; then
	grayscaling="-modulate 100,0,100"
fi
#echo "gray=$grayscaling"

# convert sat from percent change to absolute value for -modulate
sat=`convert xc: -format "%[fx:100+$sat]" info:`
#echo "sat=$sat"

# split contrast
if [ $con -le 100 ]; then
	con1=$con
	con2=0
else
	con1=100
	con2=`convert xc: -format "%[fx:$con-100]" info:`
fi
#echo "con1=$con1; con2=$con2; con=$con"

if [ "$gray" = "no" ]; then	
	convert $tmp1A \
	\( -clone 0 $grayscaling \) \
	\( -clone 1 -negate -blur 0x${edge} \) \
	\( -clone 1 -clone 2 $setcspace -compose color_dodge -composite -level ${con2}x100% \) \
	\( -clone 3 -alpha set -channel a -evaluate set ${con1}% +channel \) \
	\( -clone 3 -clone 4 -compose multiply -composite \) \
	\( -clone 0 -modulate 100,$sat,100 \) \
	-delete 0-4 $setcspace -compose screen -composite "$outfile"
else
	convert $tmp1A \
	\( -clone 0 $grayscaling \) \
	\( -clone 1 -negate -blur 0x${edge} \) \
	\( -clone 1 -clone 2 $setcspace -compose color_dodge -composite -level ${con2}x100% \) \
	\( -clone 3 -alpha set -channel a -evaluate set ${con1}% +channel \) \
	\( -clone 3 -clone 4 $setcspace -compose multiply -composite \) \
	-delete 0-4 "$outfile"
fi

exit 0




