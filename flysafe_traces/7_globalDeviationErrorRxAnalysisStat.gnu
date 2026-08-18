# -----------------------------------------------------------------------------
# Stats deviation delay errors from individual nodes analysis and
# put data in a global file for each node and creates a global file to simulation
#
# Jan 25, 2024
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalDeviationErrorRxAnalysisStat.gnu)
#
# Execution Order: 7
# -----------------------------------------------------------------------------

ListOfFiles = system('find . -name *deviation_delay_rx_analysis_192.168.1.*') # Get all files in current directory

# Print node statistics to one file invidualy
do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
   if (strlen(file) == 59){
      VAR1 = file[55:55]
   } else {
      if (strlen(file) == 60){
         VAR1 = file[55:56]
      } else {
         VAR1 = file[55:57]
      }
   }
   VAR2 = file[3:15]
   VAR3 = './'.VAR2.'/deviation_delay_rx_statistics_192.168.1.'.VAR1.'.txt'
   set print VAR3
   print 'simulation min(ms) max(ms) mean(ms) stddev(ms)'       			  # Get statistics and turn off the output
   stats file using 3 nooutput
   print VAR2,"\t",(floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2)
}								  # Close the loop

unset print 

# Operates over the global file created directly from NS3 simulation
ListOfFiles = system('find . -name *deviation_delay_rx_analysis_global*') # Get all files in current directory

# Print all node statistics to one file invidualy
do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
   VAR2 = file[3:15]
   VAR3 = './'.VAR2.'/deviation_delay_rx_statistics_global.txt'
   set print VAR3
   print 'simulation min(ms) max(ms) mean(ms) stddev(ms)' 
   stats file using (floor($5*1e2)/1e2) nooutput
   print VAR2,"\t",(floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2)
} 
   							  # Close the loop    
unset print 
