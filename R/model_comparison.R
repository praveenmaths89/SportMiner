#' Compare Multiple Topic Models
#'
#' Trains and compares three topic modeling approaches: LDA (Latent Dirichlet
#' Allocation), STM (Structural Topic Model), and CTM (Correlated Topic Model).
#' Calculates semantic coherence and exclusivity metrics for each model and
#' suggests the optimal model.
#'
#' @param dtm A DocumentTermMatrix object.
#' @param k Number of topics to extract. Default is 10.
#' @param metadata Optional data frame with document-level covariates for STM.
#'   Must have the same number of rows as dtm. Default is NULL.
#' @param prevalence Optional formula for STM prevalence specification.
#'   Default is NULL.
#' @param seed Random seed for reproducibility. Default is 1729.
#' @param lda_method Method for LDA. Options: "gibbs" or "vem".
#'   Default is "gibbs".
#' @param verbose Logical indicating whether to print progress messages.
#'   Default is TRUE.
#'
#' @return A list containing:
#'   \item{models}{List of fitted models (lda, stm, ctm)}
#'   \item{metrics}{Data frame comparing coherence and exclusivity}
#'   \item{recommendation}{Character string naming the optimal model}
#'
#' @importFrom topicmodels LDA CTM posterior
#' @importFrom stm stm
#' @importFrom textmineR CalcProbCoherence
#' @importFrom Matrix sparseMatrix
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires document-term matrix from sm_create_dtm()
#' dtm <- sm_create_dtm(processed_data)
#' comparison <- sm_compare_models(dtm, k = 10)
#' print(comparison$metrics)
#' print(comparison$recommendation)
#' }
sm_compare_models <- function(dtm,
                               k = 10,
                               metadata = NULL,
                               prevalence = NULL,
                               seed = 1729,
                               lda_method = "gibbs",
                               verbose = TRUE) {

  if (verbose) {
    message("=== Starting Multi-Model Comparison ===\n")
  }

  dtm_sparse <- Matrix::sparseMatrix(
    i = dtm$i,
    j = dtm$j,
    x = dtm$v,
    dims = c(dtm$nrow, dtm$ncol),
    dimnames = dimnames(dtm)
  )

  models <- list()
  metrics <- data.frame(
    model = character(),
    coherence = numeric(),
    exclusivity = numeric(),
    stringsAsFactors = FALSE
  )

  if (verbose) {
    message("1/3 Training LDA model...")
  }

  lda_control <- if (tolower(lda_method) == "gibbs") {
    list(seed = seed, iter = 500, burnin = 100, best = TRUE)
  } else {
    list(seed = seed)
  }

  models$lda <- tryCatch(
    {
      topicmodels::LDA(dtm, k = k, method = lda_method, control = lda_control)
    },
    error = function(e) {
      warning("LDA training failed: ", e$message)
      NULL
    }
  )

  if (!is.null(models$lda)) {
    phi_lda <- topicmodels::posterior(models$lda)$terms
    coh_lda <- mean(textmineR::CalcProbCoherence(phi_lda, dtm_sparse), na.rm = TRUE)
    excl_lda <- calculate_exclusivity(phi_lda)

    metrics <- rbind(metrics, data.frame(
      model = "LDA",
      coherence = coh_lda,
      exclusivity = excl_lda
    ))
  }

  if (verbose) {
    message("2/3 Training STM model...")
  }

  models$stm <- tryCatch(
    {
      stm_docs <- convert_dtm_to_stm(dtm)

      stm::stm(
        documents = stm_docs$documents,
        vocab = stm_docs$vocab,
        K = k,
        prevalence = prevalence,
        data = metadata,
        seed = seed,
        verbose = FALSE
      )
    },
    error = function(e) {
      warning("STM training failed: ", e$message)
      NULL
    }
  )

  if (!is.null(models$stm)) {
    phi_stm <- exp(models$stm$beta$logbeta[[1]])
    coh_stm <- mean(textmineR::CalcProbCoherence(phi_stm, dtm_sparse), na.rm = TRUE)
    excl_stm <- calculate_exclusivity(phi_stm)

    metrics <- rbind(metrics, data.frame(
      model = "STM",
      coherence = coh_stm,
      exclusivity = excl_stm
    ))
  }

  if (verbose) {
    message("3/3 Training CTM model...")
  }

  models$ctm <- tryCatch(
    {
      topicmodels::CTM(dtm, k = k, control = list(seed = seed))
    },
    error = function(e) {
      warning("CTM training failed: ", e$message)
      NULL
    }
  )

  if (!is.null(models$ctm)) {
    phi_ctm <- topicmodels::posterior(models$ctm)$terms
    coh_ctm <- mean(textmineR::CalcProbCoherence(phi_ctm, dtm_sparse), na.rm = TRUE)
    excl_ctm <- calculate_exclusivity(phi_ctm)

    metrics <- rbind(metrics, data.frame(
      model = "CTM",
      coherence = coh_ctm,
      exclusivity = excl_ctm
    ))
  }

  if (nrow(metrics) == 0) {
    stop("All models failed to train. Check your DTM and parameters.", call. = FALSE)
  }

  metrics$combined_score <- scale(metrics$coherence) + scale(metrics$exclusivity)

  recommended_model <- metrics$model[which.max(metrics$combined_score)]

  if (verbose) {
    message("\n=== Model Comparison Complete ===")
    message("Recommended model: ", recommended_model)
    print(metrics)
  }

  list(
    models = models,
    metrics = metrics,
    recommendation = recommended_model
  )
}


#' Calculate Topic Exclusivity
#'
#' Calculates the exclusivity metric for topics, measuring how uniquely
#' words are distributed across topics.
#'
#' @param phi Topic-word probability matrix (topics x terms).
#' @param top_n Number of top words to consider per topic. Default is 10.
#'
#' @return Numeric value representing average exclusivity across topics.
#'
#' @keywords internal
calculate_exclusivity <- function(phi, top_n = 10) {

  exclusivity_scores <- apply(phi, 1, function(topic_dist) {
    top_words_idx <- order(topic_dist, decreasing = TRUE)[1:top_n]
    top_word_probs <- phi[, top_words_idx, drop = FALSE]

    word_specificity <- apply(top_word_probs, 2, function(word_dist) {
      entropy <- -sum(word_dist * log(word_dist + 1e-10))
      max_entropy <- log(nrow(phi))
      1 - (entropy / max_entropy)
    })

    mean(word_specificity, na.rm = TRUE)
  })

  mean(exclusivity_scores, na.rm = TRUE)
}


#' Convert DTM to STM Format
#'
#' Helper function to convert a DocumentTermMatrix to the format required
#' by the stm package.
#'
#' @param dtm A DocumentTermMatrix object.
#'
#' @return A list with documents and vocab components for stm.
#'
#' @keywords internal
convert_dtm_to_stm <- function(dtm) {

  vocab <- colnames(dtm)

  documents <- lapply(1:dtm$nrow, function(i) {
    row_indices <- which(dtm$i == i)
    if (length(row_indices) == 0) {
      return(matrix(c(1, 0), nrow = 2))
    }
    word_indices <- dtm$j[row_indices]
    word_counts <- dtm$v[row_indices]
    rbind(word_indices, word_counts)
  })

  list(documents = documents, vocab = vocab)
}
