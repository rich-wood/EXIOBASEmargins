# -*- coding: utf-8 -*-
"""
Created on Mon Jan  6 10:05:51 2025

@author: richa
"""

import numpy as np
import pandas as pd
import numpy as np

def extract_naio_hfce(naio_db, codes_cpa, countries):
    """
    Extracts relevant purchaser price and valuation data from the 
    Eurostat National Accounts.

    Parameters:
        naio_db (pd.DataFrame): DataFrame with NAIO data.
        codes_cpa (list): List of CPA codes.
        countries (list): List of country codes.
    
    Returns:
        np.ndarray: Extracted NAIO data.
    """
    # Split `Var1` column to create an ID table
    tmp_naio_db_pp_id = naio_db['Var1'].str.split(',', expand=True)
    naio_db_id = pd.DataFrame(tmp_naio_db_pp_id.iloc[1:, :].values, columns=tmp_naio_db_pp_id.iloc[0, :])
    naio_db_data = naio_db.iloc[1:, 1:33].astype(float).values

    induse = 'P3_S14'
    stk_flow = 'TOTAL'

    # Prepare the output array
    naio_db_id_extracted = np.zeros((len(codes_cpa), len(countries), naio_db_data.shape[1]))

    for jj, geo in enumerate(countries):
        # Map country codes
        if geo == 'GB':
            geo = 'UK'
        elif geo == 'GR':
            geo = 'EL'

        # Filter rows based on the specified conditions
        filter_country = (
            (naio_db_id['geo\\time'] == geo) &
            (naio_db_id['induse'] == induse) &
            (naio_db_id['stk_flow'] == stk_flow) &
            (naio_db_id['unit'] == 'MIO_EUR')
        )
        naio_db_id_extract_id = naio_db_id[filter_country]
        naio_db_id_extract_data = naio_db_data[filter_country.values, :]

        # Process each CPA code
        for i, code in enumerate(codes_cpa):
            naio_db_id_extract = naio_db_id_extract_id['prod_na'].str.contains(code, na=False)

            # Handle cases where more than one match is found
            if naio_db_id_extract.sum() > 1 and code != 'CPA_L68':
                raise ValueError(f"More than one match found for CPA code {code}.")
            
            naio_db_id_extracted[i, jj, :] = naio_db_id_extract_data[naio_db_id_extract.values, :].sum(axis=0)

    return naio_db_id_extracted
