# JOSS Submission Guide

## Submission Package Contents

This directory contains all files required for submitting SportMiner to the Journal of Open Source Software (JOSS).

### Files Included

1. **paper.md** - Main JOSS paper manuscript (required)
2. **paper.bib** - Bibliography in BibTeX format (required)
3. **CITATION.cff** - Machine-readable citation metadata (recommended)
4. **README_JOSS.md** - Reviewer-focused README
5. **AI_USAGE.md** - AI usage disclosure
6. **joss-submission.md** - Submission checklist
7. **SUBMISSION-GUIDE.md** - This file

## Submission Steps

### Step 1: Pre-Submission Verification

```r
# Run from R console
setwd("SportMiner")
devtools::check()
```

Ensure all checks pass without errors or warnings.

### Step 2: Create Version Tag

```bash
git tag -a v1.0.0-joss -m "JOSS submission version"
git push origin v1.0.0-joss
```

### Step 3: Update ORCID (if available)

Edit `paper.md` and replace `0000-0000-0000-0000` with your actual ORCID identifier.

### Step 4: Submit to JOSS

1. Visit: https://joss.theoj.org/papers/new
2. Provide repository URL: https://github.com/praveenmaths89/SportMiner
3. Provide version tag: v1.0.0-joss
4. Complete submission form
5. Wait for editorial review

## Key Points for Reviewers

- SportMiner is already published on CRAN
- The software provides workflow infrastructure, not novel algorithms
- Sport science is the motivating domain, not a technical limitation
- The implementation is domain-agnostic and configurable
- All JOSS requirements are met

## Contact

Praveen D. Chougale (praveenmaths89@gmail.com)
Koita Centre for Digital Health
Indian Institute of Technology Bombay, Mumbai, Maharashtra, India
GitHub: @praveenmaths89

Usha Ananthakumar (usha@som.iitb.ac.in)
Shailesh J. Mehta School of Management
Indian Institute of Technology Bombay, Mumbai, Maharashtra, India

## License

MIT License
