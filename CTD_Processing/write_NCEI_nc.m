% inputs: 
% cast example 1
% cast table example cast01u
% filename string example 'test.nc'
% platform_name example 'Armstrong' 
cast = cast03u; 
cast_number = 3;
filename_string = 'cast03u.nc';
platform_name = 'R/V Armstrong'; 

% Need to format time properly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creat .nc file 
netcdf_filename = filename_string; 
ncid = netcdf.create(netcdf_filename,'clobber');

% Define dimensions 
% Size of cast
[dim1, dim2] = size(cast);

z_axis = dim1;
profile = cast_number; 
DepthDimID = netcdf.defDim(ncid, 'pressure', z_axis);

% Define variables.
% Time/lat/lon --> change to one value 
VarIdTime = netcdf.defVar(ncid, 'time' , 'float', DepthDimID); 
netcdf.putAtt(ncid, VarIdTime, 'long_name', 'time');
netcdf.putAtt(ncid, VarIdTime, 'standard_name', 'time');
netcdf.putAtt(ncid, VarIdTime, 'units', 'hours since 1970-01-01'); % Need to format time properly 
netcdf.putAtt(ncid, VarIdTime, 'calendar', 'julian');
netcdf.putAtt(ncid, VarIdTime, 'axis', 'T');
netcdf.putAtt(ncid, VarIdTime, '_FillValue', single(-9999));
% netcdf.putAtt(ncid, VarIdTime, 'data_min', time(1));
% netcdf.putAtt(ncid, VarIdTime, 'data_max', time(end));

VarIdLatitude = netcdf.defVar(ncid, 'lat' , 'float', DepthDimID);
netcdf.putAtt(ncid, VarIdLatitude, 'long_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'standard_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'units', 'degrees_north');
netcdf.putAtt(ncid, VarIdLatitude, 'axis', 'Y');
netcdf.putAtt(ncid, VarIdLatitude, 'valid_min', -90);
netcdf.putAtt(ncid, VarIdLatitude, 'valid_max', 90);
netcdf.putAtt(ncid, VarIdLatitude, '_FillValue', single(-9999));

VarIdLongitude = netcdf.defVar(ncid, 'lon' , 'float', DepthDimID);
netcdf.putAtt(ncid, VarIdLongitude, 'long_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'standard_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'units', 'degrees_east');
netcdf.putAtt(ncid, VarIdLongitude, 'axis', 'X');
netcdf.putAtt(ncid, VarIdLongitude, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdLongitude, 'valid_max', 360);
netcdf.putAtt(ncid, VarIdLongitude, '_FillValue', single(-9999));

VarIdPressure = netcdf.defVar(ncid, 'pressure' , 'float', DepthDimID);
netcdf.putAtt(ncid, VarIdPressure, 'long_name', 'pressure');
netcdf.putAtt(ncid, VarIdPressure, 'standard_name', 'pressure');
netcdf.putAtt(ncid, VarIdPressure, 'units', 'meters');
netcdf.putAtt(ncid, VarIdPressure, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdPressure, 'positive', 'down');
netcdf.putAtt(ncid, VarIdPressure, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdPressure, 'valid_max', 5000);

VarIdTemp = netcdf.defVar(ncid, 'sea_water_temperature', 'float', DepthDimID);
netcdf.putAtt(ncid, VarIdTemp, 'long_name', 'In situ sea water wemperature (ITS-90)'); % check scale 
netcdf.putAtt(ncid, VarIdTemp, 'standard_name', 'sea_water_temperature');
netcdf.putAtt(ncid, VarIdTemp, 'units', 'degree_Celsius');
netcdf.putAtt(ncid, VarIdTemp, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdTemp, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdTemp, 'valid_max', 30);
netcdf.putAtt(ncid, VarIdTemp, 'coordinates', 'time lat lon z');
netcdf.putAtt(ncid, VarIdTemp, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdTemp, 'platform', platform_name);

VarIdSalinity = netcdf.defVar(ncid, 'sea_water_salinity', 'float', DepthDimID);
netcdf.putAtt(ncid, VarIdSalinity, 'long_name', 'Practical sea water salinity');
netcdf.putAtt(ncid, VarIdSalinity, 'standard_name', 'sea_water_salinity');
% netcdf.putAtt(ncid, VarIdSalinity, 'units', '');
netcdf.putAtt(ncid, VarIdSalinity, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdSalinity, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdSalinity, 'valid_max', 40);
netcdf.putAtt(ncid, VarIdSalinity, 'coordinates', 'time lat lon z');
netcdf.putAtt(ncid, VarIdSalinity, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdSalinity, 'platform', platform_name);

VarIdOxygen = netcdf.defVar(ncid, 'Oxygen', 'float', DepthDimID); % Update 
netcdf.putAtt(ncid, VarIdOxygen, 'long_name', 'dissolved_oxygen'); % Update 
netcdf.putAtt(ncid, VarIdOxygen, 'standard_name', 'dissolved_oxygen');
netcdf.putAtt(ncid, VarIdOxygen, 'units', 'umol/kg');
netcdf.putAtt(ncid, VarIdOxygen, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdOxygen, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdOxygen, 'valid_max', 500); % Change? 
netcdf.putAtt(ncid, VarIdOxygen, 'coordinates', 'time lat lon z');
netcdf.putAtt(ncid, VarIdOxygen, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdOxygen, 'platform', platform_name);

netcdf.endDef(ncid)  % Leave define mode.

% Now store the data
netcdf.putVar(ncid, VarIdTime, cast.CastTimeS(1));
netcdf.putVar(ncid, VarIdLatitude, cast.lat(1));
netcdf.putVar(ncid, VarIdLongitude, cast.lon(1));
netcdf.putVar(ncid, VarIdPressure, cast.prs);
netcdf.putVar(ncid, VarIdTemp, cast.t);
netcdf.putVar(ncid, VarIdSalinity, cast.SP);
netcdf.putVar(ncid, VarIdOxygen, cast.DOcorr_umolkg);

% Close the file. Finished.
netcdf.sync(ncid)
netcdf.close(ncid)
