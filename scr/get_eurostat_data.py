# -*- coding: utf-8 -*-
"""
Created on Mon Jan  6 10:25:47 2025

Get Eurostat National accounts (input-output) data for basic price and margins and taxes and writes to csv file.

@author: richa
"""

# Notes on meta data used in Eurostat
# [TS_BP] Total supply at basic prices 
# [D21X31] Taxes less subsidies on products 
# [OTTM] Trade and transport margins 
# [TS_PP] Total supply at purchasers' prices 



import eurostat

# Table of trade and transport margins
naio_10_cp1620= eurostat.get_data_df('naio_10_cp1620')
naio_10_cp1620.to_csv('naio_10_cp1620.csv')
# Table of taxes less subsidies on product
naio_10_cp1630= eurostat.get_data_df('naio_10_cp1630')
naio_10_cp1630.to_csv('naio_10_cp1630.csv')
#  Use table at purchasers' prices 
naio_10_cp16= eurostat.get_data_df('naio_10_cp16')
naio_10_cp16.to_csv('naio_10_cp16.csv')
# Use table at basic prices
naio_10_cp1610= eurostat.get_data_df('naio_10_cp1610')
naio_10_cp1610.to_csv('naio_10_cp1610.csv')
#  Supply table at basic prices incl. transformation into purchasers' prices 
naio_10_cp15= eurostat.get_data_df('naio_10_cp15')
naio_10_cp15.to_csv('naio_10_cp15.csv')

naio_10_cp15.ind_impv.unique()
naio_10_cp15_bptopp=naio_10_cp15[naio_10_cp15.ind_impv.isin(['TS_BP', 'D21X31','OTTM', 'TS_PP'])]
naio_10_cp15_bptopp.to_csv('../data/eurostat/naio_10_cp15_bptopp.csv')





# naio_10_cp1610a=naio_10_cp1610.copy()
# naio_10_cp1610a.columns=naio_10_cp1610.columns.str.replace(r'\\','_', regex=True)

