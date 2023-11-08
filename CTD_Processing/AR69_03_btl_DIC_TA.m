cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load DICTA_GOHSNAP2022_sample_output.mat
btl_dir = 'C:\Users\fogaren\Documents\Python\Bottle_Files\AR69-03'; % my processed bottle product 
% cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
% load AR6903_Nuts_KF.mat
% load AR6903_Processed_KF_notfinal.mat btlsum_AR6903 btlsum_tbl_AR6903

clear s
s.Cast = sample_output.Station_ID;
s.Bottle = sample_output.Niskin_ID;

s.DIC = sample_output.DIC;
s.DIC(sample_output.DIC_flag ~=6) = NaN;
s.TA = sample_output.TA;
s.TA(sample_output.TA_flag ~=6) = NaN;

s = struct2table(s);
for i = 1:height(s)
    if s.Bottle(i) > 13 % Difference in how bottles were counted on cruise
        s.Bottle(i) = s.Bottle(i)-4;
    end
end


%% Read in calibrated CTD data from netcdfs 
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03\SOI_Processed')
btlfile = readtable('bottle_data.csv','FileType','text');
vars = {'SSSCC','BTLNBR','CTDPRS','CTDTMP1','CTDTMP2','CTDCOND1','CTDCOND2','CTDSAL','BTL_SAL'};
btlfile = btlfile(:,vars);
newvars = {'Station','Bottle','prs','temp1','temp2','cond1','cond2','sal1','Discrete_Salinity_psu'};
btlfile.Properties.VariableNames = newvars;
btlfile.Cruise(:) = string('AR69-03');
btlfile.cond1 = btlfile.cond1/10; btlfile.cond2 = btlfile.cond2/10; % Change cond units 
btlfile = btlfile(2:end,:);
for i = 1:height(btlfile)
    if btlfile.Bottle(i) > 13 % Difference in how bottles were counted on cruise
        btlfile.Bottle(i) = btlfile.Bottle(i)-4;
    end
end

btl_num = unique(btlfile.Station); % Stations with bottles 

siobtl = [];
for i = 1:length(btl_num)
    ind = find(btlfile.Station == btl_num(i));
    siobtl{btl_num(i)} = btlfile(ind,:);
end
%%
cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
btlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 
DIC_casts = unique(s.Cast);
CTD_sen = 1;
DICsum = []; 
for i = 1:length(DIC_casts) % Number of Stations with bottles 
    ind = find(btlcasts == DIC_casts(i));
    DICsum{DIC_casts(i)} = combine_btl_files(siobtl{DIC_casts(i)},mybtlfiles(ind,:),s(s.Cast == DIC_casts(i),:),CTD_sen) ;
end

DICsum_tbl = [];
for i = 1:length(DIC_casts)
    DICsum_tbl = [DICsum_tbl; DICsum{DIC_casts(i)}];
end
%%
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
save AR6903_DIC_TA_KF.mat DICsum_tbl DICsum DIC_casts

function btlsum = combine_btl_files(sio_btl,my_btl_file,nutrient_table,CTD_sen)
    btlsum = nutrient_table; % Winklers for just the cast 
    
    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Latitude','Longitude'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','lat','lon'};
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum0 = join(btlsum,sio_btl,'Keys','Bottle');
    btlsum = join(btlsum0,btl,'Keys','Bottle');
 
    btlsum.t = btlsum.temp1; 
    btlsum.SP = btlsum.sal1; % Only one calibrated salinity value 
    btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
    btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
    btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT);
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0

     % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Cast','Bottle','prs','lat','lon','temp1','temp2','sal1','Discrete_Salinity_psu','CTDcal',...
    'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','DIC','TA'};
    btlsum = btlsum(:,btlvars);
end