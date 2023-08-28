% Set up workspace 

clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')


% Calculate oxygen sensor lag for CTD alignment 

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9')
cd('C:\Users\fogaren\Documents\SBE\Year1')
% Casts 
% cast01 = readSBScnv( 'kn22104001.cnv' );
cast02 = readSBScnv( 'kn22104002.cnv' );
cast03 = readSBScnv( 'kn22104003.cnv' );
cast04 = readSBScnv( 'kn22104004.cnv' );
cast05 = readSBScnv( 'kn22104005.cnv' );
cast06 = readSBScnv( 'kn22104006.cnv' );
cast07 = readSBScnv( 'kn22104007.cnv' );
cast08 = readSBScnv( 'kn22104008.cnv' );
cast09 = readSBScnv( 'kn22104009.cnv' );

%%
% cast = alignCTD_KF(cast,CastString,a1,a2,a3) % Function
a1 = 4; a2 = 6; a3 = 8;
cast02 = align_CTD_KF(cast02,'Cast 02',a1,a2,a3);
cast03 = align_CTD_KF(cast03,'Cast 03',a1,a2,a3);
cast04 = align_CTD_KF(cast04,'Cast 04',a1,a2,a3);
cast05 = align_CTD_KF(cast05,'Cast 05',a1,a2,a3);
cast06 = align_CTD_KF(cast06,'Cast 06',a1,a2,a3);
cast07 = align_CTD_KF(cast07,'Cast 07',a1,a2,a3);
cast08 = align_CTD_KF(cast08,'Cast 08',a1,a2,a3);
cast09 = align_CTD_KF(cast09,'Cast 09',a1,a2,a3);