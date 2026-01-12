test_that("sm_keyword_network validates input data", {
  test_data <- data.frame(
    title = c("Paper 1", "Paper 2"),
    abstract = c("Text here", "More text")
  )

  expect_error(
    sm_keyword_network(test_data),
    "Column 'author_keywords' not found"
  )
})

test_that("sm_keyword_network requires valid keyword data", {
  test_data <- data.frame(
    author_keywords = c(NA, NA, NA)
  )

  expect_error(
    sm_keyword_network(test_data),
    "No valid keyword data found"
  )
})

test_that("sm_keyword_network creates network plot", {
  skip_on_cran()

  test_data <- data.frame(
    author_keywords = c(
      "machine learning; data science; sport",
      "machine learning; artificial intelligence; sport",
      "data science; statistics; analysis",
      "machine learning; neural networks; sport",
      "data science; machine learning; python"
    ),
    stringsAsFactors = FALSE
  )

  p <- sm_keyword_network(test_data, min_cooccurrence = 1, top_n = 10)

  expect_s3_class(p, "gg")
  expect_s3_class(p, "ggplot")
})
