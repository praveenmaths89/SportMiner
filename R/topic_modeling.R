#' Select Optimal Number of Topics
#'
#' Tests multiple values of k (number of topics) and calculates topic
#' coherence for each. Returns the optimal k based on maximum coherence
#' score, along with a comparison plot.
#'
#' @param dtm A DocumentTermMatrix object.
#' @param k_range Vector of k values to test. Default is seq(2, 20, by = 2).
#' @param method Topic modeling method. Options: "gibbs" or "vem".
#'   Default is "gibbs".
#' @param seed Random seed for reproducibility. Default is 1729.
#' @param iter Number of Gibbs iterations (if method = "gibbs").
#'   Default is 500.
#' @param burnin Number of burn-in iterations (if method = "gibbs").
#'   Default is 100.
#' @param plot Logical indicating whether to display the coherence plot.
#'   Default is TRUE.
#'
#' @return A list containing:
#'   \item{optimal_k}{The k value with the highest coherence score}
#'   \item{results}{Data frame with k and coherence for each tested value}
#'   \item{plot}{A ggplot object showing coherence vs k}
#'
#' @importFrom topicmodels LDA posterior
#' @importFrom textmineR CalcProbCoherence
#' @importFrom Matrix sparseMatrix
#' @importFrom ggplot2 ggplot aes geom_line geom_point labs theme_minimal
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires document-term matrix from sm_create_dtm()
#' dtm <- sm_create_dtm(processed_data)
#' k_selection <- sm_select_optimal_k(dtm, k_range = c(5, 10, 15, 20))
#' print(k_selection$optimal_k)
#' }
sm_select_optimal_k <- function(dtm,
                                 k_range = seq(2, 20, by = 2),
                                 method = "gibbs",
                                 seed = 1729,
                                 iter = 500,
                                 burnin = 100,
                                 plot = TRUE) {

  if (length(k_range) == 0) {
    stop("k_range must contain at least one value.", call. = FALSE)
  }

  message("Testing ", length(k_range), " values of k...")

  dtm_sparse <- Matrix::sparseMatrix(
    i = dtm$i,
    j = dtm$j,
    x = dtm$v,
    dims = c(dtm$nrow, dtm$ncol),
    dimnames = dimnames(dtm)
  )

  control_list <- if (tolower(method) == "gibbs") {
    list(seed = seed, iter = iter, burnin = burnin, nstart = 1, best = TRUE)
  } else {
    list(seed = seed)
  }

  coherence_scores <- vapply(k_range, function(k) {
    message("  Testing k = ", k, "...")

    lda_model <- topicmodels::LDA(
      dtm,
      k = k,
      method = method,
      control = control_list
    )

    phi <- topicmodels::posterior(lda_model)$terms

    coherence_per_topic <- textmineR::CalcProbCoherence(
      phi = phi,
      dtm = dtm_sparse
    )

    mean(coherence_per_topic, na.rm = TRUE)
  }, numeric(1))

  results <- data.frame(
    topics = k_range,
    coherence = coherence_scores
  )

  optimal_row <- results[which.max(results$coherence), ]
  optimal_k <- optimal_row$topics

  message("\nOptimal k selected: ", optimal_k,
          " (coherence = ", round(optimal_row$coherence, 3), ")")

  p <- ggplot2::ggplot(results, ggplot2::aes(x = .data$topics, y = .data$coherence)) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 3) +
    ggplot2::labs(
      title = "Topic Coherence vs. Number of Topics (k)",
      x = "Number of Topics (k)",
      y = "Coherence Score (Higher is Better)"
    ) +
    ggplot2::theme_minimal()

  if (plot) {
    print(p)
  }

  list(
    optimal_k = optimal_k,
    results = results,
    plot = p
  )
}


#' Train LDA Topic Model
#'
#' Fits a Latent Dirichlet Allocation (LDA) model to a document-term matrix.
#'
#' @param dtm A DocumentTermMatrix object.
#' @param k Number of topics. If NULL, will attempt to use sm_select_optimal_k
#'   first. Default is NULL.
#' @param method Method for fitting. Options: "gibbs" or "vem".
#'   Default is "gibbs".
#' @param seed Random seed for reproducibility. Default is 1729.
#' @param iter Number of Gibbs iterations (if method = "gibbs").
#'   Default is 500.
#' @param burnin Number of burn-in iterations (if method = "gibbs").
#'   Default is 100.
#' @param alpha Hyperparameter for document-topic distributions.
#'   Default is 50/k (following Griffiths & Steyvers 2004).
#' @param beta Hyperparameter for topic-word distributions. Default is 0.1.
#'
#' @return An LDA_Gibbs or LDA_VEM object from the topicmodels package.
#'
#' @importFrom topicmodels LDA
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires document-term matrix from sm_create_dtm()
#' dtm <- sm_create_dtm(processed_data)
#' lda_model <- sm_train_lda(dtm, k = 10)
#' }
sm_train_lda <- function(dtm,
                          k = NULL,
                          method = "gibbs",
                          seed = 1729,
                          iter = 500,
                          burnin = 100,
                          alpha = NULL,
                          beta = 0.1) {

  if (is.null(k)) {
    stop(
      "k must be specified. Use sm_select_optimal_k() to find the optimal k.",
      call. = FALSE
    )
  }

  if (is.null(alpha)) {
    alpha <- 50 / k
  }

  message("Training LDA model with k = ", k, "...")

  control_list <- if (tolower(method) == "gibbs") {
    list(
      seed = seed,
      iter = iter,
      burnin = burnin,
      alpha = alpha,
      delta = beta
    )
  } else {
    list(seed = seed, alpha = alpha)
  }

  lda_model <- tryCatch(
    {
      topicmodels::LDA(
        dtm,
        k = k,
        method = method,
        control = control_list
      )
    },
    error = function(e) {
      stop("LDA training failed: ", e$message, call. = FALSE)
    }
  )

  message("LDA training complete.")

  return(lda_model)
}
