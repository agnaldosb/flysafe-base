#!/usr/bin/env python3
"""Run every metric script over the chosen scenarios, in order.

Author: Vinicius Trindade
Date:   Sep 03, 2026

    ./0_run_all.py [bl|ba|all]

    bl   BASELINE    no attack
    ba   BASEATTK    under false location injection
    all  both (default)

Each script owns one metric, computes it, aggregates it and plots it, writing to
<scenario>/flysafe_global_traces/. They are independent, so any of them can be run on
its own with the same argument. Only 8_tables.py depends on the others, and it runs
last for that reason.
"""

import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))

STEPS = [
    '1_neighborhood_perception.py',
    '2_discovery_error.py',
    '3_localization_error.py',
    '4_delay_recognition.py',
    '5_spatial_awareness.py',
    '6_incorrect_information.py',
    '7_convergence_rounds.py',
    '8_tables.py',
]


def clean(arg):
    """Empty the result folder of each selected scenario.

    A full run regenerates every file, so anything left there is from an earlier run and
    would sit next to the new numbers looking just as current. Individual metric scripts
    never do this, because they would wipe the output of the others.
    """
    import common as c

    keys = list(c.SCENARIOS) if arg == 'all' else [arg]
    for k in keys:
        gdir = os.path.join(c.TRACES_ROOT, c.SCENARIOS[k], c.GLOBAL_DIR)
        if not os.path.isdir(gdir):
            continue
        n = 0
        for name in os.listdir(gdir):
            path = os.path.join(gdir, name)
            if os.path.isfile(path):
                os.remove(path)
                n += 1
        if n:
            print(f'   {c.SCENARIOS[k]}: {n} arquivo(s) anterior(es) removido(s)')


def main():
    sys.path.insert(0, HERE)
    import common as c

    # Valid arguments come from the scenario table, so registering a scenario there
    # is enough: nothing here needs editing.
    valid = list(c.SCENARIOS) + ['all']
    arg = sys.argv[1] if len(sys.argv) > 1 else 'all'
    if arg not in valid:
        print(f"uso: {os.path.basename(sys.argv[0])} [{'|'.join(valid)}]")
        return 1

    started = time.time()
    print('== limpando resultados anteriores')
    clean(arg)

    failed = []
    for step in STEPS:
        print(f'== {step}')
        t0 = time.time()
        r = subprocess.run([sys.executable, os.path.join(HERE, step), arg], cwd=HERE)
        if r.returncode != 0:
            failed.append(step)
            print(f'   !! {step} terminou com codigo {r.returncode}')
        print(f'   {time.time() - t0:.1f}s')

    print(f'\ntotal: {time.time() - started:.1f}s')
    if failed:
        print(f'falharam: {", ".join(failed)}')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
