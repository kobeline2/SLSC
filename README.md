# SLSC Benchmark

Simulation study for evaluating goodness-of-fit criteria in hydrological frequency analysis, with focus on the **SLSC (Standard Least-Squares Criterion)** and its comparison with likelihood-based model selection (AIC).

## Background

In Japanese hydrological practice, the SLSC has been used since 1986 (Takasao & Takara) as the standard goodness-of-fit measure for selecting probability distributions in flood frequency analysis. A fixed threshold of SLSC < 0.04 is conventionally applied regardless of sample size or distribution type.

This project investigates:

1. **Statistical properties of SLSC** -- sample-size dependence, distribution-dependent bias under nonlinear standardisation, and the lack of a formal null distribution.
2. **Comparison with AIC** -- whether likelihood-based criteria provide fairer and more consistent model selection.
3. **Structural bias toward 3P Lognormal** -- how log-transformation compresses tail errors, giving 3PLN a systematic advantage in SLSC-based selection.

## Method

Monte Carlo simulation with the following pipeline:

```
Sampler (true distribution)
  → Generate N i.i.d. samples
    → Fit candidate distributions via MLE
      → Evaluate: SLSC, AIC, Cross-entropy
        → Compare across 10,000 repetitions
```

### Candidate distributions

| Distribution | Parameters | Notes |
|---|---|---|
| Gumbel | location, scale | 2P, extreme value type I |
| GEV | location, scale, shape | 3P, generalisation of Gumbel |
| 3P Lognormal | shift, log-mean, log-std | 3P, non-regular model |
| Log-Gamma (Pearson III) | scale, shape, location | 3P |
| sqrt-ET | a, b | 2P, Takara (1989) |

True parameters are calibrated to Kyoto annual maximum daily rainfall.

## Requirements

- MATLAB R2020b or later
- Statistics and Machine Learning Toolbox
- Optimization Toolbox
- Parallel Computing Toolbox (optional, for `parfor`)

## Quick start

```matlab
% Add project root to path (packages are auto-resolved)
cd /path/to/SLSC
paths = init();

% Configure and run
cfg = simstudy.config.base();
cfg.genList = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
cfg.fitList = ["gumbel", "gev", "lp3", "sqrtet", "exponential", "lnormal"];
cfg.Nlist   = [50, 100, 150];
cfg.rep     = 10000;

experiments.runBatch(cfg);
```

Results are saved to `results/` as `.mat` files.

For the S-space SLSC, the default transform profile is `japan_admin`.
This uses `(x-mu)/sigma` for `gev` and `b*x` for `sqrtet`.
If you want the older reduced-variate formulas, set `cfg.slscProfile = "eva_reduced"`.
You can also override a single model via `cfg.slscTransforms.<model>`.

## Project structure

```
SLSC/
├── +simstudy/             Core package
│   ├── +config/           Simulation parameters and true values
│   ├── +distributions/    Distribution implementations (rnd, pdf, loglike, icdf)
│   ├── +estimators/       Parameter estimation (MLE)
│   ├── +metrics/          Goodness-of-fit metrics (SLSC, AIC, cross-entropy)
│   ├── +util/             Utilities (transforms, aggregation, plotting positions)
│   ├── +analysis/         Visualisation and summary
│   └── +diagnostics/      Diagnostic tools
├── +experiments/          Experiment runners (batch and single)
├── test/                  Test and validation scripts
└── results/               Simulation output (.mat)
```

## References

- Takasao, T. & Takara, K. (1986). SLSC -- criteria for evaluating probability distribution models. *Proc. JSCE*, 393/II-9, 151--160. (in Japanese)
- Takara, K. & Stedinger, J.R. (1994). Recent Japanese contributions to frequency analysis and quantile lower bound estimators. *Stochastic and Statistical Methods in Hydrology and Environmental Engineering*, 1, 217--234.
- Filliben, J.J. (1975). The probability plot correlation coefficient test for normality. *Technometrics*, 17(1), 111--117.

## Author

Takahiro Koshiba, Disaster Prevention Research Institute, Kyoto University

## License

TBD
