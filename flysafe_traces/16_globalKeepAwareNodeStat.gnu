# -----------------------------------------------------------------------------
# Stats keep spatial awareness nodes data analysis and put data in a global file
# for each node and creates a global simulation file for each node with the 
# average value for each node in the simulation
#
# Jun 28, 2023
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalKeepAwareNodeStat.gnu)
# -----------------------------------------------------------------------------


do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'rounds_keep_aware_analysis_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory
    
   globalFile = './flysafe_global_traces/global_keep_spatial_awareness_sum_192.168.1.'.i.'.txt'
   set print globalFile
   print 'simulation',"\t",'tDur(s)',"\t",'tTM',"\t",'tTB',"\t",'tTI',"\t",'tTT',"\t",'tRM',"\t",'tRB',"\t",'tRI',"\t",'tRT',"\t",'tM' 

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{             # Loop for each file in 'ListOfFiles'
     # Save data to a simulation global file
     dateTime = file[3:15]
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
     stats file using 12 name "J" nooutput
     print dateTime,"\t",A_sum,"\t",int(B_sum),"\t",int(C_sum),"\t",int(D_sum),"\t",int(E_sum),"\t",int(F_sum),"\t",int(G_sum),"\t",int(H_sum),"\t",int(I_sum),"\t",int(J_sum)

     # Save data to a node global file
     simFile = './'.dateTime.'/spatial_keep_awareness_sum_192.168.1.'.i.'.txt'
     set print simFile append
     #print simFile
     print 'tDur(s)',"\t",'tTM',"\t",'tTB',"\t",'tTI',"\t",'tTT',"\t",'tRM',"\t",'tRB',"\t",'tRI',"\t",'tRT',"\t",'tM' 
     print A_sum,"\t",int(B_sum),"\t",int(C_sum),"\t",int(D_sum),"\t",int(E_sum),"\t",int(F_sum),"\t",int(G_sum),"\t",int(H_sum),"\t",int(I_sum),"\t",int(J_sum)
   }
}

unset print

do for [i=1:40]{ # Controls the loop based on the number of nodes in simulation
   fileName = 'global_keep_spatial_awareness_sum_192.168.1.'.i.'.txt'
   findCommand = sprintf("find . -name *%s", fileName)
   ListOfFiles = system(findCommand) # Get nodes files in simulation directory
    
   globalFile = './flysafe_global_traces/global_keep_spatial_awareness_stats_192.168.1.'.i.'.txt'

   # Print node statistics to one file invidualy
   do for [file in ListOfFiles]{             # Loop for each file in 'ListOfFiles'
     set print globalFile append
     
     ### ADICIONADO ### - Lê a Coluna 2 (tDur(s)) e salva em 'PSI'
     stats file using 2 name "PSI" nooutput
     
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
     
     ### ADICIONADO ### - Imprime as estatísticas da variável 'PSI'
     print "Psi_Duration(s)","\t",int(PSI_max),"\t",int(PSI_min),"\t",(floor(PSI_mean*1e2)/1e2),"\t",(floor(PSI_stddev*1e2)/1e2)
     
     print "Sent msgs","\t",int(A_max),"\t",int(A_min),"\t",(floor(A_mean*1e2)/1e2),"\t",(floor(A_stddev*1e2)/1e2)
     print "Sent broad","\t",int(B_max),"\t",int(B_min),"\t",(floor(B_mean*1e2)/1e2),"\t",(floor(B_stddev*1e2)/1e2)
     print "Sent Ident","\t",int(C_max),"\t",int(C_min),"\t",(floor(C_mean*1e2)/1e2),"\t",(floor(C_stddev*1e2)/1e2)
     print "Sent Trap","\t",int(D_max),"\t",int(D_min),"\t",(floor(D_mean*1e2)/1e2),"\t",(floor(D_stddev*1e2)/1e2)
     print "Recv msgs","\t",int(E_max),"\t",int(E_min),"\t",(floor(E_mean*1e2)/1e2),"\t",(floor(E_stddev*1e2)/1e2)
     print "Recv broad","\t",int(F_max),"\t",int(F_min),"\t",(floor(F_mean*1e2)/1e2),"\t",(floor(F_stddev*1e2)/1e2)
     print "Recv Ident","\t",int(G_max),"\t",int(G_min),"\t",(floor(G_mean*1e2)/1e2),"\t",(floor(G_stddev*1e2)/1e2)
     print "Recv Trap","\t",int(H_max),"\t",int(H_min),"\t",(floor(H_mean*1e2)/1e2),"\t",(floor(H_stddev*1e2)/1e2)
     print "Total msgs","\t",int(I_max),"\t",int(I_min),"\t",(floor(I_mean*1e2)/1e2),"\t",(floor(I_stddev*1e2)/1e2)
   }
}