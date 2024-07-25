% First day to last day timeseries
% Calculate daily mean for combined dataset 
% Includes daily mean of original data (w/outliers) for future data
% coverage calculation in errorbar calculation 

newtime = datenum(2014,09,11,00,00,00):combo.time(end); 

DOmean = []; % prho/DO outliers removed 
prhomean = []; % prho/DO outiers removed 
DOallmean = []; % w/ outliers 
for j = 1:length(newtime)-1
    indstart  = find(combo.time >= newtime(j),1,'first');
    indend = find(combo.time < newtime(j+1),1,'last');
    ind = indstart:indend;

    DOmean(:,j) = mean(combo.doxy_outs_removed(:,ind),2,'omitnan');
    prhomean(:,j) = mean(combo.prho_outs_removed(:,ind),2,'omitnan');
    DOallmean(:,j) = mean(combo.doxy(:,ind),2,'omitnan');
end

time = (newtime(1)+ 12/24):(newtime(end-1)+12/24);
daily.time = time';
daily.doxy = DOmean;
daily.prho = prhomean;
daily.doxy_w_outliers = DOallmean;

clear time newtime DOallmean DOmean prhomean indstart indend ind j 

        
