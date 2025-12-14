library(tidymodels)
library(tidyverse)
library(magrittr)
library(plotly)
library(igraph)

input_orig = read_csv("day08/input", col_names = FALSE) %>% 
  rowid_to_column()

n = 1000

# kmeans for kicks and giggles
kclust = input_orig %>%
  kmeans(centers = 8)

input_orig %$%
  plot_ly(x=X1, y=X2, z=X3, type="scatter3d", mode="markers", color = factor(kclust$cluster))

kclust$size

# Part I

distances = input_orig %>% 
  select(-rowid) %>% 
  as.matrix() %>% 
  dist() %>% 
  as.matrix() %>% 
  as_tibble(rownames = "rowid") %>% 
  pivot_longer(-rowid, names_to = "colid", values_to = "d") %>% 
  filter(d != 0) %>% 
  distinct(d, .keep_all = TRUE) %>% 
  mutate(id = paste(rowid, colid, sep = "-"))

groupings = distances %>% 
  arrange(d) %>% 
  rowid_to_column("order") %>%  
  pivot_wider(names_from = rowid, values_from = colid) %>% 
  pivot_longer(-c(d, id, order)) %>% 
  drop_na(value)

first1000 = groupings %>% 
  slice_min(order, n = n)

g = first1000 %>% 
  select(from = name, to = value) %>% 
  graph_from_data_frame(directed = FALSE)

sizes = components(g)$csize

tibble(sizes) %>% 
  slice_max(sizes, n = 3, with_ties = FALSE) %>% 
  summarise(prod(sizes))

# Part II

unconnected_boxes = input_orig %>% 
  filter(! rowid %in% first1000$name) %>% 
  filter(! rowid %in% first1000$value)

g = g + as.character(unconnected_boxes$rowid)

is_connected(g)

for (i in n:nrow(groupings)){
  n1 = groupings[i, "name"]  %>% as.character()
  n2 = groupings[i, "value"] %>% as.character()
  
  g <- g + edge(n1, n2)
  
  if (is_connected(g)){
    print(paste(n1, n2, sep = "-"))
    input_orig %>% 
      filter(rowid %in% c(n1, n2)) %>% 
      summarise(prod(X1)) %>% 
      print()
    break
  }

}
plot(g)

