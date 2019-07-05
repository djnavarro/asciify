utils::globalVariables(c("x", "y", "label", "value"), package = "asciify")

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
  
  # create the tibble
  dictionary <- tibble::tibble(
      character = alphabet,
      value = purrr::map_dbl(.x = alphabet, .f = lightness)
    ) 
  
  # sort it and return
  dictionary <- dictionary %>% 
    dplyr::arrange(value)
    
  return(dictionary)
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

# use the letter dictionary to assign a character to each
# cell in the data set 
#' @importFrom ggplot2 cut_number
#' @importFrom dplyr %>%
label_with <- function(data, dictionary) {
  
  nletters <- dim(dictionary)[1] # how many characters?
  
  which_char <- data$value %>% 
    ggplot2::cut_number(n = nletters) %>% 
    as.integer()
  
  data$label <- dictionary$character[which_char]
  return(data)
  
}


# construct the image map
#' @importFrom imager grayscale
#' @importFrom imager imresize
#' @importFrom dplyr %>%
#' @importFrom dplyr filter
#' @importFrom tibble as_tibble
map_image <- function(image, threshold, rescale) {
  
  # if the user does not specify the rescale, set it so that
  # the larger dimension is 100 cells in size
  if(is.null(rescale)) {
    img_size <- dim(image)[1:2]
    rescale <- 100 / max(img_size)
    warning("Using a rescale value of ", round(rescale, digits = 3))
  }
  
  # convert the image to grayscale, resize, convert to data frame
  image_map <- image %>% 
    imager::grayscale() %>%  # convert to greyscale
    imager::imresize(scale = rescale)    # resize the image (hack!)
  
  # convert from cimg to data frame (with variables x, y and value),
  # and then to a tibble because I don't like data frames
  image_map <- image_map %>% 
    as.data.frame() %>%
    tibble::as_tibble()
  
  # strip out cells below threshold (too bright)
  image_map <- image_map %>%  
    dplyr::filter(value < threshold)
  
  return(image_map)
}


#' Creates ASCII art from an image
#'
#' @param file A character string specifying the path to the file
#' @param alphabet A character vector that lists the set of characters to use
#' @param rescale Scale to resize image to (if NULL, sets maximum size of 100x100)
#' @param threshold Lightness value at which to truncate
#' @details This is the workhorse function for the package. The user specifies 
#' the path to the image fil` as a character vector, and the function returns
#' a tibble specifying the map. You can customise the set of characters used to
#' render the image by changing the alphabet argument. The amount of whitespace
#' in the ASCII image depends on the threshold parameter, which specifies the
#' maximum brightness (in greyscale terms, from 0 to 1) at which the relevant 
#' cell in the output will be mapped to a character. Pixels in the image 
#' brighter than the threshold are automatically mapped to whitespace. Finally,
#' you can "rescale" the input image. By default, images are rescaled so that 
#' the largest dimension is 100 pixels, but you can choose any rescaling factor
#' you want. If your original image is 600x400 you could specify rescale = .1 
#' which would result in a character map that is 60x40 characters is size
#' @return The function returns a tibble with three variables. The x and y 
#' variables specify co-ordinates on the grid, and the label variable specifies
#' the character that should be shown at that point. Whitespace characters are
#' not included in the output.
#' @examples
#' bayes_img <- ascii_data("bayes.png")
#' bayes_map <- ascii_map(file = bayes_img)
#' bayes_map
#' @importFrom dplyr %>%
#' @importFrom dplyr select
#' @export
ascii_map <- function(file, 
                      alphabet = letters, 
                      rescale = NULL,
                      threshold = .5){
  
  image <- import_image(file)   # import the image
  dictionary <- map_chars(alphabet) # information about the alphabet
  
  image_map <- image %>% 
    map_image(threshold, rescale) %>%  # construct map
    label_with(dictionary) %>%  # annotate it
    dplyr::select(x,y,label)    # drop junk variables
  
  return(image_map)
}
