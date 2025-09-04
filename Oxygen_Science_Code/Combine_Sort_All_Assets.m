%% Combining glider and wfp assets 
glid_time = []; 
glid_DO_all = [];
glid_DO_prho_out_removed_all = [];
glid_prho_all = []; 
glid_prho_prho_out_removed_all = []; 
glid_temp_all = [];
glid_temp_prho_out_removed_all = [];
glid_sal_all = [];
glid_sal_prho_out_removed_all = [];

% Oxygen and density data has density outliers removed 
for j = [1:4 6:13]  % Ignoring Year 3 (Glider 5)  %[1:4 6:11 13] if want to ignore glider 12 as well 
    glid_time = [glid_time; glider{j}.time];
    glid_DO_all = [glid_DO_all glider{j}.doxy]; % All data, including outliers 
    glid_DO_prho_out_removed_all = [glid_DO_prho_out_removed_all glider{j}.doxy_prho_out_removed];
    glid_prho_all = [glid_prho_all glider{j}.pdens];
    glid_prho_prho_out_removed_all = [glid_prho_prho_out_removed_all glider{j}.prho_prho_out_removed];
    glid_temp_all = [glid_temp_all glider{j}.temp];
    glid_temp_prho_out_removed_all = [glid_temp_prho_out_removed_all glider{j}.temp_prho_out_removed];
    glid_sal_all = [glid_sal_all glider{j}.pracsal];
    glid_sal_prho_out_removed_all = [glid_sal_prho_out_removed_all glider{j}.sal_prho_out_removed];
end

% Create emtpy NaN matrix for each profile and fill with glider data 
glid_DO = NaN(max(wfp_prs),length(glid_time));
glid_prho = glid_DO; 
glid_temp = glid_DO;
glid_sal = glid_DO;
glid_DO_prho_out_removed = glid_DO;
glid_prho_prho_out_removed = glid_DO; 
glid_temp_prho_out_removed = glid_DO;
glid_sal_prho_out_removed = glid_DO;

for pn = 1:length(glid_time)
    glid_DO(1:1000,pn) = glid_DO_all(:,pn);
    glid_prho(1:1000,pn) = glid_prho_all(:,pn);
    glid_temp(1:1000,pn) = glid_temp_all(:,pn);
    glid_sal(1:1000,pn) = glid_sal_all(:,pn);
    glid_DO_prho_out_removed(1:1000,pn) = glid_DO_prho_out_removed_all(:,pn);
    glid_prho_prho_out_removed(1:1000,pn) = glid_prho_prho_out_removed_all(:,pn);   
    glid_temp_prho_out_removed(1:1000,pn) = glid_temp_prho_out_removed_all(:,pn);
    glid_sal_prho_out_removed(1:1000,pn) = glid_sal_prho_out_removed_all(:,pn);  
end

% Create empty NaN matrix and fill with WFP data 
wfp_DO = NaN(max(wfp_prs),length(resp.time));
wfp_DO_prho_out_removed = wfp_DO;
wfp_prho = wfp_DO; 
wfp_prho_prho_out_removed = wfp_DO;
wfp_temp = wfp_DO; 
wfp_temp_prho_out_removed = wfp_DO;
wfp_sal = wfp_DO;
wfp_sal_prho_out_removed = wfp_DO;

% WFP already has density outliers removed
for pn = 1:length(resp.time)
    wfp_DO(wfp_prs,pn) = resp.doxy(:,pn);
    wfp_DO_prho_out_removed(wfp_prs,pn) = resp.doxy_prho_out_removed(:,pn);
    wfp_prho(wfp_prs,pn) = resp.prho(:,pn);
    wfp_prho_prho_out_removed(wfp_prs,pn) = resp.prho_prho_out_removed(:,pn);
    wfp_temp(wfp_prs,pn) = resp.temp(:,pn);
    wfp_temp_prho_out_removed(wfp_prs,pn) = resp.temp_prho_out_removed(:,pn);
    wfp_sal(wfp_prs,pn) = resp.sal(:,pn);
    wfp_sal_prho_out_removed(wfp_prs,pn) = resp.sal_prho_out_removed(:,pn);
end

DO_unsorted = [glid_DO wfp_DO];
DO_prho_out_removed_unsorted = [glid_DO_prho_out_removed wfp_DO_prho_out_removed];
prho_unsorted = [glid_prho wfp_prho]; 
prho_prho_out_removed_unsorted = [glid_prho_prho_out_removed wfp_prho_prho_out_removed];
temp_unsorted = [glid_temp wfp_temp];
temp_prho_out_removed_unsorted = [glid_temp_prho_out_removed wfp_temp_prho_out_removed];
sal_unsorted = [glid_sal wfp_sal];
sal_prho_out_removed_unsorted = [glid_sal_prho_out_removed wfp_sal_prho_out_removed];
time_unsorted = [glid_time; resp.time];

[combo.time,IND] = sort(time_unsorted);
combo.doxy = DO_unsorted(:,IND); % original data 
combo.doxy_prho_out_removed = DO_prho_out_removed_unsorted(:,IND);
combo.prho = prho_unsorted(:,IND);
combo.prho_prho_out_removed = prho_prho_out_removed_unsorted(:,IND);
combo.temp = temp_unsorted(:,IND);
combo.temp_prho_out_removed = temp_prho_out_removed_unsorted(:,IND);
combo.sal = sal_unsorted(:,IND); 
combo.sal_prho_out_removed = sal_prho_out_removed_unsorted(:,IND);

% clear glid_* wfp* DO_* prho_prho_out_removed_unsorted prho_unsorted temp_* sal_* time_* IND j pn
wfp_prs = 150:1:2600; % Depths of Hilary's product