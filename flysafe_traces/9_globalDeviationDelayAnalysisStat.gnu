# -----------------------------------------------------------------------------
# Stats deviation delay errors from all simulations and and put data in a global
# file to all simulations
#
# Jan 25, 2024
#
# Run from inside flysafe traces folder: 
#     (e.g. ns3.34/flysafe_traces# gnuplot globalNeighDiscoveryAnalysisStat.gnu)
#
# Execution Order: 9 (after _globaDeviationDelayErrorData.sh)
# -----------------------------------------------------------------------------

set key autotitle columnhead # ignore header line

VAR1 = './flysafe_global_traces/global_deviation_delay_statistics.txt' # global file name
file = './flysafe_global_traces/global_deviation_delay_rx_statistics.txt' # global file name
set print VAR1
print 'avgMin(ms) avgMax(ms) avgMean(ms) avgStddev(ms)' # insert header line in the global file
stats file using (floor($2*1e2)/1e2) name "A" nooutput        			  # Get avgMin and turn off the output
stats file using (floor($3*1e2)/1e2) name "B" nooutput         			  # Get avgMax and turn off the output
stats file using (floor($4*1e2)/1e2) name "C" nooutput         			  # Get avgMean and turn off the output
stats file using (floor($5*1e2)/1e2) name "D" nooutput         			  # Get avgStddev and turn off the output
print A_mean,"\t",B_mean,"\t",C_mean,"\t",D_mean
