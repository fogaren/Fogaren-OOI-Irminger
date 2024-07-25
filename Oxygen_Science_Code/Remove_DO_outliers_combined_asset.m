%% Find oxygen outliers for combined assets, overwrite with NaN 
% Make copies of data with prho outliers already removed 
combo.prho_outs_removed = combo.prho_prho_out_removed; % copy density data with prho outliers removed 
combo.doxy_outs_removed = combo.doxy_prho_out_removed; % copy oxygen data with prho outliers removed 
for yr = 1:7
    for z =  1:2000

        if resp_end{yr}(z) > resp_start{yr}(z)
            [resp_start_z,~] = find(combo.time > resp_start{yr}(z),1,'first');
            [resp_end_z,~] = find(combo.time < resp_end{yr}(z),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            
            % Identify DO outliers from data with previously removed prho outliers  
            DO_detrend = detrend(combo.doxy_prho_out_removed(z,resp_ind),'omitnan');
            bad_DO = isoutlier(DO_detrend,'quartiles','SamplePoints',combo.time(resp_start_z:resp_end_z));
                        
            % Overwrite DO outliers with NaN in prho and DO data 
            combo.prho_outs_removed(z,resp_ind(bad_DO == 1)) = NaN;
            combo.doxy_outs_removed(z,resp_ind(bad_DO == 1)) = NaN;
        end
    end
end

clear bad_DO DO_detrend resp_end_z resp_start_z yr z