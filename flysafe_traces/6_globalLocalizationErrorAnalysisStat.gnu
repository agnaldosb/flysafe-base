# -----------------------------------------------------------------------------
# Combine the overall average of average localization errors from individual 
# nodes in a global file to all simulatios
#
# Jan 25, 2024
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot _globalLocalizartionErrorAnalysisStat.gnu)
#
# Execution order: 6
# -----------------------------------------------------------------------------

ListOfFiles = system('ls *flysafe_global_traces/global_localization_error_rx_statistics_*') # Get global nodes files in current directory

set key autotitle columnhead # ignore header line

VAR1 = './flysafe_global_traces/global_localization_error_rx_statistics.txt' # global file name
set print VAR1

# insert header line in the global file
print 'node	gAvgError	gStdDevAvgError	gAvgMin	gStdDevAvgMin	gAvgMax	gStdDevAvgMax'

# Print node statistics to one file invidualy
do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
   if (strlen(file) == 77){ # get the final IP number relying on string length
      VAR2 = file[73:73]
   } else {
      if (strlen(file) == 78){
         VAR2 = file[73:74]
      } else {
         VAR2 = file[73:75]
      }
   }

   stats file using (floor($2*1e1)/1e1) name "A" nooutput        			  # Get avgMin and turn off the output
   stats file using (floor($3*1e1)/1e1) name "B" nooutput         			  # Get avgMax and turn off the output
   stats file using (floor($4*1e1)/1e1) name "C" nooutput         			  # Get avgMean and turn off the output
   stats file using (floor($5*1e1)/1e1) name "D" nooutput         			  # Get avgStddev and turn off the output
   stats file using (floor($6*1e1)/1e1) name "E" nooutput         			  # Get avgStddev and turn off the output
   stats file using (floor($7*1e1)/1e1) name "F" nooutput         			  # Get avgStddev and turn off the output
   print VAR2,"\t",A_mean,"\t",B_mean,"\t",C_mean,"\t",D_mean,"\t",E_mean,"\t",F_mean
   #print VAR2
}

stats VAR1 using (floor($2*1e1)/1e1) name "A" nooutput        			  # Get avgMin and turn off the output
stats VAR1 using (floor($3*1e1)/1e1) name "B" nooutput         			  # Get avgMax and turn off the output
stats VAR1 using (floor($4*1e1)/1e1) name "C" nooutput         			  # Get avgMean and turn off the output
stats VAR1 using (floor($5*1e1)/1e1) name "D" nooutput         			  # Get avgStddev and turn off the output
stats VAR1 using (floor($6*1e1)/1e1) name "E" nooutput         			  # Get avgStddev and turn off the output
stats VAR1 using (floor($7*1e1)/1e1) name "F" nooutput         			  # Get avgStddev and turn off the output
print "Avg","\t",A_mean,"\t",B_mean,"\t",C_mean,"\t",D_mean,"\t",E_mean,"\t",F_mean