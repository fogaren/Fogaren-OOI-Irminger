%Example metadata
Latitude = 44.656;
Longitude = 235.474;
depth_sst = 0;
depth_wav = 0;
depth_press = 0;
NDBC_ID = 46050;

%Create example time array
time = datenum(2021,1,1,0,0,0)*24:1:datenum(2021,12,31,23,0,0)*24;
time = time-datenum(1970,1,1,0,0,0)*24;

current_time = datenum(str2num(datestr(now,10)),str2num(datestr(now,5)),str2num(datestr(now,7)),0,0,0)*24;

%Create example data arrays
whgt = rand(length(time),1);  %m
dwpd = rand(length(time),1);  %sec
awpd = rand(length(time),1);  %sec
mwdir = rand(length(time),1);   %deg
press = rand(length(time),1);   %hPa
sst = rand(length(time),1);   %oC

dc = datestr(now,31);
dc = strcat(num2str(dc(1:10)),'T',num2str(dc(12:19)));
dc_hist = strcat('Created:_',num2str(dc(1:10)),'T',num2str(dc(12:19)),'. Version: 1.0');
dc_hist = strrep(dc_hist,'_',' ');

first_measurement = datestr((time(1)+datenum(1970,1,1,0,0,0)*24)/24,31);
first_measurement = strcat(num2str(first_measurement(1:10)),'T',num2str(first_measurement(12:19)));

last_measurement = datestr((time(end)+datenum(1970,1,1,0,0,0)*24)/24,31);
last_measurement = strcat(num2str(last_measurement(1:10)),'T',num2str(last_measurement(12:19)));

z_axis = length(time);

%Create .nc file
netcdf_filename = 'test.nc';
ncid = netcdf.create(netcdf_filename,'clobber');

% Define dimentions
TimeDimID = netcdf.defDim(ncid, 'time', z_axis);

netcdf_title = strcat('Hourly_NDBC_',num2str(NDBC_ID),'_data');
netcdf_title = strrep(netcdf_title,'_',' ');

geospatial_bounds_txt = strcat('POINT%(',num2str(Longitude),'%',num2str(Latitude),')');
geospatial_bounds_txt = strrep(geospatial_bounds_txt,'%',' ');

% Set global attributes
VarID = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid, VarID, 'title', netcdf_title);
netcdf.putAtt(ncid, VarID, 'creator_name', 'Kristen Fogaren');
netcdf.putAtt(ncid, VarID, 'creator_email', 'fogaren@bc.edu');
% netcdf.putAtt(ncid, VarID, 'creator_url', 'https://ceoas.oregonstate.edu/people/craig-risien');
netcdf.putAtt(ncid, VarID, 'creator_type', 'position');
netcdf.putAtt(ncid, VarID, 'creator_institution', 'Earth and Environmental Sciences; Boston College');
netcdf.putAtt(ncid, VarID, 'creator_address', '140 Commonwealth Ave');
netcdf.putAtt(ncid, VarID, 'creator_city', 'Chestnut Hill');
% netcdf.putAtt(ncid, VarID, 'creator_phone', '+1-541-737-0011');
netcdf.putAtt(ncid, VarID, 'creator_postalcode', '02467');
netcdf.putAtt(ncid, VarID, 'creator_state', 'Massachusetts');
netcdf.putAtt(ncid, VarID, 'creator_county', 'USA');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
netcdf.putAtt(ncid, VarID, 'publisher_name', 'Kristen Fogaren');
netcdf.putAtt(ncid, VarID, 'publisher_email', 'fogaren@bc.edu');
% netcdf.putAtt(ncid, VarID, 'publisher_url', 'https://ceoas.oregonstate.edu/people/craig-risien');
netcdf.putAtt(ncid, VarID, 'publisher_type', 'position');
netcdf.putAtt(ncid, VarID, 'publisher_institution', 'Earth and Environmental Sciences; Boston College');
netcdf.putAtt(ncid, VarID, 'publisher_address', '140 Commonwealth Ave');
netcdf.putAtt(ncid, VarID, 'publisher_city', 'Chestnut Hill');
% netcdf.putAtt(ncid, VarID, 'publisher_phone', '+1-541-737-0011');
netcdf.putAtt(ncid, VarID, 'publisher_postalcode', '02467');
netcdf.putAtt(ncid, VarID, 'publisher_state', 'Massachusetts');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
netcdf.putAtt(ncid, VarID, 'contributor_name', 'Kristen Fogaren');
netcdf.putAtt(ncid, VarID, 'contributor_email', 'fogaren@bc.edu');
netcdf.putAtt(ncid, VarID, 'contributor_role', 'processor');
netcdf.putAtt(ncid, VarID, 'contributor_role_vocabulary', 'https://vocab.nerc.ac.uk/collection/G04/current/');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
netcdf.putAtt(ncid, VarID, 'date_created', dc);
netcdf.putAtt(ncid, VarID, 'date_modified', dc);
netcdf.putAtt(ncid, VarID, 'history', dc_hist);
netcdf.putAtt(ncid, VarID, 'time_coverage_start', first_measurement);
netcdf.putAtt(ncid, VarID, 'time_coverage_end', last_measurement);
netcdf.putAtt(ncid, VarID, 'time_coverage_resolution', 'hourly averages');
netcdf.putAtt(ncid, VarID, 'geospatial_bounds', geospatial_bounds_txt);
netcdf.putAtt(ncid, VarID, 'geospatial_bounds_crs', 'EPSG:4326');
netcdf.putAtt(ncid, VarID, 'geospatial_bounds_vertical_crs','EPSG:5829');
netcdf.putAtt(ncid, VarID, 'geospatial_lat_min', Latitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_max', Latitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_units', 'degrees_north');
netcdf.putAtt(ncid, VarID, 'geospatial_lon_min', Longitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lon_max', Longitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lon_units', 'degrees_east');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_units', 'meters');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_resolution', 'point');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_positive', 'down');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_min', 0);
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_max', 0);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_resolution','0 degree grid'); 
netcdf.putAtt(ncid, VarID, 'geospatial_lon_resolution','0 degree grid');
netcdf.putAtt(ncid, VarID, 'keywords', 'ndbc, noaa, nanoos, sea surface temperature, wind speed, wind direction, wave height, wave period, wave direction, air temperature, barometric pressure');
netcdf.putAtt(ncid, VarID, 'Conventions', 'CF-1.6');
netcdf.putAtt(ncid, VarID, 'comment', 'NA');
netcdf.putAtt(ncid, VarID, 'cdm_data_type', 'Station');
netcdf.putAtt(ncid, VarID, 'featureType', 'timeSeries');
netcdf.putAtt(ncid, VarID, 'data_type', 'NDBC time-series data');
netcdf.putAtt(ncid, VarID, 'area', 'North Pacific Ocean');
netcdf.putAtt(ncid, VarID, 'license', 'Follows NDBC standards. Data available free of charge. User assumes all risk for use of data. User must display citation in any publication or product using data.');
netcdf.putAtt(ncid, VarID, 'citation', 'These data were collected and made freely available by NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'acknowledgement', 'These data were collected and made freely available by NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'wmo_platform_code', num2str(NDBC_ID));
netcdf.putAtt(ncid, VarID, 'summary', 'Quality controlled NDBC Station data that have been repackaged and distributed by NANOOS');
netcdf.putAtt(ncid, VarID, 'naming_authority', 'NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'history', 'Quality controlled at NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'source', 'in-situ observation');
netcdf.putAtt(ncid, VarID, 'standard_name_vocabulary', 'CF Standard Name Table v32');
netcdf.putAtt(ncid, VarID, 'references', 'https://www.nodc.noaa.gov/data/formats/netcdf/v2.0/');
netcdf.putAtt(ncid, VarID, 'id', 'Test_Data');
netcdf.putAtt(ncid, VarID, 'project', 'Test Project');
netcdf.putAtt(ncid, VarID, 'processing_level', 'Level 3');
netcdf.putAtt(ncid, VarID, 'institution', 'OSU');
netcdf.putAtt(ncid, VarID, 'time_coverage_start', '2021-01-01T00:00:00Z');  
netcdf.putAtt(ncid, VarID, 'time_coverage_end', '2021-12-31T23:00:00');    
netcdf.putAtt(ncid, VarID, 'time_coverage_duration', '8760 hours');         
netcdf.putAtt(ncid, VarID, 'time_coverage_resolution', 'hourly');
netcdf.putAtt(ncid, VarID, 'keywords_vocabulary', 'GCMD Science Keywords');
netcdf.putAtt(ncid, VarID, 'date_issued', '2023-02-01T10:15:00Z');

% Define variables.
VarIdLatitude = netcdf.defVar(ncid, 'latitude' , 'float', []);
netcdf.putAtt(ncid, VarIdLatitude, 'units', 'degrees_north');
netcdf.putAtt(ncid, VarIdLatitude, 'long_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'standard_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'valid_min', -90);
netcdf.putAtt(ncid, VarIdLatitude, 'valid_max', 90);
netcdf.putAtt(ncid, VarIdLatitude, 'data_min', min(Latitude));
netcdf.putAtt(ncid, VarIdLatitude, 'data_max', max(Latitude));
netcdf.putAtt(ncid, VarIdLatitude, 'axis', 'Y');
netcdf.putAtt(ncid, VarIdLatitude, '_FillValue', single(-9999));

VarIdLongitude = netcdf.defVar(ncid, 'longitude' , 'float', []);
netcdf.putAtt(ncid, VarIdLongitude, 'units', 'degrees_east');
netcdf.putAtt(ncid, VarIdLongitude, 'long_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'standard_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdLongitude, 'valid_max', 360);
netcdf.putAtt(ncid, VarIdLongitude, 'data_min', min(Longitude));
netcdf.putAtt(ncid, VarIdLongitude, 'data_max', max(Longitude));
netcdf.putAtt(ncid, VarIdLongitude, 'axis', 'X');
netcdf.putAtt(ncid, VarIdLongitude, '_FillValue', single(-9999));

VarIdTime = netcdf.defVar(ncid, 'time' , 'float', TimeDimID);
netcdf.putAtt(ncid, VarIdTime, 'units', 'hours since 1970-01-01');
netcdf.putAtt(ncid, VarIdTime, 'calendar', 'gregorian');
netcdf.putAtt(ncid, VarIdTime, 'long_name', 'time');
netcdf.putAtt(ncid, VarIdTime, 'standard_name', 'time');
netcdf.putAtt(ncid, VarIdTime, 'data_min', time(1));
netcdf.putAtt(ncid, VarIdTime, 'data_max', time(end));
netcdf.putAtt(ncid, VarIdTime, 'axis', 'T');

VarIdDepthSST = netcdf.defVar(ncid, 'depth_sst' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthSST, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthSST, 'long_name', 'Depth of SST measurements');
netcdf.putAtt(ncid, VarIdDepthSST, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthSST, 'valid_min', -1000);
netcdf.putAtt(ncid, VarIdDepthSST, 'valid_max', 10000);
netcdf.putAtt(ncid, VarIdDepthSST, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthSST, 'positive', 'up');
netcdf.putAtt(ncid, VarIdDepthSST, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdDepthSST, 'data_min', min(depth_sst));
netcdf.putAtt(ncid, VarIdDepthSST, 'data_max', max(depth_sst));

VarIdDepthPRESS = netcdf.defVar(ncid, 'depth_press' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthPRESS, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'long_name', 'Height of barometric pressure measurements');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'valid_min', -1000);
netcdf.putAtt(ncid, VarIdDepthPRESS, 'valid_max', 10000);
netcdf.putAtt(ncid, VarIdDepthPRESS, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'positive', 'up');
netcdf.putAtt(ncid, VarIdDepthPRESS, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdDepthPRESS, 'data_min', min(depth_press));
netcdf.putAtt(ncid, VarIdDepthPRESS, 'data_max', max(depth_press));

VarIdDepthWAV = netcdf.defVar(ncid, 'depth_wav' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthWAV, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthWAV, 'long_name', 'Height of wave measurements');
netcdf.putAtt(ncid, VarIdDepthWAV, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthWAV, 'valid_min', -1000);
netcdf.putAtt(ncid, VarIdDepthWAV, 'valid_max', 10000);
netcdf.putAtt(ncid, VarIdDepthWAV, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthWAV, 'positive', 'up');
netcdf.putAtt(ncid, VarIdDepthWAV, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdDepthWAV, 'data_min', min(depth_wav));
netcdf.putAtt(ncid, VarIdDepthWAV, 'data_max', max(depth_wav));

VarIdTS = netcdf.defVar(ncid, 'timeSeries' , 'int', []);
netcdf.putAtt(ncid, VarIdTS, 'long_name', num2str(NDBC_ID));
netcdf.putAtt(ncid, VarIdTS, 'cf_role', 'timeseries_id');

VarIdCRS = netcdf.defVar(ncid, 'crs' , 'double', []);
netcdf.putAtt(ncid, VarIdCRS, 'grid_mapping_name', 'latitude_longitude');
netcdf.putAtt(ncid, VarIdCRS, 'longitude_of_prime_meridian', double(0.0));
netcdf.putAtt(ncid, VarIdCRS, 'semi_major_axis', double(6378137.0));
netcdf.putAtt(ncid, VarIdCRS, 'inverse_flattening', double(298.257223563));
netcdf.putAtt(ncid, VarIdCRS, 'epsg_code', 'EPSG:4326');

VarIdPlat = netcdf.defVar(ncid, 'platform' , 'int', []);
netcdf.putAtt(ncid, VarIdPlat, 'wmo_code', num2str(NDBC_ID));
netcdf.putAtt(ncid, VarIdPlat, 'long_name', num2str(NDBC_ID));
netcdf.putAtt(ncid, VarIdPlat, 'ncei_code', 'FIXED PLATFORM, MOORINGS');

VarIdSSTemp = netcdf.defVar(ncid, 'sea_water_temperature', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdSSTemp, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdSSTemp, 'units', 'degree_Celsius');
netcdf.putAtt(ncid, VarIdSSTemp, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdSSTemp, 'long_name', 'Hourly Sea Water Temperature');
netcdf.putAtt(ncid, VarIdSSTemp, 'standard_name', 'sea_water_temperature');
netcdf.putAtt(ncid, VarIdSSTemp, 'coordinates', 'longitude latitude time depth_sst');
netcdf.putAtt(ncid, VarIdSSTemp, 'sensor_mount', 'mounted on mooring bridal');
netcdf.putAtt(ncid, VarIdSSTemp, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdSSTemp, 'valid_max', 30);
netcdf.putAtt(ncid, VarIdSSTemp, 'data_min', min(sst));
netcdf.putAtt(ncid, VarIdSSTemp, 'data_max', max(sst));
netcdf.putAtt(ncid, VarIdSSTemp, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdSSTemp, 'platform', 'platform');

VarIdPress = netcdf.defVar(ncid, 'air_pressure', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdPress, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdPress, 'units', 'hPa');
netcdf.putAtt(ncid, VarIdPress, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdPress, 'long_name', 'Hourly Air Pressure');
netcdf.putAtt(ncid, VarIdPress, 'standard_name', 'air_pressure_at_sea_level');
netcdf.putAtt(ncid, VarIdPress, 'coordinates', 'longitude latitude time depth_press');
netcdf.putAtt(ncid, VarIdPress, 'sensor_mount', 'mounted on the buoy tower');
netcdf.putAtt(ncid, VarIdPress, 'valid_min', 950);
netcdf.putAtt(ncid, VarIdPress, 'valid_max', 1050);
netcdf.putAtt(ncid, VarIdPress, 'data_min', min(press));
netcdf.putAtt(ncid, VarIdPress, 'data_max', max(press));
netcdf.putAtt(ncid, VarIdPress, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdPress, 'platform', 'platform');

VarIdWHGT = netcdf.defVar(ncid, 'significant_wave_height', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWHGT, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWHGT, 'units', 'm');
netcdf.putAtt(ncid, VarIdWHGT, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWHGT, 'long_name', 'Hourly Significant Height of Wind and Swell Waves');
netcdf.putAtt(ncid, VarIdWHGT, 'standard_name', 'sea_surface_wave_significant_height');
netcdf.putAtt(ncid, VarIdWHGT, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWHGT, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWHGT, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWHGT, 'valid_max', 30);
netcdf.putAtt(ncid, VarIdWHGT, 'data_min', min(whgt));
netcdf.putAtt(ncid, VarIdWHGT, 'data_max', max(whgt));
netcdf.putAtt(ncid, VarIdWHGT, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdWHGT, 'platform', 'platform');

VarIdWAPd = netcdf.defVar(ncid, 'average_wave_period', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWAPd, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWAPd, 'units', 's');
netcdf.putAtt(ncid, VarIdWAPd, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWAPd, 'long_name', 'Hourly Average Wave Period');
netcdf.putAtt(ncid, VarIdWAPd, 'standard_name', 'average_wave_period');
netcdf.putAtt(ncid, VarIdWAPd, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWAPd, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWAPd, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWAPd, 'valid_max', 40);
netcdf.putAtt(ncid, VarIdWAPd, 'data_min', min(awpd));
netcdf.putAtt(ncid, VarIdWAPd, 'data_max', max(awpd));
netcdf.putAtt(ncid, VarIdWAPd, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdWAPd, 'platform', 'platform');

VarIdWDPd = netcdf.defVar(ncid, 'dominant_wave_period', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWDPd, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWDPd, 'units', 's');
netcdf.putAtt(ncid, VarIdWDPd, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWDPd, 'long_name', 'Hourly Dominant Wave Period');
netcdf.putAtt(ncid, VarIdWDPd, 'standard_name', 'dominant_wave_period');
netcdf.putAtt(ncid, VarIdWDPd, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWDPd, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWDPd, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWDPd, 'valid_max', 40);
netcdf.putAtt(ncid, VarIdWDPd, 'data_min', min(dwpd));
netcdf.putAtt(ncid, VarIdWDPd, 'data_max', max(dwpd));
netcdf.putAtt(ncid, VarIdWDPd, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdWDPd, 'platform', 'platform');

VarIdMWDir = netcdf.defVar(ncid, 'mean_wave_direction', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdMWDir, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdMWDir, 'units', 'degree');
netcdf.putAtt(ncid, VarIdMWDir, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdMWDir, 'long_name', 'Hourly Mean Wave Direction');
netcdf.putAtt(ncid, VarIdMWDir, 'standard_name', 'sea_surface_wave_from_direction');
netcdf.putAtt(ncid, VarIdMWDir, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdMWDir, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdMWDir, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdMWDir, 'valid_max', 360);
netcdf.putAtt(ncid, VarIdMWDir, 'data_min', min(mwdir));
netcdf.putAtt(ncid, VarIdMWDir, 'data_max', max(mwdir));
netcdf.putAtt(ncid, VarIdMWDir, 'grid_mapping', 'crs');
netcdf.putAtt(ncid, VarIdMWDir, 'platform', 'platform');

netcdf.endDef(ncid)  % Leave define mode.

% Now store the data
netcdf.putVar(ncid, VarIdLatitude,Latitude);
netcdf.putVar(ncid, VarIdLongitude,Longitude);
netcdf.putVar(ncid, VarIdTime,time);
netcdf.putVar(ncid, VarIdDepthSST,depth_sst);
netcdf.putVar(ncid, VarIdDepthATMP,depth_atmp);
netcdf.putVar(ncid, VarIdDepthWND,depth_wnd);
netcdf.putVar(ncid, VarIdDepthPRESS,depth_press);
netcdf.putVar(ncid, VarIdDepthWAV,depth_wav);
netcdf.putVar(ncid, VarIdTS ,NDBC_ID);
netcdf.putVar(ncid, VarIdSSTemp,sst);
netcdf.putVar(ncid, VarIdPress,press);
netcdf.putVar(ncid, VarIdWHGT,whgt);
netcdf.putVar(ncid, VarIdWAPd,awpd);
netcdf.putVar(ncid, VarIdWDPd,dwpd);
netcdf.putVar(ncid, VarIdMWDir,mwdir);

% Close the file. Finished.
netcdf.sync(ncid)
netcdf.close(ncid)
