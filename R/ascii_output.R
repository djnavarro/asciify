
#' Plots an ASCII map
#'
#' @param image_map Map from ascii_map
#' @param charsize Size of the characters
#' @return A ggplot object
#' @examples
#' print("hi")
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_text
#' @importFrom ggplot2 scale_y_reverse
#' @importFrom ggplot2 theme_void
#' @export
ascii_plot <- function(image_map, charsize = 4) {
  
  pic <- ggplot2::ggplot(
    data = image_map,
    mapping = ggplot2::aes(x = x, y = y, label = label)
  ) +
    ggplot2::geom_text(size = charsize) + 
    ggplot2::scale_y_reverse() + 
    ggplot2::theme_void()
  
  return(pic)
}


#' Converts an ASCII map to a matrix
#'
#' @param image_map Map from ascii_map
#' @param file Save as csv file if not null
#' @return A matrix
#' @examples
#' print("hi")
#' @export
ascii_grid <- function(image_map, file = NULL) {
  
  # initialise as a matrix of white space
  text_grid <- matrix(
    data = " ",
    nrow = max(image_map$y), 
    ncol = max(image_map$x)
  )
  
  # this really ought to be vectorised...
  for(i in 1:dim(image_map)[1]) {
    text_grid[image_map$y[i], image_map$x[i]] <- image_map$label[i]
  }
  
  # for convenience, write to a CSV file if 
  # the user specifies a file path
  if(!is.null(file)) {
    write.table(
      x = as.data.frame(text_grid),
      file = file, 
      quote = FALSE,
      row.names = FALSE, 
      col.names = FALSE)
  }
  
  return(text_grid)
  
}


