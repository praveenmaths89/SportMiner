## Example Data Preparation Workflow
## This script demonstrates how to use SportMiner
## It is NOT run during package build (data-raw/ is excluded)

library(SportMiner)

# Set API key (get yours from https://dev.elsevier.com/)
Sys.setenv(SCOPUS_API_KEY = "your_key_here")
sm_set_api_key()

# Define search query
query <- paste0(
  'TITLE-ABS-KEY(',
  '("talent identification" OR "sport science" OR "athlete") ',
  'AND ',
  '("principal component analysis" OR "PCA" OR "cluster analysis") ',
  ') AND DOCTYPE(ar) AND PUBYEAR > 2010'
)

# Retrieve papers
papers <- sm_search_scopus(
  query = query,
  max_count = 100,
  verbose = TRUE
)

# Save raw data (optional)
# saveRDS(papers, "data-raw/sport_science_papers.rds")

# Preprocess
processed_data <- sm_preprocess_text(
  data = papers,
  text_col = "abstract"
)

# Create DTM
dtm <- sm_create_dtm(
  word_counts = processed_data,
  min_term_freq = 3
)

# Find optimal k
k_selection <- sm_select_optimal_k(
  dtm = dtm,
  k_range = seq(4, 16, by = 2),
  method = "gibbs"
)

# Train final model
lda_model <- sm_train_lda(
  dtm = dtm,
  k = k_selection$optimal_k,
  method = "gibbs"
)

# Create visualizations
p1 <- sm_plot_topic_terms(lda_model, n_terms = 10)
p2 <- sm_plot_topic_frequency(lda_model, dtm)

# Add doc_id for trends
papers$doc_id <- paste0("doc_", seq_len(nrow(papers)))

p3 <- sm_plot_topic_trends(
  model = lda_model,
  dtm = dtm,
  metadata = papers
)

# Keyword network
p4 <- sm_keyword_network(
  data = papers,
  min_cooccurrence = 2,
  top_n = 30
)

# Compare models
comparison <- sm_compare_models(
  dtm = dtm,
  k = 10,
  verbose = TRUE
)

print(comparison$metrics)
print(comparison$recommendation)

# Save plots
# ggsave("output/topic_terms.png", p1, width = 12, height = 8)
# ggsave("output/topic_frequency.png", p2, width = 8, height = 6)
# ggsave("output/topic_trends.png", p3, width = 10, height = 6)
# ggsave("output/keyword_network.png", p4, width = 12, height = 10)
