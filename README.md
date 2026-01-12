# SportMiner

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/SportMiner)](https://CRAN.R-project.org/package=SportMiner)
<!-- badges: end -->

## Overview

**SportMiner** is a comprehensive toolkit for mining, analyzing, and visualizing scientific literature in sport science domains. It provides an end-to-end workflow from data retrieval to publication-ready visualizations.

### Key Features

- **🔍 Data Retrieval**: Seamlessly search and download abstracts from Scopus
- **📝 Text Processing**: Advanced preprocessing with stemming and stopword removal
- **🎯 Topic Modeling**: Multiple algorithms (LDA, STM, CTM) with automated model selection
- **📊 Visualizations**: Publication-ready plots with a custom colorblind-friendly theme
- **🕸️ Network Analysis**: Keyword co-occurrence networks to reveal research connections
- **✅ CRAN Compliant**: Rigorous testing, proper API key handling, and offline-safe tests

## Installation

```r
# From CRAN
install.packages("SportMiner")

# Development version from GitHub
devtools::install_github("praveenmaths89/SportMiner", subdir = "SportMiner")
```

## Quick Start

```r
library(SportMiner)

# 1. Set your Scopus API key
sm_set_api_key("your_key_here")

# 2. Search for papers
papers <- sm_search_scopus(
  query = 'TITLE-ABS-KEY("sport science" AND "machine learning")',
  max_count = 100
)

# 3. Preprocess text
processed <- sm_preprocess_text(papers)

# 4. Create document-term matrix
dtm <- sm_create_dtm(processed)

# 5. Find optimal number of topics
k_selection <- sm_select_optimal_k(dtm, k_range = seq(5, 20, by = 5))

# 6. Train topic model
lda_model <- sm_train_lda(dtm, k = k_selection$optimal_k)

# 7. Visualize results
sm_plot_topic_terms(lda_model, n_terms = 10)
sm_plot_topic_frequency(lda_model, dtm)

# 8. Create keyword network
sm_keyword_network(papers, min_cooccurrence = 2)
```

## Advanced Usage

### Compare Multiple Models

```r
# Compare LDA, STM, and CTM
comparison <- sm_compare_models(dtm, k = 10)

# View metrics
print(comparison$metrics)
#>   model coherence exclusivity combined_score
#> 1   LDA     0.542       0.678          0.321
#> 2   STM     0.589       0.712          0.854
#> 3   CTM     0.521       0.645         -0.175

# Recommendation
print(comparison$recommendation)
#> [1] "STM"
```

### Topic Trends Over Time

```r
papers$doc_id <- paste0("doc_", seq_len(nrow(papers)))

sm_plot_topic_trends(
  model = lda_model,
  dtm = dtm,
  metadata = papers,
  year_filter = 2015:2025
)
```

### Custom Visualizations

```r
library(ggplot2)

# All plots use theme_sportminer() by default
p <- sm_plot_topic_frequency(lda_model, dtm)

# Customize further
p + labs(
  title = "Your Custom Title",
  subtitle = "Based on N papers"
) + theme_sportminer(base_size = 14, grid = FALSE)
```

## Getting Your Scopus API Key

1. Visit [Elsevier Developer Portal](https://dev.elsevier.com/)
2. Create an account or log in
3. Navigate to "API Keys" and create a new key
4. Add to your `.Renviron` file:

```r
usethis::edit_r_environ()
# Add this line:
# SCOPUS_API_KEY=your_key_here
```

## Documentation

See the package vignette for detailed usage:

```r
vignette("getting-started", package = "SportMiner")
```

## Design Philosophy

### CRAN Compliance

SportMiner adheres to strict CRAN standards:

- **No hardcoded keys**: API keys via environment variables
- **Graceful failures**: All API calls wrapped in `tryCatch()`
- **Proper messaging**: Uses `message()` and `warning()`, not `cat()` or `print()`
- **Global variables**: Uses `.data` pronoun from rlang to avoid R CMD check NOTEs
- **Offline tests**: Mock API responses via httptest for CRAN checks

### Visualization Standards

All plots use `theme_sportminer()`, which provides:

- Clean, minimalist aesthetic
- Colorblind-friendly palettes
- Publication-ready fonts and spacing
- Consistent styling across all functions

## Bug Reports

For bug reports and feature requests, please contact the package maintainer.

## Citation

If you use SportMiner in your research, please cite:

```r
citation("SportMiner")
```

## Related Packages

- **rscopus**: Scopus API client (used by SportMiner)
- **topicmodels**: LDA and CTM algorithms
- **stm**: Structural Topic Models
- **tidytext**: Text mining framework

## License

MIT © 2026 Praveen D Chougale and Usha Ananthakumar

## Acknowledgments

This package builds on the excellent work of:

- The rscopus team for Scopus API access
- The topicmodels and stm developers for topic modeling algorithms
- The tidytext team for text mining infrastructure
