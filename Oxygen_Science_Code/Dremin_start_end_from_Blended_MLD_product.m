% Creates Dremineralization(z) for each remineralization year using blended
% mixed layer product (mostly from WFP, some gliders, and some ARGO)

% Output is indexed by scientific year 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat

%%
% Remove nan data and create MLDs for every day
day_dn0 = datenum(blended_mld_daily_all.time);
day_mld0 = blended_mld_daily_all.mld; 
day_dn0(isnan(day_mld0)) = [];
day_mld0(isnan(day_mld0)) = [];

% This overwrites the one point in Winter 6 that is the deepest early in
% the season; Makes Dremin max for year 6 longer and for year 7 shorter
% Doesn't change integrated rates; decided not to use 

% day_dn0(2191) = [];
% day_mld0(2191) = []; % If want to change winter max for year 6

day_mld = interp1(day_dn0,day_mld0,datenum(blended_mld_daily_all.time),'linear');
day_mld = round(day_mld); % Because oxygen product is gridded by meter
day_dn = datenum(blended_mld_daily_all.time); 
blended_mld_daily_all.dn = day_dn; 

mld_max = islocalmax(day_mld,'MinSeparation',days(270),'SamplePoints',blended_mld_daily_all.time);
mld_max = find(mld_max); 
mld_max_ind = mld_max(1:8); % Ignore last winter, past my timeseries 

%% Create binary in or below the ML product

% %% Find the depth of the ML
% Everything below is a zero (not in ML)
% Everything above and == ML is a one (in the ML)
 
depth = 1:2000; 
data_in_mld = zeros(length(depth),length(day_dn));
% zeros for data not in the mixed layer

% replace with ones for data points that are in the mixed layer 
for j = 1:length(day_dn)
        [~,b] = find(depth == day_mld(j));
        data_in_mld(1:b,j) = 1; 
        clear b
end

%% Find the respiration length for each isobar each stratification season 
% Converts from deployment year to scientific analysis year 

resp_start = [];
resp_end = [];
resp_length_days = [];
for j = 2:8 % deployment yr 
    % 
    time_chunk1 = find(day_dn >= datenum(2012+j,08,15) & day_dn <= datenum(2013+j,08,15)); % find time between maximum winter ML mixing
    time_chunk2 = find(day_dn >= datenum(2013+j,08,15) & day_dn <= datenum(day_dn(mld_max(j))));
    
    % Indexed by scientific year 
    for z = 1:length(depth)
        [~,b1] = find(data_in_mld(z,time_chunk1),1,'last'); 
        if isempty(b1)
            resp_start{j-1}(z) = day_dn(mld_max(j-1));
        else
            resp_start{j-1}(z) = day_dn(time_chunk1(b1));
        end

        [~,b2] = find(data_in_mld(z,time_chunk2),1,'first');
        if isempty(b2)
            resp_end{j-1}(z) = day_dn(mld_max(j));
        else
            resp_end{j-1}(z) = day_dn(time_chunk2(b2));
        end
        
        resp_length_days{j-1}(z) = resp_end{j-1}(z) - resp_start{j-1}(z);

    end
end

MLD_winter_max = day_mld(mld_max_ind(2:end)); 
clear time_chunk* z mld_max j depth data_in_mld b1 b2...
    day_dn0 day_mld0 clear blended_mld_daily %day*
