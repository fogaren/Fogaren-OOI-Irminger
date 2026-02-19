%% Find density outliers for each asset during Dremin
% Does this for each glider and than does it for WFP during each Dremin

% Overwrites outliers with NaNs 
for j = 1:13 % Glider numbers 
    glider{j}.doxy_prho_out_removed = glider{j}.doxy; % Copy oxygen data for glider to then overwrite outliers 
    glider{j}.prho_prho_out_removed = glider{j}.pdens; % Copy prho data for glider
    glider{j}.temp_prho_out_removed = glider{j}.temp; % Copy temp data 
    glider{j}.sal_prho_out_removed = glider{j}.pracsal; % Copy sal data 
    glider{j}.prho_bad = NaN(size(glider{j}.pracsal)); % Copy sal data
   
    % Assign glider number, science year for Dremin start and end 
    if j == 1 || 2 || 3
        yr = 1;
    elseif j == 4 
        yr = 2;
    elseif j == 5
        yr = 3;
    elseif j == 6 || 7
        yr = 4;
    elseif j == 8 || 9
        yr = 5;
    elseif j == 10 || 11
        yr = 6;
    elseif j == 12 || 13
        yr = 7;
    end

    for z =  1:1000

        if resp_end{yr}(z) > resp_start{yr}(z)
            [resp_start_z,~] = find(glider{j}.time > resp_start{yr}(z),1,'first');
            [resp_end_z,~] = find(glider{j}.time < resp_end{yr}(z),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            
            % Identify prho outliers 
            prho_detrend = detrend(glider{j}.pdens(z,resp_ind),'omitnan');
            bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',glider{j}.time(resp_start_z:resp_end_z));
            
            % Overwrite prho outliers with NaN in both density and oxygen datasets  
            glider{j}.doxy_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            glider{j}.prho_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            glider{j}.temp_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            glider{j}.sal_prho_out_removed(z,resp_ind(bad_prho ==1)) = NaN;
            glider{j}.prho_bad(z,resp_ind) = bad_prho; 

        end
    end
end

%% Working with WFP data
% Sort time to be in ascending order
[time,IND] = sort(wggmerge.time);
doxy = wggmerge.doxy(:,IND);
prho = wggmerge.pdens(:,IND);
temp = wggmerge.temp(:,IND);
sal = wggmerge.pracsal(:,IND);

resp.time = time;
resp.doxy = doxy; 
resp.prho = prho; 
resp.temp = temp; 
resp.sal = sal; 
resp.doxy_prho_out_removed = resp.doxy; % Copy oxygen data to then overwrite outliers with NaN 
resp.prho_prho_out_removed = resp.prho; % Copy prho data 
resp.temp_prho_out_removed = resp.temp; % Copy temp data
resp.sal_prho_out_removed = resp.sal; % Copy sal data
resp.prho_bad = NaN(size(resp.sal)); % Matrix of Zeros
clear time doxy prho temp sal backscatter chla IND wggmerge wggmerge_fl
%% Find density outliers for WFP data, overwrite with NaN
for yr = 1:7
    for z =  175:2000

        if resp_end{yr}(z) > resp_start{yr}(z)
            [resp_start_z,~] = find(resp.time > resp_start{yr}(z),1,'first');
            [resp_end_z,~] = find(resp.time < resp_end{yr}(z),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            
            % Identify prho outliers  
            prho_detrend = detrend(resp.prho(z,resp_ind),'omitnan');
            bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',resp.time(resp_start_z:resp_end_z));
                        
            % Overwrite prho outliers with NaN in density and oxygen
            % datasets 
            resp.prho_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            resp.doxy_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            resp.temp_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            resp.sal_prho_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            resp.prho_bad(z,resp_ind) = bad_prho;

        end
    end
end
%%
clear HYPM* bad*prho z j yr pres_grid_hypm prho_detrend resp_ind resp_end_z resp_start_z