#!/bin/bash

# Este é o script "worker" (13-2). Ele processa 1 pasta por execução.
# Otimização: substitui loops com wc/sed/bc por uma varredura linear com awk,
# mantendo o mesmo resultado dos arquivos gerados.

TARGET_DIR=$1
if [ -z "$TARGET_DIR" ]; then
	echo "Erro: O nome do diretório alvo não foi fornecido."
	exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
	echo "Erro: Diretório alvo inexistente: $TARGET_DIR"
	exit 1
fi

#: <<'COMMENT0'
IPFile="spatial_no_awareness_192.168.1.*"

analyze_rounds_file() {
	local roundsFile="$1"
	local msgFile="$2"
	local outFile="$3"

	printf "sTime\teTime\tdur\tnMsg\tnBroad\tnId\tnTrap\n" > "$outFile"

	# O(n+m): carrega mensagens em memória uma vez; varre janelas em ordem crescente usando ponteiro.
	awk -v OFS='\t' '
		ARGIND==1 {
			if (FNR==1) next
			++n
			t[n]=$1
			tag[n]=$3
			next
		}
		ARGIND==2 {
			if (FNR==1) next
			s=$1; e=$2; dur=$3
			while (idx < n && (t[idx+1] + 0) < (s + 0)) idx++
			j=idx+1
			nMsg=0; nBroad=0; nId=0; nTrap=0
			while (j <= n && (t[j] + 0) <= (e + 0)) {
				nMsg++
				if (tag[j] == 0) nBroad++
				else if (tag[j] == 1) nId++
				else nTrap++
				j++
			}
			idx=j-1
			if (nMsg > 0) print s, e, dur, nMsg, nBroad, nId, nTrap
		}
	' "$msgFile" "$roundsFile" >> "$outFile"
}

build_global_file() {
	local roundsFile="$1"
	local rxFile="$2"
	local txFile="$3"
	local outFile="$4"

	printf "sTime\teTime\tdur\tnTM\tnTB\tnTI\tnTT\tnRM\tnRB\tnRI\tnRT\tnTM\n" > "$outFile"

	awk -v OFS='\t' '
		ARGIND==1 {
			if (FNR==1) next
			key=$1
			rxMsg[key]=$4; rxBroad[key]=$5; rxId[key]=$6; rxTrap[key]=$7
			next
		}
		ARGIND==2 {
			if (FNR==1) next
			key=$1
			txMsg[key]=$4; txBroad[key]=$5; txId[key]=$6; txTrap[key]=$7
			next
		}
		ARGIND==3 {
			if (FNR==1) next
			key=$1
			tr=(key in txMsg) ? txMsg[key] : 0
			tb=(key in txBroad) ? txBroad[key] : 0
			ti=(key in txId) ? txId[key] : 0
			tt=(key in txTrap) ? txTrap[key] : 0
			rm=(key in rxMsg) ? rxMsg[key] : 0
			rb=(key in rxBroad) ? rxBroad[key] : 0
			ri=(key in rxId) ? rxId[key] : 0
			rt=(key in rxTrap) ? rxTrap[key] : 0
			total=(tr + 0) + (rm + 0)
			print $1, $2, $3, tr, tb, ti, tt, rm, rb, ri, rt, total
		}
	' "$rxFile" "$txFile" "$roundsFile" >> "$outFile"
}

while IFS= read -r line; do
	bn=$(basename "$line")
	nodeNumber=${bn#spatial_no_awareness_192.168.1.}
	nodeNumber=${nodeNumber%.txt}

	baseDir=$(dirname "$line")
	rxFile="$baseDir/messages_received_192.168.1.${nodeNumber}.txt"
	txFile="$baseDir/messages_sent_192.168.1.${nodeNumber}.txt"

	rxAwareFile="$baseDir/rounds_rx_achieve_spatial_awareness_analysis_192.168.1.${nodeNumber}.txt"
	txAwareFile="$baseDir/rounds_tx_achieve_spatial_awareness_analysis_192.168.1.${nodeNumber}.txt"
	awareGlobal="$baseDir/rounds_achieve_aware_analysis_192.168.1.${nodeNumber}.txt"

	# Se faltarem arquivos de mensagens, trata como "0 mensagens" (arquivo vazio)
	# para evitar awk fatal e manter saídas consistentes.
	if [ ! -f "$rxFile" ]; then
		echo "WARN: faltando $rxFile (assumindo 0 mensagens recebidas)" >&2
		rxFile=/dev/null
	fi
	if [ ! -f "$txFile" ]; then
		echo "WARN: faltando $txFile (assumindo 0 mensagens enviadas)" >&2
		txFile=/dev/null
	fi

	# Gera RX/TX (mesmo formato do script 13 original)
	analyze_rounds_file "$line" "$rxFile" "$rxAwareFile"
	analyze_rounds_file "$line" "$txFile" "$txAwareFile"

	# Resume em um único arquivo (mesmo formato do script 13 original)
	build_global_file "$line" "$rxAwareFile" "$txAwareFile" "$awareGlobal"
done < <(find "$TARGET_DIR" -type f -name "$IPFile")
#COMMENT0

