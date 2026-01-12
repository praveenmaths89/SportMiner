#' SportMiner Custom ggplot2 Theme
#'
#' A clean, professional, and colorblind-friendly ggplot2 theme designed
#' for academic publications and presentations in sport science.
#'
#' @param base_size Base font size in points. Default is 11.
#' @param base_family Base font family. Default is "".
#' @param grid Logical indicating whether to display grid lines.
#'   Default is TRUE.
#'
#' @return A ggplot2 theme object.
#'
#' @importFrom ggplot2 theme_minimal theme element_text element_blank element_line element_rect
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_sportminer()
theme_sportminer <- function(base_size = 11,
                              base_family = "",
                              grid = TRUE) {

  base_theme <- ggplot2::theme_minimal(
    base_size = base_size,
    base_family = base_family
  )

  custom_theme <- base_theme +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        size = base_size * 1.3,
        face = "bold",
        hjust = 0,
        margin = ggplot2::margin(b = 10)
      ),
      plot.subtitle = ggplot2::element_text(
        size = base_size * 0.95,
        color = "gray40",
        hjust = 0,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = base_size * 0.8,
        color = "gray50",
        hjust = 1,
        margin = ggplot2::margin(t = 10)
      ),
      axis.title = ggplot2::element_text(
        size = base_size * 1.05,
        face = "bold"
      ),
      axis.text = ggplot2::element_text(
        size = base_size * 0.9,
        color = "gray20"
      ),
      axis.line = ggplot2::element_line(
        color = "gray30",
        linewidth = 0.5
      ),
      panel.border = ggplot2::element_rect(
        color = "gray80",
        fill = NA,
        linewidth = 0.5
      ),
      panel.background = ggplot2::element_rect(
        fill = "white",
        color = NA
      ),
      plot.background = ggplot2::element_rect(
        fill = "white",
        color = NA
      ),
      legend.title = ggplot2::element_text(
        size = base_size * 0.95,
        face = "bold"
      ),
      legend.text = ggplot2::element_text(
        size = base_size * 0.85
      ),
      legend.background = ggplot2::element_rect(
        fill = "white",
        color = "gray80",
        linewidth = 0.3
      ),
      legend.key = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(
        size = base_size * 1.0,
        face = "bold",
        color = "gray20"
      ),
      strip.background = ggplot2::element_rect(
        fill = "gray95",
        color = "gray80"
      )
    )

  if (!grid) {
    custom_theme <- custom_theme +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank()
      )
  } else {
    custom_theme <- custom_theme +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_line(
          color = "gray90",
          linewidth = 0.3
        ),
        panel.grid.minor = ggplot2::element_blank()
      )
  }

  return(custom_theme)
}
