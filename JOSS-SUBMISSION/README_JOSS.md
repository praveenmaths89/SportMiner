# SportMiner: JOSS Submission Package

## Overview

SportMiner is an R package providing a workflow engine for large-scale literature mining and analysis. This submission package is prepared for review by the Journal of Open Source Software (JOSS).

## Software Status

- **CRAN Status**: Accepted and published on CRAN
- **License**: MIT
- **Repository**: https://github.com/praveenmaths89/SportMiner
- **Documentation**: Available via CRAN and GitHub

## Domain Scope

**Important Clarification**: Although the package name and CRAN description reference sport science, this reflects the original motivating use case rather than a technical limitation.

- **Original motivation**: Sport science literature reviews
- **Implementation**: Domain-agnostic workflow design
- **Technical scope**: The software operates on standard bibliographic data structures and contains no hard-coded domain-specific assumptions
- **Applicability**: Any research field requiring systematic literature mining and topic modeling

The workflow components (API retrieval, text preprocessing, topic modeling, network analysis, visualization) are configurable and can be applied to literature from any discipline.

## Key Features

- Automated literature retrieval via Scopus API
- Text preprocessing and normalization utilities
- Topic modeling using Latent Dirichlet Allocation
- Co-authorship and citation network analysis
- Publication-ready visualization generation
- Reproducible pipeline configuration

## Installation

```r
install.packages("SportMiner")
```

## Repository Structure

- `SportMiner/`: Main R package source code
- `JOSS-SUBMISSION/`: Files specific to JOSS submission
  - `paper.md`: JOSS paper manuscript
  - `paper.bib`: Bibliography
  - `CITATION.cff`: Citation metadata
  - `AI_USAGE.md`: AI usage disclosure
  - `joss-submission.md`: Submission checklist

## Authors

1. Praveen D. Chougale
   - Koita Centre for Digital Health
   - Indian Institute of Technology Bombay, Mumbai, Maharashtra, India
   - Email: praveenmaths89@gmail.com
   - GitHub: @praveenmaths89

2. Usha Ananthakumar
   - Shailesh J. Mehta School of Management
   - Indian Institute of Technology Bombay, Mumbai, Maharashtra, India
   - Email: usha@som.iitb.ac.in
