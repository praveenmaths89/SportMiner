#' Plot Topic Term Probabilities
#'
#' Creates a bar chart showing the top terms for each topic, based on their
#' beta (topic-word) probabilities.
#'
#' @param model A fitted topic model (LDA, STM, or CTM).
#' @param n_terms Number of top terms to display per topic. Default is 10.
#' @param topics Vector of topic numbers to display. If NULL, shows all topics.
#'   Default is NULL.
#'
#' @return A ggplot object.
#'
#' @importFrom dplyr filter group_by slice_max ungroup arrange
#' @importFrom ggplot2 ggplot aes geom_bar labs theme_minimal theme element_text
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires trained model from sm_train_lda()
#' lda_model <- sm_train_lda(dtm, k = 10)
#' sm_plot_topic_terms(lda_model, n_terms = 15)
#' }
sm_plot_topic_terms <- function(model, n_terms = 10, topics = NULL) {

  if (inherits(model, "LDA") || inherits(model, "CTM")) {
    topics_beta <- tidytext::tidy(model, matrix = "beta")
  } else if (inherits(model, "STM")) {
    beta_matrix <- exp(model$beta$logbeta[[1]])
    topics_beta <- data.frame(
      topic = rep(1:nrow(beta_matrix), each = ncol(beta_matrix)),
      term = rep(model$vocab, times = nrow(beta_matrix)),
      beta = as.vector(t(beta_matrix)),
      stringsAsFactors = FALSE
    )
  } else {
    stop("Model type not supported. Use LDA, STM, or CTM.", call. = FALSE)
  }

  if (!is.null(topics)) {
    topics_beta <- topics_beta %>%
      dplyr::filter(.data$topic %in% topics)
  }

  top_terms <- topics_beta %>%
    dplyr::group_by(.data$topic) %>%
    dplyr::slice_max(.data$beta, n = n_terms, with_ties = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(.data$topic, -.data$beta)

  top_terms$term <- reorder_within(top_terms$term, top_terms$beta, top_terms$topic)

  p <- ggplot2::ggplot(
    top_terms,
    ggplot2::aes(x = .data$beta, y = .data$term, fill = factor(.data$topic))
  ) +
    ggplot2::geom_bar(stat = "identity", show.legend = FALSE) +
    facet_wrap(~ topic, scales = "free_y", ncol = 3) +
    scale_y_reordered() +
    ggplot2::labs(
      title = paste("Top", n_terms, "Terms per Topic"),
      x = "Beta (Topic-Word Probability)",
      y = NULL
    ) +
    theme_sportminer() +
    ggplot2::theme(strip.text = ggplot2::element_text(face = "bold", size = 11))

  return(p)
}


#' Plot Topic Frequency Distribution
#'
#' Creates a bar chart showing how many documents are assigned to each topic.
#'
#' @param model A fitted topic model (LDA, STM, or CTM).
#' @param dtm The document-term matrix used to train the model.
#' @param threshold Minimum gamma probability for topic assignment.
#'   Default is 0.3.
#'
#' @return A ggplot object.
#'
#' @importFrom dplyr count filter mutate group_by slice_max ungroup
#' @importFrom ggplot2 ggplot aes geom_bar geom_text labs theme_minimal
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires trained model from sm_train_lda()
#' lda_model <- sm_train_lda(dtm, k = 10)
#' sm_plot_topic_frequency(lda_model, dtm)
#' }
sm_plot_topic_frequency <- function(model, dtm, threshold = 0.3) {

  if (inherits(model, "LDA") || inherits(model, "CTM")) {
    topics_gamma <- tidytext::tidy(model, matrix = "gamma")
  } else if (inherits(model, "STM")) {
    gamma_matrix <- model$theta
    topics_gamma <- data.frame(
      document = rep(rownames(dtm), each = ncol(gamma_matrix)),
      topic = rep(1:ncol(gamma_matrix), times = nrow(gamma_matrix)),
      gamma = as.vector(gamma_matrix),
      stringsAsFactors = FALSE
    )
  } else {
    stop("Model type not supported. Use LDA, STM, or CTM.", call. = FALSE)
  }

  doc_topics <- topics_gamma %>%
    dplyr::group_by(.data$document) %>%
    dplyr::slice_max(.data$gamma, n = 1, with_ties = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::filter(.data$gamma >= threshold)

  topic_counts <- doc_topics %>%
    dplyr::count(.data$topic, sort = TRUE) %>%
    dplyr::mutate(topic_label = factor(.data$topic))

  p <- ggplot2::ggplot(
    topic_counts,
    ggplot2::aes(x = reorder(.data$topic_label, -.data$n), y = .data$n)
  ) +
    ggplot2::geom_bar(stat = "identity", fill = "#2C7FB8", alpha = 0.8) +
    ggplot2::geom_text(ggplot2::aes(label = .data$n), vjust = -0.5, size = 4) +
    ggplot2::labs(
      title = "Number of Documents per Topic",
      x = "Topic",
      y = "Document Count"
    ) +
    theme_sportminer()

  return(p)
}


#' Plot Topic Trends Over Time
#'
#' Creates a stacked percentage bar chart showing how topic proportions
#' change over publication years.
#'
#' @param model A fitted topic model (LDA, STM, or CTM).
#' @param dtm The document-term matrix used to train the model.
#' @param metadata Data frame with a 'year' column and document identifiers.
#' @param doc_id_col Name of the document ID column in metadata.
#'   Default is "doc_id".
#' @param year_filter Optional vector of years to include. Default is NULL
#'   (includes all years).
#'
#' @return A ggplot object.
#'
#' @importFrom dplyr filter left_join count mutate group_by slice_max ungroup
#' @importFrom ggplot2 ggplot aes geom_bar scale_fill_brewer scale_y_continuous labs theme
#' @importFrom scales percent_format
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires trained model and metadata
#' papers$doc_id <- paste0("doc_", seq_len(nrow(papers)))
#' lda_model <- sm_train_lda(dtm, k = 10)
#' sm_plot_topic_trends(lda_model, dtm, metadata = papers)
#' }
sm_plot_topic_trends <- function(model,
                                  dtm,
                                  metadata,
                                  doc_id_col = "doc_id",
                                  year_filter = NULL) {

  if (!"year" %in% names(metadata)) {
    stop("metadata must contain a 'year' column.", call. = FALSE)
  }

  if (inherits(model, "LDA") || inherits(model, "CTM")) {
    topics_gamma <- tidytext::tidy(model, matrix = "gamma")
  } else if (inherits(model, "STM")) {
    gamma_matrix <- model$theta
    topics_gamma <- data.frame(
      document = rep(rownames(dtm), each = ncol(gamma_matrix)),
      topic = rep(1:ncol(gamma_matrix), times = nrow(gamma_matrix)),
      gamma = as.vector(gamma_matrix),
      stringsAsFactors = FALSE
    )
  } else {
    stop("Model type not supported. Use LDA, STM, or CTM.", call. = FALSE)
  }

  doc_topics <- topics_gamma %>%
    dplyr::group_by(.data$document) %>%
    dplyr::slice_max(.data$gamma, n = 1, with_ties = FALSE) %>%
    dplyr::ungroup()

  metadata_clean <- metadata %>%
    dplyr::mutate(year = as.numeric(.data$year)) %>%
    dplyr::filter(!is.na(.data$year))

  if (!is.null(year_filter)) {
    metadata_clean <- metadata_clean %>%
      dplyr::filter(.data$year %in% year_filter)
  }

  trends_data <- doc_topics %>%
    dplyr::left_join(
      metadata_clean,
      by = setNames(doc_id_col, "document")
    ) %>%
    dplyr::filter(!is.na(.data$year)) %>%
    dplyr::count(.data$year, .data$topic) %>%
    dplyr::mutate(
      topic_label = factor(.data$topic),
      year_label = factor(.data$year)
    )

  p <- ggplot2::ggplot(
    trends_data,
    ggplot2::aes(x = .data$year_label, y = .data$n, fill = .data$topic_label)
  ) +
    ggplot2::geom_bar(stat = "identity", position = "fill") +
    ggplot2::scale_fill_brewer(palette = "Paired") +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    ggplot2::labs(
      title = "Topic Trends Over Time",
      x = "Year",
      y = "Percentage of Papers",
      fill = "Topic"
    ) +
    theme_sportminer() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )

  return(p)
}


#' Helper: Reorder Terms Within Facets
#'
#' @keywords internal
reorder_within <- function(x, by, within, sep = "___") {
  new_x <- paste(x, within, sep = sep)
  stats::reorder(new_x, by)
}


#' Helper: Scale for Reordered Terms
#'
#' @keywords internal
scale_y_reordered <- function(..., sep = "___") {
  reg_match <- paste0(sep, ".+$")
  ggplot2::scale_y_discrete(labels = function(x) gsub(reg_match, "", x), ...)
}
