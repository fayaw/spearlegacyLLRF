function restore_RFP_mux(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% restore_RFP_mux.m - Restores the current signal and cavity multiplexer setting on the
%                     RF processing VXI module to the values saved by store_RFP_mux.m
%                     Also turnes off the DACs and starts recording so a fast
%                     fault will have valid data to save.  Paul 2/4/99

% W. Colocho, 04/11/2005 - restore RFP NOISE selector setting.
% MOD: W. Colocho, 12/9/2002 - Made into a function() and 
% replaced rf_module with handles.rfModule, 
% signal_mux_setting with handles.signalMuxSetting, and 
% cavity_mux_setting with handles.cavityMuxSetting for use with handles structure.

fprintf(1,'\nReady to restore RFP mux setting\n');
pvNames = {
    [handles.rfModule, ':FBSIG'];
    [handles.rfModule, ':CAVSEL'];
    [handles.rfModule, ':DINJ']
    };
pvValues = [
    handles.signalMuxSetting;
    handles.cavityMuxSetting;
    handles.noiseMuxSetting
    ];
lcaPut( pvNames, pvValues );

lcaPut({[handles.rfModule, ':DACS']; [handles.rfModule, ':SSCONT']}, [0;1]);
% reset, load, run
for ind = 0:2,
    lcaPut([handles.rfModule, ':STATE'], ind);
    % pause to allow module to respond to these states
    pause(0.1);
end % for ind = 0:2,

return
end
% % restore the SIGNAL multiplexer setting
% %fprintf(1,'ready to restore RFP signal mux setting\n');
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':FBSIG ',handles.signalMuxSetting]);
% if status ~=0
%    fprintf(1,'Error - unable to restore RFP signal mux setting\n');
% end
% 
% % restore the cavity multiplexer setting
% %fprintf(1,'ready to restore RFP cavity mux setting\n');
% [status,answer] = caShell(['caput -s -w 60 ', handles.rfModule,':CAVSEL ',handles.cavityMuxSetting]);
% if status ~=0
%    fprintf(1,'Error - unable to restore RFP cavity mux setting\n');
% end
% 
% % restore the NOISE 1/2 selector setting.
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':DINJ ',handles.noiseMuxSetting]);
% if status ~=0
%    fprintf(1,'Error - unable to restore RFP cavity mux setting\n');
% end
% 
% % disable the DACs
% %fprintf(1,'ready to disable the RFP DACs\n');
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':DACS 0']);
% if status ~=0
%    fprintf(1,'Error - can not disable the DACs\n');
% end
% 
% % place the module in continuous mode
% %fprintf(1,'ready to place the RFP module in continuous mode\n');
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':SSCONT 1']);
% if status ~=0
%    fprintf(1,'Error - can not place the module in continuous mode\n');
% end
% 
% % place the module in Reset mode
% %fprintf(1,'ready to place the RFP module in reset state\n');
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':STATE 0']);
% if status ~=0
%    fprintf(1,'Error - can not place RF module in Reset state\n');
% end
% 
% % place the module in Load mode
% %fprintf(1,'ready to place the RFP module in load state\n');
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':STATE 1']);
% if status ~=0
%    fprintf(1,'Error - can not place RF module in Load state\n');
% end
% 
% % go to run mode to continuously take data
% %fprintf(1,'ready to place the RFP module in run state\n');
% [status,answer] = caShell(['caput -w 60 ', handles.rfModule,':STATE 2']);
% if status ~=0
%    fprintf(1,'Error - can not place RF module in Run state\n');
% end
