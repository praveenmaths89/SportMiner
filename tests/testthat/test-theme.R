test_that("theme_sportminer produces valid theme", {
  theme_obj <- theme_sportminer()

  expect_s3_class(theme_obj, "theme")
  expect_type(theme_obj, "list")
})

test_that("theme_sportminer accepts base_size parameter", {
  theme_obj <- theme_sportminer(base_size = 14)

  expect_s3_class(theme_obj, "theme")
})

test_that("theme_sportminer grid parameter works", {
  theme_with_grid <- theme_sportminer(grid = TRUE)
  theme_without_grid <- theme_sportminer(grid = FALSE)

  expect_s3_class(theme_with_grid, "theme")
  expect_s3_class(theme_without_grid, "theme")
})
