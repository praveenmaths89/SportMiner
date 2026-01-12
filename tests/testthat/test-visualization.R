test_that("sm_plot_topic_terms works with LDA model", {
  skip_on_cran()
  set.seed(789)

  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:20), each = 30),
    stem = sample(c("sport", "scienc", "data", "perform", "athlet",
                    "train", "model", "analys", "result", "method"), 600, replace = TRUE),
    n = sample(1:5, 600, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)
  model <- sm_train_lda(dtm, k = 3, method = "vem", seed = 789)

  p <- sm_plot_topic_terms(model, n_terms = 5)

  expect_s3_class(p, "gg")
  expect_s3_class(p, "ggplot")
})

test_that("sm_plot_topic_frequency works with LDA model", {
  skip_on_cran()
  set.seed(101)

  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:20), each = 30),
    stem = sample(c("sport", "scienc", "data", "perform", "athlet",
                    "train", "model", "analys", "result", "method"), 600, replace = TRUE),
    n = sample(1:5, 600, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)
  model <- sm_train_lda(dtm, k = 3, method = "vem", seed = 101)

  p <- sm_plot_topic_frequency(model, dtm)

  expect_s3_class(p, "gg")
  expect_s3_class(p, "ggplot")
})

test_that("sm_plot_topic_trends requires year column", {
  skip_on_cran()
  set.seed(202)

  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:20), each = 30),
    stem = sample(letters[1:10], 600, replace = TRUE),
    n = sample(1:5, 600, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)
  model <- sm_train_lda(dtm, k = 3, method = "vem", seed = 202)

  metadata <- data.frame(doc_id = paste0("doc", 1:20))

  expect_error(
    sm_plot_topic_trends(model, dtm, metadata),
    "metadata must contain a 'year' column"
  )
})
