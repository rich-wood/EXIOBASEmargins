function naio_db_id_extracted=extract_naio_hfce(naio_db,codes_cpa,countries)
% this function extracts the relevant purchaser price and valuation data
% from the Eurostat National Accounts.

% You only need to run this script if there is new Eurostat data available.

% the function is called from 
% read_exio_pp_data.m

% Note that the country naming and number is specified partially manually
% below.



tmp_naio_db_pp_id=split(naio_db.Var1,',');
naio_db_id=array2table(tmp_naio_db_pp_id(2:end,:),'VariableNames',tmp_naio_db_pp_id(1,:));
naio_db_data=naio_db{2:end,2:33};


induse='P3_S14';
stk_flow='TOTAL';
%%
for jj=1:27
    geo=countries{jj};
    if strcmp('GB',geo)
        geo='UK'
    elseif strcmp('GR',geo)
        geo='EL'
    end
    filter_country=strcmp(naio_db_id.("geo\time"),geo) & strcmp(naio_db_id.induse,induse) & strcmp(naio_db_id.stk_flow,stk_flow) & strcmp(naio_db_id.unit,'MIO_EUR');
    naio_db_id_extract_id=naio_db_id(filter_country,:);
    naio_db_id_extract_data=naio_db_data(filter_country,:);

    for i=1:length(codes_cpa)
        naio_db_id_extract=contains(naio_db_id_extract_id.prod_na,codes_cpa{i}); 
        if sum(naio_db_id_extract)>1 & ~strcmp(codes_cpa{i},'CPA_L68') %imputed and actual rents are summed
            keyboard
        end
        naio_db_id_extracted(i,jj,:)=sum(naio_db_id_extract_data(naio_db_id_extract,:),1);
    end
end