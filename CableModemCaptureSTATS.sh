#!/bin/sh
#
# CableModemCapture-STATS.sh
# v2017-04-12
# Script by pchevalier
#
# To be run from cron, typically every 5 minutes, to keep a running log of Arris SB6183 cable modem stats
# Captures downstream power, SNR, and upstream power, each stored in running csv files for later graphing (e.g. dygraphs)
# When run for the first time, manually add your preferred headers to the first line of the csv files (e.g. Date, ch1, ch2, etc.)
#
# ******************** Configuration ***********************************
# Change MYDIR to your target location where resulting CSV files will be stored.
#MYDIR=/cygdrive/c/users/pc/CableModemLogs/SANDBOX
MYDIR=/cygdrive/c/users/pc/CableModemLogs/STATS
#
# ********* Shouldn't need to modify anything below ********************
#
TEMPDIR=/dev/shm
#
TEMPMASTER=$TEMPDIR/TEMPMASTER
rm -f $TEMPMASTER
#
TEMPFILE=$TEMPDIR/TEMPFILE
rm -f $TEMPFILE
#
TEMPDATE=$TEMPDIR/TEMPDATE
rm -f $TEMPDATE
#
# put the current ISO8601 formatted date & time into a temp file
date +%Y-%m-%d-%H:%M:%S > $TEMPDATE
#
# run w3m against the cable modem status page to capture it in plain text format to a file, to be used in the following three parse operations
/usr/bin/w3m -dump http://192.168.100.1/RgConnect.asp > $TEMPMASTER
#
# ==================  DOWNSTREAM POWER DATA  ============================
# put date in a temp file
cat $TEMPDATE > $TEMPFILE
# parse the lines and columns to extract the downstream power data (trim to lines 30-60, remove lines with "dBmV", trim to columns 45-48), append to temp file
cat $TEMPMASTER | sed -n '30,60 p' | grep -v dBmV | cut -c45-48 >> $TEMPFILE
#
# run sed to move the content from all lines to the first line, separate with commas, and append to target csv file
sed -e :a -e '/$/N; s/\n/,/; ta' $TEMPFILE >>  $MYDIR/DownPowerLevels.csv
rm -f $TEMPFILE
#
# ==================  SNR DATA   ========================================
# put date in a temp file
cat $TEMPDATE > $TEMPFILE
# parse the lines and columns to extract the SNR data (trim to lines 30-60, remove lines with "dBmV", trim to columns 51-54), append to temp file
 cat $TEMPMASTER | sed -n '30,60 p' | grep -v dBmV | cut -c51-54 >> $TEMPFILE
 #
# run sed to move the content from all lines to the first line, separate with commas, and append to target csv file
sed -e :a -e '/$/N; s/\n/,/; ta' $TEMPFILE >>  $MYDIR/SNR-Levels.csv
rm -f $TEMPFILE
#
# ==================  UPSTREAM POWER DATA  ==============================
# put date in a temp file
cat $TEMPDATE > $TEMPFILE
# parse the lines and columns to extract the upstream power data (trim to lines 67-71, remove lines with "sec", trim to columns 72-75), append to temp file
cat $TEMPMASTER | sed -n '67,71 p' | grep -v sec | cut -c72-75 >> $TEMPFILE
#
# run sed to move the content from all lines to the first line, separate with commas, and append to target csv file
sed -e :a -e '/$/N; s/\n/,/; ta' $TEMPFILE >>  $MYDIR/UpPowerLevels.csv
rm -f $TEMPFILE
# =======================================================================
#
rm -f $TEMPMASTER
rm -f $TEMPDATE
