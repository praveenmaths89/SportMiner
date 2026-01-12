#' Set Scopus API Key
#'
#' Configures the Scopus API key for the current R session. The key can be
#' provided directly or set via the SCOPUS_API_KEY environment variable.
#'
#' @param api_key Character string containing your Scopus API key. If NULL,
#'   the function will attempt to read from the SCOPUS_API_KEY environment
#'   variable.
#'
#' @return Invisible NULL. Called for side effects.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires Scopus API key
#' sm_set_api_key("your_api_key_here")
#' }
sm_set_api_key <- function(api_key = NULL) {
  if (is.null(api_key)) {
    api_key <- Sys.getenv("SCOPUS_API_KEY")
    if (api_key == "") {
      stop(
        "No API key provided. Either pass it to sm_set_api_key() or set ",
        "the SCOPUS_API_KEY environment variable.",
        call. = FALSE
      )
    }
  }

  tryCatch(
    {
      rscopus::set_api_key(api_key)
      message("Scopus API key configured successfully.")
    },
    error = function(e) {
      stop("Failed to set API key: ", e$message, call. = FALSE)
    }
  )

  invisible(NULL)
}


#' Search Scopus Database
#'
#' Retrieves abstracts and metadata from the Scopus database based on a
#' structured query. Handles pagination automatically and provides progress
#' feedback.
#'
#' @param query Character string containing the Scopus search query. Should
#'   follow Scopus query syntax (e.g., 'TITLE-ABS-KEY("machine learning")').
#' @param max_count Maximum number of papers to retrieve. Use Inf to retrieve
#'   all available papers. Default is 200.
#' @param batch_size Number of records to retrieve per API call. Maximum is
#'   100. Default is 100.
#' @param view Level of detail in the response. Options are "STANDARD" or
#'   "COMPLETE". Default is "COMPLETE".
#' @param verbose Logical indicating whether to print progress messages.
#'   Default is TRUE.
#'
#' @return A data.frame containing the retrieved papers with columns including
#'   title, abstract, author_keywords, year, DOI, and EID.
#'
#' @importFrom rscopus scopus_search gen_entries_to_df
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires Scopus API key
#' sm_set_api_key()
#' query <- 'TITLE-ABS-KEY("sport science" AND "machine learning")'
#' papers <- sm_search_scopus(query, max_count = 50)
#' }
sm_search_scopus <- function(query,
                              max_count = 200,
                              batch_size = 100,
                              view = "COMPLETE",
                              verbose = TRUE) {

  if (!is.character(query) || nchar(query) == 0) {
    stop("Query must be a non-empty character string.", call. = FALSE)
  }

  if (batch_size > 100) {
    warning("batch_size cannot exceed 100. Setting to 100.")
    batch_size <- 100
  }

  if (verbose) {
    message("Starting Scopus search...")
  }

  res <- tryCatch(
    {
      rscopus::scopus_search(
        query = query,
        view = view,
        count = batch_size,
        max_count = max_count,
        verbose = verbose
      )
    },
    error = function(e) {
      stop(
        "Scopus search failed: ", e$message,
        "\nPlease check your query syntax and API key.",
        call. = FALSE
      )
    }
  )

  if (is.null(res$entries) || length(res$entries) == 0) {
    warning("No results found for the given query.")
    return(data.frame())
  }

  entries_list <- rscopus::gen_entries_to_df(res$entries)
  main_df <- entries_list$df

  main_df$abstract <- main_df$`dc:description`
  main_df$author_keywords <- main_df$authkeywords
  main_df$title <- main_df$`dc:title`
  main_df$year <- substr(main_df$`prism:coverDate`, 1, 4)

  if (verbose) {
    message("Retrieved ", nrow(main_df), " papers.")
  }

  return(main_df)
}


#' Get Indexed Keywords from Scopus
#'
#' Retrieves indexed keywords for a single paper using its DOI or EID.
#' This function makes an additional API call per paper, so use judiciously.
#'
#' @param doi Character string containing the paper's DOI.
#' @param eid Character string containing the paper's EID (Scopus identifier).
#' @param verbose Logical indicating whether to print error messages.
#'   Default is FALSE.
#'
#' @return Character string of indexed keywords separated by " | ", or NA if
#'   not available.
#'
#' @importFrom rscopus abstract_retrieval
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires Scopus API key
#' keywords <- sm_get_indexed_keywords(
#'   doi = "10.1016/j.jsams.2020.01.001"
#' )
#' }
sm_get_indexed_keywords <- function(doi = NA, eid = NA, verbose = FALSE) {

  if ((!is.na(doi) && nzchar(doi))) {
    id_val <- doi
    id_type <- "doi"
  } else if ((!is.na(eid) && nzchar(eid))) {
    id_val <- eid
    id_type <- "eid"
  } else {
    return(NA_character_)
  }

  es <- tryCatch(
    {
      rscopus::abstract_retrieval(
        id = id_val,
        identifier = id_type,
        view = "FULL",
        verbose = FALSE
      )
    },
    error = function(e) {
      if (verbose) {
        message("API Error for ", id_val, ": ", e$message)
      }
      return(NULL)
    }
  )

  if (is.null(es)) {
    return(NA_character_)
  }

  idx <- es$content$`abstracts-retrieval-response`$idxterms$mainterm

  if (is.null(idx)) {
    return(NA_character_)
  }

  terms <- vapply(
    idx,
    function(mt) {
      if (is.null(mt) || length(mt) == 0) {
        return(NA_character_)
      }

      val <- mt[["$"]]

      if (is.null(val)) {
        val <- as.character(mt[[length(mt)]])
      }

      if (is.null(val) || length(val) != 1 || !is.atomic(val)) {
        return(NA_character_)
      }

      return(as.character(val))
    },
    character(1)
  )

  terms <- unique(terms[!is.na(terms) & nzchar(terms)])

  if (length(terms) == 0) {
    return(NA_character_)
  }

  paste(terms, collapse = " | ")
}
