function [ machine ] = stationtomachine( stationName )
% function [ machine ] = stationtomachine( stationName )
% stationtomachine returns the value of the machine name to use in the
%  various parameter files for a given RF station
%
% stationName     name of station used in guis (e.g. 'SRF1', 'HR81')
% machine         name of machine in RF tables (e.g. 'spear3', 'pepii-HER')
%
% usage:  machine = stationtomachine( 'SRF1' );

switch( stationName )
    case {'HR41', 'HR46','HR81', 'HR83', 'HR85', 'HR21', 'HR22', 'HR23', ...
          'HR24','HR25', 'HR26'}
        machine = 'pepii-HER';
    case {'LR42', 'LR43', 'LR44', 'LR45'}
        machine = 'pepii-LER';
    case 'SRF1'
        machine = 'spear3';
    case 'LAB1'
        machine = 'pepii-LAB';
    otherwise
        machine = 'unknown';
end
