---
title: 'SportMiner: A Domain-Agnostic Workflow Engine for Large-Scale Literature Mining'
tags:
  - R
  - text mining
  - literature mining
  - topic modeling
  - reproducible research
  - bibliometrics
authors:
  - name: Praveen D. Chougale
    orcid: 0000-0002-5262-4726
    affiliation: 1
  - name: Usha Ananthakumar
    orcid: 0000-0003-1983-2168
    affiliation: 2
affiliations:
  - name: Koita Centre for Digital Health, Indian Institute of Technology Bombay, Mumbai, Maharashtra, India
    index: 1
  - name: Shailesh J. Mehta School of Management, Indian Institute of Technology Bombay, Mumbai, Maharashtra, India
    index: 2
date: 19 January 2025
bibliography: paper.bib
---

# Summary

SportMiner is an R package that provides a workflow engine for large-scale literature mining and analysis. The package orchestrates existing text-mining and bibliographic tools into reproducible, configurable pipelines for systematic literature review and bibliometric analysis. Although initially developed to support sport science literature reviews, the software is implemented in a domain-agnostic manner and can be applied to literature mining workflows in any research field. SportMiner emphasizes reproducibility, scalability, and ease of configuration, making systematic literature analysis accessible to researchers without extensive programming expertise.

# Statement of Need

Systematic literature reviews and bibliometric analyses are fundamental to evidence-based research across disciplines. However, conducting such reviews at scale requires integrating multiple tools for data retrieval, preprocessing, topic modeling, network analysis, and visualization. Researchers often face challenges in creating reproducible workflows that combine these disparate tools effectively.

SportMiner addresses this gap by providing a unified workflow engine that:

- Integrates with the Scopus API for automated literature retrieval
- Provides preprocessing utilities for text normalization and cleaning
- Implements topic modeling workflows using Latent Dirichlet Allocation (LDA) via the `topicmodels` package [@Grun2011]
- Supports co-authorship and citation network analysis
- Generates publication-ready visualizations using `ggplot2` [@Wickham2016]
- Ensures reproducibility through structured data pipelines and configuration

The package builds upon established R packages for text mining [@Silge2016], network analysis, and visualization, providing a higher-level interface that reduces the implementation burden for domain researchers. Although the package was originally motivated by literature reviews in sport science, no domain-specific assumptions are hard-coded into the implementation. The workflow components operate on standard bibliographic data structures and can be configured for any research domain through parameter specification.

SportMiner is available on CRAN and has been designed following best practices for R package development, including comprehensive documentation, unit tests, and vignettes demonstrating typical usage patterns.

## Software Design
`SportMiner` is implemented as an R package utilizing a modular functional programming approach. The core architecture follows a sequential data engineering pipeline:
1. **Data Acquisition**: Functions like `sm_search_scopus` interface with external APIs.
2. **Text Processing**: Standardized cleaning via `sm_preprocess_text`.
3. **Analytical Engine**: A unified interface for LDA, STM, and CTM models.
4. **Visualization**: A custom `ggplot2`-based theme for domain-specific reporting.

## Research Impact
This software addresses the "information overload" in sports medicine by allowing researchers to synthesize thousands of publications into digestible thematic maps. It lowers the barrier for sports scientists to perform bibliometric "state of the field" reviews, shifting the focus from manual searching to high-level trend analysis.

# AI Usage Disclosure

AI-assisted tools were used during the development of documentation and testing code for this package. All AI-generated content was carefully reviewed, validated, and modified by the author to ensure correctness and compliance with software engineering best practices. The core algorithmic implementation and workflow design represent original work by the authors.

# References
