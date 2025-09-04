function d = distlatlon(lat_1,lat_2,lon_1,lon_2)

%Input latitudes and longitudes and output distance between them in
%kilometers

%%Source for formula used in calculations:
%%http://www.movable-type.co.uk/scripts/latlong.html
% Haversine formula:
% 
% a = sin²(?lat/2) + cos(lat1).cos(lat2).sin²(?long/2)
% c = 2.atan2(?a, ?(1?a))
% d = R.c
%  	where R is earth’s radius (mean radius = 6,371km);
% note that angles need to be in radians to pass to trig functions!
% JavaScript:	
% var R = 6371; // km
% var dLat = (lat2-lat1).toRad();
% var dLon = (lon2-lon1).toRad();
% var lat1 = lat1.toRad();
% var lat2 = lat2.toRad();
% 
% var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
%         Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
% var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
% var d = R * c;

R = 6371; %Earth's radius, in km

    dlat=(lat_2-lat_1)*(pi/180);
    dlon=(lon_2-lon_1)*(pi/180);
    lat1=lat_1*(pi/180);
    lat2=lat_2*(pi/180);
    a=(sin(dlat/2))^2 + (sin(dlon/2))^2*cos(lat1)*cos(lat2);
    c=2*atan2(sqrt(a),sqrt(1-a));
    d=R*c;




