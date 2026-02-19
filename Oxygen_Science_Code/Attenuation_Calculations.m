%% Calculate the attenuation of the remineralized data using the zstar exponential fit to the C remin data 

% 'a*exp(-(x-50)/b)' fit to data 
clear C_total_remin_zstarfit C_total_remin_mean_zstarfit
for yr = 1:7
    if yr == 3
        top_cutoff = 200;
    else 
        top_cutoff = 50;
    end
    % Exp zstar fit to remineralized export attenuation 
    depth_to_use = top_cutoff:Remin0(yr);
    if yr == 3
        [C_total_remin_zstarfit{yr}, gof_C_total_remin_zstarfit{yr}] = fit(depth_to_use',C_total_remin{yr}(depth_to_use)','a*exp(-(x-200)/b)');
    else 
        [C_total_remin_zstarfit{yr}, gof_C_total_remin_zstarfit{yr}] = fit(depth_to_use',C_total_remin{yr}(depth_to_use)','a*exp(-(x-50)/b)');
    end
    CI_remin_zstarfit{yr} = confint(C_total_remin_zstarfit{yr},0.95);
    [R{yr}, pvalue{yr}] = corrcoef(C_total_remin{yr}(depth_to_use)',(C_total_remin_zstarfit{yr}.a*exp(-(depth_to_use'-top_cutoff)/C_total_remin_zstarfit{yr}.b)));
end

% Fit is to the mean calculated as integration of mean Daily Resp rate * mean Dremin 
mean_depth_to_use = 50:1149; 
[C_total_remin_mean_zstarfit, gof_C_total_remin_mean_zstarfit] = fit(mean_depth_to_use',C_total_remin_mean(50:1149)','a*exp(-(x-50)/b)');  
CI_remin_mean_zstarfit = confint(C_total_remin_mean_zstarfit,0.95);

% % b term not appropriate because log log fit is not linear? 
% when use semilog fit, still not linear and get worse r2 than fits above 
% for yr = 1:7
%     if yr == 3
%         top_cutoff = 200;
%     else 
%         top_cutoff = 50;
%     end
% 
%     depth_to_use = top_cutoff:Remin0(yr);
%     testlm{yr} = fitlm(depth_to_use',log(C_total_remin{yr}(depth_to_use)/C_total_remin{yr}(depth_to_use(1))')); % stats match the numbers in Table S3 Marsay 2015
%     figure(yr)
%     clf
%     semilogy(depth_to_use,C_total_remin{yr}(depth_to_use))
% end
%%
figure
set(gcf,'position',[100,100,900,300])
for yr = 1:7
    subplot(2,4,yr)
    if yr == 3
        top_cutoff = 200;
    else 
        top_cutoff = 50;
    end
    depth_to_use = top_cutoff:Remin0(yr); % Convert from pressure to depth 
    barh(depth_to_use,C_total_remin{yr}(depth_to_use))
    hold on % 'a*exp(-(x-50)/b)'
    plot(C_total_remin_zstarfit{yr}.a.*exp(-((50:1500)-top_cutoff)./C_total_remin_zstarfit{yr}.b),50:1500,'Color','k','Linewidth',2)
    ylabel('Pressure (dbar)')
    axis ij 
    grid on
    ylim([0 1500])
    clear top_cutoff

end

% To look at specific Transfer efficiency from data and not exp fit 
for yr = 1:7
    try 
        T600_200(yr) = C_total_remin{yr}(600)./C_total_remin{yr}(200);
    catch
        T600_200(yr) = 0;
    end

end

% % For mean remin rate * mean Dremin
subplot(2,4,8)
depth_to_use = 50:1149;
barh(depth_to_use,C_total_remin_mean(depth_to_use))
hold on
plot(C_total_remin_mean_zstarfit.a.*exp(-((50:1500)-50)./C_total_remin_mean_zstarfit.b),50:1500,'Color','k','Linewidth',2)
ylabel('Pressure (dbar)')
axis ij 
grid on
%% Calculate Yr 3 projected inventory from the exp fit extrapolated from 200 to 50 m
% 50-200 can be calculated from inventory at 50 minus inventory at 201 
Yr3_projected_expfit = C_total_remin_zstarfit{3}.a.*exp(-((50)-200)./C_total_remin_zstarfit{3}.b) - C_total_remin_zstarfit{3}.a;
Cinventory_Yr3_projected_from_expfit = export_Cinventory_molm2(3) + Yr3_projected_expfit; 
%% Create table for exp zstar fit 
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
C_total_remin_gof_table = struct2table([gof_C_total_remin_zstarfit{1} gof_C_total_remin_zstarfit{2} gof_C_total_remin_zstarfit{3} gof_C_total_remin_zstarfit{4}...
    gof_C_total_remin_zstarfit{5} gof_C_total_remin_zstarfit{6} gof_C_total_remin_zstarfit{7} gof_C_total_remin_mean_zstarfit],'RowNames',["Remin. Yr 1" "Remin. Yr 2" "Remin. Yr 3" ...
    "Remin. Yr 4" "Remin. Yr 5" "Remin. Yr 6" "Remin. Yr 7" "Mean"]);
Var1 = [C_total_remin_zstarfit{1}.b C_total_remin_zstarfit{2}.b C_total_remin_zstarfit{3}.b C_total_remin_zstarfit{4}.b...
    C_total_remin_zstarfit{5}.b C_total_remin_zstarfit{6}.b C_total_remin_zstarfit{7}.b C_total_remin_mean_zstarfit.b]';
Var1CI = [CI_remin_zstarfit{1}(1,2) CI_remin_zstarfit{1}(2,2); CI_remin_zstarfit{2}(1,2) CI_remin_zstarfit{2}(2,2); CI_remin_zstarfit{3}(1,2) CI_remin_zstarfit{3}(2,2);...
    CI_remin_zstarfit{4}(1,2) CI_remin_zstarfit{4}(2,2); CI_remin_zstarfit{5}(1,2) CI_remin_zstarfit{5}(2,2); CI_remin_zstarfit{6}(1,2) CI_remin_zstarfit{6}(2,2); CI_remin_zstarfit{7}(1,2) CI_remin_zstarfit{7}(2,2); CI_remin_mean_zstarfit(1,2) CI_remin_mean_zstarfit(2,2);];
Var2 = [C_total_remin_zstarfit{1}.a C_total_remin_zstarfit{2}.a C_total_remin_zstarfit{3}.a.*exp(-((50)-200)./C_total_remin_zstarfit{3}.b) C_total_remin_zstarfit{4}.a...
    C_total_remin_zstarfit{5}.a C_total_remin_zstarfit{6}.a C_total_remin_zstarfit{7}.a C_total_remin_mean_zstarfit.a]';
Var2CI = [CI_remin_zstarfit{1}(1,1) CI_remin_zstarfit{1}(2,1); CI_remin_zstarfit{2}(1,1) CI_remin_zstarfit{2}(2,1); CI_remin_zstarfit{3}(1,1) CI_remin_zstarfit{3}(2,1);...
    CI_remin_zstarfit{4}(1,1) CI_remin_zstarfit{4}(2,1); CI_remin_zstarfit{5}(1,1) CI_remin_zstarfit{5}(2,1); CI_remin_zstarfit{6}(1,1) CI_remin_zstarfit{6}(2,1); CI_remin_zstarfit{7}(1,1) CI_remin_zstarfit{7}(2,1); CI_remin_mean_zstarfit(1,1) CI_remin_mean_zstarfit(2,1);];

% convert zstar in presssure to meters and create table 
C_total_remin_zstarfit_table = table(-gsw_z_from_p(Var1,60),-gsw_z_from_p(Var1CI,60),Var2,Var2CI,'VariableNames',{'Remin. zstar, m','zstar CI (95%)','Export at 50 dbar','export CI (95%)'},...
    'RowNames',["Remin. Yr 1" "Remin. Yr 2" "Remin. Yr 3" "Remin. Yr 4" "Remin. Yr 5" "Remin. Yr 6" "Remin. Yr 7" "Mean"]);
zstar = Var1(1:7); % Convert from pressure to depth units 
zstar_errorbar = Var1(1:7) - Var1CI(1:7,1); % For plotting purposes, but errorbars end up being smaller than the plot symbol used 

annual_export_from_zstarfit = []; 
for j = 1:7
    annual_export_from_zstarfit(j) = C_total_remin_zstarfit{j}(50); 
end
annual_export_mean_from_expfit = C_total_remin_mean_zstarfit(50);
zstar_mean = -gsw_z_from_p(C_total_remin_mean_zstarfit.b,60);
zstar_mean_errorbar = zstar_mean - -gsw_z_from_p(CI_remin_mean_zstarfit(1,2),60);

%% BBL attenuation calculations 
% Calculate fit of attenuation 
% pulses to include in mean attenuation calculations 
% Have to use first order exponential fit and not zstar fit because zstar
% result is Inf ( I think because zstar is greater than max sinking pulse
% depth) 
clear curve_exp_gaussfilter_omitnan
for j = 1:8
    [curve_exp_gaussfilter_omitnan{j},gof_exp_gaussfilter_omitnan{j}] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,j),'exp1'); 
end

atten_pulses_good = [1:5 8]; 
% atten_pulses_good = [1:3 5]; 
sinkingpulse_max_gaussfilter_omitnan_mean = nanmean(squeeze(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good)),2); 
sinkingpulse_max_gaussfilter_omitnan_std = nanstd(squeeze(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good)),0,2); 

[curve_exp_gaussfilter_omitnan_mean,gof_exp_gaussfilter_omitnan_mean] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean,'exp1'); % 'exp1';
% [curve_power_gaussfilter_omitnan_mean,gof_power_gaussfilter_omitnan_mean] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean,'power1'); % For literature context

bbl_extend_depths = 200:5000;
figure
plot(bbl_extend_depths,curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bbl_extend_depths'))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200))))
hold on
% plot(bbl_extend_depths,curve_power_gaussfilter_omitnan_mean.a*(bbl_extend_depths.^curve_power_gaussfilter_omitnan_mean.b)/(curve_power_gaussfilter_omitnan_mean.a*(200^curve_power_gaussfilter_omitnan_mean.b)))

%% Sinking pulses with exponential fit
figure
for j = 1:length(atten_pulses_good)
    subplot(2,3,j)
    plot(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Pressure (m)')
    xlabel('max b_b_l (m^-^1)') 
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    xlim([0 0.00025])
end

%% Sinking carbon with exponential fit

clear curve_exp_gaussfilter_omitnan
for j = 1:8
    [curve_exp_gaussfilter_omitnan{j},gof_exp_gaussfilter_omitnan{j}] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,j)*35400*54,'exp1'); 
end

atten_pulses_good = [1:5 8]; 
% atten_pulses_good = [1:3 5]; 
sinkingpulse_max_gaussfilter_omitnan_mean = nanmean(squeeze(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good)*35400*54),2); 
sinkingpulse_max_gaussfilter_omitnan_std = nanstd(squeeze(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good)*35400*54),0,2); 

[curve_exp_gaussfilter_omitnan_mean,gof_exp_gaussfilter_omitnan_mean] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean,'exp1'); % 'exp1';
% [curve_power_gaussfilter_omitnan_mean,gof_power_gaussfilter_omitnan_mean] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean,'power1'); % For literature context

bbl_extend_depths = 200:5000;
figure
plot(bbl_extend_depths,curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bbl_extend_depths'))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200))))
hold on
% plot(bbl_extend_depths,curve_power_gaussfilter_omitnan_mean.a*(bbl_extend_depths.^curve_power_gaussfilter_omitnan_mean.b)/(curve_power_gaussfilter_omitnan_mean.a*(200^curve_power_gaussfilter_omitnan_mean.b)))

figure
for j = 1:length(atten_pulses_good)
    subplot(2,3,j)
    plot(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j))*35400*54,wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('depth (m)')
    xlabel('POC (mg C m^-^2 d^-^1)') 
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    xlim([0 500])
end

%% b term check
clear testlm
for j = 1:length(atten_pulses_good)
    testlm{j} = fitlm(log(wfpmerge.sinkingpulsedepths'),log(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j))')); % stats match the numbers in Table S3 Marsay 2015
    figure(j)
    clf
    loglog(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j)),'ok')
end

testlm{j+1} = fitlm(log(wfpmerge.sinkingpulsedepths'),log(sinkingpulse_max_gaussfilter_omitnan_mean'))

%%
% Expontial fit gives same r2 as zstarfit but can't use bbl to solve for
% zstar because zstar is deeper than the collected data?
clear bbl_expfit_gof_table
bbl_expfit_gof_table = struct2table([gof_exp_gaussfilter_omitnan{1} gof_exp_gaussfilter_omitnan{2} gof_exp_gaussfilter_omitnan{3} gof_exp_gaussfilter_omitnan{4}...
    gof_exp_gaussfilter_omitnan{5} gof_exp_gaussfilter_omitnan{6} gof_exp_gaussfilter_omitnan{7} gof_exp_gaussfilter_omitnan{8} gof_exp_gaussfilter_omitnan_mean],'RowNames',...
    ["Pulse 1" "Pulse 2" "Pulse 3" "Pulse 4" "Pulse 5" "Pulse 6" "Pulse 7" "Pulse 8" "Mean"]);
% bbl_expfit_gof_table = struct2table([gof_exp_gaussfilter_omitnan{1} gof_exp_gaussfilter_omitnan{2} gof_exp_gaussfilter_omitnan{3} gof_exp_gaussfilter_omitnan{5} gof_exp_gaussfilter_omitnan_mean],...
%     'RowNames',["Pulse 1" "Pulse 2" "Pulse 3" "Pulse 5" "Mean"]);
%% 
% If you were to calcualte zstar from the extrapolated exp fit to the data.


clear zstar_bbl bbl_extend_zstar_fit
% Calculate zstar for bbl from extrapolated bbl exponential fit 

bbl_extend_zstar_fit = [];
bbl_extend_depths = 50:50:3000; 
clear test_fit
clear j
for j = 1:8
    bbl_extend_zstar_fit{j} = fit(bbl_extend_depths',(curve_exp_gaussfilter_omitnan{j}.a*exp(curve_exp_gaussfilter_omitnan{j}.b*(bbl_extend_depths')))./(curve_exp_gaussfilter_omitnan{j}.a*exp(curve_exp_gaussfilter_omitnan{j}.b*(50))),'a*exp(-(x-50)/b)');
    test_fit{j} = fit(bbl_extend_depths',(curve_exp_gaussfilter_omitnan{j}.a*exp(curve_exp_gaussfilter_omitnan{j}.b*(bbl_extend_depths')))/(curve_exp_gaussfilter_omitnan{j}.a*exp(curve_exp_gaussfilter_omitnan{j}.b*(50))),'1*exp(-(x-50)/b)');
    %test_fit{j} =
    %fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,j)./sinkingpulse_max_gaussfilter_omitnan(1,1,j),'a*exp(-(x-200)/b)');
end

%%
zstar_bbl = []; %already in depth units
clear j
for j = 1:8
    zstar_bbl(j) = bbl_extend_zstar_fit{j}.b;
end
clear bbl_extend_zstar_mean_fit zstar_bbl_mean
bbl_extend_zstar_mean_fit = fit(bbl_extend_depths',curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bbl_extend_depths'))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50))),'1*exp(-(x-50)/b)');
%bbl_extend_zstar_mean_fit = fit(bbl_extend_depths',curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bbl_extend_depths')),'a*exp(-(x-50)/b)');
zstar_bbl_mean = bbl_extend_zstar_mean_fit.b; 

zstar_bbl_all = round([zstar_bbl'; zstar_bbl_mean])

% No 95 % CI because zstar is calculated from the extended fit to the data
% so results in a perfect fit with 95% CI the same as zstar result 


