#!/bin/bash

# -----------------------------------------------------------------------------
# Perform rounds analysys to achieve spatial awareness individual nodes tx and 
# rx of each simulation and put in an individual files to each node. It computes
# the total of received and transmited messages to achieve spatial awareness
#
#
# Jun 27, 2023
#
# Run from inside flysafe traces folder
#			 (e.g. ns3.34/flysafe_traces# ./_roundsAchieveAwarenessNodeAnalysis.sh)
#
# Execution order: 12
# -----------------------------------------------------------------------------

#: <<'COMMENT0'
#[ ! -d flysafe_global_traces ] && mkdir flysafe_global_traces # create folder, if no exists
#folder="flysafe_global_traces" # define the name of the folder to global traces
IPFile="spatial_no_awareness_192.168.1.*"
find . -name $IPFile  > _traceFiles # get nodes files from all simulations
#IPFileGlobal="global_localization_error_rx_statistics_192.168.1."$i".txt"
#echo -e "dateTime\tavgAvgError\tstdDevAvgError\tavgAvgMin\tstdDevAvgMin\tavgAvgMax\tstdDevAvgMax" >> $folder"/"$IPFileGlobal # insert a header line in global file
cat _traceFiles | while read line # get each file of one specific node
do
	dateTime=${line:2:13}
	fileLength=${#line}
	if [ $fileLength == "52" ]; then
		nodeNumber=${line:47:1}
	else
		if [ $fileLength == "53" ]; then
			nodeNumber=${line:47:2}
		else
			nodeNumber=${line:47:3}
		fi
	fi
		

	#***************************************************************************************************
	# Received messages analysis
	#***************************************************************************************************

	rxAwareFile="./"$dateTime"/rounds_rx_achieve_spatial_awareness_analysis_192.168.1."$nodeNumber".txt"
	echo -e "sTime\teTime\tdur\tnMsg\tnBroad\tnId\tnTrap" >> $rxAwareFile # Insert header line in rounds file
	nLines=$(wc -l < $line) # get number of lines in the file
	for i in $(seq 2 $nLines)
	do
		nRxMsg=0
		nTrap=0
		nBroad=0
		nId=0
		fileLine=$(sed $i'q;d' $line) # get data line from file (2nd line)
		startTime=$(echo $fileLine | cut -d ' ' -f 1)
		endTime=$(echo $fileLine | cut -d ' ' -f 2)
		rxFile="./"$dateTime"/messages_received_192.168.1."$nodeNumber".txt"
		nRxLines=$(wc -l < $rxFile) # get number of lines in the file
		for j in $(seq 2 $nRxLines)
		do
			rxFileLine=$(sed $j'q;d' $rxFile) # get data line from file (2nd line)
			rxTime=$(echo $rxFileLine | cut -d ' ' -f 1)
			rxMsg=$(echo $rxFileLine | cut -d ' ' -f 3)
			if [ "$rxTime" == "$startTime" ]; then
				nRxMsg=$((nRxMsg + 1))
				if [ $rxMsg == "0" ]; then #broadcast
					nBroad=$((nBroad + 1))
				else
					if [ $rxMsg == "1" ]; then #id
						nId=$((nId + 1))
					else # trap
						nTrap=$((nTrap + 1))
					fi
				fi
			else
				if (( $(echo "$rxTime > $startTime" |bc -l) )); then
					if (( $(echo "$rxTime < $endTime" |bc -l) )); then
						nRxMsg=$((nRxMsg + 1))
						if [ $rxMsg == "0" ]; then #broadcast
							nBroad=$((nBroad + 1))
						else
							if [ $rxMsg == "1" ]; then #id
								nId=$((nId + 1))
							else # trap
								nTrap=$((nTrap + 1))
							fi
						fi
					fi
					if [ "$rxTime" == "$endTime" ]; then
						nRxMsg=$((nRxMsg + 1))
						if [ $rxMsg == "0" ]; then #broadcast
							nBroad=$((nBroad + 1))
						else
							if [ $rxMsg == "1" ]; then #id
								nId=$((nId + 1))
							else # trap
								nTrap=$((nTrap + 1))
							fi
						fi
						break
					fi
					if (( $(echo "$rxTime > $endTime" |bc -l) )); then
						break
					fi
				fi
			fi
		done
		if (( $(echo "$nRxMsg > 0" |bc -l) )); then
			duration=$(bc <<< "$endTime-$startTime")
			echo -e $startTime"\t"$endTime"\t"$duration"\t"$nRxMsg"\t"$nBroad"\t"$nId"\t"$nTrap >> $rxAwareFile
		fi
	done
	

	#***************************************************************************************************
	# Transmitted messages analysis
	#***************************************************************************************************
	txAwareFile="./"$dateTime"/rounds_tx_achieve_spatial_awareness_analysis_192.168.1."$nodeNumber".txt"
	echo -e "sTime\teTime\tdur\tnMsg\tnBroad\tnId\tnTrap" >> $txAwareFile # Insert header line in rounds file
	nLines=$(wc -l < $line) # get number of lines in the file
	for i in $(seq 2 $nLines)
	do
		nTxMsg=0
		nTrap=0
		nBroad=0
		nId=0
		fileLine=$(sed $i'q;d' $line) # get data line from file (2nd line)
		startTime=$(echo $fileLine | cut -d ' ' -f 1)
		endTime=$(echo $fileLine | cut -d ' ' -f 2)
		txFile="./"$dateTime"/messages_sent_192.168.1."$nodeNumber".txt"
		nTxLines=$(wc -l < $txFile) # get number of lines in the file
		for j in $(seq 2 $nTxLines)
		do
			txFileLine=$(sed $j'q;d' $txFile) # get data line from file (2nd line)
			txTime=$(echo $txFileLine | cut -d ' ' -f 1)
			txMsg=$(echo $txFileLine | cut -d ' ' -f 3)
			if [ "$txTime" == "$startTime" ]; then
				nTxMsg=$((nTxMsg + 1))
				if [ $txMsg == "0" ]; then #broadcast
					nBroad=$((nBroad + 1))
				else
					if [ $txMsg == "1" ]; then #id
						nId=$((nId + 1))
					else # trap
						nTrap=$((nTrap + 1))
					fi
				fi
			else
				if (( $(echo "$txTime > $startTime" |bc -l) )); then
					if (( $(echo "$txTime < $endTime" |bc -l) )); then
						nTxMsg=$((nTxMsg + 1))
						if [ $txMsg == "0" ]; then #broadcast
							nBroad=$((nBroad + 1))
						else
							if [ $txMsg == "1" ]; then #id
								nId=$((nId + 1))
							else # trap
								nTrap=$((nTrap + 1))
							fi
						fi
					fi
					if [ "$txTime" == "$endTime" ]; then
						nTxMsg=$((nTxMsg + 1))
						if [ $txMsg == "0" ]; then #broadcast
							nBroad=$((nBroad + 1))
						else
							if [ $txMsg == "1" ]; then #id
								nId=$((nId + 1))
							else # trap
								nTrap=$((nTrap + 1))
							fi
						fi
						break
					fi
					if (( $(echo "$txTime > $endTime" |bc -l) )); then
						break
					fi
				fi
			fi
		done
		if (( $(echo "$nTxMsg > 0" |bc -l) )); then
			duration=$(bc <<< "$endTime-$startTime")
			echo -e $startTime"\t"$endTime"\t"$duration"\t"$nTxMsg"\t"$nBroad"\t"$nId"\t"$nTrap >> $txAwareFile
		fi
	done
done	

[ -e _traceFiles ] && rm _traceFiles # remove temporary file

#COMMENT0
#***************************************************************************************************
# Resume all date in only one file for each node
#***************************************************************************************************

noAwareFile="spatial_no_awareness_192.168.1.*"
find . -name $noAwareFile  > _traceFiles # get nodes files from all simulations
cat _traceFiles | while read line # get each file of one specific node
do
	dateTime=${line:2:13}
	fileLength=${#line}
	if [ $fileLength == "52" ]; then
		nodeNumber=${line:47:1}
	else
		if [ $fileLength == "53" ]; then
			nodeNumber=${line:47:2}
		else
			nodeNumber=${line:47:3}
		fi
	fi

	awareGlobal="./"$dateTime"/rounds_achieve_aware_analysis_192.168.1."$nodeNumber".txt"
	headerTx="sTime\teTime\tdur\tnTM\tnTB\tnTI\tnTT"
	headerRx="nRM\tnRB\tnRI\tnRT\tnTM"
	echo -e $awareGlobal
	echo -e $headerTx"\t"$headerRx >> $awareGlobal

	rxFile="./"$dateTime"/rounds_rx_achieve_spatial_awareness_analysis_192.168.1."$nodeNumber".txt"
	txFile="./"$dateTime"/rounds_tx_achieve_spatial_awareness_analysis_192.168.1."$nodeNumber".txt"

	nLines=$(wc -l < $line) # get number of lines in the file
	for k in $(seq 2 $nLines)
	do
		noAwareLine=$(sed $k'q;d' $line)
		startTime=$(echo $noAwareLine | cut -d ' ' -f 1)
		endTime=$(echo $noAwareLine | cut -d ' ' -f 2)
		duration=$(echo $noAwareLine | cut -d ' ' -f 3)

		# get line from rx file
		nRxLines=$(wc -l < $rxFile) # get number of lines in the file
		for l in $(seq 2 $nRxLines)
		do
			rRxLine=$(sed $l'q;d' $rxFile)
			rFirst=$(echo $rRxLine | cut -d ' ' -f 1)
			if [ "$startTime" == "$rFirst" ]; then
				nRxMsg=$(echo $rRxLine | cut -d ' ' -f 4)
				nRxBroad=$(echo $rRxLine | cut -d ' ' -f 5)
				nRxId=$(echo $rRxLine | cut -d ' ' -f 6)
				nRxTrap=$(echo $rRxLine | cut -d ' ' -f 7)
				break
			else
				nRxMsg=0
				nRxBroad=0
				nRxId=0
				nRxTrap=0
			fi
		done

		#get line from tx file
		nTxLines=$(wc -l < $txFile) # get number of lines in the file
		for m in $(seq 2 $nTxLines)
		do
			rTxLine=$(sed $m'q;d' $txFile)
			rFirst=$(echo $rTxLine | cut -d ' ' -f 1)
			if [ "$startTime" == "$rFirst" ]; then
				nTxMsg=$(echo $rTxLine | cut -d ' ' -f 4)
				nTxBroad=$(echo $rTxLine | cut -d ' ' -f 5)
				nTxId=$(echo $rTxLine | cut -d ' ' -f 6)
				nTxTrap=$(echo $rTxLine | cut -d ' ' -f 7)
				break
			else
				nTxMsg=0
				nTxBroad=0
				nTxId=0
				nTxTrap=0
			fi
		done

		nTotalMsg=$(bc <<< "$nRxMsg+$nTxMsg")

		lineTx=$startTime"\t"$endTime"\t"$duration"\t"$nTxMsg"\t"$nTxBroad"\t"$nTxId"\t"$nTxTrap
		lineRx=$nRxMsg"\t"$nRxBroad"\t"$nRxId"\t"$nRxTrap"\t"$nTotalMsg

		echo -e $lineTx"\t"$lineRx >> $awareGlobal
	done
done	

[ -e _traceFiles ] && rm _traceFiles # remove temporary file