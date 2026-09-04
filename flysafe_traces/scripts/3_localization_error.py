#!/usr/bin/env python3
"""Location error (Omega): how far a neighbor really is from where it was thought to be.

Author: Vinicius Trindade
Date:   Sep 03, 2026

Omega^t = |d^r - d^m|, already computed per reception by the simulation and recorded in
neighborhood_rx_localization_error_analysis_*, whose columns are time, nNeighs, AvgError,
MinError, MaxError, Errors. The three error columns are summarized here.

    ./3_localization_error.py [bl|ba|ai|all]

Writes, per scenario:
    <sim>/localization_error_rx_statistics_192.168.1.<n>.txt          per node, per simulation
    <global>/global_localization_error_rx_statistics_192.168.1.<n>.txt   per node, all simulations
    <global>/global_localization_error_rx_statistics.txt              per node average + overall
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c

HEADER = ['avgAvgError', 'stdDevAvgError', 'avgAvgMin', 'stdDevAvgMin',
          'avgAvgMax', 'stdDevAvgMax']


def run(scenario):
    print(f'  {os.path.basename(scenario)}: erro de localizacao (Omega)')
    per_node = {}

    for sim in c.sim_dirs(scenario):
        name = c.sim_name(sim)
        for node in c.node_ids(sim):
            ip = f'192.168.1.{node}'
            rows = c.read_table(
                os.path.join(sim, f'neighborhood_rx_localization_error_analysis_{ip}.txt'))
            rows = [r for r in rows if len(r) > 4]
            if not rows:
                continue
            avg = [c.trunc(float(r[2]), 1) for r in rows]
            mn = [c.trunc(float(r[3]), 1) for r in rows]
            mx = [c.trunc(float(r[4]), 1) for r in rows]
            stats = c.mean_sd(avg) + c.mean_sd(mn) + c.mean_sd(mx)
            c.write_table(os.path.join(sim, f'localization_error_rx_statistics_{ip}.txt'),
                          HEADER, [stats])
            per_node.setdefault(node, []).append((name,) + stats)

    gdir = c.global_dir(scenario)
    summary = []
    for node in sorted(per_node):
        entries = per_node[node]
        c.write_table(
            os.path.join(gdir, f'global_localization_error_rx_statistics_192.168.1.{node}.txt'),
            ['dateTime'] + HEADER, entries)
        cols = [[e[i] for e in entries] for i in range(1, 7)]
        avg = [c.mean_sd(col)[0] for col in cols]
        summary.append([node] + avg)

    if summary:
        overall = [c.mean_sd([s[i] for s in summary])[0] for i in range(1, 7)]
        summary.append(['Avg'] + overall)
        c.write_table(os.path.join(gdir, 'global_localization_error_rx_statistics.txt'),
                      ['node', 'gAvgError', 'gStdDevAvgError', 'gAvgMin', 'gStdDevAvgMin',
                       'gAvgMax', 'gStdDevAvgMax'], summary)
        print(f'    {len(summary) - 1} nos | Omega medio {overall[0]:.2f} m')


if __name__ == '__main__':
    for s in c.parse_scenarios(__doc__.splitlines()[0]):
        run(s)
