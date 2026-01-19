# JOSS Submission Checklist

## Repository Information

- **Repository URL**: https://github.com/praveenmaths89/SportMiner
- **Version Tag**: v1.0.0-joss (to be created before submission)
- **License**: MIT
- **Programming Language**: R

## Software Status

- [x] Software is published on CRAN
- [x] Software has an OSI-approved open source license
- [x] Software repository is publicly accessible
- [x] Software has a README with installation instructions
- [x] Software has documentation (vignettes and function documentation)
- [x] Software includes unit tests

## JOSS Submission Requirements

### Required Files

- [x] `paper.md` - JOSS-compliant paper manuscript
- [x] `paper.bib` - Bibliography in BibTeX format
- [x] `CITATION.cff` - Machine-readable citation metadata
- [x] `README_JOSS.md` - README for JOSS reviewers
- [x] `AI_USAGE.md` - AI usage disclosure

### Paper Content

- [x] Summary section
- [x] Statement of need
- [x] AI usage disclosure
- [x] References section
- [x] Proper YAML header with metadata

### Compliance Checklist

- [x] Software is under active development or maintenance
- [x] Software has a clear statement of need
- [x] Software includes installation instructions
- [x] Software includes usage examples
- [x] Software is appropriately documented
- [x] Software includes automated tests
- [x] Software follows community standards for the language
- [x] Paper does not describe new methods or results
- [x] Paper focuses on software functionality and design
- [x] All authors (Praveen D. Chougale and Usha Ananthakumar) have reviewed and approved the submission

## Domain Scope Clarification

The submission explicitly clarifies that:
- Sport science was the original motivating domain
- The implementation is domain-agnostic
- No domain-specific assumptions are hard-coded
- The software can be applied to any research field via configuration

## Pre-Submission Actions

Before submitting to JOSS, complete the following:

1. Create a version tag (e.g., `v1.0.0-joss`) in the GitHub repository
2. Ensure all tests pass: `R CMD check SportMiner`
3. Verify CRAN package is up-to-date
4. Update ORCID identifier in `paper.md` if available
5. Review all submission files for completeness
6. Prepare GitHub repository URL for submission form

## Submission URL

https://joss.theoj.org/papers/new

## Notes for Reviewers

This software represents research infrastructure for reproducible literature mining workflows. The contribution is a workflow engine that orchestrates existing tools, not a novel algorithm or methodology. The package has been accepted on CRAN and follows R package development best practices.
