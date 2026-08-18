# -----------------------------------------------------------------------------
# Stats spatial awareness duration from individual nodes rx analysis and
# put data in a global file for each node and creates a global file with simu-
# ation results and creates a global file with the average value for each node
# in the simualtion
#
# Jun 18, 2023
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalSpatialAwarenessRxAnalysisStat.gnu)
#
# Execution order: 11
# -----------------------------------------------------------------------------


do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'spatial_awareness_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory
   
   globalFile = './flysafe_global_traces/global_spatial_awareness_statistics_192.168.1.'.i.'.txt'
   set print globalFile
   print 'simulation min(s) max(s) mean(s) stddev(s)' 

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
      # Save data to a simulation global file
      dateTime = file[3:15]
      set print globalFile append
      stats file using 3 nooutput
      print dateTime,"\t",(floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2)
      
      # Save data to a node global file
      simFile = './'.dateTime.'/spatial_awareness_statistics_192.168.1.'.i.'.txt'
      set print simFile append
      print 'min(s) max(s) mean(s) stddev(s)'
      print (floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2)
   #    VAR2 = file[3:15]
   #    VAR3 = './'.VAR2.'/deviation_delay_rx_statistics_192.168.1.'.VAR1.'.txt'
     
      #print 'min(s) max(s) mean(s) stddev(s)' 
      #print (floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2)
      #set print VAR3
      #print 'simulation min(ms) max(ms) mean(ms) stddev(ms)'       			  # Get statistics and turn off the output
      #stats file using 3 nooutput
      #print VAR2,"\t",(floor(STATS_min*1e2)/1e2),"\t",(floor(STATS_max*1e2)/1e2),"\t",(floor(STATS_mean*1e2)/1e2),"\t",(floor(STATS_stddev*1e2)/1e2)
   }

}								  # Close the loop

unset print 

# Stats nodes global data to a global simulation file 
set key autotitle columnhead # ignore header line
# set global file   
globalFile = './flysafe_global_traces/global_spatial_awareness_statistics.txt'
set print globalFile append
print 'node minAvg(s) maxAvg(s) meanAvg(s) stddevAvg(s)' 

do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'global_spatial_awareness_statistics_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
        stats file using 2 name "A" nooutput        			  # Get avgMin and turn off the output
        stats file using 3 name "B" nooutput         			  # Get avgMax and turn off the output
        stats file using 4 name "C" nooutput         			  # Get avgMean and turn off the output
        stats file using 5 name "D" nooutput         			  # Get avgStddev and turn off the output
        print i,"\t",(floor(A_mean*1e2)/1e2),"\t",(floor(B_mean*1e2)/1e2),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)
   }

}		

unset print 
