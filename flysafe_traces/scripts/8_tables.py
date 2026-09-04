#!/usr/bin/env python3
"""LaTeX result tables, in the format of the KEYSUAV paper.

Author: Vinicius Trindade
Date:   Sep 03, 2026

Reads what the metric scripts wrote under each <scenario>/flysafe_global_traces/ and
fills the paper's tables with it. Runs last, since it consumes their output.

The tables compare scenarios, so they belong to none of them: they are written to
flysafe_traces/tables/, ready to be included from the paper.

    ./8_tables.py [bl|ba|all]
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import common as c

OUT_DIR = os.path.join(c.TRACES_ROOT, 'tables')
ORDER = ['BASELINE', 'BASEATTK']


def read_named(path, name, column):
    """One column of the row labelled `name`, or None when the file has no such row."""
    for r in c.read_table(path):
        if r and r[0] == name and len(r) > column:
            try:
                return float(r[column])
            except ValueError:
                return None
    return None


def collect(scenario):
    """Every headline figure of one scenario, from its global files."""
    g = os.path.join(scenario, c.GLOBAL_DIR)
    j = lambda f: os.path.join(g, f)
    return {
        'aoi': read_named(j('global_spatial_awareness_statistics.txt'), 'Avg', 3),
        'psi': read_named(j('global_total_spatial_awareness.txt'), 'Avg', 1),
        'aoii': read_named(j('global_no_spatial_awareness_statistics.txt'), 'Avg', 3),
        'omega': read_named(j('global_localization_error_rx_statistics.txt'), 'Avg', 1),
        # W is the neighborhood a UAV perceives; Gamma is what it failed to perceive of
        # the one in range. Earlier work published W under Gamma's name, so both are
        # reported here and each is labelled for what it is.
        'perception': read_named(j('global_neighborhood_rx_statistics.txt'), 'Avg', 3),
        'gamma': read_named(j('global_discovery_error_statistics.txt'), 'Avg', 3),
        'upsilon': (c.read_table(j('global_deviation_delay_statistics.txt')) or [[None] * 3])[0][2],
        'phi': read_named(j('global_achieve_spatial_awareness_stats.txt'), 'Avg', 1),
    }


def num(v, nd=2):
    """A number for the table, or a dash when the scenario has no such figure."""
    try:
        return f'{float(v):.{nd}f}'
    except (TypeError, ValueError):
        return '--'


def spatial_awareness(data):
    rows = '\n'.join(
        f'        {s} & {num(data[s]["aoi"])} & {num(data[s]["aoii"])} & {num(data[s]["psi"])} \\\\'
        for s in ORDER if s in data)
    return f"""\\begin{{table}}[!htb]
    \\centering
    \\caption{{Spatial awareness condition}}
    \\label{{tab:aoii_aoi_spatial}}
    \\begin{{tabular}}{{llccc}}
        \\hlineB{{4}}
        \\textbf{{Config.}} & \\textbf{{AoI}} (s) & \\textbf{{AoII}} (s) & \\textbf{{$\\psi$}} (s)\\\\ \\hline
{rows}
        \\hlineB{{4}}
    \\end{{tabular}}
\\end{{table}}
"""


def neighborhood_perception(data):
    rows = '\n'.join(
        f'        {s} & {num(data[s]["omega"])} & {num(data[s]["upsilon"])} '
        f'& {num(data[s]["perception"])} & {num(data[s]["gamma"])} \\\\'
        for s in ORDER if s in data)
    return f"""\\begin{{table}}[H]
    \\centering
    \\caption{{Neighborhood perception}}
    \\label{{tab:location_delay}}
    \\begin{{tabular}}{{lcccc}}
    \\hlineB{{4}}
    \\textbf{{Config.}} & $\\Omega$ (m) &\\textbf{{$\\Upsilon$}} (ms) & \\textbf{{$W$}} (\\# nodes) & \\textbf{{$\\Gamma$}} (\\# nodes)\\\\
    \\hline
{rows}
    \\hlineB{{4}}
    \\end{{tabular}}
\\end{{table}}
"""


def convergence_rounds(data):
    present = [s for s in ORDER if s in data]
    head = ' & '.join(present)
    vals = ' & '.join(num(data[s]['phi']) for s in present)
    cols = 'l' + 'c' * len(present)
    return f"""\\begin{{table}}[!htb]
	\\centering
	\\caption{{Convergence rounds to achieve spatial awareness}}
        \\setlength{{\\tabcolsep}}{{9pt}}
	\\label{{tab:rounds}}
	\\begin{{tabular}}{{{cols}}}
        \\hlineB{{4}}
        & \\multicolumn{{{len(present)}}}{{c}}{{\\textbf{{Configuration scenario}}}} \\\\ \\cline{{2-{len(present) + 1}}}
        & {head} \\\\ \\hline
        \\textbf{{$\\varphi$}} & {vals}\\\\
        \\hlineB{{4}}
	\\end{{tabular}}
\\end{{table}}
"""




def main():
    scenarios = c.parse_scenarios(__doc__.splitlines()[0])
    data = {os.path.basename(s): collect(s) for s in scenarios}
    if not data:
        return
    os.makedirs(OUT_DIR, exist_ok=True)
    written = []
    for name, text in (('Spatial-awareness.tex', spatial_awareness(data)),
                       ('Neighborhood-perception.tex', neighborhood_perception(data)),
                       ('Convergence-rounds.tex', convergence_rounds(data))):
        with open(os.path.join(OUT_DIR, name), 'w') as fh:
            fh.write(text)
        written.append(name)
    print(f'  tabelas em {os.path.relpath(OUT_DIR, os.getcwd())}: {", ".join(written)}')


if __name__ == '__main__':
    main()
