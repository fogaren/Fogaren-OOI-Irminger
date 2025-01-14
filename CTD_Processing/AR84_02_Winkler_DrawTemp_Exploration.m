% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
cal_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\final_salinity_cal_2db'; 
Wink_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\Winkler_csvs'; 
btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\btl_csvs';

%% Combine Winkler data with oxygen voltages and Leah's calibrated product 
cd(cal_dir)
btlfiles = ls('*.cbot_so'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files

cd(Wink_dir)
% removed duplicate station files to Duplicate_Stations folder
% Looks like they made some type of sal correction at sea
Winkfiles = ls('*.csv'); % List of my processed bottle files 
Winkcasts = str2num(Winkfiles(:,1:3)); % Pulls out cast numbers that have bottle files 

cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

% Removed bottle files that didn't have sal or DO discrete samples 
addpath(cal_dir)
addpath(Wink_dir)
addpath(btl_dir)

%%
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
for j = 1:height(Winkcasts) % Number of Winker files 
    btlfile_ind = find(btlcasts == Winkcasts(j)); % because not every cast has sal and winkler bottles 
    mybtlfile_ind = find(mybtlcasts == Winkcasts(j)); 
    btlsum{Winkcasts(j)} = combine_btl_files(Winkfiles(j,:),btlfiles(btlfile_ind,:),mybtlfiles(mybtlfile_ind,:));
end

% Pull all bottle files and create one large table 
btlsum_tbl = [];
for j = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{j}];
end
% btl_num = unique(btlsum_tbl.Cast);
%%

figure
subplot(2,1,1)
scatter(1:height(btlsum_tbl),btlsum_tbl.t1-btlsum_tbl.draw_temp,[],btlsum_tbl.t1,'filled')
grid on; box on
colorbar
xlabel('Winkler #')
ylabel('In situ - water draw temperature (\circC)')
c = colorbar; c.Label.String = 'In situ temp. (\circC)';
cmocean('thermal')

subplot(2,1,2)
scatter(1:height(btlsum_tbl),btlsum_tbl.Winkler_umolkg1-btlsum_tbl.Winkler_umolkg1_draw,[],btlsum_tbl.Winkler_umolkg1,'filled')
grid on; box on
colorbar
xlabel('Winkler #')
ylabel('in-situ - water draw (\mumol/kg)')
c = colorbar; c.Label.String = 'Winkler in-situ conc. (\mumol/kg)';
cmocean('thermal')
%%
figure
plot(btlsum_tbl.t1-btlsum_tbl.draw_temp,btlsum_tbl.Winkler_umolkg1-btlsum_tbl.Winkler_umolkg1_draw,'.','MarkerSize',20)
grid on
xlabel('In situ - water draw temperature (\circC)')
ylabel('Winkler conc. using in-situ - water draw (\mumol/kg)')
%%
figure
scatter(btlsum_tbl.t1-btlsum_tbl.draw_temp,btlsum_tbl.Winkler_umolkg1-btlsum_tbl.Winkler_umolkg1_draw,[],btlsum_tbl.O2sol_umolkg1_draw,'filled')
grid on
xlabel('In situ - water draw temperature (\circC)')
ylabel('Winkler conc. using in-situ - water draw (\mumol/kg)')
%%
figure
subplot(2,1,1)
plot(btlsum_tbl.draw_temp -btlsum_tbl.t1,'o')
grid on

subplot(2,1,2)
plot(btlsum_tbl.O2sol_umolkg1_draw - btlsum_tbl.O2sol_umolkg1,'o')
grid on
%%
figure
subplot(3,1,1)
plot(btlsum_tbl.draw_temp -btlsum_tbl.t1,'.','MarkerSize',20)
grid on

subplot(3,1,2)
plot(btlsum_tbl.O2sol_umolkg1_draw - btlsum_tbl.O2sol_umolkg1,'.','MarkerSize',20)
grid on

subplot(3,1,3)
plot(btlsum_tbl.O2sol_umolkg1_draw - btlsum_tbl.Winkler_umolkg1,'.','MarkerSize',20)
grid on
%%
function btlsum = combine_btl_files(Wink_btl_file,leah_btl_file,my_btl_file)

    % Format structure for conversion to table and convert to table 
    Winkbtl = readtable(Wink_btl_file,'FileType','text');
    % Reorder variables and remove unnecessary ones
    btlvars = {'station','bottle','flask_id','draw_temp','o2mll','o2umolkg'};
    Winkbtl = Winkbtl(:,btlvars);
    Winkbtl.Properties.VariableNames = {'Cast','Bottle','flask_id','draw_temp','Winkler_mLL','o2umolkg'};

    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text',NumHeaderLines=4);
    leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th190','th290','sal1','sal2','CTDoxy_mLL1','CTDoxy_mLL2','Meas_SAL','Meas_OXYG','QUAL'};
    leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
    leah_btl.Discrete_Salinity_psu = leah_btl.Meas_SAL;
    leah_btl.Meas_OXYG(leah_btl.Meas_OXYG == -9) = NaN; % replaces no data flag with NaN
    % leah_btl.CTDcal(:) = {'True'};
    % leah_btl.CTDcal = string(btl.CTDcal);    

    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','Sbeox1V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts1','oxy_volts2'};
    
    btlsum = join(Winkbtl,leah_btl,'Keys','Bottle');
    btlsum = join(btlsum,btl,'Keys','Bottle');

    btlsum.t1 = btlsum.temp1; % Calibrated product value
    btlsum.SP1 = btlsum.sal1; % Calibrated product value
    btlsum.t2 = btlsum.temp2; % Calibrated product value
    btlsum.SP2 = btlsum.sal2; % Calibrated product value
    % btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 

    % Hydrodynamic properties using calibrated sensor 1 
    btlsum.SA1 = gsw_SA_from_SP(btlsum.SP1,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT1 = gsw_CT_from_t(btlsum.SA1,btlsum.t1,btlsum.prs);
    btlsum.pt1 = gsw_pt_from_CT(btlsum.SA1,btlsum.CT1);
    btlsum.O2sol_umolkg1 = gsw_O2sol(btlsum.SA1,btlsum.CT1,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho1 = gsw_rho_CT_exact(btlsum.SA1,btlsum.CT1,btlsum.prs); % in situ density
    btlsum.prho1 = gsw_rho_CT_exact(btlsum.SA1,btlsum.CT1,0); % potential density with ref == surf
    btlsum.sigma01 = gsw_sigma0_CT_exact(btlsum.SA1,btlsum.CT1); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler_umolkg1 = btlsum.Winkler_mLL*1000*44.661./btlsum.prho1; % uses potential density 
    
    % Hydrodynamic properties using calibrated sensor 2 
    btlsum.SA2 = gsw_SA_from_SP(btlsum.SP2,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT2 = gsw_CT_from_t(btlsum.SA2,btlsum.t2,btlsum.prs);
    btlsum.pt2 = gsw_pt_from_CT(btlsum.SA2,btlsum.CT2);
    btlsum.O2sol_umolkg2 = gsw_O2sol(btlsum.SA2,btlsum.CT2,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho2 = gsw_rho_CT_exact(btlsum.SA2,btlsum.CT2,btlsum.prs); % in situ density
    btlsum.prho2 = gsw_rho_CT_exact(btlsum.SA2,btlsum.CT2,0); % potential density with ref == surf
    btlsum.sigma02 = gsw_sigma0_CT_exact(btlsum.SA2,btlsum.CT2); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler_umolkg2 = btlsum.Winkler_mLL*1000*44.661./btlsum.prho2; % uses potential density 
    
    % Hydrodynamic properties using calibrated sensor 1 sal and water draw temperature  
    btlsum.CT1_draw = gsw_CT_from_t(btlsum.SA1,btlsum.draw_temp,btlsum.prs);
    btlsum.pt1_draw = gsw_pt_from_CT(btlsum.SA1,btlsum.CT1_draw);
    btlsum.O2sol_umolkg1_draw = gsw_O2sol(btlsum.SA1,btlsum.CT1_draw,btlsum.prs,btlsum.lon,btlsum.lat); 
    btlsum.rho1_draw = gsw_rho_CT_exact(btlsum.SA1,btlsum.CT1_draw,btlsum.prs); % in situ density
    btlsum.prho1_draw = gsw_rho_CT_exact(btlsum.SA1,btlsum.CT1_draw,0); % potential density with ref == surf
    btlsum.sigma01_draw = gsw_sigma0_CT_exact(btlsum.SA1,btlsum.CT1_draw ); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler_umolkg1_draw = btlsum.Winkler_mLL*1000*44.661./btlsum.prho1_draw; % uses potential density 

    % Hydrodynamic properties using calibrated sensor 2 sal and water draw temperature  
    btlsum.CT2_draw = gsw_CT_from_t(btlsum.SA2,btlsum.draw_temp,btlsum.prs);
    btlsum.pt2_draw = gsw_pt_from_CT(btlsum.SA2,btlsum.CT2_draw);
    btlsum.O2sol_umolkg2_draw = gsw_O2sol(btlsum.SA2,btlsum.CT2_draw,btlsum.prs,btlsum.lon,btlsum.lat); 
    btlsum.rho2_draw = gsw_rho_CT_exact(btlsum.SA2,btlsum.CT2_draw,btlsum.prs); % in situ density
    btlsum.prho2_draw = gsw_rho_CT_exact(btlsum.SA2,btlsum.CT2_draw,0); % potential density with ref == surf
    btlsum.sigma02_draw = gsw_sigma0_CT_exact(btlsum.SA2,btlsum.CT2_draw ); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler_umolkg2_draw = btlsum.Winkler_mLL*1000*44.661./btlsum.prho2_draw; % uses potential density 

    btlvars = {'Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','oxy_volts1','oxy_volts2',...
        'Discrete_Salinity_psu','draw_temp','Winkler_mLL','t1','CT1','pt1','SP1','SA1','rho1','prho1','sigma01','O2sol_umolkg1','Winkler_umolkg1',...
        't2','CT2','pt2','SP2','SA2','rho2','prho2','sigma02','O2sol_umolkg2','Winkler_umolkg2',...
        'prho1_draw','O2sol_umolkg1_draw','Winkler_umolkg1_draw','prho2_draw','O2sol_umolkg2_draw','Winkler_umolkg2_draw'};
    btlsum = btlsum(:,btlvars);
end