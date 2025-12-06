library(tidyverse)

filename = "day06/input"

input_orig = read_table(filename, col_names = FALSE) %>% 
  janitor::remove_empty()

orders = slice_tail(input_orig, n = 1) %>% 
  pivot_longer(everything(), values_to = "order")

# Part I
homework = input_orig %>% 
  slice(-n()) %>% 
  pivot_longer(everything()) %>% 
  mutate(value = parse_number(value)) %>% 
  left_join(orders)
  

sums = homework %>% 
  filter(order == "+") %>% 
  group_by(name) %>% 
  summarise(sums = sum(value)) %>% 
  summarise(total = sum(sums))

mults = homework %>% 
  filter(order == "*") %>% 
  group_by(name) %>% 
  summarise(mult = prod(value)) %>% 
  summarise(total = sum(mult))

paste(sums$total + mults$total)

# Part II
line = read_lines(filename, skip = nrow(input_orig) - 1) %>% 
  str_split_1("")

splits = tibble(line) %>% 
  rowid_to_column("loc") %>% 
  mutate(group = if_else(line != " ", row_number(), NA)) %>% 
  fill(group, .direction = "down") %>% 
  count(group)

input_orig2 = read.fwf(filename, widths = splits$n)

orders = orders %>% 
  mutate(name = str_replace(name, "X", "V"))

homework = input_orig2 %>% 
  slice(-n()) %>% 
  rowid_to_column() %>% 
  pivot_longer(-rowid, names_to = "column") %>% 
  mutate(value = str_remove(value, " $")) %>% # rem one space from end
  separate_longer_position(value, width = 1) %>% 
  group_by(rowid, column) %>% 
  mutate(loc = row_number()) %>% 
  filter(value != " ") %>% 
  group_by(column, loc) %>% 
  summarise(value = paste0(value, collapse = "") %>% parse_number()) %>% 
  arrange(column) %>% 
  left_join(orders, by = join_by(column == name))


sums = homework %>% 
  filter(order == "+") %>% 
  group_by(column) %>% 
  summarise(sums = sum(value)) %>% 
  summarise(total = sum(sums))

mults = homework %>% 
  filter(order == "*") %>% 
  group_by(column) %>% 
  summarise(mult = prod(value)) %>% 
  summarise(total = sum(mult))

paste(sums$total + mults$total)
