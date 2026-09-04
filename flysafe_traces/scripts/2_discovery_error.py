#!/usr/bin/env python3
"""Neighbor discovery error (Gamma): neighbors in range the UAV failed to know.

Author: Vinicius Trindade
Date:   Sep 03, 2026

Gamma^t_j = W^t_j - W^t_S, the gap between the neighborhood a UAV perceives and the one
that should be within its coverage area. It is column 5 of
neighborhood_rx_analysis_gnuplot_*, and equals nPsbNeigh - nNeighCIdent.

    ./2_discovery_error.py [bl|ba|ai|all]

Writes, per scenario:
    <sim>/discovery_error_statistics_192.168.1.<n>.txt          per node, per simulation
    <global>/global_discovery_error_statistics_192.168.1.<n>.txt   per node, all simulations
    <global>/global_discovery_error_statistics.txt              per node average + overall
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c


def run(scenario):
    print(f'  {os.path.basename(scenario)}: erro de descoberta de vizinhos (Gamma)')
    per_node = {}

    for sim in c.sim_dirs(scenario):
        name = c.sim_name(sim)
        for node in c.node_ids(sim):
            ip = f'192.168.1.{node}'
            rows = c.read_table(os.path.join(sim, f'neighborhood_rx_analysis_gnuplot_{ip}.txt'))
            values = [float(r[4]) for r in rows if len(r) > 4]
            stats = c.describe(values, 2)
            if stats is None:
                continue
            c.write_table(os.path.join(sim, f'discovery_error_statistics_{ip}.txt'),
                          ['min', 'max', 'mean', 'stddev'], [stats])
            per_node.setdefault(node, []).append((name,) + stats)

    gdir = c.global_dir(scenario)
    summary = []
    for node in sorted(per_node):
        entries = per_node[node]
        c.write_table(os.path.join(gdir, f'global_discovery_error_statistics_192.168.1.{node}.txt'),
                      ['dateTime', 'min', 'max', 'mean', 'stddev'], entries)
        cols = [[e[i] for e in entries] for i in range(1, 5)]
        avg = [c.mean_sd(col)[0] for col in cols]
        summary.append([node] + avg)

    if summary:
        overall = [c.mean_sd([s[i] for s in summary])[0] for i in range(1, 5)]
        summary.append(['Avg'] + overall)
        c.write_table(os.path.join(gdir, 'global_discovery_error_statistics.txt'),
                      ['node', 'avgMin', 'avgMax', 'avgMean', 'avgStddev'], summary)
        print(f'    {len(summary) - 1} nos | Gamma medio {overall[2]:.2f} nos')


if __name__ == '__main__':
    for s in c.parse_scenarios(__doc__.splitlines()[0]):
        run(s)
