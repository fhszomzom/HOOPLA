function [Qsim, param, varargout] = HydroMod11( P, E, param )
% 
% [Qsim, param, varargout] = HydroMod11( P, E, param )
%
% MORDOR hydrological model
%
% INPUTS (time series of daily observations [n,1])
% P       = mean areal rainfall (mm)
% E       = mean areal evapotranspiration (mm)
% Q       = stream flow (mm)
% x       = the six model parameters (see "param" below) - [6,1]
%
% OUTPUTS
% Qs      = simulated stream flow (mm)
% perf    = model performances
% inter   = MORD6's internal values
% param -->
%   .x(1) = Coefficient correcteur sur la pluie
%   .x(2) = Constante de vidange du r�servoir L
%   .x(3) = Constante de vidange du r�servoir N
%   .x(4) = Temps de r�ponse de l�hydrogramme unitaire HU2
%   .x(5) = Capacit� du r�servoir U
%   .x(6) = Capacit� du r�servoir L
%
%   .U    = R�servoir de surface
%   .L    = R�servoir de sol
%   .Z    = R�servoir de sol profond
%   .N    = R�servoir souterrain
%
%   .UH2  = Unit hydrograph 2
%   .H2   = Hydrograph 2 values (mm) - updated at each time step
%
% FOLLOWING
% Mathevet, T., Quels mod�les pluie-d�bit globaux au pas de temps horaires,
% 2005
%
% Programmed by G. Seiller, Univ. Laval (05-2013)
% Slightly modified by A. Thiboult (2016)

%% Modeling
% Get parameters
%
x   = param.x ;
U   = param.U ;
L   = param.L ;
Z   = param.Z ;
N   = param.N ;
UH2 = param.UH2 ;
H2vsal  = param.H2vsal ;
H2rur  = param.H2rur ;
H2vn  = param.H2vn ;

%%%
%%% PRODUCTION PART
%%%

% Net inputs
%
Pl = P*x(1);
dtr1 = Pl*(U/x(5));
dtu1 = Pl-dtr1;

% Soil moisture accounting
%
vs = dtr1+max(0,U-x(5));
U = min(U+dtu1,x(5));
evu = min([U,x(5),(E*U)/x(5)]);
U = U-evu;

al = min(x(6)-L,vs*(1-(L/x(6))));
L = L+al;
vl = L/x(2);
L = L-vl;

% Percolation
%
dtz = vl*(1-(Z/90));
rur = 0.2*vl*(Z/90);
an = 0.8*vl*(Z/90);
Z = Z+dtz;
evz = min(Z,((E-evu)*Z)/90);
Z = min(90,Z-evz);

N = N+an;
vn = min(N,(N/x(3))^3);
N = N-vn;

%%%
%%% ROUTING
%%%

% Mise � jour de l'hydrogramme
%
H2vsal = [H2vsal(2:end); 0] + UH2* (vs-al) ;
H2rur = [H2rur(2:end); 0] + UH2* rur ;
H2vn = [H2vn(2:end); 0] + UH2* vn ;

% Calcul du d�bit total
%
Qsim = max( [0; H2vsal(1)] ) + max( [0; H2rur(1)] ) + max( [0; H2vn(1)] );


param.U  = U ;
param.L  = L ;
param.Z  = Z ;
param.N  = N ;
param.H2vsal = H2vsal ;
param.H2rur = H2rur ;
param.H2vn = H2vn ;

if nargout>2
    inter = [ U L Z N dtu1 dtr1 evu evz dtz vn rur ] ;
    
    % Flow components
    qsf = H2vsal(1) ;
    qs1 = H2rur(1) ; qs2 = 0 ; qs = qs1+qs2 ;
    qrs1 = 0 ; qrs2 = 0 ; qrs = qrs1+qrs2 ;
    qss1 = 0 ; qss2 = 0 ; qss = qss1+qss2 ;
    qrss1 = 0 ; qrss2 = 0 ; qrss = qrss1+qrss2 ;
    qn = H2vn(1) ;
    qr = 0 ;
    
    interq = [ qsf qs1 qs2 qs qrs1 qrs2 qrs qss1 qss2 qss qrss1 qrss2 qrss qn qr ];
    
    % Outputs
    varargout{1}=inter;
    varargout{2}=interq;
end