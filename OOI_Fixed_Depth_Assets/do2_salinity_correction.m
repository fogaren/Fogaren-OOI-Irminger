function [DO_umolkg] = do2_salinity_correction(DO_uM, prs, T, SP, lat, lon, S0)

%     Description:
% 
%         Calculates the data product DOXYGEN_L2 (renamed from DOCONCS_L2) from DOSTA
%         (Aanderaa) instruments by correcting the the DOCONCS_L1 data product for
%         salinity and pressure effects and changing units.

%     Usage:
% 
%         DOc = do2_salinity_correction(DO,P,T,SP,lat,lon, sref=0, pref=0)
% 
%             where
% 
%         DOc = corrected dissolved oxygen [micro-mole/kg], DOXYGEN_L2
%         DO = uncorrected dissolved oxygen [micro-mole/L], DOCONCS_L1
%         P = PRESWAT water pressure [dbar]. (see
%             1341-00020_Data_Product_Spec_PRESWAT). Interpolated to the
%             same timestamp as DO.
%         T = TEMPWAT water temperature [deg C]. (see
%             1341-00010_Data_Product_Spec_TEMPWAT). Interpolated to the
%             same timestamp as DO.
%         SP = PRACSAL practical salinity [unitless]. (see
%             1341-00040_Data_Product_Spec_PRACSAL)
%         lat, lon = latitude and longitude of the instrument [degrees].
%         sref/S0 = reference salinity, the value of the preset `Salinity` 
%             setting in the Aanderaa optode configuration.  Typically set
%             to 0 or 35.  The default is 0.
%         pref = pressure reference level for potential density [dbar].
%             The default is 0 dbar.
% 
%     Example:
%         DO = 433.88488978325478  # Uncompensated Oxygen from an optode
%         P = 5.40    # Pressure in dbar from co-located CTD
%         T = 1.97    # Temperature in deg C from co-located CTD
%         SP = 33.716 # Practical Salinity derived from co-located CTD
%         lat,lon = -52.82, 87.64 # Latitude and Longitude
% 
%         DOc = do2_salinity_correction(DO,P,T,SP,lat,lon)
%         print DOc
%         > 335.967894709
% 
%     Implemented by:
%         2013-04-26: Stuart Pearce. Initial Code.
%         2015-08-04: Russell Desiderio. Added Garcia-Gordon reference.
%         2021-12-16: Stuart Pearce. Added salinity reference parameter.
% 
%     References:
%         OOI (2012). Data Product Specification for Oxygen Concentration
%             from "Stable" Instruments. Document Control Number
%             1341-00520. https://alfresco.oceanobservatories.org/ (See:
%             Company Home >> OOI >> Controlled >> 1000 System Level
%             >> 1341-00520_Data_Product_SPEC_DOCONCS_OOI.pdf)
% 
%         "Oxygen solubility in seawater: Better fitting equations", 1992,
%         Garcia, H.E. and Gordon, L.I. Limnol. Oceanogr. 37(6) 1307-1312.
%         Table 1, 5th column.
%     """

    % density calculation from GSW toolbox

    SA = gsw_SA_from_SP(SP,prs,lon,lat); 
    CT = gsw_CT_from_t(SA,T,prs);
    pdens = gsw_rho(SA,CT,0); % potential referenced to prs = 0

    %  Convert from volume to mass units:
    DO_umolkg = 1000*DO_uM./pdens;
    
    % Salinity and pressure correction 
    temps = log((298.15-T)./(273.15+T)); %scaled temperature
    SB = [-6.24097E-3; %salinity correction coefficients (B0, B1, B2, and B3)
            -6.93498E-3;
            -6.90358E-3;
            -4.29155E-3];
    SC = -3.11680E-7; % salinity correction coefficient C0    
    D = 0.032; % pressure correction coefficient usual KF
    DO_umolkg = DO_umolkg.*exp((SP - S0).*(SB(1)+SB(2)*temps+SB(3)*temps.^2+SB(4)*temps.^3)...
        + SC.*(SP.^2 - S0.^2))...
        .*(1+prs.*D./1000);
end