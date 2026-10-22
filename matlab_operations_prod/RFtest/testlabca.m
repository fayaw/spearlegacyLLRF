function testlabca
beamcurrpv = 'SPEAR:BeamCurrAvg'
beamcurr=lcaGet(beamcurrpv)
fprintf(1,'beam current = %s\n',beamcurr)
return
