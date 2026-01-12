# CRAN Submission Checklist for SportMiner

This document provides a step-by-step guide to prepare SportMiner for CRAN submission.

## Pre-Submission Requirements

### 1. Update Package Metadata

- [ ] Update `DESCRIPTION` file with your name, email, and affiliation
- [ ] Verify all package dependencies are correct and minimal
- [ ] Ensure version number follows semantic versioning (currently 0.1.0)
- [ ] Add maintainer email (the `cre` role in Authors@R)

### 2. Documentation

- [ ] Run `devtools::document()` to regenerate all `.Rd` files
- [ ] Check that all exported functions have complete documentation
- [ ] Ensure all examples run without errors (or are wrapped in `\dontrun{}`)
- [ ] Build vignettes: `devtools::build_vignettes()`
- [ ] Update `NEWS.md` with all changes

### 3. Testing

Run comprehensive checks:

```r
# Local check
devtools::check()

# Check with CRAN settings
devtools::check(remote = TRUE, manual = TRUE)

# Check on R-hub (multiple platforms)
rhub::check_for_cran()

# Check on win-builder
devtools::check_win_devel()
devtools::check_win_release()
```

**Target**: 0 Errors, 0 Warnings, 0 Notes

### 4. Common CRAN Notes to Fix

#### "No visible binding for global variable"

✅ **Fixed**: All global variables are declared in `R/utils.R` using `utils::globalVariables()`

#### "Undeclared imports"

✅ **Fixed**: All imported functions use `@importFrom` in roxygen2 comments

#### Examples taking too long

- Wrap slow examples in `\donttest{}` or `\dontrun{}`
- Use smaller datasets in examples

#### API calls in examples/tests

✅ **Fixed**:
- Examples use `\dontrun{}`
- Tests use `httptest` for mocking
- Computationally expensive tests use `skip_on_cran()`

### 5. Legal & Licensing

- [ ] Ensure `LICENSE` file is correct
- [ ] Check that you have rights to submit (if forked or collaborative)
- [ ] Verify no proprietary code or data is included

### 6. Spell Check

```r
devtools::spell_check()
```

Fix any typos in documentation or vignettes.

### 7. URL and Email Checks

CRAN checks all URLs in documentation. Verify:

- [ ] All URLs are accessible and correct
- [ ] GitHub links point to the correct repository
- [ ] Email addresses are valid

### 8. Reverse Dependency Check

Since this is a new package (v0.1.0), there are no reverse dependencies to check.

For future versions:

```r
revdepcheck::revdep_check(num_workers = 4)
```

## CRAN Submission Process

### Step 1: Build the Package

```r
# Build source tarball
devtools::build()
```

This creates `SportMiner_0.1.0.tar.gz` in the parent directory.

### Step 2: Final Check on Built Package

```r
devtools::check_built("../SportMiner_0.1.0.tar.gz")
```

### Step 3: Submit to CRAN

**Option A: Via devtools**

```r
devtools::submit_cran()
```

**Option B: Manual Submission**

1. Go to https://cran.r-project.org/submit.html
2. Upload `SportMiner_0.1.0.tar.gz`
3. Fill in the submission form
4. Confirm your email address

### Step 4: CRAN Submission Comments

In the submission form, include:

```
This is a new submission.

Test environments:
- local: R 4.3.0 on macOS
- win-builder: R-devel and R-release
- R-hub: ubuntu-latest, windows-latest, macos-latest

R CMD check results:
0 errors | 0 warnings | 0 notes

All examples are wrapped in \dontrun{} as they require API authentication.
Tests use httptest mocking for offline safety.
```

## Post-Submission

### What to Expect

1. **Automated checks** (within minutes): CRAN runs checks on multiple platforms
2. **Manual review** (1-10 days): CRAN maintainers review your package
3. **Possible rejection**: Don't worry, it's common for first submissions

### If Rejected

- Read the feedback carefully
- Make requested changes
- Increment the version number (e.g., 0.1.0 → 0.1.1)
- Resubmit with a note explaining the changes

### If Accepted

🎉 **Congratulations!** Your package is now on CRAN.

- Update README badges
- Announce on social media / blog
- Monitor for user issues on GitHub

## Maintenance Schedule

After acceptance:

- Fix any bugs within 2 weeks of user reports
- Submit updates if dependencies change
- Respond to CRAN emails promptly

## Important CRAN Policies

1. **No API keys in package code**: ✅ We use environment variables
2. **No writing to user's file system**: ✅ We don't write files
3. **Fast examples** (<5s total): ✅ Examples use `\dontrun{}`
4. **Graceful failures**: ✅ All API calls use `tryCatch()`
5. **Proper messaging**: ✅ We use `message()` and `warning()`

## Resources

- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)
- [rOpenSci Packaging Guide](https://devguide.ropensci.org/)
- [R Packages Book](https://r-pkgs.org/)

---

**Last Updated**: January 2026
**Package Version**: 0.1.0
**Status**: Ready for initial CRAN submission (pending maintainer details)
