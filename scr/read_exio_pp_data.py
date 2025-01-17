# -*- coding: utf-8 -*-
"""
Created on Mon Jan  6 10:10:33 2025




**********INCOMPLETE UNDER DEVELOPMENT******************







@author: richa
"""

import pandas as pd
import numpy as np



def dual_concordance_func(z):
    """
    Returns an aggregation matrix to add rows that are dependent.
    Input is a concordance matrix (z); output is a condensed concordance
    matrix (z2), where any overlapping maps are aggregated.
    
    Example:
    G = np.array([[1, 0], [1, 1]])
    dual_concordance_func(G)
    Output:
    array([[1, 1]])
    
    Author: Richard Wood, 07.05.2009
    Converted to Python: [Your Name], [Date]
    """
    def reducerows(z, F1):
        """
        Helper function to find rows that should be aggregated.
        """
        F2 = np.where(np.sum(z[F1, :] != 0, axis=0) > 0)[0]
        F11 = np.where(np.sum(z[:, F2] != 0, axis=1) > 0)[0]
        if len(F11) == len(F1):
            return F11
        return reducerows(z, F11)
    
    n = 0
    z2 = np.zeros((1, z.shape[0]), dtype=int)
    for i in range(z.shape[0]):
        if np.sum(z2[:, i] == 1) == 0:
            F111 = reducerows(z, [i])
            n += 1
            if F111.size > 0:
                z2 = np.vstack([z2, np.zeros((1, z.shape[0]), dtype=int)])
                z2[n, F111] = 1
    
    z2 = z2[1:]  # Remove the first row of zeros
    if z2.size == 0 or (z2.shape[0] == 1 and np.sum(z2) == 0):
        return np.array([])
    return z2



# --MAIN--


# Import CPA codes
codes_cpa = pd.read_excel('../auxiliary/classifications/cpa.xlsx',header=None)

naio_db = pd.read_csv('naio_10_cp15_bptopp.csv',index_col=0)
naio_db=naio_db.drop(['freq','unit','stk_flow'],axis=1)


dim_types = ['TS_BP', 'D21X31', 'OTTM', 'TS_PP']




# Extract year vector
yrvec = naio_db.columns[6::].astype(str).values

# Read country codes
countries = pd.read_excel('countries.xlsx')



# Load EXIOBASE bridge and dual concordance functions
bridge_cpa_exio_raw = pd.read_excel('../auxiliary/concordances/CPAsut64_EXIOBASEpMatrix.xlsx', index_col=0)
bridge_cpa64_48 = dual_concordance_func(bridge_cpa_exio_raw.values)
bridge_cpa48_exio = dual_concordance_func(bridge_cpa_exio_raw.values.T)

# Extract data, bridge, and calculate relative values
naio_db_yr = {}
ifppdata = {}



