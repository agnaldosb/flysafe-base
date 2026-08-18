#!/bin/bash

# ============================================================================
# Script para executar uma sequência de análises
#
# Este script executa uma lista de scripts .sh e .gnu na ordem
# numérica predefinida. Para scripts divididos em partes (-1 e -2),
# apenas a parte -1 é chamada.
# ============================================================================

# --- 1. Garantir permissões de execução ---
echo "Garantindo permissões de execução para todos os scripts .sh..."
chmod +x *.sh
echo "Permissões atualizadas."
echo ""

MODE_RUN=1
DO_CLEAN=1
case "${1:-}" in
	--clean-only|-c)
		MODE_RUN=0
		DO_CLEAN=1
		;;
	--no-clean)
		MODE_RUN=1
		DO_CLEAN=0
		;;
	"")
		;;
	*)
		echo "Uso: $0 [--clean-only|-c] [--no-clean]" >&2
		exit 2
		;;
esac

clean_outputs() {

# --- 1b. Limpeza de outputs (para permitir re-execução sem duplicar linhas) ---
echo "Limpando outputs antigos de análise (sem apagar traces brutos)..."

# Arquivos globais: muitos scripts antigos usam '>>' e acumulam linhas.
rm -rf flysafe_global_traces
mkdir -p flysafe_global_traces

# Temporários comuns
rm -f _temp*.txt 2>/dev/null || true

# Outputs por simulação (regeneráveis): remove para evitar acumular/duplicar.
for sim_dir in [0-9]*_[0-9]*/ ; do
	[ -d "$sim_dir" ] || continue
	sim_dir="${sim_dir%/}"
	rm -f \
		"$sim_dir"/spatial_awareness_192.168.1.*.txt \
		"$sim_dir"/spatial_no_awareness_192.168.1.*.txt \
		"$sim_dir"/spatial_awareness_rx_analysis_192.168.1.*.txt \
		"$sim_dir"/rounds_rx_achieve_spatial_awareness_analysis_192.168.1.*.txt \
		"$sim_dir"/rounds_tx_achieve_spatial_awareness_analysis_192.168.1.*.txt \
		"$sim_dir"/rounds_achieve_aware_analysis_192.168.1.*.txt \
		"$sim_dir"/rounds_rx_keep_spatial_awareness_analysis_192.168.1.*.txt \
		"$sim_dir"/rounds_tx_keep_spatial_awareness_analysis_192.168.1.*.txt \
		"$sim_dir"/rounds_keep_aware_analysis_192.168.1.*.txt \
		"$sim_dir"/neighborhood_rx_statistics_192.168.1.*.txt \
		"$sim_dir"/localization_error_rx_statistics_192.168.1.*.txt \
		"$sim_dir"/flysafe_MiM_confusion_matrix.txt \
		"$sim_dir"/flysafe_MiM_altered_received_rate_by_node.txt \
		"$sim_dir"/flysafe_MiM_altered_received_rate_stats.txt \
		"$sim_dir"/flysafe_MiM_altered_message_delay_stats_by_node.txt \
		"$sim_dir"/flysafe_MiM_altered_message_delay_192.168.1.*.txt \
		"$sim_dir"/flysafe_MiM_altered_message_delay_plot_max_node_*.png \
		2>/dev/null || true
done

echo "Limpeza concluída."
echo ""
}

if [ "$DO_CLEAN" -eq 1 ]; then
	clean_outputs
fi

if [ "$MODE_RUN" -eq 0 ]; then
	echo "Saindo após limpeza (--clean-only)."
	exit 0
fi

# --- 2. Iniciar a execução da sequência ---
echo "Iniciando a execução da sequência de scripts..."

# --- Execução dos Scripts ---

echo "Executando (1/16): 1_neighRxAnalysisStat.gnu"
gnuplot 1_neighRxAnalysisStat.gnu

echo "Executando (2/16): 2_globalNeighDiscoveryErrorData.sh"
bash 2_globalNeighDiscoveryErrorData.sh

echo "Executando (3/16): 3_globalNeighDiscoveryAnalysisStat.gnu"
gnuplot 3_globalNeighDiscoveryAnalysisStat.gnu

echo "Executando (4/16): 4_localizationErrorAnalysisStat.gnu"
gnuplot 4_localizationErrorAnalysisStat.gnu

echo "Executando (5/16): 5_globalLocalizationErrorData.sh"
bash 5_globalLocalizationErrorData.sh

echo "Executando (6/16): 6_globalLocalizationErrorAnalysisStat.gnu"
gnuplot 6_globalLocalizationErrorAnalysisStat.gnu

echo "Executando (7/16): 7_globalDeviationErrorRxAnalysisStat.gnu"
gnuplot 7_globalDeviationErrorRxAnalysisStat.gnu

echo "Executando (8/16): 8_globaDeviationDelayErrorData.sh"
bash 8_globaDeviationDelayErrorData.sh

echo "Executando (9/16): 9_globalDeviationDelayAnalysisStat.gnu"
gnuplot 9_globalDeviationDelayAnalysisStat.gnu

echo "Executando (10/16): 10_spatialAwarenessNodeAnalysis.sh"
bash 10_spatialAwarenessNodeAnalysis.sh

echo "Executando (11/16): 11_globalSpatialAwarenessRxAnalysisStat.gnu"
gnuplot 11_globalSpatialAwarenessRxAnalysisStat.gnu

echo "Executando (11-2/16): 11_2_globalSpatialAwarenessRxAnalysisStat.gnu"
gnuplot 11_2_globalSpatialAwarenessRxAnalysisStat.gnu

echo "Executando (12/16): 12_globalNoSpatialAwarenessRxAnalysisStat.gnu"
gnuplot 12_globalNoSpatialAwarenessRxAnalysisStat.gnu

echo "Executando (13/16): 13-1_runParallel13.sh"
bash 13-1_runParallel13.sh

echo "Executando (14/16): 14_globalAchieveAwareNodeStat.gnu"
gnuplot 14_globalAchieveAwareNodeStat.gnu

echo "Executando (15/16): 15-1_runParallel15.sh"
bash 15-1_runParallel15.sh

echo "Executando (16/16): 16_globalKeepAwareNodeStat.gnu"
gnuplot 16_globalKeepAwareNodeStat.gnu

echo "---"
echo "Todos os scripts foram executados com sucesso!"
echo "---"
