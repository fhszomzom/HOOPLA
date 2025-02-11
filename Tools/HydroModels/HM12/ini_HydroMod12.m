function [Result, Param] = ini_HydroMod12(Switches, Date, x)
%
% [Result, Param] = ini_HydroMod12(Switches, Date, x)
%
% HydroMod12 initialization, for details see associated HydroMod12.m file
%
% Programmed by G. Seiller, Univ. Laval (05-2013)
% Slightly modified by A. Thiboult (2016)

% Parameters
Param.x = x ;

% Routing delay consideration
drtfc = ceil( x(4) );
k = (0:drtfc)';
Param.DL = zeros( size(k) );
Param.DL(end-1) = 1/(x(4)-k(end-1)+1);
Param.DL(end) = 1-1/(x(4)-k(end-1)+1);
Param.HY  = zeros( size(Param.DL) );

% Initialization of the reservoir states
%
Param.U = x(9);
Param.L = x(7)*0.5;
Param.CK1 = 0;
Param.CK1b = 0;
Param.CK2 = 0;
Param.CK2b = 0;
Param.GW = 50;

% Initialize HydroMod12 for all time steps
%
lP    = length( Date ) ;
Result.Qs    = zeros( lP,1 ) ;

if Switches.exportLight.on == 0
    % Flow components
    Result.inter = zeros( lP, 7 ) ;
    Result.interq = zeros( lP, 15 ) ;
end