function castdata = importBCODMOfile(filename)

% importBCODMOfile reads in both the metadata in the header and the binned
% CTD data from submitted BCO DMO files and outputs them into Matlab tables

%% Set up the Import Options and import the data from the file header
opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = [1 2];
opts.Delimiter = ["\t", " "];
opts0 = detectImportOptions(filename);
% Specify column names and types
opts.VariableNames = opts0.VariableNames;
opts = setvartype(opts,opts0.VariableNamesLine,'char');

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";

opts = setvaropts(opts, opts0.VariableNames, "WhitespaceRule", "preserve");
opts = setvaropts(opts, opts0.VariableNames, "EmptyFieldRule", "auto");

% Import the data from file header
T1 = readtable(filename, opts);

%% Convert to output type
T1 = table2cell(T1);
numIdx = cellfun(@(x) ~isnan(str2double(x)), T1);
T1(numIdx) = cellfun(@(x) {str2double(x)}, T1(numIdx));

%% Parse header data into desired variables 
castinfo.cruise = T1{1,1};
castinfo.cast_type = T1{1,4};
castinfo.lat = T1{2,2};
castinfo.lon = T1{2,4};
castinfo.cast = T1{1,6};
castinfo.date = T1{2,5};
castinfo.time = T1{2,6};
castinfo.dn = datenum([castinfo.date castinfo.time]);
castinfo.dt = datetime(castinfo.dn,'ConvertFrom','datenum');

%% Read in binned CTD cast data 
T2 = readtable(filename);
castdata = T2;
castdata.cruise(:) = {castinfo.cruise};
castdata.cast(:) = castinfo.cast;
castdata.cast_type(:) = {castinfo.cast_type};
castdata.lat(:) = castinfo.lat;
castdata.lon(:) = castinfo.lon;
castdata.dn(:) = castinfo.dn;
castdata.dt(:) = castinfo.dt;

% Format with header metadata before the CTD cast data
castdata = movevars(castdata,{'cruise','cast','cast_type','lat','lon','dn','dt'},'Before',1);
end