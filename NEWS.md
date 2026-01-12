# SportMiner 0.1.0

## Initial CRAN Release

### New Features

* **API Functions**
  - `sm_set_api_key()`: Secure API key management via environment variables
  - `sm_search_scopus()`: Retrieve papers from Scopus with automatic pagination
  - `sm_get_indexed_keywords()`: Extract indexed keywords for individual papers

* **Text Processing**
  - `sm_preprocess_text()`: Tokenize, remove stopwords, and stem abstracts
  - `sm_create_dtm()`: Generate document-term matrices with flexible filtering

* **Topic Modeling**
  - `sm_select_optimal_k()`: Coherence-based selection of topic count
  - `sm_train_lda()`: Train Latent Dirichlet Allocation models
  - `sm_compare_models()`: Multi-model comparison (LDA, STM, CTM) with metrics

* **Visualizations**
  - `sm_plot_topic_terms()`: Bar charts of top terms per topic
  - `sm_plot_topic_frequency()`: Document distribution across topics
  - `sm_plot_topic_trends()`: Stacked percentage charts showing temporal trends
  - `theme_sportminer()`: Custom colorblind-friendly ggplot2 theme

* **Network Analysis**
  - `sm_keyword_network()`: Co-occurrence network visualization

### CRAN Compliance

* All API calls wrapped in `tryCatch()` for graceful error handling
* Global variables properly declared using `.data` pronoun from rlang
* Message/warning functions used instead of `cat()` or `print()`
* Comprehensive test suite with offline-safe mocks via httptest
* Zero errors, warnings, or notes in `R CMD check --as-cran`

### Documentation

* Complete roxygen2 documentation for all exported functions
* "Getting Started" vignette with end-to-end workflow example
* README with quick start guide and advanced usage examples

### Testing

* 30+ unit tests covering all major functions
* Edge case handling (empty data, missing columns, invalid parameters)
* Mock API responses for offline testing
* Tests marked with `skip_on_cran()` for computationally expensive operations

---

**Note**: This is the initial release. Future versions will include additional topic modeling algorithms, enhanced network analysis features, and extended visualization options.
