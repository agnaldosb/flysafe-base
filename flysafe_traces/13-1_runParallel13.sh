#!/bin/bash

echo "Iniciando a execução paralela da etapa 13..."

# Detecta o número de núcleos de CPU
N_CORES=$(nproc)
echo "Utilizando até $N_CORES núcleos de CPU em paralelo."

# O nome do novo script "worker"
WORKER_SCRIPT="13-2_parallelRoundsAchieveAwarenessNodeAnalysis.sh"

# Encontra as subpastas de simulação (ex.: 30012026_1847) e as envia para o xargs
# Evita pegar pastas auxiliares como flysafe_global_traces
find . -maxdepth 1 -type d -name '[0-9]*_[0-9]*' | xargs -P $N_CORES -I {} bash -c "
    echo '==> Iniciando processamento da pasta: {}'
    ./$WORKER_SCRIPT {}
    echo '<== Finalizado processamento da pasta: {}'
"

echo "Processamento paralelo concluído!"