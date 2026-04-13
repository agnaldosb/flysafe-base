# Change this value to set the number of sequential simulations.
TOTAL_RUNS=1
# Modify the parameters inside the quotes to configure the simulation (e.g., nNodes, nMalicious).
SIM_COMMAND="./ns3 run \"scratch/flysafe -nNodes=40 -runMode=R -nMalicious=0\" > result.txt"

TRACES_DIR="flysafe_traces"
MIN_START_INTERVAL=60

cd "$(dirname "$0")"

echo "Starting execution of $TOTAL_RUNS simulations..."
echo "----------------------------------------------------"

for i in $(seq 1 $TOTAL_RUNS)
do
    SIM_START_EPOCH=$(date +%s)
    echo ">> [$(date +%T)] Starting simulation $i of $TOTAL_RUNS..."

    eval $SIM_COMMAND
    SIM_STATUS=$?
    SIM_END_EPOCH=$(date +%s)
    SIM_DURATION=$((SIM_END_EPOCH - SIM_START_EPOCH))

    if [ "$SIM_DURATION" -lt 0 ]; then
        SIM_DURATION=0
    fi

    echo "   Simulation $i completed in ${SIM_DURATION}s. Moving result files..."

    if [ "$SIM_STATUS" -ne 0 ]; then
        echo "   !! WARNING: Simulation $i exited with code $SIM_STATUS."
    fi

    LATEST_DIR=$(ls -td "$TRACES_DIR"/*/ | head -n 1)

    if [ -d "$LATEST_DIR" ]; then
        mv result.txt "$LATEST_DIR"
        mv flysafe.xml "$LATEST_DIR"
        mv *.pcap "$LATEST_DIR"
        echo "   Files successfully moved to: $LATEST_DIR"
    else
        echo "   !! WARNING: No destination directory found in '$TRACES_DIR'. Files were not moved."
    fi

    if [ "$i" -lt "$TOTAL_RUNS" ]; then
        if [ "$SIM_DURATION" -lt "$MIN_START_INTERVAL" ]; then
            WAIT_SECONDS=$((MIN_START_INTERVAL - SIM_DURATION))
            echo "   Waiting ${WAIT_SECONDS}s to ensure at least ${MIN_START_INTERVAL}s between simulation starts..."
            sleep "$WAIT_SECONDS"
        else
            echo "   Minimum start interval already satisfied (${SIM_DURATION}s >= ${MIN_START_INTERVAL}s)."
        fi
    fi

    echo "----------------------------------------------------"
done

echo ">> All $TOTAL_RUNS simulations have been completed."
