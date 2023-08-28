% Roo's code for unpacking indexed structures into tables and then
% outputting as csv files 

cruiseid = 'yr9';

% construct variable names
fn = [cruiseid,'_Processed_KF.mat'];
btl = ['btlsum_',cruiseid,'_tbl'];
dwn = ['downcasts_', cruiseid];
up = ['upcasts_',cruiseid];

% load in variable
% Sbtl = load(fn,btl);
% Tbtl = Sbtl.(btl);
Sdwn = load(fn,dwn);
Sup = load(fn,up);

% unpack structures into tables
ncast = length(Sdwn);
Tdwn = table;
Tup = table;
for ii = 1:ncast
    if istable(Sdwn.(dwn){ii})
        Tdwn = [Tdwn;Sdwn.(dwn){ii}];
    end
    if istable(Sup.(up){ii})
        Tup = [Tup;Sup.(up){ii}];
    end
end

% write to csv
writetable(Tbtl,[btl,'.csv']);
writetable(Tdwn,[dwn,'.csv']);
writetable(Tup,[up,'.csv']);

%%

load Year9_Processed_KF.mat

downcasts = downcasts_yr9;
upcasts = upcasts_yr9;
btl_num = btl_num_yr9;
cast_num = cast_num_yr9;
btlsum = btlsum_yr9;


%%
%Change folder to BCO-DMO location 
for i = 1:length(cast_num)
    dwn_out = downcasts{cast_num(i)};
    fheader = ['AR30-03    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
    '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
    sprintf('Pres, T90, Sal, OxCur, OXY_umolkg') newline];

    fileIDd = fopen(['AR30-03_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
    fprintf(fileIDd,fheader);
    for ii = 1:length(dwn_out.prs)
        fprintf(fileIDd,'%.1f,%.5f,%.5f,%.5f,%.2f\n', dwn_out.prs(ii),dwn_out.t(ii),dwn_out.SP(ii),dwn_out.oxy_volts(ii),dwn_out.DOcorr_umolkg(ii));
    end
    fclose(fileIDd);
end

for i = 1:length(cast_num)
    up_out = upcasts{cast_num(i)};

    fheader = ['AR30-03    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
    '   ' datestr(up_out.StartTimeUTC(1)) newline...
    sprintf('Pres (db), T90(, Sal, OxCur, OXY_umolkg') newline];

    fileIDu = fopen(['AR30-03_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
    fprintf(fileIDu,fheader);
    for ii = 1:length(up_out.prs)
        fprintf(fileIDu,'%.1f,%.5f,%.5f,%.5f,%.2f\n', up_out.prs(ii),up_out.t(ii),up_out.SP(ii),up_out.oxy_volts(ii),up_out.DOcorr_umolkg(ii));
    end
    fclose(fileIDu);
end

for i = 1:length(btl_num)
    btl_out = btlsum{btl_num(i)};
    btl_out.Winkler_OOI_umolkg(isnan(btl_out.Winkler_OOI_umolkg)) = -9.0000;
    btl_out.Winkler1_HIP_umolkg(isnan(btl_out.Winkler1_HIP_umolkg)) = -9.0000;
    btl_out.Winkler2_HIP_umolkg(isnan(btl_out.Winkler2_HIP_umolkg)) = -9.0000;
    fheader = ['AR30-03    Post-CTD Oxygen Calibration   Station: ' num2str(cast_num(i)) newline...
    %sprintf('Bottle (#), Pres (db), T90 (oC), Sal (psu), OxCur (volts), CTD OXY (umol/kg), Meas OXY (umol/kg)') newline
    sprintf('Bottle (#), Pres (db), T90 (oC), Sal (psu), OxCur (volts), CTD OXY (umol/kg), Meas OXY1 (umol/kg), Meas OXY2 (umol/kg), Meas OXY3 (umol/kg)') newline];

    fileID = fopen(['AR30-03_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
    fprintf(fileID,fheader);
    for ii = 1:length(btl_out.Bottle)
%         fprintf(fileID,'%d,%.1f,%.5f,%.5f,%.5f,%.2f,%.2f\n', btl_out.Bottle(ii),btl_out.prs(ii),btl_out.t(ii),btl_out.SP(ii),btl_out.oxy_volts(ii),btl_out.DOcorr_umolkg(ii),...
%             btl_out.Winkler_umolkg);
        fprintf(fileID,'%d,%.1f,%.5f,%.5f,%.5f,%.2f,%.2f,%.2f,%.2f\n', btl_out.Bottle(ii),btl_out.prs(ii),btl_out.t(ii),btl_out.SP(ii),btl_out.oxy_volts(ii),btl_out.DOcorr_umolkg(ii),...
            btl_out.Winkler_OOI_umolkg(ii),btl_out.Winkler1_HIP_umolkg(ii),btl_out.Winkler2_HIP_umolkg(ii));
    end
    fclose(fileID);
end