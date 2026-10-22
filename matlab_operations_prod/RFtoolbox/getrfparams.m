function [fRf, h, fSampHarm, rfData, rfTable, dspFile] = ...
    getrfparams( machine )
% function [fRf, h, fSampHarm, rfData, rfTable, dspFile] = ...
%     getrfparams( machine )
% getrfparams obtains the various parameters of the rf system
%  needed for the matlab interface
% these parameters are stored in the files
%  accel_prm.m (fRf, h)
%  rf_prm.m  (fSampHarm)
%  file_prm.m  (rfData, rfTable, dspFile)
%
% machine         name of machine ('pepii-LER', 'spear3', etc.)
% fRf             rf frequency of machine in Hz
% h               harmonic number of machine
% fSampHarm       the revolution harmonic of the sampling frequency
% rfData          the directory in which the VXI controller writes
%                  the data
% rfTable         the directory in which the VXI controller writes
%                  the tables
% dspFile         the file used in configure_direct for ripple meas
% usage:  [fRf, h, fS, rfData, rfTable, dspFile] = getrfparams( 'spear3' );

% get fRf and h
accel = accel_prm( machine );
if isfield( accel, 'error' ),
    error( ['unable to obtain fRf or h for ', machine] );
end % if isfield( ap, 'error' ),
if isfield( accel, 'wrf' ),
    fRf = accel.wrf/(2*pi);
else
    error( ['unable to obtain fRf for ', machine] );
end % if isfield( accel, 'wrf' ),
if isfield( accel, 'h' ),
    h = accel.h;
else
    error( ['unable to obtain h for ', machine] );
end % if isfield( accel, 'h' ),

% get fSampHarm
rf = rf_prm( machine );
if isfield( rf, 'error' ),
    error( ['unable to obtain fSampHarm for ', machine] );
end % if isfield( rf, 'error' ),
if isfield( rf, 'hcomb' ),
    fSampHarm = rf.hcomb;
else
    error( ['unable to obtain fSampHarm for ', machine] );
end % if isfield( rf, 'hcomb' ),

% get rfData, rfTable, dspFile
file = file_prm( machine );
if isfield( file, 'error' ),
    error( ['unable to obtain directories and file for ', machine] );
end % if isfield( file, 'error' ),
if isfield( file, 'rf_data' ),
    rfData = file.rf_data;
else
    error( ['unable to obtain rf data directory for ', machine] );
end % if isfield( file, 'rf_data' ),
if isfield( file, 'rf_tbl' ),
    rfTable = file.rf_tbl;
else
    error( ['unable to obtain rf table directory for ', machine] );
end % if isfield( file, 'rf_tbl' ),
if isfield( file, 'dsp_rip' ),
    dspFile = file.dsp_rip;
else
    error( ['unable to obtain ripple file for ', machine] );
end % if isfield( file, 'dsp_rip' ),

return
