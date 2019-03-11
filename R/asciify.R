
# function to compute the lightness of a character.
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

# function to compute the lightnesses of all characters, 
# and return a tibble. called internally but not exported
#' @importFrom purrr map_dbl
#' @importFrom tibble tibble
#' @importFrom dplyr arrange
map_chars <- function(alphabet) {
  
  alphabet_data <- tibble::tibble(
      alphabet = alphabet,
      value = purrr::map_dbl(.x = alphabet, .f = lightness)
    ) %>% 
    dplyr::arrange(value)
    
  return(alphabet_data)
}


# function to import the image in a suitable format
# called internally by ascii_map, but not exported
#' @importFrom imager load.image
#' @importFrom imager as.cimg
import_image <- function(filename) {
  im <- imager::load.image(filename) 
  im <- imager::as.cimg(im[,,1:3])
  return(im)
}


#' Creates ASCII art from an image
#'
#' @param filename A character string specifying the path to the file
#' @param alphabet A character string that lists the set of characters to use
#' @param threshold Lightness value at which to truncate
#' @return A data frame with...
#' @examples
#' print("hi")
#' @importFrom imager grayscale
#' @importFrom imager imresize
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom dplyr select
#' @importFrom purrr map_dbl
#' @importFrom ggplot2 cut_number
#' @importFrom tibble as_tibble
#' @export
ascii_map <- function(filename, 
                      alphabet = c(LETTERS, letters), 
                      threshold = .5){
  
  # set up for the mapping
  image <- import_image(filename)    # import the image
  alphabet_data <- map_chars(alphabet) # information about the alphabet
  n <- length(alphabet)           # how many characters?
  
  # convert the image to grayscale, resize, convert to data frame
  image_map <- image %>% 
    imager::grayscale() %>%  # convert to greyscale
    imager::imresize(.15)    # resize the image (hack!)
  
  # convert from cimg to data frame (with variables x, y and value),
  # and then to a tibble because I don't like data frames
  image_map <- image_map %>% 
    as.data.frame() %>%
    tibble::as_tibble()

  # strip out cells below threshold (too bright)
  image_map <- image_map %>%  
    dplyr::filter(value < threshold)
  
  # quantise image at the number of distinct characters
  image_map <- image_map %>%  
    dplyr::mutate(
      qv = ggplot2::cut_number(value, n) %>% as.integer(), # discretise
      label = alphabet_data$alphabet[qv]  # map to a character
    ) %>% 
    dplyr::select(x,y,label)
  
  return(image_map)
}
