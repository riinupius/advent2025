import pandas as pd
import numpy as np

input_orig = pd.read_csv('day05/input-test', names=['comb'], header=None)

fresh             = input_orig[input_orig['comb'].str.contains('-')]
fresh[['a', 'b']] = fresh['comb'].str.split('-', expand=True).astype(int)
fresh             = fresh.drop(columns = 'comb')

# Part I
ingredients       = input_orig[~input_orig['comb'].str.contains('-')]
ingredients['id'] = ingredients['comb'].astype(int)
ingredients       = ingredients.drop(columns=['comb'])

inventory = ingredients.merge(fresh, how = 'cross')# cross join fresh and ingredients

inventory.query('id >= a & id <= b')['id'].nunique()

# Part II
fresh['id'] = np.arange(0, len(fresh))
fresh       = fresh.melt(id_vars='id').sort_values(by=['value']).reset_index(drop=True)
fresh['include'] = np.repeat(True, len(fresh))

for i in range(1, len(fresh)):
    print(i)
    if all(fresh.iloc[i:(i+2)]['variable'] == 'a'):
        fresh.at[i+1, 'include'] = False
        continue
    if all(fresh.iloc[i:(i+2)]['variable'] == 'b'):
        fresh.at[i, 'include'] = False


fresh.at[len(fresh)-1, 'include'] = True
keep = fresh.loc[lambda x: x['include']]
keep       = keep.drop(columns=['include'])
keep['id'] = np.arange(0, len(keep), 2).repeat(2)

wider = keep.pivot(columns='variable', index = "id")
wider.columns = ['_'.join(col).strip() for col in wider.columns.values]
wider['diff'] = wider['value_b'].sub(wider['value_a'], axis = 0) + 1

# Ah this excludes the 15 which gets caught in between. 