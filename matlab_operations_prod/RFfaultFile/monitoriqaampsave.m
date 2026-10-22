function monitoriqaampsave
for ind=1:100,
    d = lcaGet('SRF1:STN:IQA3:MODU.ASTT',1, 'int');
    fprintf(1,'d = %d\n', d);
    pause(0.1)
end 
return
end