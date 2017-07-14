#!/bin/sh
#
# CableModemCapture-SB6183.sh
# v2017-05-17
# Copyright (C) 2017 Paul Chevalier - All Rights Reserved
# Permission to use, copy, modify, and distribute this software is hereby granted for any purpose without fee, provided that the above copyright notice appears in all copies.
# No representation is made about the suitability of this software for any purpose, it is provided "as is" without express or implied warranty.
# Any use is at your own risk.
# 
#==========================  PURPOSE  ===============================
# 1: Runs the lynx text-based web browser via cli to dump text data from a cable modem status URI,
# 2: Parses the text data to extract specific numerical data of interest (downstream power, SNR, upstream power), 
# 3: Appends the timestamped numerical data to running CSV data files (DownPowerLevels.csv , DownPowerLevels.csv, and SNR-Levels.csv)
# Can be run from cron, typically every 5 minutes.
# The parsing parameters are specific to an Arris SB6183 cable modem, but can be easily modified for other modems/devices that can produce a repeatable pattern of data via a URI.
# The csv's can subsequently be used to produce graphs over time(e.g. dygraphs), and/or published via web server
#
# ======================  CONFIGURATION  ============================
# Change MYDIR to your target preexisting directory where the CSV files produced by this script will be written.
MYDIR=/var/www/html/SB6183
# When run for the first time, optionally manually add your preferred headers to the first line of each of the csv files (e.g. Date, ch1, ch2, etc.)
#
# ================= Shouldn't need to modify anything below =========
#
mkdir -p $MYDIR
TEMPDIR=/dev/shm
#
#  use pid ($$) to uniquely name the working files, to minimize filenaming collisions with any other processes
#
TEMPMASTER=$TEMPDIR/TEMPMASTER-$$
rm -f $TEMPMASTER
#
TEMPFILE=$TEMPDIR/TEMPFILE-$$
rm -f $TEMPFILE
#
TEMPDATE=$TEMPDIR/TEMPDATE-$$
rm -f $TEMPDATE
#
# put the current ISO8601 formatted date & time into a temp file
date +%Y-%m-%d-%H:%M:%S > $TEMPDATE
#
# run lynx against the cable modem status URI, using a width of 100 to avoid line-wrapping, and using the "dump" option to capture all URI content in plain text format. That text data will then be parsed in subsequent operations
/usr/bin/lynx -width=100 -dump http://192.168.100.1/RgConnect.asp > $TEMPMASTER
#
# ===================  DOWNSTREAM POWER  ============================
# insert date into a new temp file
cat $TEMPDATE > $TEMPFILE
# parse $TEMPMASTER to extract the downstream power data 
# (trim to range of target line numbers, grep for lines with target identifier, use sed to shrink multiple whitespace to one, cut using a whitespace delimiter to the target field, append to temp file)
cat $TEMPMASTER | sed -n '23,38 p' | grep dBmV | sed 's/   */ /g' | cut -d" " -f 8 >> $TEMPFILE
# use sed to move the content from all lines to the first line, separate with commas, and append to target csv file
sed -e :a -e '/$/N; s/\n/,/; ta' $TEMPFILE >>  $MYDIR/DownPowerLevels.csv
# cleanup temp file
rm -f $TEMPFILE
#
# ===========================  SNR  =================================
# insert date into a new temp file
cat $TEMPDATE > $TEMPFILE
# parse $TEMPMASTER to extract the SNR data
# (trim to range of target line numbers, grep for lines with target identifier, use sed to shrink multiple whitespace to one, cut using a whitespace delimiter to the target field, append to temp file)
cat $TEMPMASTER | sed -n '23,38 p' | grep dBmV | sed 's/   */ /g' | cut -d" " -f 10 >> $TEMPFILE
#
# use sed to move the content from all lines to the first line, separate with commas, and append to target csv file
sed -e :a -e '/$/N; s/\n/,/; ta' $TEMPFILE >>  $MYDIR/SNR-Levels.csv
# cleanup temp file
rm -f $TEMPFILE
#
# ======================  UPSTREAM POWER  ===========================
# insert date into a new temp file
cat $TEMPDATE > $TEMPFILE
# parse $TEMPMASTER to extract the upstream power data
# (trim to range of target line numbers, grep for lines with target identifier, use sed to shrink multiple whitespace to one, cut using a whitespace delimiter to the target field, append to temp file)
cat $TEMPMASTER | sed -n '42,44 p' | grep dBmV | sed 's/   */ /g' | cut -d' ' -f 10 >> $TEMPFILE
#
# use sed to move the content from all lines to the first line, separate with commas, and append to target csv file
sed -e :a -e '/$/N; s/\n/,/; ta' $TEMPFILE >>  $MYDIR/UpPowerLevels.csv
# cleanup temp file
rm -f $TEMPFILE
# ===================================================================
# final cleanup and exit
rm -f $TEMPMASTER
rm -f $TEMPDATE