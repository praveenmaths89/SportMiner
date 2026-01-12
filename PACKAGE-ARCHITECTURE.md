# SportMiner Package Architecture

## Overview

SportMiner is a modular, CRAN-compliant R package for mining and analyzing sport science literature. This document explains the package structure and design decisions.

## Directory Structure

```
SportMiner/
├── R/                          # Source code (modular organization)
│   ├── api.R                   # API key management & Scopus search
│   ├── preprocess.R            # Text preprocessing & DTM creation
│   ├── topic_modeling.R        # LDA training & k selection
│   ├── model_comparison.R      # Multi-model comparison (LDA/STM/CTM)
│   ├── visualization.R         # Plotting functions
│   ├── network.R               # Keyword co-occurrence networks
│   ├── theme.R                 # Custom ggplot2 theme
│   └── utils.R                 # Package documentation & globals
├── man/                        # Auto-generated documentation (via roxygen2)
├── tests/                      # Test suite
│   ├── testthat.R
│   └── testthat/
│       ├── test-api.R
│       ├── test-preprocess.R
│       ├── test-topic_modeling.R
│       ├── test-visualization.R
│       ├── test-network.R
│       └── test-theme.R
├── vignettes/                  # Long-form documentation
│   └── getting-started.Rmd
├── data-raw/                   # Example scripts (not exported)
│   └── example-workflow.R
├── inst/                       # Installed files
│   └── CITATION
├── DESCRIPTION                 # Package metadata
├── NAMESPACE                   # Exported functions & imports
├── LICENSE                     # License details
├── README.md                   # GitHub landing page
├── NEWS.md                     # Version changelog
├── .Rbuildignore              # Files to exclude from build
└── .gitignore                 # Git exclusions
```

## Module Breakdown

### 1. API Module (`R/api.R`)

**Purpose**: Secure Scopus API interaction

**Functions**:
- `sm_set_api_key()`: Environment variable-based key management
- `sm_search_scopus()`: Paginated paper retrieval with error handling
- `sm_get_indexed_keywords()`: Extract indexed keywords per paper

**CRAN Compliance**:
- No hardcoded API keys
- All API calls wrapped in `tryCatch()`
- Uses `message()` instead of `cat()` or `print()`

### 2. Preprocessing Module (`R/preprocess.R`)

**Purpose**: Transform raw text into analysis-ready format

**Functions**:
- `sm_preprocess_text()`: Tokenize, remove stopwords, stem
- `sm_create_dtm()`: Generate sparse document-term matrices

**Key Features**:
- Uses `.data` pronoun from rlang to avoid global variable NOTEs
- Flexible filtering (min/max term frequency)
- Automatic empty document removal

### 3. Topic Modeling Module (`R/topic_modeling.R`)

**Purpose**: Core LDA functionality

**Functions**:
- `sm_select_optimal_k()`: Coherence-based k selection
- `sm_train_lda()`: Train LDA models with customizable hyperparameters

**Algorithm**:
- Tests multiple k values
- Calculates topic coherence (via `textmineR`)
- Returns optimal k + diagnostic plot

### 4. Model Comparison Module (`R/model_comparison.R`)

**Purpose**: Advanced multi-algorithm benchmarking

**Functions**:
- `sm_compare_models()`: Compare LDA, STM, and CTM
- `calculate_exclusivity()`: Internal metric calculation
- `convert_dtm_to_stm()`: Format conversion helper

**Metrics**:
- **Coherence**: Semantic relatedness of top words
- **Exclusivity**: Uniqueness of words to topics
- **Combined Score**: Standardized weighted average

**Output**: Automatic model recommendation

### 5. Visualization Module (`R/visualization.R`)

**Purpose**: Publication-ready plots

**Functions**:
- `sm_plot_topic_terms()`: Top terms bar chart
- `sm_plot_topic_frequency()`: Document distribution
- `sm_plot_topic_trends()`: Temporal trends (stacked %)

**Design**:
- All plots use `theme_sportminer()`
- Faceted displays for multi-topic comparisons
- Helper functions for term reordering

### 6. Network Module (`R/network.R`)

**Purpose**: Keyword co-occurrence analysis

**Functions**:
- `sm_keyword_network()`: Create and visualize networks

**Algorithm**:
1. Extract keywords from papers
2. Calculate pairwise co-occurrences (`widyr`)
3. Build graph (`igraph`)
4. Visualize with `ggraph`

**Parameters**:
- `min_cooccurrence`: Filter weak connections
- `top_n`: Limit to most frequent keywords
- `layout`: Network layout algorithm

### 7. Theme Module (`R/theme.R`)

**Purpose**: Consistent, professional styling

**Function**:
- `theme_sportminer()`: Custom ggplot2 theme

**Features**:
- Colorblind-friendly palette
- Clean, minimalist aesthetic
- Customizable base size and grid

### 8. Utils Module (`R/utils.R`)

**Purpose**: Package-level configuration

**Content**:
- Package documentation (`@docType package`)
- Global variable declarations via `utils::globalVariables()`
- Imports `.data` pronoun from rlang

## Data Flow

```
User Query
    ↓
sm_search_scopus() → Raw Papers (data.frame)
    ↓
sm_preprocess_text() → Word Counts (doc_id, stem, n)
    ↓
sm_create_dtm() → Document-Term Matrix (sparse)
    ↓
    ├─→ sm_select_optimal_k() → Optimal k (coherence-based)
    │       ↓
    └─→ sm_train_lda() → LDA Model
            ↓
            ├─→ sm_plot_topic_terms()
            ├─→ sm_plot_topic_frequency()
            └─→ sm_plot_topic_trends()

Alternative: sm_compare_models() → Multi-model comparison
Alternative: sm_keyword_network() → Co-occurrence network
```

## Testing Strategy

### Test Coverage

| Module          | Tests | Coverage Focus                          |
|-----------------|-------|-----------------------------------------|
| API             | 5     | Key validation, query errors, limits    |
| Preprocess      | 4     | NA handling, column validation, DTM     |
| Topic Modeling  | 4     | k validation, model output, coherence   |
| Visualization   | 3     | Plot generation, metadata requirements  |
| Network         | 3     | Input validation, network creation      |
| Theme           | 3     | Theme object structure                  |

### CRAN-Safe Testing

- **httptest**: Mock API responses for offline checks
- **skip_on_cran()**: Skip slow tests during CRAN checks
- **Deterministic**: All tests use fixed seeds

## Design Principles

### 1. Modularity

Each file follows the Single Responsibility Principle:
- API functions → `api.R`
- Preprocessing → `preprocess.R`
- Modeling → `topic_modeling.R`

### 2. User-Friendly Defaults

All functions have sensible defaults:
- `max_count = 200` (manageable dataset size)
- `min_term_freq = 3` (removes rare terms)
- `method = "gibbs"` (better quality than VEM)

### 3. Graceful Degradation

Functions fail gracefully with informative messages:
- Missing API key → Clear instructions
- Empty data → Warning + empty return
- API errors → Wrapped in `tryCatch()`

### 4. Pipe-Friendly

All functions are designed for `%>%` workflows:
- First argument is always data/model
- Return values are standard classes (data.frame, ggplot, etc.)

### 5. CRAN Standards

- **No global variables**: Uses `.data` pronoun
- **No side effects**: Except `sm_set_api_key()`
- **No filesystem writes**: Except user-initiated saves
- **Fast examples**: All wrapped in `\dontrun{}`

## Dependencies

### Required Imports

| Package      | Purpose                                    |
|--------------|--------------------------------------------|
| rscopus      | Scopus API client                          |
| dplyr        | Data manipulation                          |
| tidytext     | Text mining (unnest_tokens, cast_dtm)     |
| topicmodels  | LDA and CTM algorithms                     |
| stm          | Structural Topic Models                    |
| ggplot2      | Visualization                              |
| rlang        | `.data` pronoun for tidy evaluation        |
| tm           | Document-term matrix infrastructure        |
| SnowballC    | Porter stemming algorithm                  |
| scales       | Plot scale formatting                      |
| textmineR    | Topic coherence calculation                |
| Matrix       | Sparse matrix operations                   |
| ggraph       | Network visualization                      |
| igraph       | Graph construction                         |
| widyr        | Pairwise operations                        |

### Suggested Packages

| Package  | Purpose                   |
|----------|---------------------------|
| httptest | Mock API responses        |
| testthat | Unit testing framework    |
| knitr    | Vignette rendering        |
| rmarkdown| Documentation formatting  |

## Version Control

### Semantic Versioning

SportMiner follows [semver](https://semver.org/):

- **MAJOR**: Breaking API changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Current: `0.1.0` (initial CRAN release)

## Contributing

### Code Style

- Use `snake_case` for functions and variables
- Limit lines to 80 characters where possible
- Add roxygen2 documentation for all exported functions

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run `devtools::check()` (must pass)
5. Update NEWS.md
6. Submit PR with clear description

## Future Roadmap

### Version 0.2.0 (Planned)

- [ ] Add BERTopic integration
- [ ] Support for multiple languages
- [ ] Interactive network plots (plotly/visNetwork)
- [ ] Batch keyword extraction

### Version 0.3.0 (Planned)

- [ ] Longitudinal topic modeling
- [ ] Topic model diagnostics dashboard
- [ ] Export to LaTeX tables

## Contact

- **Issues**: [GitHub Issues](https://github.com/yourusername/SportMiner/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/SportMiner/discussions)
- **Email**: maintainer@email.com

---

**Last Updated**: January 2026
**Version**: 0.1.0
**Status**: Ready for CRAN submission
