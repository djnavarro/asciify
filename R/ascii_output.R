
#' Plots an ASCII character map
#'
#' @param image_map A tibble specifying a character map
#' @param charsize Size of the characters
#' @details A simple plotting function for a character map. It takes a tibble
#' as input, in the form output by the ascii_map function, and plots it using 
#' ggplot2. The charsize argument allows you to customise the size of the 
#' characters in the plot
#' @return A ggplot object. 
#' @examples
#' bayes_img <- ascii_data("bayes.png")
#' bayes_map <- ascii_map(file = bayes_img)
#' ascii_plot(bayes_map)
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
#' bayes_img <- ascii_data("bayes.png") # path to the bayes image
#' bayes_map <- ascii_map(bayes_img)    # construct ASCII map
#' bayes_grid <- ascii_grid(bayes_map)  # make grid
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
#' ## Not run:
#' bayes_img <- ascii_data("bayes.png") # path to the bayes image
#' bayes_map <- ascii_map(bayes_img)    # construct ASCII map
#' bayes_grid <- ascii_grid(bayes_map)   # make grid
#' ascii_text(bayes_grid, file = "bayes_grid.txt")
#' ## End(Not run)
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


#' Specifies path to one of the data files in the package
#'
#' @param file Name of file as a character string
#' @details This is a convenience function that returns the path to one of the
#' external data files bundled in the asciify package. There are only four 
#' such files: "bayes.png", "unicorn.png", "heart.jpg", "rain.html"
#' @return Path to file as a character string
#' @examples
#' ascii_data("bayes.png")
#' ascii_data("unicorn.png")
#' ascii_data("heart.jpg")
#' ascii_data("rain.html")
#' @export
ascii_data <- function(file) {
  system.file("extdata", file, package = "asciify", mustWork = TRUE)
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
#' ## Not run:
#' bayes_img <- ascii_data("bayes.png") # path to the bayes image
#' bayes_map <- ascii_map(bayes_img)    # construct ASCII map
#' bayes_grid <- ascii_grid(bayes_map)   # make grid
#' ascii_rain(bayes_grid, file = "bayes_rain.html")
#' ## End(Not run)
#' @importFrom dplyr %>%
#' @importFrom stringr str_replace_all
#' @importFrom stringr fixed
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
  readLines(con = ascii_data("rain.html")) %>%
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

