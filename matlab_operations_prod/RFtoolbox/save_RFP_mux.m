function save_RFP_mux(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save_RFP_mux.m - Stores the current signal and cavity multiplexer setting on
%                  the RF processing VXI module so they can be restored after a
%                  task has been completed.  This is designed to preserve fast
%                  fault history settings.  Paul 2/4/99

% W. Colocho, 04/11/2005 - save RFP NOISE selector setting.
% MOD: W. Colocho, 12/9/2002 - Made into a function() and 
% replaced rf_module with handles.rfModule, 
% signal_mux_setting with handles.signalMuxSetting, and 
% cavity_mux_setting with handles.cavityMuxSetting for use with handles structure.

pvNames = {
    [handles.rfModule, ':FBSIG'];
    [handles.rfModule, ':CAVSEL'];
    [handles.rfModule, ':DINJ']
    };
pvValues = lcaGet( pvNames, 0, 'double' );
handles.signalMuxSetting = pvValues(1);
handles.cavityMuxSetting = pvValues(2);   
handles.noiseMuxSetting  = pvValues(3);   

% update handles data
guidata(handles.output, handles)
return
end
% % get the SIGNAL multiplexer setting 
% [status,answer] = caShell(['caget -t -n -w 20 ' handles.rfModule,':FBSIG']);
% if status ~=0 
%    fprintf(1,'Error - unable to read RFP signal mux setting\n');
%    return
% end
% %signal_mux_setting = answer;  % mux labeled 0 to 3
% handles.signalMuxSetting = answer;  
% 
% % get the CAVITY multiplexer setting
% [status,answer] = caShell(['caget -w 20 ' handles.rfModule,':CAVSEL']);
% if status ~=0   
%    fprintf(1,'Error - unable to read RFP cavity mux setting\n');
%    return
% end
% %cavity_mux_setting = answer;  % mux labeled 0 to 3
% handles.cavityMuxSetting = answer;   
% 
% % get the NOISE 1/2 setting
% [status,answer] = caShell(['caget -t -n -w 20 ' handles.rfModule,':DINJ']);
% if status ~=0   
%    fprintf(1,'Error - unable to read NOISE 1/2 control setting\n');
%    return
% end
% %cavity_mux_setting = answer;  % mux labeled 0 to 3
% handles.noiseMuxSetting = answer;  
% % update handles data
% guidata(handles.output, handles)
