#!/bin/bash

# Este é o script "worker" (15-3). Ele processa 1 pasta por execução.
# Otimização: substitui loops com wc/sed/bc por uma varredura linear com awk,
# mantendo o mesmo resultado do 15-2 e sobrescrevendo os mesmos arquivos.

TARGET_DIR=$1
if [ -z "$TARGET_DIR" ]; then
	echo "Erro: O nome do diretório alvo não foi fornecido."
	exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
	echo "Erro: Diretório alvo inexistente: $TARGET_DIR"
	exit 1
fi

IPFile="spatial_awareness_192.168.1.*"
OUT_SUFFIX=""

analyze_rounds_file_keep() {
	local roundsFile="$1"  # spatial_awareness_...
	local msgFile="$2"     # messages_received/sent_...
	local outFile="$3"     # rounds_rx/tx_keep_..._NEW.txt

	printf "sTime\teTime\tdur\tnMsg\tnBroad\tnId\tnTrap\n" > "$outFile"

	# Mantém a lógica do 15-2:
	# - Inclui se timeStr == startTimeStr
	# - Inclui se timeNum > startTimeNum e timeNum < endTimeNum
	# - Inclui se timeStr == endTimeStr e então para (break)
	# - Para quando timeNum > endTimeNum
	awk -v OFS='\t' '
		ARGIND==1 {
			if (FNR==1) next
			++n
			tStr[n]=$1
			tNum[n]=$1 + 0
			tag[n]=$3
			next
		}
		ARGIND==2 {
			if (FNR==1) next
			sStr=$1; eStr=$2; dur=$3
			sNum=sStr + 0; eNum=eStr + 0

			while (idx < n && tNum[idx+1] < sNum) idx++
			j=idx+1
			nMsg=0; nBroad=0; nId=0; nTrap=0
			for (; j<=n; j++) {
				ts=tStr[j]
				tn=tNum[j]

				if (ts == sStr) {
					nMsg++
					if (tag[j] == 0) nBroad++
					else if (tag[j] == 1) nId++
					else nTrap++
					continue
				}

				if (tn > sNum) {
					if (tn < eNum) {
						nMsg++
						if (tag[j] == 0) nBroad++
						else if (tag[j] == 1) nId++
						else nTrap++
						continue
					}

					if (ts == eStr) {
						nMsg++
						if (tag[j] == 0) nBroad++
						else if (tag[j] == 1) nId++
						else nTrap++
						break
					}

					if (tn > eNum) {
						break
					}
				}
			}
			idx=j-1
			if (nMsg > 0) print sStr, eStr, dur, nMsg, nBroad, nId, nTrap
		}
	' "$msgFile" "$roundsFile" >> "$outFile"
}

build_global_file_keep() {
	local roundsFile="$1" # spatial_awareness_...
	local rxFile="$2"     # rounds_rx_keep..._NEW
	local txFile="$3"     # rounds_tx_keep..._NEW
	local outFile="$4"    # rounds_keep_aware..._NEW

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

while IFS= read -r awarenessFile; do
	bn=$(basename "$awarenessFile")
	nodeNumber=${bn#spatial_awareness_192.168.1.}
	nodeNumber=${nodeNumber%.txt}

	baseDir=$(dirname "$awarenessFile")
	rxFile="$baseDir/messages_received_192.168.1.${nodeNumber}.txt"
	txFile="$baseDir/messages_sent_192.168.1.${nodeNumber}.txt"

	rxAwareFile="$baseDir/rounds_rx_keep_spatial_awareness_analysis_192.168.1.${nodeNumber}${OUT_SUFFIX}.txt"
	txAwareFile="$baseDir/rounds_tx_keep_spatial_awareness_analysis_192.168.1.${nodeNumber}${OUT_SUFFIX}.txt"
	awareGlobal="$baseDir/rounds_keep_aware_analysis_192.168.1.${nodeNumber}${OUT_SUFFIX}.txt"

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

	analyze_rounds_file_keep "$awarenessFile" "$rxFile" "$rxAwareFile"
	analyze_rounds_file_keep "$awarenessFile" "$txFile" "$txAwareFile"
	build_global_file_keep "$awarenessFile" "$rxAwareFile" "$txAwareFile" "$awareGlobal"

done < <(find "$TARGET_DIR" -maxdepth 1 -type f -name "$IPFile")
