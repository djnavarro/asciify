
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
#' @return A matrix
#' @examples
#' print("hi")
#' @export
ascii_grid <- function(image_map) {
  
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
  
  return(text_grid)
  
}

#' Writes an ASCII grid to text file
#'
#' @param text_grid Matrix from ascii_grid
#' @param file Path to text file
#' @return A matrix, invisibly
#' @examples
#' print("hi")
#' @importFrom utils write.table
#' @export
ascii_text <- function(text_grid, file) {
  
  write.table(
    x = as.data.frame(text_grid),
    file = file, 
    quote = FALSE,
    row.names = FALSE, 
    col.names = FALSE)
  
  # invisibly return the original object
  return(invisible(text_grid))
  
}

#' Writes an ASCII grid to an HTML file with the rain animation
#'
#' @param text_grid Matrix from ascii_grid
#' @param file Path to HMTL file
#' @param fontsize How big is the text
#' @param lineheight How tall is a line
#' @param turnon Animation parameter
#' @param turnoff Animation parameter
#' @return A matrix, invisibly
#' @examples
#' print("hi")
#' @importFrom dplyr %>%
#' @importFrom stringr str_replace_all
#' @importFrom stringr fixed
#' @importFrom here here
#' @export
ascii_rain <- function(text_grid, 
                       file,
                       fontsize = "5px",
                       lineheight = "4px",
                       turnon = 0.1,
                       turnoff = 0.025) {
  
  # NOTE: this function is essentially a cut and paste job
  # from the "itsraining" project. It could almost certainly
  # be done better. Job for later
  
  ncol <- ncol(text_grid)
  nrow <- nrow(text_grid)
  
  # construct the HTML table
  str <- "<table class = 'matrix'>"
  for(r in 1:nrow) {
    str <- paste0(str,"<tr>")
    for(c in 1:ncol) {
      str <- paste0(str, "<td id='c",r,"_",c,"'>",text_grid[r,c],"</td>")
    }
  }
  str <- paste0(str,"</table>")
  
  # write into the HTML template
  readLines(con = here::here("inst", "extdata", "matrix-template.html")) %>%
    stringr::str_replace_all(
      pattern = fixed("{{matrix-table-here}}"),
      replacement = fixed(str)) %>%
    stringr::str_replace_all(
      pattern = stringr::fixed("{{ncol}}"), 
      replacement = stringr::fixed(as.character(ncol))) %>%
    stringr::str_replace_all(
      pattern = stringr::fixed("{{nrow}}"), 
      replacement = fixed(as.character(nrow-1))) %>%
    stringr::str_replace_all(
      pattern = stringr::fixed("{{font-size}}"), 
      replacement = stringr::fixed(fontsize)) %>%   
    stringr::str_replace_all(
      pattern = stringr::fixed("{{line-height}}"), 
      replacement = stringr::fixed(lineheight)) %>%
    str_replace_all(
      pattern = stringr::fixed("{{onprob}}"), 
      replacement = stringr::fixed(as.character(turnon))) %>%    
    stringr::str_replace_all(
      pattern = stringr::fixed("{{offprob}}"), 
      replacement = stringr::fixed(as.character(turnoff))) %>%    
    writeLines(file)
  
  # invisibly return the original object
  return(invisible(text_grid))
  
}

