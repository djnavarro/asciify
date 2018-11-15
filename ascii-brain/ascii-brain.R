library(tidyverse)
library(imager)
library(here)

# function to convert an image to an ascii character map
asciify <- function(file, charset, threshold){
  
  # load image
  im <- load.image(file) 
  im <- as.cimg(im[,,1:3])
  
  # function to compute the lightness of a character
  greyval <- function(chr) {
    implot(imfill(50,50,val=1), text(25,25,chr,cex=5)) %>% 
      grayscale %>% 
      mean
  }
  
  # compute lightness of all characters
  g <- map_dbl(charset, greyval)
  
  # sort and count
  charset <- charset[order(g)]
  n <- length(charset)
  
  # convert the image to grayscale, resize, convert to data.frame, 
  # quantise image at the number of distinct characters
  charmap <- grayscale(im) %>%  # convert to greyscale
    imresize(.3) %>%       # resize the image (hack!)
    as.data.frame %>%          # convert to tibble
    filter(value < threshold) %>%   # threshold the image
    mutate(
      qv = cut_number(value, n) %>% as.integer, # discretise
      char = charset[qv]  # map to a character
    )
  
  return(charmap)
}


# msg <-
# 'complex_human_data %>% 
#   dplyr::filter(
#     where = "Melbourne",
#     when = "Dec 9-14, 2018"
#   )'

msg <- "Complex Human Data Summer School 
Melbourne, December 9-14, 2018"


# construct a character set using the workshop title
asc <- msg %>%
  str_squish() %>%
  str_split(pattern = "") %>%
  first() %>%
  unique()

# some parameters
charsize <- 6
threshold <- .6
imgwidth <- 1600
imgheight <- 1100

# filenames
input <- here("ascii-brain", "brain-picture.jpg")  
output <- here("ascii-brain", "ascii-brain-chdss.png")
textfile <- here("ascii-brain", "ascii-brain-chdss.txt")

# construct ascii character map
charmap <- asciify(
  file = input,
  charset = asc,
  threshold = threshold)

# draw the plot
pic <- charmap %>% 
  ggplot(aes(x, y)) +
  geom_text(aes(label = char), size = charsize) + 
  scale_y_reverse() + 
  theme_void()

# add the annotation
pic <- pic + 
  annotate(geom = "text", label = msg, 
           x = 2, y = 7, size = 8, hjust = 0)

# draw the plot
plot(pic)

# write the image
dev.print(
  device = png, 
  filename = output, 
  width = imgwidth, 
  height = imgheight
)


# export the text
nrow <- max(charmap$y)
ncol <- max(charmap$x)
txt <- matrix(" ",nrow,ncol)
for(i in 1:dim(charmap)[1]) {
  txt[charmap$y[i],charmap$x[i]] <- charmap$char[i]
}
write.table(
  x = as.data.frame(txt),
  file = textfile, 
  quote = FALSE,
  row.names = FALSE, 
  col.names = FALSE)