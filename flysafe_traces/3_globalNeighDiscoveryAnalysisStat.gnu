# -----------------------------------------------------------------------------
# Stats neighborhood discovery errors from individual nodes global analysis and
# put data in a global file
#
# May 22, 2023
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalNeighDiscoveryAnalysisStat.gnu)
#
# Execution Order: 3
# -----------------------------------------------------------------------------

ListOfFiles = system('ls *flysafe_global_traces/global_neighborhood_rx_statistics_*') # Get global nodes files in current directory

set key autotitle columnhead # ignore header line

VAR1 = './flysafe_global_traces/global_neighborhood_rx_statistics.txt' # global file name
set print VAR1
print 'node avgMin avgMax avgMean avgStddev' # insert header line in the global file

# Print node statistics to one file invidualy
do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
   if (strlen(file) == 71){ # get the final IP number relying on string length
      VAR2 = file[67:67]
   } else {
      if (strlen(file) == 72){
         VAR2 = file[67:68]
      } else {
         VAR2 = file[67:69]
      }
   }

   stats file using (floor($2*1e2)/1e2) name "A" nooutput        			  # Get avgMin and turn off the output
   stats file using (floor($3*1e2)/1e2) name "B" nooutput         			  # Get avgMax and turn off the output
   stats file using (floor($4*1e2)/1e2) name "C" nooutput         			  # Get avgMean and turn off the output
   stats file using (floor($5*1e2)/1e2) name "D" nooutput         			  # Get avgStddev and turn off the output
   print VAR2,"\t",A_mean,"\t",B_mean,"\t",C_mean,"\t",D_mean
}	# Close the loop

stats VAR1 using (floor($2*1e2)/1e2) name "A" nooutput        			  # Get avgMin and turn off the output
stats VAR1 using (floor($3*1e2)/1e2) name "B" nooutput         			  # Get avgMax and turn off the output
stats VAR1 using (floor($4*1e2)/1e2) name "C" nooutput         			  # Get avgMean and turn off the output
stats VAR1 using (floor($5*1e2)/1e2) name "D" nooutput         			  # Get avgStddev and turn off the output
print "Avg","\t",A_mean,"\t",B_mean,"\t",C_mean,"\t",D_mean