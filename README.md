# Part 3: De-biasing a Parameter Estimate Using Controls

## 1. Model Overview

In this simulation study, I constructed a data-generating process (DGP) in which the outcome variable `Y` is influenced by a treatment variable `T`, two covariates `X1` and `X2`, and a group-level effect captured by `strata`. The treatment `T` is not randomly assigned but instead depends on both `X1` (a confounder) and `X3` (an irrelevant instrument-like variable). The true treatment effect is set to 0.5. I estimated this effect using five regression models:

1. `reg Y T`  
2. `reg Y T X1`  
3. `reg Y T X1 X2`  
4. `xtreg Y T X1 X2, fe` (strata fixed effects)  
5. `xtreg Y T X1 X2 X3, fe` (adds irrelevant variable)

Each model was run across varying sample sizes (N = 100 to 10,000) using repeated simulations to assess bias and convergence behavior.

## 2. Bias in Treatment Effect Estimates

The comparison across models reveals clear differences in bias. The naive model that includes only the treatment variable ("T only") produces a strongly upward-biased estimate, far from the true treatment effect of 0.5. This is due to omitted variable bias from leaving out `X1`, a confounder that affects both the treatment and the outcome. Once `X1` is included in the model (“T + X1”), the bias is effectively removed. Adding `X2`, which only affects the outcome, does not change the treatment estimate but improves precision slightly. The inclusion of fixed effects for `strata` further controls for unobserved group-level heterogeneity, yielding unbiased and more precise estimates. Including the irrelevant variable `X3` (which influences treatment but not outcome) does not bias the result but slightly increases variance.

[Figure 1. Biaseness](image/biaseness.jpg.jpg)

## 3. Convergence Toward the True Effect

As the sample size increases, all correctly specified models show convergence toward the true treatment effect of 0.5. This is visible in the shrinking confidence intervals and increasingly stable coefficient estimates across larger `N`. The models that properly control for confounding (beginning with “T + X1”) consistently yield estimates centered around the true effect, even at moderate sample sizes. In contrast, the “T only” model remains biased regardless of `N`, indicating that increasing sample size cannot fix misspecification. These findings demonstrate the importance of including confounders and group-level controls to ensure both unbiasedness and efficient convergence in causal inference.

[Figure 2. Convergence](image/convergence.jpg)