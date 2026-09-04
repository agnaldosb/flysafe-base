#!/usr/bin/env python3
"""Delay on location changes recognition (Upsilon).

Author: Vinicius Trindade
Date:   Sep 03, 2026

Upsilon = t^r_j - t^d_i, the gap between a UAV detecting its own location change and a
neighbor becoming aware of it. The simulation records it per reception in
deviation_delay_rx_analysis_*, whose third column is the delay in milliseconds.

    ./4_delay_recognition.py [bl|ba|ai|all]

Writes, per scenario:
    <sim>/deviation_delay_rx_statistics_192.168.1.<n>.txt   per node, per simulation
    <sim>/deviation_delay_rx_statistics_global.txt          all nodes of the simulation
    <global>/global_deviation_delay_rx_statistics.txt       one line per simulation
    <global>/global_deviation_delay_statistics.txt          overall average
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c

HEADER = ['min(ms)', 'max(ms)', 'mean(ms)', 'stddev(ms)']


def run(scenario):
    print(f'  {os.path.basename(scenario)}: delay de reconhecimento (Upsilon)')
    per_sim = []

    for sim in c.sim_dirs(scenario):
        name = c.sim_name(sim)
        all_delays = []
        for node in c.node_ids(sim):
            ip = f'192.168.1.{node}'
            rows = c.read_table(os.path.join(sim, f'deviation_delay_rx_analysis_{ip}.txt'))
            delays = [float(r[2]) for r in rows if len(r) > 2]
            if not delays:
                continue
            stats = c.describe(delays)
            c.write_table(os.path.join(sim, f'deviation_delay_rx_statistics_{ip}.txt'),
                          HEADER, [stats])
            all_delays.extend(delays)
        if all_delays:
            stats = c.describe(all_delays)
            c.write_table(os.path.join(sim, 'deviation_delay_rx_statistics_global.txt'),
                          HEADER, [stats])
            per_sim.append((name,) + stats)

    gdir = c.global_dir(scenario)
    if per_sim:
        c.write_table(os.path.join(gdir, 'global_deviation_delay_rx_statistics.txt'),
                      ['simulation'] + HEADER, per_sim)
        overall = [c.mean_sd([p[i] for p in per_sim])[0] for i in range(1, 5)]
        c.write_table(os.path.join(gdir, 'global_deviation_delay_statistics.txt'),
                      ['avgMin(ms)', 'avgMax(ms)', 'avgMean(ms)', 'avgStddev(ms)'], [overall])
        print(f'    {len(per_sim)} simulacoes | Upsilon medio {overall[2]:.2f} ms')


if __name__ == '__main__':
    for s in c.parse_scenarios(__doc__.splitlines()[0]):
        run(s)
