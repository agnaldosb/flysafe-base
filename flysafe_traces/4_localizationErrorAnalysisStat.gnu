# -----------------------------------------------------------------------------
# Stats Localization errors from individual nodes analysis to a individual file
# for each node in its simulation folder results
#
# May 31, 2023
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot _localizationErrorAnalysisStat.gnu)
#
# Execution Order: 4
#
# Attention, run the bash script ./_globalLocalizationErrorData.sh right after!
# -----------------------------------------------------------------------------

ListOfFiles = system('find . -name *neighborhood_rx_localization_error_analysis_*') # Get nodes log files

set key autotitle columnhead # ignore header line

# Print node statistics to one file invidualy
do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
   if (strlen(file) == 75){ # get the final IP number relying on string length
      VAR1 = file[71:71]
   } else {
      if (strlen(file) == 76){
         VAR1 = file[71:72]
      } else {
         VAR1 = file[71:73]
      }
   }
   VAR2 = file[1:16] # get folder name
   
   VAR3 = VAR2.'localization_error_rx_statistics_192.168.1.'.VAR1.'.txt' # global file name
   set print VAR3
   
   print 'avgAvgError stdDevAvgError avgAvgMin stdDevAvgMin avgAvgMax stdDevAvgMax' # insert header line in the global file

   stats file using (floor($3*1e1)/1e1) name "A" nooutput        			  # Get avgMin and turn off the output
   stats file using (floor($4*1e1)/1e1) name "B" nooutput         			  # Get avgMax and turn off the output
   stats file using (floor($5*1e1)/1e1) name "C" nooutput         			  # Get avgMean and turn off the output
   print (floor(A_mean*1e2)/1e2),"\t",(floor(A_stddev*1e2)/1e2),"\t",(floor(B_mean*1e2)/1e2),"\t",(floor(B_stddev*1e2)/1e2),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(C_stddev*1e2)/1e2)
}
