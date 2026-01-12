#' Create Keyword Co-occurrence Network
#'
#' Generates and visualizes a keyword co-occurrence network from author-provided
#' keywords. Shows which keywords frequently appear together in the same papers.
#'
#' @param data Data frame containing papers with keyword information.
#' @param keyword_col Name of the column containing keywords. Default is
#'   "author_keywords".
#' @param separator Character string separating keywords within a cell.
#'   Default is "; " (Scopus format).
#' @param min_cooccurrence Minimum number of times keywords must co-occur to
#'   be included in the network. Default is 2.
#' @param top_n Number of top keywords (by frequency) to include. If NULL,
#'   includes all keywords meeting min_cooccurrence. Default is 30.
#' @param layout Network layout algorithm. Options include "fr"
#'   (Fruchterman-Reingold), "kk" (Kamada-Kawai), "circle". Default is "fr".
#'
#' @return A ggraph/ggplot object displaying the keyword network.
#'
#' @importFrom dplyr filter mutate count select n all_of
#' @importFrom tidyr separate_rows
#' @importFrom widyr pairwise_count
#' @importFrom igraph graph_from_data_frame V
#' @importFrom ggraph ggraph geom_edge_link geom_node_point geom_node_label
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires API data from sm_search_scopus()
#' papers <- sm_search_scopus(query, max_count = 100)
#' network_plot <- sm_keyword_network(papers, top_n = 25)
#' print(network_plot)
#' }
sm_keyword_network <- function(data,
                                keyword_col = "author_keywords",
                                separator = "; ",
                                min_cooccurrence = 2,
                                top_n = 30,
                                layout = "fr") {

  if (!keyword_col %in% names(data)) {
    stop("Column '", keyword_col, "' not found in data.", call. = FALSE)
  }

  data_with_id <- data %>%
    dplyr::filter(!is.na(.data[[keyword_col]]) & nzchar(.data[[keyword_col]])) %>%
    dplyr::mutate(paper_id = seq_len(dplyr::n()))

  if (nrow(data_with_id) == 0) {
    stop("No valid keyword data found.", call. = FALSE)
  }

  keywords_df <- data_with_id %>%
    dplyr::select(dplyr::all_of(c("paper_id", keyword_col))) %>%
    tidyr::separate_rows(dplyr::all_of(keyword_col), sep = separator) %>%
    dplyr::mutate(keyword = tolower(trimws(.data[[keyword_col]]))) %>%
    dplyr::filter(nchar(.data$keyword) > 2) %>%
    dplyr::select(dplyr::all_of(c("paper_id", "keyword")))

  keyword_counts <- keywords_df %>%
    dplyr::count(.data$keyword, sort = TRUE)

  if (!is.null(top_n)) {
    top_keywords <- keyword_counts$keyword[1:min(top_n, nrow(keyword_counts))]
    keywords_df <- keywords_df %>%
      dplyr::filter(.data$keyword %in% top_keywords)
  }

  keyword_pairs <- keywords_df %>%
    widyr::pairwise_count(keyword, paper_id, sort = TRUE) %>%
    dplyr::filter(.data$n >= min_cooccurrence)

  if (nrow(keyword_pairs) == 0) {
    stop(
      "No keyword pairs found with min_cooccurrence >= ", min_cooccurrence,
      ". Try lowering the threshold.",
      call. = FALSE
    )
  }

  keyword_graph <- igraph::graph_from_data_frame(
    d = keyword_pairs,
    directed = FALSE
  )

  node_freq <- keyword_counts %>%
    dplyr::filter(.data$keyword %in% names(igraph::V(keyword_graph)))

  igraph::V(keyword_graph)$freq <- node_freq$n[
    match(names(igraph::V(keyword_graph)), node_freq$keyword)
  ]

  p <- ggraph::ggraph(keyword_graph, layout = layout) +
    ggraph::geom_edge_link(
      ggplot2::aes(edge_alpha = .data$n, edge_width = .data$n),
      color = "gray60",
      show.legend = FALSE
    ) +
    ggraph::geom_node_point(
      ggplot2::aes(size = .data$freq, color = .data$freq),
      alpha = 0.8
    ) +
    ggraph::geom_node_label(
      ggplot2::aes(label = .data$name),
      size = 3,
      repel = TRUE,
      box.padding = 0.3
    ) +
    ggplot2::scale_color_gradient(
      low = "#41B6C4",
      high = "#253494",
      name = "Frequency"
    ) +
    ggplot2::scale_size_continuous(
      range = c(3, 12),
      name = "Frequency"
    ) +
    ggplot2::labs(
      title = "Keyword Co-occurrence Network",
      subtitle = paste("Minimum co-occurrence:", min_cooccurrence)
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = 11, hjust = 0.5),
      legend.position = "right"
    )

  return(p)
}
