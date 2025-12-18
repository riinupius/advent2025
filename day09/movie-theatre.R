library(tidyverse)

input_orig = read_csv("day09/input", col_names = c("x", "y"))

crossed = crossing(input_orig, rename(input_orig, xx = x, yy = y))

# Part I
rectangles = crossed %>% 
  mutate(area = (abs(x-xx)+1)*(abs(y-yy)+1))

max(rectangles$area)

# Part II
rectangles %>% 
  filter(area == 1525241870) %>% 
  ggplot(aes(x = x, y = y)) +
  geom_rect(aes(xmin = x, xmax = xx, ymin = y, ymax = yy),
            colour = "blue", alpha = 0.1) +
  geom_point(data = input_orig) +
  coord_fixed()

plotly::ggplotly()

# picked these out using plotly:
naughty_points = tibble(x = c(94651, 94651), y = c(48450, 50319))

# it has to involve the naughty points, trying top one first:
rectangles %>% 
  filter(x == 94651, y == 50319) %>% 
  filter(yy > y) %>% 
  rowwise() %>% 
  mutate(left = which(input_orig$x <= x  & input_orig$y <= yy)[1],
    right = which(input_orig$x <= x & input_orig$y >= y)[1],
    mult = !is.na(left*right)) %>% 
  ungroup() %>% 
  filter(mult) %>% 
  filter(left != right) %>% 
  slice_max(area)

ggsave("day09/area.png")
