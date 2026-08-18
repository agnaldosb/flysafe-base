#!/bin/bash

# -----------------------------------------------------------------------------
# Get Deviation errors from all simulation rx analysis and put in a global file 
# inside global traces folder
#
# Jan 25, 2024
#
# Run from inside flysafe traces folder
#			 (e.g. ns3.34/flysafe_traces# ./_globalDeviationDelayErrorData.sh)
#
# Execution Order: 8
# -----------------------------------------------------------------------------

[ ! -d flysafe_global_traces ] && mkdir flysafe_global_traces # create folder, if no exists

folder="flysafe_global_traces" # define the name of the folder to global traces

IPFile="deviation_delay_rx_statistics_global.txt"
find . -name $IPFile  > _traceRxFiles # get nodes files from all simulations
IPFileGlobal="global_deviation_delay_rx_statistics.txt"
echo -e "simulation\tmin(ms)\tmax(ms)\tmean(ms)\tstddev(ms)" >> $folder"/"$IPFileGlobal # insert a header line in global file
cat _traceRxFiles | while read line # get each file of one specific node
do
	file=$line
	fileLine=$(sed '2q;d' $file) # get data line from file (2nd line)
	echo -e $fileLine	>> $folder"/"$IPFileGlobal # put the dateTime and data line in global file
done	
[ -e _traceRxFiles ] && rm _traceRxFiles # remove temporary file
