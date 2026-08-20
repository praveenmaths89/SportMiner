# Contributing to SportMiner

Thank you for considering a contribution. SportMiner is an R package for literature mining workflows. The maintainers welcome bug reports, documentation fixes, tests, and well-scoped feature additions.

## How to report a problem

Open a GitHub issue at https://github.com/praveenmaths89/SportMiner/issues with:

- The SportMiner and R versions (`packageVersion("SportMiner")`, `R.version.string`)
- A minimal example (query or data snippet that does not include private API keys)
- The expected and actual result

Never paste a Scopus API key into an issue or pull request.

## Development setup

```r
install.packages(c("devtools", "testthat", "knitr", "rmarkdown"))
devtools::load_all()
devtools::test()
devtools::check()
```

Put `SCOPUS_API_KEY` in `~/.Renviron` for live retrieval tests. Default unit tests are written to run offline.

## Pull requests

1. Fork the repository and create a topic branch from `main`.
2. Add or update tests under `tests/testthat/` for behavioral changes.
3. Run `devtools::check()` and keep CRAN-style warnings at zero when possible.
4. Use roxygen2 comments for exported functions, then `devtools::document()`.
5. Open a pull request describing the motivation and the user-facing change.

Feature work that reimplements `tidytext`, `topicmodels`, or `stm` is out of scope; extend the orchestration layer instead.

## Support expectations

Issues and pull requests are reviewed by the authors as time permits. There is no paid support channel. Security-sensitive reports (leaked keys in examples) should be emailed to praveenmaths89@gmail.com rather than posted publicly.
