#' Creates ASCII art from an image
#'
#' @return Something
#' @examples
#' print("hi")
#' @importFrom imager load.image
#' @importFrom imager as.cimg
#' @importFrom imager implot
#' @importFrom imager imfill
#' @importFrom imager grayscale
#' @importFrom imager imresize
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom purrr map_dbl
#' @importFrom ggplot2 cut_number
#' @export
asciify <- function(file, charset, threshold){
  
  # load image
  im <- imager::load.image(file) 
  im <- imager::as.cimg(im[,,1:3])
  
  # function to compute the lightness of a character
  greyval <- function(chr) {
    imager::implot(
      imager::imfill(50,50,val=1), 
      text(25,25,chr,cex=5)
    ) %>% 
    imager::grayscale() %>% 
    mean()
  }
  
  # compute lightness of all characters
  g <- purrr::map_dbl(charset, greyval)
  
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
      qv = ggplot2cut_number(value, n) %>% as.integer(), # discretise
      char = charset[qv]  # map to a character
    )
  
  return(charmap)
}
