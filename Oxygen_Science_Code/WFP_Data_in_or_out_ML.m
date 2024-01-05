clearvars 
close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')
wfp_prs = 150:1:2600;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load blended_MLD_prelim_final.mat

%% Remove Nans for interpolation 

dt0 = wfp_dt;
wfp_mld0 = wfp_mld;

dt0(isnan(wfp_mld)) = [];
wfp_mld0(isnan(wfp_mld)) = [];
%%
figure
plot(wfp_dt,wfp_mld,'.')
plot(dt0,wfp_mld0,'.')
axis ij
datetick; grid on

figure
plot(dt0(1:end-1),diff(dt0))
%% Find start and end of wfp mld each year 
wfp_dt_end = find(diff(dt0) > 150);
wfp_dt_start = wfp_dt_end +1; 
wfp_dt_start = [1; wfp_dt_start];
wfp_dt_end = [wfp_dt_end; length(dt0)];

% Find closest value because of time difference in wggmerge and wggmerge_fl for year 8 
for j = 1:length(wfp_dt_end)
    [~,ind_start(j)] = min(abs(wggmerge.time - dt0(wfp_dt_start(j))));
    [~,ind_end(j)] = min(abs(wggmerge.time - dt0(wfp_dt_end(j))));
end

%% Interpolate checked mld outputs onto wfp timeseries

vq = interp1(dt0,wfp_mld0,wggmerge.time,'linear','extrap');

figure % check interpolation
plot(wggmerge.time,vq,'.')
hold on
plot(dt0,wfp_mld0,'.')
axis ij
datetick; grid on
plot(dt0(wfp_dt_start),wfp_mld0(wfp_dt_start),'ro')
plot(wggmerge.time(ind_start),vq(ind_start),'m*')
plot(dt0(wfp_dt_end),wfp_mld0(wfp_dt_end),'ok')
plot(wggmerge.time(ind_end),vq(ind_end),'c*')

%% Overwrite time periods with no MLD from wfp CHl with NaN

for j = 1:length(ind_end)-1 
    vq(ind_end(j):ind_start(j+1)) = NaN;
end

vq(1:ind_start(1)) = NaN;
vq(ind_end(end):length(vq)) = NaN; 

%%
vq = round(vq); % interpolation results in non interger MLDs 

data_in_mld = zeros(size(wggmerge.doxy));

for j = 1:length(wggmerge.time)
    if ~isnan(vq(j))
        [~,b] = find(wfp_prs == vq(j));
        data_in_mld(1:b,j) = 1; 
        clear b
    end
end

%%

DO_not_inML = wggmerge.doxy;
DO_not_inML(data_in_mld == 1) = NaN;

z = 1000;
figure
plot(wggmerge.time,wggmerge.doxy(wfp_prs == z,:),'.')
hold on
plot(wggmerge.time,DO_not_inML(wfp_prs == z,:),'.')
datetick
grid on

%%
z = find(wfp_prs == 500);
yy1 = smooth(wggmerge.time,wggmerge.doxy(z,:),0.05,'loess');
yy2 = smooth(wggmerge.time,wggmerge.doxy(z,:),0.075,'loess');
yy3 = smooth(wggmerge.time,wggmerge.doxy(z,:),0.1,'loess');

figure
plot(wggmerge.time,wggmerge.doxy(z,:),'.')
hold on
plot(wggmerge.time,yy1,'Linewidth',1.5)
plot(wggmerge.time,yy2,'Linewidth',1.5)
plot(wggmerge.time,yy3,'Linewidth',1.5)



