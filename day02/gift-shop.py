import pandas as pd
import numpy as np

with open('day02/input', 'r') as f:
    ranges_input = f.readline().strip().split(sep = ",")

# Part I
ranges = pd.DataFrame(ranges_input, columns=['ranges'])
ranges[['start', 'end']] = ranges['ranges'].str.split('-', n=1, expand=True).astype(int)

ranges_list = [np.arange(row['start'], row['end']+1, 1) for _, row in ranges.iterrows()]
flattened = np.concatenate(ranges_list).astype(str)

ids = pd.DataFrame({'value': flattened})
ids['str_count'] = ids['value'].str.len()

ids = ids[ids['str_count'] % 2 == 0]

# split values into two columns first and second half
ids[['first_half', 'second_half']] = ids.apply(
    lambda row: pd.Series([
        row['value'][:row['str_count'] // 2],
        row['value'][row['str_count'] // 2:]
    ]),
    axis=1
)

# count lines where first_half is equal to second_half
ids['invalid'] = (ids['first_half'] == ids['second_half'])

# make values int again and sum invalids
ids['value'] = ids['value'].astype(int)
result = ids.loc[ids['invalid'], ['value']].sum()
print(result)

# Part II
