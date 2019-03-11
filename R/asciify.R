
# function to compute the lightness of a character
# called internally by ascii_map, but not exported
#' @importFrom graphics text
#' @importFrom imager implot
#' @importFrom imager imfill
#' @importFrom imager grayscale
lightness <- function(chr) {
  imager::implot(
    imager::imfill(50, 50, val = 1), 
    graphics::text(x = 25, y = 25, labels = chr, cex = 5)
  ) %>% 
  imager::grayscale() %>% 
  mean()
}


#' Creates ASCII art from an image
#'
#' @param file A character string specifying the path to the file
#' @param charset A character string that lists the set of characters to use
#' @param threshold Lightness value at which to truncate
#' @return A data frame with...
#' @examples
#' print("hi")
#' @importFrom imager load.image
#' @importFrom imager as.cimg
#' @importFrom imager grayscale
#' @importFrom imager imresize
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom purrr map_dbl
#' @importFrom ggplot2 cut_number
#' @export
ascii_map <- function(file, charset = c(LETTERS, letters), threshold = .5){
  
  # load image
  im <- imager::load.image(file) 
  im <- imager::as.cimg(im[,,1:3])
  
  # compute lightness of all characters
  g <- purrr::map_dbl(.x = charset, .f = lightness)
  
  # sort and count
  charset <- charset[order(g)]
  n <- length(charset)
  
  # convert the image to grayscale, resize, convert to data.frame, 
  # quantise image at the number of distinct characters
  charmap <- imager::grayscale(im) %>%     # convert to greyscale
    imager::imresize(.15) %>%              # resize the image (hack!)
    as.data.frame() %>%                    # convert to tibble
    dplyr::filter(value < threshold) %>%   # threshold the image
    dplyr::mutate(
      qv = ggplot2::cut_number(value, n) %>% as.integer(), # discretise
      char = charset[qv]  # map to a character
    )
  
  return(charmap)
}
