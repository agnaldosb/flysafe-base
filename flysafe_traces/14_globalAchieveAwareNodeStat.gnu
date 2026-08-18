# -----------------------------------------------------------------------------
# Stats achieve spatial awareness nodes data analysis and put data in a global
# file for each node and creates a global simulation file for each node with the 
# average value for each node in the simulation
#
# Jul 03, 2023
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalAchieveAwareNodeStat.gnu)
# -----------------------------------------------------------------------------


do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'rounds_achieve_aware_analysis_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory
   
   globalFile = './flysafe_global_traces/global_achieve_spatial_awareness_sum_192.168.1.'.i.'.txt'
   set print globalFile
   print 'simulation',"\t",'tDur(s)',"\t",'tTM',"\t",'tTB',"\t",'tTI',"\t",'tTT',"\t",'tRM',"\t",'tRB',"\t",'tRI',"\t",'tRT',"\t",'tM' 

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
      # Save data to a simulation global file
      dateTime = file[3:15]
      set print globalFile append
      # Alguns nós podem não ter dados (arquivo só com header). Nesse caso, o stats
      # não define A_sum e o script quebra. Aqui tratamos como soma=0.
      A_sum=0; B_sum=0; C_sum=0; D_sum=0; E_sum=0; F_sum=0; G_sum=0; H_sum=0; I_sum=0; J_sum=0

      nLines = int(system(sprintf("awk 'END{print NR}' \"%s\"", file)))
      if (nLines <= 1) {
         print dateTime,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0
      } else {
         stats file using 3 name "A" nooutput
         stats file using 4 name "B" nooutput
         stats file using 5 name "C" nooutput
         stats file using 6 name "D" nooutput
         stats file using 7 name "E" nooutput
         stats file using 8 name "F" nooutput
         stats file using 9 name "G" nooutput
         stats file using 10 name "H" nooutput
         stats file using 11 name "I" nooutput
         stats file using 12 name "J" nooutput
         print dateTime,"\t",A_sum,"\t",int(B_sum),"\t",int(C_sum),"\t",int(D_sum),"\t",int(E_sum),"\t",int(F_sum),"\t",int(G_sum),"\t",int(H_sum),"\t",int(I_sum),"\t",int(J_sum)
      }

      # Save data to a node global file
      simFile = './'.dateTime.'/spatial_achieve_awareness_sum_192.168.1.'.i.'.txt'
      set print simFile append
      #print simFile
      print 'tDur(s)',"\t",'tTM',"\t",'tTB',"\t",'tTI',"\t",'tTT',"\t",'tRM',"\t",'tRB',"\t",'tRI',"\t",'tRT',"\t",'tM' 
      print A_sum,"\t",int(B_sum),"\t",int(C_sum),"\t",int(D_sum),"\t",int(E_sum),"\t",int(F_sum),"\t",int(G_sum),"\t",int(H_sum),"\t",int(I_sum),"\t",int(J_sum)
   }
}

# unset print

do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'global_achieve_spatial_awareness_sum_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory
   
   globalFile = './flysafe_global_traces/global_achieve_spatial_awareness_stats_192.168.1.'.i.'.txt'

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{    				  # Loop for each file in 'ListOfFiles'
      set print globalFile append
      stats file using 3 name "A" nooutput
      stats file using 4 name "B" nooutput
      stats file using 5 name "C" nooutput
      stats file using 6 name "D" nooutput
      stats file using 7 name "E" nooutput
      stats file using 8 name "F" nooutput
      stats file using 9 name "G" nooutput
      stats file using 10 name "H" nooutput
      stats file using 11 name "I" nooutput

      print "Description","\t","max","\t","min","\t","mean","\t","stdDev"
      print "Sent msgs","\t",int(A_max),"\t",int(A_min),"\t",(floor(A_mean*1e2)/1e2),"\t",(floor(A_stddev*1e2)/1e2)
      print "Sent broad","\t",int(B_max),"\t",int(B_min),"\t",(floor(B_mean*1e2)/1e2),"\t",(floor(B_stddev*1e2)/1e2)
      print "Sent Ident","\t",int(C_max),"\t",int(C_min),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(C_stddev*1e2)/1e2)
      print "Sent Trap","\t",int(D_max),"\t",int(D_min),"\t",(floor(D_mean*1e2)/1e2),"\t",(floor(D_stddev*1e2)/1e2)
      print "Recv msgs","\t",int(E_max),"\t",int(E_min),"\t",(floor(E_mean*1e2)/1e2),"\t",(floor(E_stddev*1e2)/1e2)
      print "Recv broad","\t",int(F_max),"\t",int(F_min),"\t",(floor(F_mean*1e2)/1e2),"\t",(floor(F_stddev*1e2)/1e2)
      print "Recv Ident","\t",int(G_max),"\t",int(G_min),"\t",(floor(G_mean*1e2)/1e2),"\t",(floor(G_stddev*1e2)/1e2)
      print "Recv Trap","\t",int(H_max),"\t",int(H_min),"\t",(floor(H_mean*1e2)/1e2),"\t",(floor(H_stddev*1e2)/1e2)
      print "Total msgs","\t",int(I_max),"\t",int(I_min),"\t",(floor(I_mean*1e2)/1e2),"\t",(floor(I_stddev*1e2)/1e2)

      # Create temporary files to support a final global stats from all data
      tempSentMsg="./_tempSentMsg.txt"
      set print tempSentMsg append
      print int(A_max),"\t",int(A_min),"\t",(floor(A_mean*1e2)/1e2),"\t",(floor(A_stddev*1e2)/1e2)

      tempSentBroad="./_tempSentBroad.txt"
      set print tempSentBroad append
      print int(B_max),"\t",int(B_min),"\t",(floor(B_mean*1e2)/1e2),"\t",(floor(B_stddev*1e2)/1e2)

      tempSentIdent="./_tempSentIdent.txt"
      set print tempSentIdent append
      print int(C_max),"\t",int(C_min),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(C_stddev*1e2)/1e2)

      tempSentTrap="./_tempSentTrap.txt"
      set print tempSentTrap append
      print int(D_max),"\t",int(D_min),"\t",(floor(D_mean*1e2)/1e2),"\t",(floor(D_stddev*1e2)/1e2)

      tempRecvMsg="./_tempRecvMsg.txt"
      set print tempRecvMsg append
      print int(E_max),"\t",int(E_min),"\t",(floor(E_mean*1e2)/1e2),"\t",(floor(E_stddev*1e2)/1e2)

      tempRecvBroad="./_tempRecvBroad.txt"
      set print tempRecvBroad append
      print int(F_max),"\t",int(F_min),"\t",(floor(F_mean*1e2)/1e2),"\t",(floor(F_stddev*1e2)/1e2)

      tempRecvIdent="./_tempRecvIdent.txt"
      set print tempRecvIdent append
      print int(G_max),"\t",int(G_min),"\t",(floor(G_mean*1e2)/1e2),"\t",(floor(G_stddev*1e2)/1e2)

      tempRecvTrap="./_tempRecvTrap.txt"
      set print tempRecvTrap append
      print int(H_max),"\t",int(H_min),"\t",(floor(H_mean*1e2)/1e2),"\t",(floor(H_stddev*1e2)/1e2)

      tempTotalMsg="./_tempTotalMsg.txt"
      set print tempTotalMsg append
      print int(I_max),"\t",int(I_min),"\t",(floor(I_mean*1e2)/1e2),"\t",(floor(I_stddev*1e2)/1e2)
   }
}

unset print

# Create global stats file from messages to achieve spatial awareness
globalStatsFile = './flysafe_global_traces/global_achieve_spatial_awareness_stats.txt'
set print globalStatsFile append
print "Description","\t","avgMax","\t","avgMin","\t","avgMean","\t","avgStdDev"
stats tempSentMsg using 1 name "A" nooutput
stats tempSentMsg using 2 name "B" nooutput
stats tempSentMsg using 3 name "C" nooutput
stats tempSentMsg using 4 name "D" nooutput
print "Sent msgs","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempSentBroad using 1 name "A" nooutput
stats tempSentBroad using 2 name "B" nooutput
stats tempSentBroad using 3 name "C" nooutput
stats tempSentBroad using 4 name "D" nooutput
print "Sent broad","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempSentIdent using 1 name "A" nooutput
stats tempSentIdent using 2 name "B" nooutput
stats tempSentIdent using 3 name "C" nooutput
stats tempSentIdent using 4 name "D" nooutput
print "Sent ident","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempSentTrap using 1 name "A" nooutput
stats tempSentTrap using 2 name "B" nooutput
stats tempSentTrap using 3 name "C" nooutput
stats tempSentTrap using 4 name "D" nooutput
print "Sent trap","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempRecvMsg using 1 name "A" nooutput
stats tempRecvMsg using 2 name "B" nooutput
stats tempRecvMsg using 3 name "C" nooutput
stats tempRecvMsg using 4 name "D" nooutput
print "Recv msgs","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempRecvBroad using 1 name "A" nooutput
stats tempRecvBroad using 2 name "B" nooutput
stats tempRecvBroad using 3 name "C" nooutput
stats tempRecvBroad using 4 name "D" nooutput
print "Recv broad","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempRecvIdent using 1 name "A" nooutput
stats tempRecvIdent using 2 name "B" nooutput
stats tempRecvIdent using 3 name "C" nooutput
stats tempRecvIdent using 4 name "D" nooutput
print "Recv ident","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempRecvTrap using 1 name "A" nooutput
stats tempRecvTrap using 2 name "B" nooutput
stats tempRecvTrap using 3 name "C" nooutput
stats tempRecvTrap using 4 name "D" nooutput
print "Recv trap","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

stats tempTotalMsg using 1 name "A" nooutput
stats tempTotalMsg using 2 name "B" nooutput
stats tempTotalMsg using 3 name "C" nooutput
stats tempTotalMsg using 4 name "D" nooutput
print "Total msgs","\t",int(A_mean),"\t",int(B_mean),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(D_mean*1e2)/1e2)

system("rm _temp*.txt")