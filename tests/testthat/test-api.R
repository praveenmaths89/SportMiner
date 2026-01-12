test_that("sm_set_api_key works with valid key", {
  expect_message(
    sm_set_api_key("test_key_12345"),
    "Scopus API key configured successfully"
  )
})

test_that("sm_set_api_key fails without key", {
  withr::local_envvar(c(SCOPUS_API_KEY = ""))
  expect_error(
    sm_set_api_key(),
    "No API key provided"
  )
})

test_that("sm_search_scopus validates query parameter", {
  expect_error(
    sm_search_scopus(""),
    "Query must be a non-empty character string"
  )

  expect_error(
    sm_search_scopus(NULL),
    "Query must be a non-empty character string"
  )
})

test_that("sm_search_scopus limits batch_size to 100", {
  expect_warning(
    {
      withr::with_envvar(
        c(SCOPUS_API_KEY = "test_key"),
        {
          expect_error(
            sm_search_scopus("test query", batch_size = 150),
            "Scopus search failed"
          )
        }
      )
    },
    "batch_size cannot exceed 100"
  )
})

test_that("sm_get_indexed_keywords handles missing identifiers", {
  expect_equal(sm_get_indexed_keywords(doi = NA, eid = NA), NA_character_)
  expect_equal(sm_get_indexed_keywords(doi = "", eid = ""), NA_character_)
})
