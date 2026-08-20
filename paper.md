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
date: 20 August 2026
bibliography: paper.bib
---

# Summary

SportMiner is an R package that turns a common research task — reading a large body of published papers and summarizing what that literature is about — into a repeatable software workflow. Researchers in many fields now face more papers than they can read. Topic models and bibliographic networks can help, but assembling them typically means stitching together an API client, a text-cleaning pipeline, several modeling packages, and a plotting stack. SportMiner provides that assembly as one documented package: retrieve records from Scopus, clean abstracts, compare topic models, draw keyword networks, and produce publication-ready figures.

The software was first written to support literature reviews in sport science, but the implementation does not hard-code sport-specific vocabularies or ontologies. Queries, stop-word lists, and model choices are parameters. The same pipeline can be pointed at any Scopus-indexed research area. The design goal is not a new topic-modeling algorithm. It is a maintainable, CRAN-distributed workflow that domain researchers can run, cite, and modify without rebuilding the surrounding infrastructure.

# Statement of need

Systematic reviews and bibliometric maps are now routine in evidence-based research, yet the computational path from a search string to a defensible thematic summary remains fragmented. A typical analysis uses a bibliographic API, a tidy text pipeline, a topic model, and a network layout. Each step is well served by existing R packages; the research bottleneck is integrating those steps so that the same choices can be replayed months later, shared with co-authors, and inspected by reviewers.

SportMiner is written for researchers who need that integration more than they need a new estimator. The target audience includes sport scientists, information scientists, and graduate students who want a scripted literature-mining workflow rather than a graphical point-and-click tool. The package provides: (1) Scopus retrieval with environment-variable API-key handling and pagination; (2) tokenization, stop-word removal, and stemming into a document-term matrix; (3) Latent Dirichlet Allocation (LDA), Structural Topic Models (STM), and Correlated Topic Models (CTM) behind one comparison interface [@Blei2003; @Roberts2019; @Grun2011]; (4) keyword co-occurrence networks; and (5) a colorblind-friendly ggplot2 theme for topic-term, frequency, and trend plots [@Wickham2016].

The scholarly contribution is a reusable orchestration layer with tested defaults, not a replacement for the underlying algorithms. SportMiner is on CRAN, includes a getting-started vignette, and ships unit tests that run without a live Scopus key so that installation and core transforms can be checked offline.

# State of the field

Several mature R tools already address pieces of this problem. `bibliometrix` provides a comprehensive science-mapping environment, including coupling, collaboration, and conceptual-structure analyses, with a companion Shiny application [@Aria2017]. `quanteda` is a high-performance framework for corpus construction and quantitative text analysis [@Benoit2018]. `tidytext` makes text mining idiomatic in the tidyverse [@Silge2016]. `topicmodels` and `stm` implement the topic models that SportMiner calls [@Grun2011; @Roberts2019]. `rscopus` exposes the Scopus API that SportMiner uses for retrieval. `litsearchr` automates search-term discovery for systematic reviews using keyword co-occurrence [@Grames2019].

The honest “build versus contribute” question is therefore why not extend `bibliometrix` or write a vignette on top of `tidytext` plus `topicmodels`. Those packages remain the right choice for users who want a full science-mapping GUI, a general NLP toolkit, or direct control of a single model class. SportMiner exists because those strengths do not yield a small, installable pipeline that (a) starts from a Scopus query, (b) compares LDA, STM, and CTM on the same document-term matrix using coherence and exclusivity, (c) emits a consistent ggplot2 grammar for topic diagnostics, and (d) remains usable by researchers who will not assemble that stack themselves. Contributing a Scopus-to-STM helper into `bibliometrix` would bury a narrow workflow inside a much larger product and would not give CRAN users a focused citation target for this specific analysis pattern. SportMiner therefore wraps, rather than reimplements, `rscopus`, `tidytext`, `topicmodels`, and `stm`, and keeps the original algorithms as the computational core.

# Software design

The architecture is a linear data pipeline with stable intermediate objects rather than a single monolithic function. Retrieval (`sm_search_scopus`) returns a table of bibliographic records. Preprocessing (`sm_preprocess_text`, `sm_create_dtm`) converts abstracts into a sparse document-term matrix, using rlang’s `.data` pronoun so that CRAN checks do not flag tidy-evaluation columns as global variables. Modeling (`sm_select_optimal_k`, `sm_train_lda`, `sm_compare_models`) treats LDA, STM, and CTM as interchangeable backends behind shared inputs and a small metric table. Visualization and networks consume those objects and apply `theme_sportminer()`.

Three trade-offs shaped this design. First, Scopus is a paid, rate-limited API. Keys are read from the environment, calls are wrapped in `tryCatch()`, and tests mock responses so CRAN and continuous integration never hit the network. The cost is that users without Scopus access cannot run the retrieval step; preprocessing and modeling still work on any similarly structured table, which keeps the rest of the package usable. Second, exposing three topic-model families increases dependency weight. The alternative — shipping only LDA — would hide the fact that STM often fits labeled bibliographic metadata better. SportMiner therefore depends on both `topicmodels` and `stm` and reports a simple combined score so users can choose a model without writing their own comparison script. Third, a custom theme is a presentational choice, not an analytical one. It exists so that figures produced in a methods appendix share one visual contract; users can still restyle with ordinary ggplot2 layers.

The package is organized as ordinary R modules (`R/api.R`, `R/preprocess.R`, `R/topic_modeling.R`, `R/model_comparison.R`, `R/visualization.R`, `R/network.R`, `R/theme.R`) rather than an object-oriented framework. That keeps the learning path close to typical tidyverse scripts and makes review and extension a matter of reading functions, not a class hierarchy.

# Research impact statement

SportMiner has been on CRAN since January 2026 as version 0.1.0, which is the distribution channel used by the authors’ own literature-mining work in sport science and digital health. The package is the scripted backbone for synthesizing large Scopus result sets into topic maps and keyword networks, replacing ad hoc scripts that mixed retrieval, cleaning, and plotting. Reproducible materials shipped with the software include a getting-started vignette, function-level documentation, and an offline test suite covering preprocessing, model helpers, networks, and the plotting theme.

Community-readiness signals that JOSS can inspect today are therefore: a public GitHub repository with an OSI-approved MIT license, CRAN installation via `install.packages("SportMiner")`, a changelog (`NEWS.md`), and tests that do not require credentials. Near-term scholarly use is the authors’ ongoing systematic mapping of sport-science and athlete-monitoring literature; those analyses depend on the same retrieve–clean–model–plot path documented in the vignette. External citation by other groups is still emerging, as expected for a package of this age, and is not claimed here as a completed outcome.

# AI usage disclosure

Generative AI tools (GitHub Copilot and Claude) were used to draft documentation phrasing, test scaffolding, and JOSS manuscript structure. Model versions varied across the development period in 2025–2026. No topic-modeling mathematics, Scopus query logic, or metric definitions were accepted from AI output without human rewriting. The authors reviewed, edited, and executed the package code, tests, and paper text; they made the pipeline design decisions (modular functions, multi-model comparison, environment-based keys, CRAN-oriented error handling) and remain responsible for correctness.

# Acknowledgements

The authors thank the developers of `rscopus`, `tidytext`, `topicmodels`, `stm`, and `ggplot2`, whose packages SportMiner orchestrates. No specific grant number is reported for this software; the work was undertaken as part of research activity at the Indian Institute of Technology Bombay.

# References
