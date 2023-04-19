addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Functions\GSW'))

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2\Processed')
ns = 7;
ne = 9;

dc_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2\Processed\downcasts';
uc_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2\Processed\upcasts';
leah_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2\From_Leah';
%% Read in my processed casts

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
downcast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers that have bottle files 

downcast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(files)
    dcnv_in = readSBScnv(files(i,:));
    downcast{downcast_num(i)} = my_cast(dcnv_in); %change so that i references cast number not file length number 
end

% Upcasts 
cd(uc_dir)
files = ls('*.cnv');
upcast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers that have bottle files 

upcast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(files)
    ucnv_in = readSBScnv(files(i,:));
    upcast{upcast_num(i)} = my_cast(ucnv_in);
end
%% Make sure Leah's cast numbers match my cast numbers

cd(leah_dir)
downfiles = ls('*.dcc'); % List of Leah's calibrated bottle files 
downcasts = str2num(downfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

upfiles = ls('*.ucc');
upcasts = str2num(upfiles(:,9:11));

% Make sure that there is a Leah cast file for each of my cast files 
if mydowncasts == downcasts 
    disp('Downcast numbers Line Up')
    
else
    disp('Caution: Issue with Matching Downcast Numbers!')
end

if myupcasts == upcasts
    disp('Upcast numbers Line Up')
else 
    disp('Caution: Issue with Matching Upcast Numbers!')
end
%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm','sbeox0mL_L1',...
        'sbeox0mL_L2'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
end
