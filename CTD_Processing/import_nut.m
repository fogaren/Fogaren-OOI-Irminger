function nuts=import_nut(filename)
%
% Jan '05 - jadb  add btl qual-byte as nuts.q_btl
%    swap names of q-byte for oxygen. 
%  header OXY =  nuts.ctdoxyg & nuts.q_oxyg
%  header OXYG=  nuts.btloxy  & nuts.q_oxy
%function nuts=read_nut(filename)

% keyboard
fid=fopen(filename,'r');
lin=fgetl(fid);
ss=strread(lin,'%s',-1,'delimiter',' ');
k=strcmp(ss,'Number:');
% k=strcmp(ss,'Station:');
ii=find(k==1);
nuts.station=str2num(ss{ii+1});

lin=fgetl(fid);
lin=fgetl(fid);
nuts.parms=strread(lin,'%s',-1,'delimiter',' ');
lin=fgetl(fid);
nparms=length(nuts.parms);
form='';
for i=1:nparms
    form=[form,'%f'];
end
q=fscanf(fid,form,[nparms inf]);
fclose(fid);
q=q';

% ***** quality code ****
qualwd=int2str(q(:,nparms));

for i=1:nparms
    switch nuts.parms{i}
    case 'Bottle'
        nuts.bottno=q(:,i);
        nuts.q_btl=str2num(qualwd(:,i));
    case 'Pres.'
        nuts.ctdprs=q(:,i);
    case 'T1(90)'
        nuts.ctdtmp1=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_t1(j,1)=str2num(qualwd(j,i-1));
        end
    case 'T2(90)'
        nuts.ctdtmp2=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_t2(j,1)=str2num(qualwd(j,i-1));
        end
    case 'TH1(68)'
        nuts.ctdtht1=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_th1(j,1)=str2num(qualwd(j,i-1));
        end
    case 'TH2(68)'
        nuts.ctdtht2=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_th2(j,1)=str2num(qualwd(j,i-1));
        end
    case 'TH1(90)'
        nuts.ctdtht1=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_th1(j,1)=str2num(qualwd(j,i-1));
        end
    case 'TH2(90)'
        nuts.ctdtht2=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_th2(j,1)=str2num(qualwd(j,i-1));
        end
    case 'SAL1'
        nuts.ctdsal1=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_s1(j,1)=str2num(qualwd(j,i-1));
        end
    case 'SAL2'
        nuts.ctdsal2=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_s2(j,1)=str2num(qualwd(j,i-1));
        end
%ctdoxy 
% keyboard
    case 'OXY'
        nuts.ctdoxyg=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_oxyg(j,1)=str2num(qualwd(j,i-1));
        end
    case 'OXY1'
        nuts.ctdoxyg=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_oxyg(j,1)=str2num(qualwd(j,i-1));
        end
    case 'OXY2'
        nuts.ctdoxyg2=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_oxyg2(j,1)=str2num(qualwd(j,i-1));
        end
        
    case 'OXYu'
        nuts.ctdoxygu=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_oxygu(j,1)=str2num(qualwd(j,i-1));
        end
    case 'OXY2u'
        nuts.ctdoxyg2u=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_oxyg2u(j,1)=str2num(qualwd(j,i-1));
        end
        
%ctd flur
    case 'FLUR'
        nuts.ctdflur=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_flur(j,1)=str2num(qualwd(j,i-1));
        end
%ctd tran
    case 'TRAN'
        nuts.ctdtran=q(:,i);	
        for j=1:length(nuts.ctdprs)
            nuts.q_tran(j,1)=str2num(qualwd(j,i-1));
        end
        
%btl salt
    case 'SAL'
        nuts.btlsal=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_sal(j,1)=str2num(qualwd(j,i-1));
        end
%btl oxy
    case 'OXYG'
        
        nuts.btloxy=q(:,i); 
        for j=1:length(nuts.ctdprs)
            nuts.q_oxy(j,1)=str2num(qualwd(j,i-1));
        end
    case 'PO4'
        nuts.btlpo4=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_po4(j,1)=str2num(qualwd(j,i-1));
        end
    case 'NO3'
        nuts.btlno3=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_no3(j,1)=str2num(qualwd(j,i-1));
        end
    case 'SIL'
        nuts.btlsil=q(:,i); 
        for j=1:length(nuts.ctdprs)
            nuts.q_sil(j,1)=str2num(qualwd(j,i-1));
        end
    case 'NO2'
        nuts.btlno2=q(:,i);
        for j=1:length(nuts.ctdprs)
            nuts.q_no2(j,1)=str2num(qualwd(j,i-1));
        end
    end
end

