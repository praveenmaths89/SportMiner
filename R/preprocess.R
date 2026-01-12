#' Preprocess Text for Topic Modeling
#'
#' Tokenizes, cleans, and stems text data in preparation for topic modeling.
#' Removes stopwords, numbers, and performs stemming using the Porter algorithm.
#'
#' @param data A data.frame containing text data.
#' @param text_col Name of the column containing text to preprocess.
#'   Default is "abstract".
#' @param id_col Name of the column containing document IDs. If NULL, a
#'   doc_id column will be created. Default is NULL.
#' @param min_word_length Minimum word length to retain. Default is 3.
#' @param custom_stopwords Additional stopwords to remove beyond the standard
#'   English stopwords. Default is NULL.
#'
#' @return A data.frame with columns: doc_id, stem, and n (word count).
#'
#' @importFrom dplyr filter select mutate anti_join count
#' @importFrom tidytext unnest_tokens
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires API data from sm_search_scopus()
#' papers <- sm_search_scopus(query, max_count = 50)
#' processed <- sm_preprocess_text(papers)
#' }
sm_preprocess_text <- function(data,
                                text_col = "abstract",
                                id_col = NULL,
                                min_word_length = 3,
                                custom_stopwords = NULL) {

  if (!text_col %in% names(data)) {
    stop("Column '", text_col, "' not found in data.", call. = FALSE)
  }

  data_clean <- data %>%
    dplyr::filter(!is.na(.data[[text_col]]) & nzchar(.data[[text_col]]))

  if (nrow(data_clean) == 0) {
    stop("No valid text data found after filtering NAs.", call. = FALSE)
  }

  if (is.null(id_col)) {
    data_clean$doc_id <- paste0("doc_", seq_len(nrow(data_clean)))
    id_col <- "doc_id"
  }

  data_to_process <- data_clean %>%
    dplyr::select(doc_id = dplyr::all_of(id_col), text = dplyr::all_of(text_col))

  word_tokens <- data_to_process %>%
    tidytext::unnest_tokens(.data$word, .data$text)

  data("stop_words", package = "tidytext", envir = environment())

  processed_words <- word_tokens %>%
    dplyr::anti_join(stop_words, by = "word") %>%
    dplyr::filter(!grepl("\\d", .data$word)) %>%
    dplyr::filter(nchar(.data$word) >= min_word_length) %>%
    dplyr::mutate(stem = SnowballC::wordStem(.data$word))

  if (!is.null(custom_stopwords)) {
    processed_words <- processed_words %>%
      dplyr::filter(!.data$stem %in% custom_stopwords)
  }

  word_counts <- processed_words %>%
    dplyr::count(.data$doc_id, .data$stem, sort = TRUE)

  message("Preprocessing complete. ", length(unique(word_counts$doc_id)),
          " documents, ", length(unique(word_counts$stem)), " unique stems.")

  return(word_counts)
}


#' Create Document-Term Matrix
#'
#' @description
#' Converts preprocessed word counts into a document-term matrix suitable
#' for topic modeling. Filters rare terms and empty documents.
#'
#' @param word_counts A data.frame with columns doc_id, stem, and n, typically
#'   produced by sm_preprocess_text().
#' @param min_term_freq Minimum number of documents a term must appear in to
#'   be retained. Default is 3.
#' @param max_term_freq Maximum proportion of documents a term can appear in.
#'   Useful for removing ubiquitous terms. Default is 0.5 (50 percent).
#'
#' @return A DocumentTermMatrix object from the tm package.
#'
#' @importFrom tidytext cast_dtm
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @importFrom slam col_sums row_sums
#'
#' @export
#'
#' @examples
#' \dontrun{
#' processed <- sm_preprocess_text(papers)
#' dtm <- sm_create_dtm(processed)
#' }
sm_create_dtm <- function(word_counts,
                           min_term_freq = 3,
                           max_term_freq = 0.5) {

  if (!all(c("doc_id", "stem", "n") %in% names(word_counts))) {
    stop("word_counts must have columns: doc_id, stem, n", call. = FALSE)
  }

  dtm <- word_counts %>%
    tidytext::cast_dtm(.data$doc_id, .data$stem, .data$n)

  # Calculate document frequency (number of docs containing each term)
  doc_freq <- slam::col_sums(dtm > 0)
  n_docs <- dtm$nrow

  terms_to_keep <- doc_freq >= min_term_freq &
    (doc_freq / n_docs) <= max_term_freq

  dtm <- dtm[, terms_to_keep]

  doc_sums <- slam::row_sums(dtm)
  dtm <- dtm[doc_sums > 0, ]

  if (dtm$nrow == 0) {
    stop(
      "No documents remaining after filtering. ",
      "Try relaxing min_term_freq or max_term_freq.",
      call. = FALSE
    )
  }

  message("DTM created: ", dtm$nrow, " documents, ", dtm$ncol, " terms.")

  return(dtm)
}
