# SportMiner - Final Pre-Submission Checklist

## ✅ Package Metadata (COMPLETE)

- [x] **Authors**: Praveen D Chougale & Usha Ananthakumar
- [x] **Maintainer**: Praveen D Chougale (praveenmaths89@gmail.com)
- [x] **Co-author**: Usha Ananthakumar (usha@som.iitb.ac.in)
- [x] **License**: MIT © 2026
- [x] **Version**: 0.1.0

## 📋 Pre-Submission Tasks

### 1. Generate Documentation

```r
setwd("SportMiner")
devtools::document()
```

This will:
- Generate `.Rd` files in `man/` folder
- Update `NAMESPACE` with proper exports

### 2. Build Vignettes

```r
devtools::build_vignettes()
```

### 3. Run Tests

```r
devtools::load_all()
devtools::test()
```

Expected: All tests pass

### 4. Run The Final Check

```r
devtools::check(remote = TRUE, manual = TRUE)
```

**Target**: 0 Errors, 0 Warnings, 0 Notes

### 5. Platform-Specific Checks

```r
# Windows (win-builder)
devtools::check_win_devel()
devtools::check_win_release()

# Multiple platforms (R-hub)
rhub::check_for_cran()
```

### 6. Spell Check

```r
devtools::spell_check()
```

Fix any typos found in documentation.

## 📦 Build Package

```r
devtools::build()
```

This creates: `SportMiner_0.1.0.tar.gz`

## 🚀 CRAN Submission

### When to Submit

**CRAN reopens**: January 8, 2026

### How to Submit

**Option A: Via devtools**
```r
devtools::submit_cran()
```

**Option B: Web form**
1. Go to: https://cran.r-project.org/submit.html
2. Upload `SportMiner_0.1.0.tar.gz`
3. Fill submission form (see template below)

### Submission Form Template

```
This is the initial submission of the SportMiner package.

SportMiner provides tools for mining, analyzing, and visualizing scientific
literature in sport science domains. It includes functions for Scopus data
retrieval, text preprocessing, topic modeling (LDA, STM, CTM), and
publication-ready visualizations.

Test environments:
- Local: R 4.3.0 on [your OS]
- win-builder: R-devel and R-release
- R-hub: ubuntu-latest, windows-latest, macos-latest

R CMD check results:
0 errors | 0 warnings | 0 notes

Notes:
- All examples requiring API authentication are wrapped in \dontrun{}
- Tests use httptest for offline safety (no actual API calls during checks)
- Computationally expensive tests marked with skip_on_cran()

Maintainer: Praveen D Chougale <praveenmaths89@gmail.com>
```

## 📧 Maintainer Responsibilities

As the package maintainer, Praveen D Chougale will:

1. Monitor **praveenmaths89@gmail.com** for CRAN correspondence
2. Respond to CRAN feedback within 2 weeks
3. Fix bugs reported by users promptly
4. Submit updates as needed

## 🔍 Common CRAN Feedback

Be prepared to address:

1. **Examples taking too long**
   - Solution: Already wrapped in `\dontrun{}`

2. **Tests requiring internet**
   - Solution: Already using httptest mocks

3. **Undeclared imports**
   - Solution: All imports declared with `@importFrom`

4. **Author email bouncing**
   - Ensure praveenmaths89@gmail.com is accessible

## 📊 Package Statistics

- **8 source files** (1,369 lines)
- **13 exported functions**
- **30+ unit tests** (315 lines)
- **6 test suites** with offline mocks
- **1 comprehensive vignette**
- **16 package dependencies**

## 🎯 Success Criteria

Your package is ready when:

✅ `devtools::check()` passes with 0/0/0
✅ All platform checks pass
✅ Documentation renders correctly
✅ Vignette builds without errors
✅ Email addresses are valid and monitored
✅ LICENSE file is correct

## 📞 Support Channels

After CRAN acceptance, users can get help via:

- Package vignette: `vignette("getting-started", package = "SportMiner")`
- GitHub issues: https://github.com/yourusername/SportMiner/issues
- Email: praveenmaths89@gmail.com

## 🎉 After Acceptance

When SportMiner is accepted to CRAN:

1. Update README badges with CRAN status
2. Announce on social media / institutional channels
3. Monitor GitHub issues for user feedback
4. Plan version 0.2.0 enhancements

---

**Package**: SportMiner v0.1.0
**Maintainer**: Praveen D Chougale (praveenmaths89@gmail.com)
**Co-author**: Usha Ananthakumar (usha@som.iitb.ac.in)
**Status**: Ready for CRAN submission (pending documentation generation & checks)
**Submission Window**: Opens January 8, 2026
