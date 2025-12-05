import pandas as pd
import numpy as np

rotations = pd.read_csv('day01/input', names=['instr'], header=None)

# Part I
rotations = rotations.assign(
    n=rotations['instr'].replace({'R': '', 'L': '-'}, regex=True).astype(int),
    sum=lambda df: df['n'].cumsum() + 50
)

# anything that is a multiple of 100 is same as location 0
(rotations['sum'] % 100 == 0).sum()

# Part II
# YOLO - eyeballed the previous locations for the range needed,
# 12k would be enough, doing 15k for good measure
hundreds = np.arange(-15000, 15001, 100)

rotations = rotations.assign(
    lag=lambda df: df['sum'].shift(1).fillna(50),
    count_in_range=lambda df: df.apply(
        lambda row: np.sum((hundreds > row['lag']) & (hundreds < row['sum']) |
                           (hundreds < row['lag']) & (hundreds > row['sum'])),
        axis=1
    )
)
sum(rotations['count_in_range']) + (rotations['sum'] % 100 == 0).sum()
