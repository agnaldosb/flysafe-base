#!/bin/bash

# -----------------------------------------------------------------------------
# Perform spatial awareness individual nodes rx analysis of each simulation and
# put in an individual file to each node.
#
# Optimized version of 10_spatialAwarenessNodeAnalysis.sh:
# - Single-pass awk (no per-line sed/wc/bc loops)
#
# -----------------------------------------------------------------------------

set -euo pipefail

TARGET_DIR="${1:-.}"
if [ ! -d "$TARGET_DIR" ]; then
	echo "Erro: Diretório alvo inexistente: $TARGET_DIR" >&2
	exit 1
fi

IPFile="neighborhood_rx_analysis_gnuplot_192.168.1.*.txt"
OUT_SUFFIX=""

find "$TARGET_DIR" -type f -name "$IPFile" -print0 | while IFS= read -r -d '' line; do
	echo "$line"

	dateTime=$(basename "$(dirname "$line")")
	bn=$(basename "$line")
	nodeNumber=${bn#neighborhood_rx_analysis_gnuplot_192.168.1.}
	nodeNumber=${nodeNumber%.txt}

	awareFile="./${dateTime}/spatial_awareness_192.168.1.${nodeNumber}${OUT_SUFFIX}.txt"
	noAwareFile="./${dateTime}/spatial_no_awareness_192.168.1.${nodeNumber}${OUT_SUFFIX}.txt"
	nodeFile="./${dateTime}/spatial_awareness_rx_analysis_192.168.1.${nodeNumber}${OUT_SUFFIX}.txt"

	printf "startTime\tendTime\tduration\tawareness\n" > "$awareFile"
	printf "startTime\tendTime\tduration\tawareness\n" > "$noAwareFile"
	printf "startTime\tendTime\tduration\tawareness\n" > "$nodeFile"

	awk -v OFS='\t' \
		-v awareFile="$awareFile" \
		-v noAwareFile="$noAwareFile" \
		-v nodeFile="$nodeFile" \
		'
		function invert(x) { return (x+0==0) ? 1 : 0 }
		function decs(s,  m) { m=match(s, /\.[0-9]+/); return m ? RLENGTH-1 : 0 }
		function max(a,b) { return (a>b) ? a : b }
		function is_zero_str(s) { return (s ~ /^-?0+(\.0+)?$/) }
		function print_seg(sStr, eStr, aware,  sNum, eNum, dur, scale, durStr) {
			sNum = sStr + 0
			eNum = eStr + 0
			dur = eNum - sNum
			scale = max(decs(sStr), decs(eStr))
			durStr = sprintf("%.*f", scale, dur)
			# bc formatting:
			# - prints 0 as '0' (even if scale>0)
			# - for |x|<1 and x!=0 prints without leading 0 (e.g. '.8', '.0049')
			if (is_zero_str(durStr)) {
				durStr = "0"
			} else if (scale > 0 && durStr ~ /^0\./) {
				sub(/^0\./, ".", durStr)
			} else if (scale > 0 && durStr ~ /^-0\./) {
				sub(/^-0\./, "-.", durStr)
			}
			print sStr, eStr, durStr, aware >> nodeFile
			if (aware == 0) print sStr, eStr, durStr, aware >> noAwareFile
			else print sStr, eStr, durStr, aware >> awareFile
		}
		NR==1 { next }
		NR==2 {
			startStr = "0"
			aware = invert($5)
			endStr = $1
			lastStr = $1
			haveInit = 1
			next
		}
		{
			lStr = $1
			lAware = invert($5)
			lastStr = lStr
			if (lAware == aware) {
				endStr = lStr
			} else {
				endStr = lStr
				print_seg(startStr, endStr, aware)
				startStr = endStr
				aware = lAware
			}
		}
		END {
			if (!haveInit) exit
			endStr = lastStr
			print_seg(startStr, endStr, aware)
		}
		' "$line"

done
