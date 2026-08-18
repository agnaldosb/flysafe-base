# -----------------------------------------------------------------------------
# Sums spatial awareness duration from individual nodes in each simulation and
# put data in a global file for each node. Then, it creates a global file with
# total spatial awareness for all nodes
#
# Dec 01, 2025
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalTotalSpatialAwarenessStat.gnu)
#
# Execution order: 11_2
# -----------------------------------------------------------------------------

globalFile2 = './flysafe_global_traces/global_total_spatial_awareness.txt'

set print globalFile2
print 'node minAvg(s) maxAvg(s) meanAvg(s) stddevAvg(s)'

do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'spatial_awareness_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory
   
   globalFile = './flysafe_global_traces/total_spatial_awareness_192.168.1.'.i.'.txt'

   set print globalFile
   print 'simulation duration(s)' 

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
      # Save data to a simulation global file
      dateTime = file[3:15]
      set print globalFile append
      stats file using 3 nooutput
      print dateTime,"\t",(floor(STATS_sum*1e2)/1e2)
   }
   unset print

   # Print simulation statistics from each node in a global file
   set print globalFile2 append
   stats globalFile using 2 nooutput
   print i,"\t",(floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2) 
   unset print
   print i,"\t",dateTime,"\t",globalFile
}# Close the loop

unset print 	
set print globalFile2 append

# Stats average values on global file
stats globalFile2 using (floor($2*1e1)/1e1) name "A" nooutput        			  # Get avgMin and turn off the output
stats globalFile2 using (floor($3*1e1)/1e1) name "B" nooutput         			  # Get avgMax and turn off the output
stats globalFile2 using (floor($4*1e1)/1e1) name "C" nooutput         			  # Get avgMean and turn off the output
stats globalFile2 using (floor($5*1e1)/1e1) name "D" nooutput         			  # Get avgStddev and turn off the output
print "Avg","\t",A_mean,"\t",B_mean,"\t",C_mean,"\t",D_mean

unset print 
