## Resubmission

This is a resubmission. In this version I have:

* Expanded all acronyms (LDA, STM, CTM) in the DESCRIPTION file with their full names: Latent Dirichlet Allocation (LDA), Structural Topic Models (STM), and Correlated Topic Models (CTM)

* Added three methodological references with DOIs in the DESCRIPTION file:
  - Blei et al. (2003) <doi:10.1162/jmlr.2003.3.4-5.993> for LDA
  - Roberts et al. (2014) <doi:10.1111/ajps.12103> for STM
  - Blei and Lafferty (2007) <doi:10.1214/07-AOAS114> for CTM

* Regarding examples: All functions in this package require data from the Scopus API, which requires an API key. Following CRAN policy that "\dontrun{} should only be used if the example really cannot be executed (e.g. because of missing additional software, missing API keys, ...)", I have retained \dontrun{} for examples that require Scopus API keys. The exception is theme_sportminer(), which has an executable example using the built-in mtcars dataset.

## Test environments

* local: macOS (R 4.5.2)
* win-builder: windows (devel and release)
* R-hub: ubuntu, fedora, windows

## R CMD check results

0 errors | 0 warnings | 0 notes

## Downstream dependencies

There are currently no downstream dependencies for this package.
