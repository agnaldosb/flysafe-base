#!/usr/bin/env python3
"""Age of incorrect information (AoII): how long a UAV holds a wrong neighborhood picture.

Author: Vinicius Trindade
Date:   Sep 03, 2026

AoII is the complement of spatial awareness: the period a UAV remains unaware of others,
i.e. Gamma > 0. Splitting the flight into runs of that condition and averaging their
duration gives how long one such blind spell typically lasts.

    ./6_incorrect_information.py [bl|ba|ai|all]

Writes, per scenario:
    <sim>/spatial_no_awareness_192.168.1.<n>.txt                 the runs themselves
    <sim>/spatial_no_awareness_statistics_192.168.1.<n>.txt      run stats, per simulation
    <global>/global_no_spatial_awareness_statistics_192.168.1.<n>.txt  per node, all simulations
    <global>/global_no_spatial_awareness_statistics.txt          AoII per node + overall
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c

STATS = ['min(s)', 'max(s)', 'mean(s)', 'stddev(s)']


def run(scenario):
    print(f'  {os.path.basename(scenario)}: informacao incorreta (AoII)')
    per_node = {}

    for sim in c.sim_dirs(scenario):
        name = c.sim_name(sim)
        for node in c.node_ids(sim):
            ip = f'192.168.1.{node}'
            rows = c.read_table(os.path.join(sim, f'neighborhood_rx_analysis_gnuplot_{ip}.txt'))
            _, unaware = c.awareness_windows(rows)
            if not unaware:
                continue
            c.write_table(os.path.join(sim, f'spatial_no_awareness_{ip}.txt'),
                          ['startTime', 'endTime', 'duration', 'awareness'],
                          [(a, b, d, 0) for a, b, d in unaware])
            stats = c.describe([float(d) for _, _, d in unaware])
            c.write_table(os.path.join(sim, f'spatial_no_awareness_statistics_{ip}.txt'),
                          STATS, [stats])
            per_node.setdefault(node, []).append((name,) + stats)

    gdir = c.global_dir(scenario)
    summary = []
    for node in sorted(per_node):
        entries = per_node[node]
        c.write_table(
            os.path.join(gdir, f'global_no_spatial_awareness_statistics_192.168.1.{node}.txt'),
            ['simulation'] + STATS, entries)
        cols = [[e[i] for e in entries] for i in range(1, 5)]
        avg = [c.mean_sd(col)[0] for col in cols]
        summary.append([node] + avg)

    if summary:
        overall = [c.mean_sd([s[i] for s in summary])[0] for i in range(1, 5)]
        summary.append(['Avg'] + overall)
        c.write_table(os.path.join(gdir, 'global_no_spatial_awareness_statistics.txt'),
                      ['node', 'minAvg(s)', 'maxAvg(s)', 'meanAvg(s)', 'stddevAvg(s)'], summary)
        print(f'    {len(summary) - 1} nos | AoII medio {overall[2]:.2f} s')


if __name__ == '__main__':
    for s in c.parse_scenarios(__doc__.splitlines()[0]):
        run(s)
