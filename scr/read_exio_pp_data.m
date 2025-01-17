% this script extracts the relevant purchaser price and valuation data
% from the Eurostat National Accounts and maps it to EXIOBASE products

% You only need to run this script if there is new Eurostat data available.



codes_cpa=importdata('../auxiliary/classifications/cpa.xlsx')

% Download Eurostat naio_10 data and then read here:
naio_db_old.pp=readtable('../data/eurostat/naio_10_cp16.tsv','FileType','text','TreatAsEmpty',':');
naio_db_old.bp=readtable('../data/eurostat/naio_10_cp1610.tsv','FileType','text','TreatAsEmpty',':');
naio_db_old.ma=readtable('../data/eurostat/naio_10_cp1620.tsv','FileType','text','TreatAsEmpty',':');
naio_db_old.ta=readtable('../data/eurostat/naio_10_cp1630.tsv','FileType','text','TreatAsEmpty',':');

naio_db_new.pp=readtable('../data/eurostat/estat_naio_10_cp16.tsv','FileType','text','TreatAsEmpty',':');
naio_db_new.bp=readtable('../data/eurostat/estat_naio_10_cp1610.tsv','FileType','text','TreatAsEmpty',':');
naio_db_new.ma=readtable('../data/eurostat/estat_naio_10_cp1620.tsv','FileType','text','TreatAsEmpty',':');
naio_db_new.ta=readtable('../data/eurostat/estat_naio_10_cp1630.tsv','FileType','text','TreatAsEmpty',':');


naio_db = naio_db_old;
% deal with some formatting issues in the data.
naio_db.ta.Var22 = str2double(naio_db.ta.Var22);
naio_db.ma.Var33 = str2double(naio_db.ma.Var33);
naio_db.pp.Var8 = str2double(naio_db.pp.Var8);
naio_db.pp.Var10 = str2double(naio_db.pp.Var10);
naio_db.pp.Var11 = str2double(naio_db.pp.Var11);
naio_db.pp.Var12 = str2double(naio_db.pp.Var12);
naio_db.pp.Var13 = str2double(naio_db.pp.Var13);
yrvec=naio_db.pp{1,2:end}

countries=readtable('../auxiliary/classifications/countries.xlsx');

% extract the hfce from the naio data:
naio_db.bp_mat=extract_naio_hfce(naio_db.bp,codes_cpa,countries.code);
naio_db.pp_mat=extract_naio_hfce(naio_db.pp,codes_cpa,countries.code);
naio_db.ma_mat=extract_naio_hfce(naio_db.ma,codes_cpa,countries.code);
naio_db.ta_mat=extract_naio_hfce(naio_db.ta,codes_cpa,countries.code);

% load the bridge to EXIOBASE, and remove dependencies.
bridge_cpa_exio_raw=importdata('../auxiliary/concordances/CPAsut64_EXIOBASEpMatrix.xlsx')
bridge_cpa64_48=dualconcordancefunc(bridge_cpa_exio_raw.data);
bridge_cpa48_exio=dualconcordancefunc(bridge_cpa_exio_raw.data');
%% extract data from tables, bridge and calculate relative values
clear ifppdata naio_db_yr
for i=1:32
    tmp=num2str(yrvec(i))
    naio_db_yr.(['x',tmp]).bp_mat=array2table(naio_db.bp_mat(:,:,i),'RowNames',codes_cpa,'VariableNames',countries.code);
    naio_db_yr.(['x',tmp]).pp_mat=array2table(naio_db.pp_mat(:,:,i),'RowNames',codes_cpa,'VariableNames',countries.code);
    naio_db_yr.(['x',tmp]).ma_mat=array2table(naio_db.ma_mat(:,:,i),'RowNames',codes_cpa,'VariableNames',countries.code);
    naio_db_yr.(['x',tmp]).ta_mat=array2table(naio_db.ta_mat(:,:,i),'RowNames',codes_cpa,'VariableNames',countries.code);
    naio_db_yr.(['x',tmp]).bp_mat_exio=bridge_cpa_exio_raw.data'*naio_db.bp_mat(:,:,i);
    naio_db_yr.(['x',tmp]).pp_mat_exio=bridge_cpa_exio_raw.data'*naio_db.pp_mat(:,:,i);
    naio_db_yr.(['x',tmp]).ma_mat_exio=bridge_cpa_exio_raw.data'*naio_db.ma_mat(:,:,i);
    naio_db_yr.(['x',tmp]).ta_mat_exio=bridge_cpa_exio_raw.data'*naio_db.ta_mat(:,:,i);
    naio_db_yr.(['x',tmp]).ta_rel_exio=naio_db_yr.(['x',tmp]).ta_mat_exio./(naio_db_yr.(['x',tmp]).bp_mat_exio+eps);
    naio_db_yr.(['x',tmp]).ma_rel_exio=naio_db_yr.(['x',tmp]).ma_mat_exio./(naio_db_yr.(['x',tmp]).bp_mat_exio+eps);  
    naio_db_yr.(['x',tmp]).ta_rel_pp_exio=naio_db_yr.(['x',tmp]).ta_mat_exio./(naio_db_yr.(['x',tmp]).pp_mat_exio+eps);
    naio_db_yr.(['x',tmp]).ma_rel_pp_exio=naio_db_yr.(['x',tmp]).ma_mat_exio./(naio_db_yr.(['x',tmp]).pp_mat_exio+eps); 
    naio_db_yr.(['x',tmp]).bp_rel_pp_exio=naio_db_yr.(['x',tmp]).bp_mat_exio./(naio_db_yr.(['x',tmp]).pp_mat_exio+eps);    
    % where is there actually data?
    ifppdata.(['x',tmp])=(~isnan(sum(naio_db_yr.(['x',tmp]).ta_rel_exio))&(sum(naio_db_yr.(['x',tmp]).ta_rel_exio)>0))';
end
ifppdata_tab=struct2table(ifppdata,"RowNames",countries.code);
ifany=sum(ifppdata_tab{:,:},2)

save('../data/eurostat/pp_to_bp_data.mat',"naio_db_yr","ifany","ifppdata_tab")

sum(naio_db_yr.x2010.bp_mat{:,:},1)./sum(naio_db_yr.x2010.pp_mat{:,:},1);
