library(tidyverse)

schema_orig = read_table("day10/input", col_names = FALSE) %>% 
  rowid_to_column() %>% 
  rename(diagram = X1) %>% 
  pivot_longer(starts_with("X")) %>% 
  filter(! str_starts(value, "\\{"))

max_buttons = schema_orig$diagram %>% str_count() %>% max() - 2 # 2 for {}
blank = rep(0, max_buttons) %>%
  paste(collapse = "") 

schema = schema_orig %>% 
  mutate(diagram = str_remove_all(diagram, "\\[|\\]")) %>% 
  rowwise() %>% 
  mutate(loc = str_locate_all(diagram, "#"),
         schema = parse(text = paste0("c", value)) %>% 
           eval() %>% 
           list() %>% 
           map(~ .x + 1)) %>% 
  ungroup() %>% 
  mutate(effect = blank,
         target = blank)

stringi::stri_sub_all(schema$effect, from = schema$schema, length = 1) <- "1"
stringi::stri_sub_all(schema$target, from = schema$loc,    length = 1) <- "1"

schema = schema %>% 
  mutate(eff = str_split(effect, pattern = "") %>% map(~ as.numeric(.x)),
         tar = str_split(target, pattern = "") %>% map(~ as.numeric(.x)))

n_machines = schema$rowid %>%  max()

sum = 0
#m = 61
for (m in 1:n_machines){
  # if (m == 61){
  #   next
  # }
  print(m)
  machine = schema %>% 
    filter(rowid == m)
  effects = pull(machine, eff)
  target = slice(machine, 1) %>% pull(target)
  n_buttons = nrow(machine)
  
  for (b in 1:n_buttons){
    #b = 11
    print(b)
    results = combn(effects, m = b) %>% 
      as.data.frame() %>% 
      map(~ Reduce(`+`, .x)) %>% 
      map(~ .x > 0 & .x %% 2 != 0) %>% 
      map(~ as.numeric(.x) %>% paste(collapse = ""))
    if (any(results == target)){
      sum = sum + b
      break
    } else if (b == n_buttons){
      print("match not found")
    }
  }
}

# too low 413
# too high 576
sum


machine = schema %>% 
  filter(rowid == 61)
effects = pull(machine, eff)
target = slice(machine, 1) %>% pull(target)
n_buttons = nrow(machine)

m61 = tibble(rowid = rep(1:max_buttons, each = n_buttons),
       effect = unlist(effects)) %>% 
  group_by(rowid) %>% 
  mutate(colid = seq_along(rowid))

m61 %>% 
  ggplot(aes(colid, rowid, colour = factor(effect))) +
  geom_point()
