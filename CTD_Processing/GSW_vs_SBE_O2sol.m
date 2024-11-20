SP = 32; t = 4;

SA = gsw_SA_from_SP(SP,0,0,0)
CT = gsw_CT_from_t(SA,t,0)
pt = gsw_pt_from_CT(SA,CT)
oxsol = gsw_O2sol_SP_pt(SP,pt)

prho = gsw_rho_CT_exact(SA,CT,0); % potential density with ref == surf

oxsol*prho/1000/44.661