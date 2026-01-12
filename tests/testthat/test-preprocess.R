test_that("sm_preprocess_text works with valid data", {
  test_data <- data.frame(
    abstract = c(
      "This is a test abstract about machine learning.",
      "Another abstract discussing deep learning algorithms.",
      "Sport science and data analysis methods."
    ),
    stringsAsFactors = FALSE
  )

  result <- sm_preprocess_text(test_data, text_col = "abstract")

  expect_s3_class(result, "data.frame")
  expect_true(all(c("doc_id", "stem", "n") %in% names(result)))
  expect_gt(nrow(result), 0)
})

test_that("sm_preprocess_text handles missing text column", {
  test_data <- data.frame(
    content = c("Text here"),
    stringsAsFactors = FALSE
  )

  expect_error(
    sm_preprocess_text(test_data, text_col = "abstract"),
    "Column 'abstract' not found"
  )
})

test_that("sm_preprocess_text filters NA values", {
  test_data <- data.frame(
    abstract = c(
      "Valid text here.",
      NA,
      "",
      "More valid text."
    ),
    stringsAsFactors = FALSE
  )

  result <- sm_preprocess_text(test_data)

  unique_docs <- unique(result$doc_id)
  expect_equal(length(unique_docs), 2)
})

test_that("sm_create_dtm produces valid DTM", {
  word_counts <- data.frame(
    doc_id = rep(c("doc1", "doc2", "doc3"), each = 5),
    stem = c(
      "machin", "learn", "algorithm", "data", "scienc",
      "deep", "neural", "network", "model", "train",
      "sport", "athlet", "perform", "analys", "metric"
    ),
    n = c(3, 2, 1, 4, 2, 5, 3, 2, 1, 3, 4, 2, 3, 5, 1)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1)

  expect_s3_class(dtm, "DocumentTermMatrix")
  expect_gt(dtm$nrow, 0)
  expect_gt(dtm$ncol, 0)
})

test_that("sm_create_dtm validates input columns", {
  invalid_data <- data.frame(
    id = c("doc1", "doc2"),
    word = c("test", "example")
  )

  expect_error(
    sm_create_dtm(invalid_data),
    "word_counts must have columns: doc_id, stem, n"
  )
})
