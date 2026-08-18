#!/bin/bash

# -----------------------------------------------------------------------------
# Get neighborhood localization errors from individual nodes rx analysis of each
# simulation and put in a global file to each node
#
# Jan 25, 2024
#
# Run from inside flysafe traces folder
#			 (e.g. ns3.34/flysafe_traces# ./_globalLocalizationErrorData.sh)
#
# Execution Order: 5
#
# Next script to execute: gnuplot _globalLocalizartionErrorAnalysisStat.gnu
# -----------------------------------------------------------------------------

[ ! -d flysafe_global_traces ] && mkdir flysafe_global_traces # create folder, if no exists

folder="flysafe_global_traces" # define the name of the folder to global traces

for i in {1..40} # Search for all nodes
do
	IPFile="localization_error_rx_statistics_192.168.1."$i".txt"
	find . -name $IPFile  > _traceRxFiles # get nodes files from all simulations
	IPFileGlobal="global_localization_error_rx_statistics_192.168.1."$i".txt"
	echo -e "dateTime\tavgAvgError\tstdDevAvgError\tavgAvgMin\tstdDevAvgMin\tavgAvgMax\tstdDevAvgMax" >> $folder"/"$IPFileGlobal # insert a header line in global file
	cat _traceRxFiles | while read line # get each file of one specific node
	do
		file=$line
		dateTime=${line:2:13}
		fileLine=$(sed '2q;d' "./"$dateTime"/"$IPFile) # get data line from file (2nd line)
		echo -e $dateTime" "$fileLine	>> $folder"/"$IPFileGlobal # put the dateTime and data line in global file
	done	
	[ -e _traceRxFiles ] && rm _traceRxFiles # remove temporary file
done