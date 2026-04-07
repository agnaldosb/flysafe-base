# Change this value to set the number of sequential simulations.
TOTAL_RUNS=1
# Modify the parameters inside the quotes to configure the simulation (e.g., nNodes, nMalicious).
SIM_COMMAND="./ns3 run \"scratch/flysafe -nNodes=40 -runMode=R -nMalicious=0\" > result.txt"

TRACES_DIR="flysafe_traces"

cd "$(dirname "$0")"

echo "Starting execution of $TOTAL_RUNS simulations..."
echo "----------------------------------------------------"

for i in $(seq 1 $TOTAL_RUNS)
do
    echo ">> [$(date +%T)] Starting simulation $i of $TOTAL_RUNS..."

    eval $SIM_COMMAND

    echo "   Simulation $i completed. Moving result files..."

    LATEST_DIR=$(ls -td "$TRACES_DIR"/*/ | head -n 1)

    if [ -d "$LATEST_DIR" ]; then
        mv result.txt "$LATEST_DIR"
        mv flysafe.xml "$LATEST_DIR"
        mv *.pcap "$LATEST_DIR"
        echo "   Files successfully moved to: $LATEST_DIR"
    else
        echo "   !! WARNING: No destination directory found in '$TRACES_DIR'. Files were not moved."
    fi

    echo "----------------------------------------------------"
done

echo ">> All $TOTAL_RUNS simulations have been completed."
