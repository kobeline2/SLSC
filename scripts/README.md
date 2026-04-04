# scripts

Minimal entry points for interactive work.

## Files

- `../init.m`: initialize the project path for an interactive MATLAB session.
- `runSmoke.m`: one tiny end-to-end run for pipeline checks.
- `runMiniGrid.m`: small experiment for quick iteration.
- `showRunSummary.m`: load one aggregate and print simple means.
- `checkMetricSingle.m`: fit one model and inspect `SLSC`, `SLSC_X`, `AIC`, and `XENTROPY`.
- `checkSlscTransform.m`: compare the coded S-space transform with a reference reduced variate.
- `runValidationModel.m`: validate one distribution implementation and save a figure.
- `runValidationSuite.m`: run validation for all configured distributions.
- `slscLocalPaths.m`: resolve local-only storage directories.

## Local storage

Set `SLSC_LOCAL_ROOT` if you want all local data outside the repository.

If not set, the default is:

```text
<repo>/local/
  data/
  runs/
  validation/
  exports/
  scratch/
```

`runs/<runLabel>/` is the main place for simulation outputs.
`validation/<suiteLabel>/` stores consistency-check figures and summaries.

## Recommended usage

From the repository root in MATLAB:

```matlab
paths = init();
run("scripts/runSmoke.m")
```

For a quick metric check:

```matlab
run("scripts/checkMetricSingle.m")
```

The script saves outputs under `local/scratch/metric_checks/` by default.
