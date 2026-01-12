test_that("sm_train_lda requires k parameter", {
  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:10), each = 20),
    stem = sample(letters[1:20], 200, replace = TRUE),
    n = sample(1:5, 200, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)

  expect_error(
    sm_train_lda(dtm, k = NULL),
    "k must be specified"
  )
})

test_that("sm_train_lda produces valid LDA model", {
  set.seed(123)

  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:20), each = 30),
    stem = sample(c("sport", "scienc", "data", "analys", "perform",
                    "athlet", "train", "machin", "learn", "algorithm",
                    "model", "predict", "metric", "test", "valid"), 600, replace = TRUE),
    n = sample(1:5, 600, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)

  model <- sm_train_lda(dtm, k = 3, method = "vem", seed = 123)

  expect_s4_class(model, "LDA")
  expect_equal(model@k, 3)
})

test_that("sm_select_optimal_k validates k_range", {
  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:10), each = 20),
    stem = sample(letters[1:15], 200, replace = TRUE),
    n = sample(1:5, 200, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)

  expect_error(
    sm_select_optimal_k(dtm, k_range = c()),
    "k_range must contain at least one value"
  )
})

test_that("sm_select_optimal_k returns correct structure", {
  skip_on_cran()
  set.seed(456)

  word_counts <- data.frame(
    doc_id = rep(paste0("doc", 1:25), each = 25),
    stem = sample(c("sport", "scienc", "data", "analys", "perform",
                    "athlet", "train", "method", "result", "test",
                    "player", "team", "game", "skill", "coach"), 625, replace = TRUE),
    n = sample(1:5, 625, replace = TRUE)
  )

  dtm <- sm_create_dtm(word_counts, min_term_freq = 1, max_term_freq = 1.0)

  result <- suppressMessages(
    sm_select_optimal_k(dtm, k_range = c(3, 5), method = "vem", plot = FALSE)
  )

  expect_type(result, "list")
  expect_true(all(c("optimal_k", "results", "plot") %in% names(result)))
  expect_true(result$optimal_k %in% c(3, 5))
  expect_s3_class(result$results, "data.frame")
  expect_s3_class(result$plot, "gg")
})
