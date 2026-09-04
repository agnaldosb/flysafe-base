#!/usr/bin/env python3
"""Spatial awareness time (psi) and age of information (AoI).

Author: Vinicius Trindade
Date:   Sep 03, 2026

A UAV is spatially aware while Gamma == 0, i.e. it knows every neighbor within its
coverage area. Splitting the flight into runs of that condition gives both metrics:

    psi  total time aware, summed over the flight
    AoI  how long one such run lasts, i.e. how long the neighborhood picture stands

    ./5_spatial_awareness.py [bl|ba|ai|all]

Writes, per scenario:
    <sim>/spatial_awareness_192.168.1.<n>.txt                the runs themselves
    <sim>/spatial_awareness_statistics_192.168.1.<n>.txt     run stats, per simulation
    <global>/global_spatial_awareness_statistics_192.168.1.<n>.txt  per node, all simulations
    <global>/global_spatial_awareness_statistics.txt         AoI per node + overall
    <global>/global_total_spatial_awareness.txt              psi per node + overall
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c

STATS = ['min(s)', 'max(s)', 'mean(s)', 'stddev(s)']


def run(scenario):
    print(f'  {os.path.basename(scenario)}: consciencia espacial (psi, AoI)')
    per_node = {}   # node -> list of (sim, min, max, mean, stddev) of run durations
    totals = {}     # node -> list of total aware time per simulation

    for sim in c.sim_dirs(scenario):
        name = c.sim_name(sim)
        for node in c.node_ids(sim):
            ip = f'192.168.1.{node}'
            rows = c.read_table(os.path.join(sim, f'neighborhood_rx_analysis_gnuplot_{ip}.txt'))
            aware, _ = c.awareness_windows(rows)
            if not aware:
                continue
            c.write_table(os.path.join(sim, f'spatial_awareness_{ip}.txt'),
                          ['startTime', 'endTime', 'duration', 'awareness'],
                          [(a, b, d, 1) for a, b, d in aware])
            durations = [float(d) for _, _, d in aware]
            stats = c.describe(durations)
            c.write_table(os.path.join(sim, f'spatial_awareness_statistics_{ip}.txt'),
                          STATS, [stats])
            per_node.setdefault(node, []).append((name,) + stats)
            totals.setdefault(node, []).append(sum(durations))

    gdir = c.global_dir(scenario)
    aoi_rows, psi_rows = [], []
    for node in sorted(per_node):
        entries = per_node[node]
        c.write_table(
            os.path.join(gdir, f'global_spatial_awareness_statistics_192.168.1.{node}.txt'),
            ['simulation'] + STATS, entries)
        cols = [[e[i] for e in entries] for i in range(1, 5)]
        avg = [c.mean_sd(col)[0] for col in cols]
        aoi_rows.append([node] + avg)
        psi_rows.append([node, c.mean_sd(totals[node])[0]])

    if aoi_rows:
        overall = [c.mean_sd([r[i] for r in aoi_rows])[0] for i in range(1, 5)]
        aoi_rows.append(['Avg'] + overall)
        c.write_table(os.path.join(gdir, 'global_spatial_awareness_statistics.txt'),
                      ['node', 'minAvg(s)', 'maxAvg(s)', 'meanAvg(s)', 'stddevAvg(s)'], aoi_rows)
        psi_avg = c.mean_sd([r[1] for r in psi_rows])[0]
        psi_rows.append(['Avg', psi_avg])
        c.write_table(os.path.join(gdir, 'global_total_spatial_awareness.txt'),
                      ['node', 'totalAware(s)'], psi_rows)
        print(f'    {len(aoi_rows) - 1} nos | AoI {overall[2]:.2f} s | psi {psi_avg:.2f} s')


if __name__ == '__main__':
    for s in c.parse_scenarios(__doc__.splitlines()[0]):
        run(s)
