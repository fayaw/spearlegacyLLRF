% file_prm          - Generates paths to config files

function files = file_prm(machine)

switch (machine)
  case 'als'
    files = [];
  case 'dafne+'
    files = [];
  case 'dafne-'
    files = [];
  case 'dafne1+'
    files = [];
  case 'dafne1-'
    files = [];
  % DAFNE with strong RF focusing: 10 MV gap voltage
  case 'dafne_strong'
    files = [];
  case 'bessy'
    files = [];
  % HER on the gateway
  case 'pepii-HER'
    files.rf_data  = '/u1/pepii/llrf/';
    files.rf_tbl   = [ files.rf_data, 'tbl/' ];
    files.comb_iir = [ files.rf_tbl, 'cfmIirCoefsHER.tbl'];
    files.comb_eq  = [ files.rf_tbl, 'detuneEqHER.tbl'];
    files.gff_dsp  = [ files.rf_tbl, 'gvfDspConsts.tbl'];
    files.gff_eq   = [ files.rf_tbl, 'gvfHERdetun.tbl'];
    files.dsp_rip  = '/dsp/rippleRfp';
  % HER from the AFS side
  case 'pepii-HER-afs'
    files.rf_data  = '/nfs/opi00gtw00/u1/pepii/llrf/';
    files.rf_tbl   = [ files.rf_data, 'tbl/' ];
    files.comb_iir = [ files.rf_tbl, 'cfmIirCoefsHER.tbl'];
    files.comb_eq  = [ files.rf_tbl, 'detuneEqHER.tbl'];
    files.gff_dsp  = [ files.rf_tbl, 'gvfDspConsts.tbl'];
    files.gff_eq   = [ files.rf_tbl, 'gvfHERdetun.tbl'];
    files.dsp_rip  = '/dsp/rippleRfp';
  case 'pepii-LAB'
    files.rf_data  = '/nfs/slac/g/cd/ioc/';
    files.rf_tbl   = [ files.rf_data, 'tbl/' ];
    files.comb_iir = [ files.rf_tbl, 'cfmIirCoefsHER.tbl'];
    files.comb_eq  = [ files.rf_tbl, 'detuneEqHER.tbl'];
    files.gff_dsp  = [ files.rf_tbl, 'gvfDspConsts.tbl'];
    files.gff_eq   = [ files.rf_tbl, 'gvfHERdetun.tbl'];
    files.dsp_rip  = '/dsp/rippleRfp';
  case 'pepii-LER'
    files.rf_data  = '/u1/pepii/llrf/';
    files.rf_tbl   = [ files.rf_data, 'tbl/' ];
    files.comb_iir = [ files.rf_tbl, 'cfmIirCoefsLER.tbl'];
    files.comb_eq  = [ files.rf_tbl, 'detuneEqLER.tbl'];
    files.gff_dsp  = [ files.rf_tbl, 'gvfDspConsts.tbl'];
    files.gff_eq   = [ files.rf_tbl, 'gvfLERdetun.tbl'];
    files.dsp_rip  = '/dsp/rippleRfp';
  case 'pepii-LER-afs'
    files.rf_data  = '/nfs/opi00gtw00/u1/pepii/llrf/';
    files.rf_tbl   = [ files.rf_data, 'tbl/' ];
    files.comb_iir = [ files.rf_tbl, 'cfmIirCoefsLER.tbl'];
    files.comb_eq  = [ files.rf_tbl, 'detuneEqLER.tbl'];
    files.gff_dsp  = [ files.rf_tbl, 'gvfDspConsts.tbl'];
    files.gff_eq   = [ files.rf_tbl, 'gvfLERdetun.tbl'];
    files.dsp_rip  = '/dsp/rippleRfp';
  case 'spear3'
      % entered 03-dec-2003  jjs
      % spear3 has no comb filters or gap voltage control
% for pc applications use nfsmaestro, for example, to mount
%  p:  \\zantar.slac.stanford.edu\/nfs/spear
%  q:  \\zantar.slac.stanford.edu\/prod
    % check for machine type
    % file server changed from spearfs to spearfs2
    % does not work for pc yet
    if strncmp(computer,'PC',2),
        files.rf_data  = 'P:/epicsdata/app/spear/data/';
        files.rf_tbl   = 'Q:/epics/app/spear/iocBoot/tbl/';
    else
%         files.rf_data  = '/speardata/epicsdata/app/spear/data/';
        files.rf_data  = '/speardatarf/epicsdata/app/spear/data/';
        files.rf_tbl   = '/prod/epics/app/spear/iocBoot/tbl/';
    end % if strncmp(computer,'PC',2),
    files.comb_iir = [ ];
    files.comb_eq  = [ ];
    files.gff_dsp  = [ ];
    files.gff_eq   = [ ];
    files.dsp_rip  = '/dsp/sp3rippleRfp';
otherwise
    files.error = ['Unknown machine: ', machine];
    return;
end
