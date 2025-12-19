% Reading in files from BCO-DMO
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP')
load GOHSNAP_2020_2020_Calibrated_Casts.mat
% Saved this file outputs in the mat file above 
%%
AR45dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP\AR45';

cd(AR45dir)

% Pull out downcasts and upcasts, read them into tables nested by cast
% number 
ns = 6; ne = 8; % location of cast number in filename
filesd = ls('*d.csv');
filesu = ls('*u.csv');

castd = str2num(filesd(:,ns:ne));
castu = str2num(filesu(:,ns:ne));

if castd == castu 
    cast_num = castd;     
else
    disp('Caution: Issue with Downcasts and Upcasts Matching!')
end
%%
for j = 1:length(cast_num)
    downcasts{cast_num(j)} = importBCODMOfile(filesd(j,:));
    upcasts{cast_num(j)} = importBCODMOfile(filesu(j,:));
end


%%
for j = 1:length(cast_num)
    figure(j)
    plot(downcasts{cast_num(j)}.CTDOXY,downcasts{cast_num(j)}.CTDPRES,'Linewidth',1.5)
    hold on
    plot(upcasts{cast_num(j)}.CTDOXY,upcasts{cast_num(j)}.CTDPRES,'Linewidth',1.5)
    axis ij
    grid on
end
%%
go{1}.downcasts = downcasts;
go{1}.upcasts = upcasts;
go{1}.cast_num = cast_num;
%%
AR6903dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP\AR69-03';

cd(AR6903dir)

% Pull out downcasts and upcasts, read them into tables nested by cast
% number 
ns = 9; ne = 11; % location of cast number in filename
filesd = ls('*d.csv');
filesu = ls('*u.csv');

castd = str2num(filesd(:,ns:ne));
castu = str2num(filesu(:,ns:ne));

if castd == castu 
    cast_num = castd;     
else
    disp('Caution: Issue with Downcasts and Upcasts Matching!')
end
%%
for j = 1:length(cast_num)
    downcasts{cast_num(j)} = importBCODMOfile(filesd(j,:));
    upcasts{cast_num(j)} = importBCODMOfile(filesu(j,:));
end


%%
for j = 1:length(cast_num)
    figure(j)
    plot(downcasts{cast_num(j)}.CTDOXY,downcasts{cast_num(j)}.CTDPRES,'Linewidth',1.5)
    hold on
    plot(upcasts{cast_num(j)}.CTDOXY,upcasts{cast_num(j)}.CTDPRES,'Linewidth',1.5)
    axis ij
    grid on
end
%%
figure(101)
for j = 1:length(cast_num)
    if height(downcasts{j})*2 > 2000
        for k = 2:2:(height(downcasts{j})*2)
            try 
                plot(downcasts{cast_num(j)}.CTDOXY(downcasts{cast_num(j)}.CTDPRES == k) - ...
                    upcasts{cast_num(j)}.CTDOXY(upcasts{cast_num(j)}.CTDPRES == k), upcasts{cast_num(j)}.CTDPRES(upcasts{cast_num(j)}.CTDPRES == k),'.k','Markersize',8)
            catch
                disp('No matching depth cell')
            end
            hold on
        end
    axis ij
    grid on; box on
    plot([-1 -1],[0 height(downcasts{j})*2],'r--')
    plot([1 1],[0 height(downcasts{j})*2],'r--')
    xlim([-10 10])
    end
end
            
%%
go{2}.downcasts = downcasts;
go{2}.upcasts = upcasts;
go{2}.cast_num = cast_num;