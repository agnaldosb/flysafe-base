#!/usr/bin/env python3
"""Convergence rounds (phi): messages exchanged to achieve spatial awareness.

Author: Vinicius Trindade
Date:   Sep 03, 2026

phi = sum of (HM + IM + TM) over the periods a UAV pursues awareness, i.e. while
Gamma > 0. Messages sent and received are matched against the unaware runs in a single
merge pass, both series being time sorted. The same count over the aware runs gives the
traffic that sustains awareness once reached.

    ./7_convergence_rounds.py [bl|ba|ai|all]

Writes, per scenario:
    <sim>/rounds_achieve_aware_analysis_192.168.1.<n>.txt   per run, per node
    <sim>/rounds_keep_aware_analysis_192.168.1.<n>.txt      idem, while aware
    <global>/global_achieve_spatial_awareness_stats.txt     phi per node + overall
    <global>/global_keep_spatial_awareness_stats.txt        idem, while aware
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c

ROUND_HEADER = ['sTime', 'eTime', 'dur', 'nTM', 'nTB', 'nTI', 'nTT',
                'nRM', 'nRB', 'nRI', 'nRT', 'tM']


def count_rounds(windows, messages):
    """Messages of each type falling inside every window, by a single merge pass."""
    out = []
    i, n = 0, len(messages)
    for (s_str, e_str, dur) in windows:
        s, e = float(s_str), float(e_str)
        while i < n and messages[i][0] < s:
            i += 1
        j = i
        total = hm = im = tm = 0
        while j < n and messages[j][0] <= e:
            total += 1
            tag = messages[j][1]
            if tag == c.TAG_HM:
                hm += 1
            elif tag == c.TAG_IM:
                im += 1
            else:
                tm += 1
            j += 1
        out.append((s_str, e_str, dur, total, hm, im, tm))
    return out


def phase(sim, node, windows, label):
    """Write the per-run message counts of one phase and return its message total."""
    ip = f'192.168.1.{node}'
    tx = count_rounds(windows, c.load_messages(os.path.join(sim, f'messages_sent_{ip}.txt')))
    rx = count_rounds(windows, c.load_messages(os.path.join(sim, f'messages_received_{ip}.txt')))
    rows, total = [], 0
    for t, r in zip(tx, rx):
        if t[3] == 0 and r[3] == 0:
            continue
        rows.append((t[0], t[1], t[2], t[3], t[4], t[5], t[6],
                     r[3], r[4], r[5], r[6], t[3] + r[3]))
        total += t[3] + r[3]
    c.write_table(os.path.join(sim, f'rounds_{label}_aware_analysis_{ip}.txt'),
                  ROUND_HEADER, rows)
    return total


def run(scenario):
    print(f'  {os.path.basename(scenario)}: rodadas de convergencia (phi)')
    achieve, keep = {}, {}

    for sim in c.sim_dirs(scenario):
        for node in c.node_ids(sim):
            ip = f'192.168.1.{node}'
            rows = c.read_table(os.path.join(sim, f'neighborhood_rx_analysis_gnuplot_{ip}.txt'))
            aware, unaware = c.awareness_windows(rows)
            if not rows:
                continue
            achieve.setdefault(node, []).append(phase(sim, node, unaware, 'achieve'))
            keep.setdefault(node, []).append(phase(sim, node, aware, 'keep'))

    gdir = c.global_dir(scenario)
    for data, fname, label in ((achieve, 'global_achieve_spatial_awareness_stats.txt', 'achieve'),
                               (keep, 'global_keep_spatial_awareness_stats.txt', 'keep')):
        if not data:
            continue
        rows = [[n, c.mean_sd(v)[0]] for n, v in sorted(data.items())]
        overall = c.mean_sd([r[1] for r in rows])[0]
        rows.append(['Avg', overall])
        c.write_table(os.path.join(gdir, fname), ['node', 'phi(msgs)'], rows)
        if label == 'achieve':
            print(f'    {len(rows) - 1} nos | phi medio {overall:.2f} mensagens')


if __name__ == '__main__':
    for s in c.parse_scenarios(__doc__.splitlines()[0]):
        run(s)
