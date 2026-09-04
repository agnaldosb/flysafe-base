"""Shared trace reading, statistics and plotting helpers.

Author: Vinicius Trindade
Date:   Sep 03, 2026

Not a metric: every metric script imports from here so the parsing and the output
conventions stay in one place. Each metric keeps its own computation.

Scenario folders sit beside this one, each holding simulation folders named
ddmmyyyy_HHMM or ddmmyyyy_HHMMSS. Results go to <scenario>/flysafe_global_traces/, as before.
"""

import argparse
import math
import os
import re
import statistics

# Simulation folder names. Older runs stamp the time to the minute (ddmmyyyy_HHMM),
# newer ones to the second (ddmmyyyy_HHMMSS); both are accepted.
SIM_DIR_RE = re.compile(r'^\d{8}_\d{4}(?:\d{2})?$')
GLOBAL_DIR = 'flysafe_global_traces'

# Scenario keys accepted on the command line.
SCENARIOS = {'bl': 'BASELINE', 'ba': 'BASEATTK'}

# Message tags as the simulation writes them, mapped to the paper's message types.
TAG_HM = 0  # Hello message
TAG_IM = 1  # Identification message
TAG_TM = 2  # Trap message

TRACES_ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))


# ------------------------------------------------------------------- arguments

def parse_scenarios(description):
    """Read the scenario selector shared by every metric script.

    Accepts bl, ba, ai or all (the default), and returns the scenario folders that
    exist, so a missing one is reported instead of failing halfway through.
    """
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('scenario', nargs='?', default='all',
                    choices=['bl', 'ba', 'all'],
                    help='bl=BASELINE, ba=BASEATTK, all=both (default)')
    args = ap.parse_args()
    keys = list(SCENARIOS) if args.scenario == 'all' else [args.scenario]
    out = []
    for k in keys:
        path = os.path.join(TRACES_ROOT, SCENARIOS[k])
        if os.path.isdir(path):
            out.append(path)
        else:
            print(f'  aviso: cenario {SCENARIOS[k]} nao encontrado, pulando')
    return out


# -------------------------------------------------------------------------- io

def sim_dirs(scenario):
    """Simulation folders of a scenario, recognized by their ddmmyyyy_HHMM[SS] name."""
    return sorted(os.path.join(scenario, d) for d in os.listdir(scenario)
                  if SIM_DIR_RE.match(d) and os.path.isdir(os.path.join(scenario, d)))


def sim_name(sim):
    """Folder name of a simulation, used as its label in the global files."""
    return os.path.basename(sim.rstrip(os.sep))


def node_ids(sim):
    """Node numbers that have a neighborhood trace in this simulation."""
    ids = []
    for name in os.listdir(sim):
        m = re.match(r'^neighborhood_rx_analysis_gnuplot_192\.168\.1\.(\d+)\.txt$', name)
        if m:
            ids.append(int(m.group(1)))
    return sorted(ids)


def read_table(path):
    """Rows of a whitespace separated trace file, header skipped. Empty if absent."""
    if not os.path.exists(path):
        return []
    rows = []
    with open(path, errors='ignore') as fh:
        next(fh, None)
        for line in fh:
            parts = line.split()
            if parts:
                rows.append(parts)
    return rows


def global_dir(scenario):
    """Result folder of a scenario, created on demand."""
    path = os.path.join(scenario, GLOBAL_DIR)
    os.makedirs(path, exist_ok=True)
    return path


def write_table(path, header, rows):
    """Write a header line plus rows, tab separated."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as fh:
        fh.write('\t'.join(header) + '\n')
        for r in rows:
            fh.write('\t'.join(fmt(x) for x in r) + '\n')


def fmt(x):
    """Numbers with two decimals, anything else unchanged."""
    return f'{x:.2f}' if isinstance(x, float) else str(x)


# ------------------------------------------------------------------ statistics

def trunc(x, decimals):
    """Truncate toward minus infinity, as the gnuplot pipeline did."""
    f = 10.0 ** decimals
    return math.floor(x * f) / f


def describe(values, decimals=None):
    """min, max, mean and population stddev, matching gnuplot's stats."""
    if not values:
        return None
    if decimals is not None:
        values = [trunc(v, decimals) for v in values]
    mean = statistics.fmean(values)
    sd = statistics.pstdev(values) if len(values) > 1 else 0.0
    if decimals is not None:
        return (trunc(min(values), decimals), trunc(max(values), decimals),
                trunc(mean, decimals), trunc(sd, decimals))
    return (min(values), max(values), mean, sd)


def mean_sd(values):
    """Mean and population stddev of a series, zeros when empty."""
    if not values:
        return (0.0, 0.0)
    return (statistics.fmean(values),
            statistics.pstdev(values) if len(values) > 1 else 0.0)


# ----------------------------------------------------------- awareness windows

def _decimals(s):
    """Digits after the decimal point in a timestamp as it was written."""
    i = s.find('.')
    return len(s) - i - 1 if i >= 0 else 0


def duration(start_s, end_s):
    """Duration string with the precision of its operands, formatted like bc.

    bc prints a bare '0' for zero and drops the leading zero of a fraction ('.8'), and
    the existing trace files carry that convention, so it is reproduced here.
    """
    scale = max(_decimals(start_s), _decimals(end_s))
    text = f'{float(end_s) - float(start_s):.{scale}f}'
    if re.fullmatch(r'-?0+(\.0+)?', text):
        return '0'
    if scale > 0 and text.startswith('0.'):
        return text[1:]
    if scale > 0 and text.startswith('-0.'):
        return '-' + text[2:]
    return text


def awareness_windows(rows):
    """Split a neighborhood trace into contiguous runs of equal awareness.

    Columns are time, NLSize, nPsbNeigh, nNeighCIdent, Error, Aware. Awareness means
    Gamma == 0, i.e. the node knew every neighbor in range. Operation starts at t = 0
    and each run ends where the next begins, so the runs tile the whole flight.

    Returns (aware, unaware), each a list of (startStr, endStr, durationStr).
    """
    aware, unaware = [], []
    rows = [r for r in rows if len(r) > 4]
    if not rows:
        return aware, unaware
    start = '0'
    state = 1 if float(rows[0][4]) == 0 else 0
    last = rows[0][0]
    for r in rows[1:]:
        t = r[0]
        cur = 1 if float(r[4]) == 0 else 0
        last = t
        if cur != state:
            (aware if state else unaware).append((start, t, duration(start, t)))
            start, state = t, cur
    (aware if state else unaware).append((start, last, duration(start, last)))
    return aware, unaware


def load_messages(path):
    """(time, tag) pairs from a messages_sent/received file, time sorted."""
    msgs = []
    for r in read_table(path):
        if len(r) >= 3:
            try:
                msgs.append((float(r[0]), int(r[2])))
            except ValueError:
                continue
    msgs.sort(key=lambda x: x[0])
    return msgs

