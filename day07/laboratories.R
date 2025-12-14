library(tidyverse)
library(igraph)

filename = "day07/input-test"
len = readLines(filename, 1) |> str_count("")


input_orig = read.fwf(filename, widths = rep(1, len)) %>% 
  rowid_to_column("row")

lastrow = paste(nrow(input_orig), 1:len,  sep = "-")
start   = paste(which(input_orig == "S", arr.ind = TRUE)  - c(0, 1), collapse = "-")

# Part I
dir = tibble(value  = c(".", "S", "^", "^"),
             dx     = c( 1,   1,   0,   0),
             dy     = c( 0,   0,  -1,   1))

manifold = input_orig %>% 
  pivot_longer(-row, names_to = "col") %>% 
  mutate(col = parse_number(col)) %>% 
  left_join(dir, relationship = "many-to-many") %>% 
  mutate(nbx = row + dx, nby = col + dy) %>% 
  mutate(from = paste(row, col, sep = "-"), to = paste(nbx, nby, sep = "-"))

splitters  = manifold %>% 
  filter(value == "^") %>% 
  distinct(from) %>% 
  pull(from)

g = manifold %>% 
  select(from, to, value) %>% 
  mutate(value = as.numeric(value == "^")) %>% 
  graph_from_data_frame()

# This is fine for test, but runs out of memory for real input
# paths = all_simple_paths(g, from = start, to = lastrow)
# splitters %in% names(unlist(paths)) %>% sum()

d = distances(g, v = start, to = splitters, mode = "out")
sum(d < Inf)


# Part II
paths = all_simple_paths(g, from = start, to = lastrow)
paths %>% length()
