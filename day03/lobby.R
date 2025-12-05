library(tidyverse)

batteries_orig = read_csv("day03/input-test", col_names = "value")


batteries = batteries_orig %>% 
  rowid_to_column("battery_id") %>% 
  separate_longer_position(value, width = 1) %>% 
  mutate(value = parse_number(value)) %>% 
  group_by(battery_id) %>% 
  mutate(order = row_number()) %>% 
  mutate(id = paste(battery_id, order, sep = "-"))

n = max(batteries$order)

first = batteries %>% 
  filter(order != n) %>% 
  slice_max(value, with_ties = FALSE) %>% 
  rename(id_max = id, value_max = value, order_max = order)

second = batteries %>% 
  left_join(first) %>% 
  #filter(order > order_max) %>% 
  slice_max(battery, with_ties = FALSE)

combine = second %>% 
  pivot_longer(c(battery, battery_max)) %>% 
  group_by(battery_id) %>% 
  arrange(battery_id, order) %>% 
  summarise(joltage = paste(value, collapse = "") %>% parse_number())


combine %>% 
  summarise(sum(joltage))
