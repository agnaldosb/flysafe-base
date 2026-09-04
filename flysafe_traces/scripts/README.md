# FlySafe evaluation metrics

Author: Vinicius Trindade

Computes the metrics of *Resilient UAVs Location Sharing Service Based on Information
Freshness and Opportunistic Deliveries* (Section 5.2) from the ns-3 simulation traces,
and fills the paper's result tables with them.

## Layout

Put this folder next to the scenario folders:

```
flysafe_traces/
├── scripts_flysafe/     this folder
├── BASELINE/            simulation folders, named ddmmyyyy_HHMMSS
└── BASEATTK/
```

Results are written to `<scenario>/flysafe_global_traces/`, and the LaTeX tables to
`flysafe_traces/tables/`. 

## Running

From inside this folder:

```bash
./0_run_all.py          # both scenarios (all is the default)
./0_run_all.py bl       # BASELINE only
./0_run_all.py ba       # BASEATTK only
```

Any metric can also be run on its own, with the same argument:

```bash
./3_localization_error.py ba
./7_convergence_rounds.py
./8_tables.py            # only regenerate the .tex files
```

`0_run_all.py` clears `flysafe_global_traces/` before running, since it regenerates
everything. The individual scripts do not: they overwrite only their own files, so
running one does not destroy the output of the others.

## The metrics

| Script | Metric | Meaning |
|---|---|---|
| 1 | *W* | neighbors a UAV knows |
| 2 | Γ | neighbors in range it failed to know (`W_j - W_S`) |
| 3 | Ω | location error, `\|d_r - d_m\|` |
| 4 | Υ | delay recognizing a location change, `t_r - t_d` |
| 5 | ψ, AoI | time spatially aware, and how long one such period lasts |
| 6 | AoII | how long a wrong neighborhood picture is held |
| 7 | φ | messages exchanged to achieve awareness, `Σ (HM + IM + TM)` |
| 8 | — | writes the LaTeX tables |

## Extending this for your own work

These scripts cover the two scenarios we all share:

- **BASELINE** — FlySafe with no attack and no defense
- **BASEATTK** — FlySafe under an attack, undefended

The third scenario is yours: the solution you are proposing. It is not included here
because each of us names it differently and evaluates it against different criteria, so
adding it is up to each author.

### Adding your scenario

Name its folder next to the others and register it in three places:

1. `common.py`, the scenario table — pick a two-letter key:

   ```python
   SCENARIOS = {'bl': 'BASELINE', 'ba': 'BASEATTK', 'xx': 'YOURSCENARIO'}
   ```

2. `common.py`, the accepted arguments, a few lines below:

   ```python
   choices=['bl', 'ba', 'xx', 'all'],
   ```

3. `8_tables.py`, the column order of the tables:

   ```python
   ORDER = ['BASELINE', 'BASEATTK', 'YOURSCENARIO']
   ```

Nothing else needs touching. Simulations, nodes and scenarios are discovered from the
files present, so any number of them works, and `0_run_all.py` takes its valid arguments
from the scenario table above.

### Adding your own metrics and tables

The seven metrics here describe FlySafe itself, which is why we can share them. Whatever
your attack and your solution are judged by is yours to write: it will read trace files
these scripts never touch, and it will answer questions they were not built for.

So do not feel bound by how they are put together. What is worth keeping is the outer
shape, because it is what lets the pipeline stay one command:

- take the same scenario argument, so `./yourscript.py xx` behaves like the rest
- write results into `<scenario>/flysafe_global_traces/`
- add the file to `STEPS` in `0_run_all.py`, before `8_tables.py` if the tables use it
- add your own table function to `8_tables.py`, or write a separate script for your
  tables

`common.py` may or may not help. Its scenario handling and file IO — `parse_scenarios`,
`sim_dirs`, `node_ids`, `read_table`, `write_table`, `global_dir`, `mean_sd` — are
generic and cost nothing to reuse. The rest of it (awareness windows, message loading) is
FlySafe specific and will probably not fit your case. Import what serves you and write
the rest your own way.

The one habit worth copying is **one metric per file**. A script that computes,
aggregates and writes a single metric can be run on its own while you develop it, can be
reviewed without reading the rest, and cannot break another metric when you change it.
That is why these are split this way rather than gathered into one program.

Also worth copying: read each file once and hold one node at a time. That is what keeps
the whole pipeline in seconds, and it is easy to lose by accident.
