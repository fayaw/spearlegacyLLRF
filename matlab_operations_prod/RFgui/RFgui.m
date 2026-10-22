function varargout = RFgui(varargin)
% RFGUI M-file for RFgui.fig
%      RFGUI, by itself, creates a new RFGUI or raises the existing
%      singleton*.
%
%      H = RFGUI returns the handle to a new RFGUI or the handle to
%      the existing singleton*.
%
%      RFGUI('CALLBACK',hObject,eventData,handles,...) calls the local 
%      function named CALLBACK in RFGUI.M with the given input arguments. 
%
%      RFGUI('Property','Value',...) creates a new RFGUI or raises the 
%      existing singleton*.  Starting from the left, property value pairs are 
%      applied to the GUI before RFgui_OpeningFunction gets called.  An 
%      unrecognized property name or invalid value makes property application 
%      stop.  All inputs are passed to RFgui_OpeningFcn via varargin. 
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one 
%      instance to run (singleton)". 
%
% See also: GUIDE, GUIDATA, GUIHANDLES 

% Edit the above text to modify the response to help RFgui 

% Last Modified by GUIDE v2.5 28-Jul-2003 14:42:52

% Begin initialization code - DO NOT EDIT 
gui_Singleton = 1; 
gui_State = struct('gui_Name',       mfilename, ... 
                   'gui_Singleton',  gui_Singleton, ... 
                   'gui_OpeningFcn', @RFgui_OpeningFcn, ... 
                   'gui_OutputFcn',  @RFgui_OutputFcn, ... 
                   'gui_LayoutFcn',  [] , ... 
                   'gui_Callback',   []); 
if nargin & isstr(varargin{1}) 
    gui_State.gui_Callback = str2func(varargin{1}); 
end 
 
if nargout 
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:}); 
else 
    gui_mainfcn(gui_State, varargin{:}); 
end 
% End initialization code - DO NOT EDIT 
 
 
% --- Executes just before RFgui is made visible. 
function RFgui_OpeningFcn(hObject, eventdata, handles, varargin) 
% This function has no output args, see OutputFcn. 
% hObject    handle to figure 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
% varargin   command line arguments to RFgui (see VARARGIN) 
 
set(hObject,'Color',[0.839,0.878,0.878]) 
 
%Use hostMachine to select pull down menu options.

hostMachine = getenv('HOST');
handleSelSta = findobj('Tag', 'selectStation');
handleSelAct = findobj('Tag', 'selectAction' );
handleSelPri = findobj('Tag', 'selectPrinter');

%Set defaults.
selStaList = {'SRF1'};
selActList = {'Measure Direct Closed'; 'Measure Ripple'; 'Measure Cavity'; 'Plot Cavity'; ...
	      'Plot Drive'; 'Plot Klystron Out' ; 'Plot Noise'; ...
	      'Plot Total'; 'Plot AIM'; 'Measure Klystron TF'; 'Plot Closed TF'};
selPriList = {'Printer: Spear Color'; ...
	      'Printer: B270 HP4200'; ...
	      'Printer: LOS246 HP4550'; ...
	      'Printer: LOS3 HP8550'; ...
	      'Printer: LOS3 HP4050'; ...
	      'Printer: B120 HP5500'; ...
	      'Printer: AMRF'; ...
	      'Printer: spear3log'; ...
	      'Printer: elog_rf'};	   

switch hostMachine
   case { 'pepii' }
      stationName = 'HR41';      
      selStaList = {'HR41'; 'HR46'; 'HR81'; 'HR83'; 'HR85'; ...
	            'HR21'; 'HR22'; 'HR23'; 'HR24'; 'HR25'; 'HR26'; ... 
	            'LR42'; 'LR43'; 'LR44'; 'LR45'};
      selActList = {'Measure Direct Closed'; 'Measure Ripple'; 'Measure Cavity'; 'Plot Cavity'; ...
	            'Plot Drive'; 'Plot Klystron Out' ; 'Plot Noise'; ...
	            'Plot Total'; 'Plot AIM'; 'Measure Klystron TF'; 'Plot Closed TF';...
	            'Plot Comb Out'};
      selPriList = {'Printer: PEPLOG'; ... 
	            'Printer: MCC'; ...
	            'Printer: Test Lab'; ...
	            'Printer: TL Color'; ...
	            'Printer: AMRF';
	            'Printer: elog_rf'};
   otherwise
      stationName = 'SRF1';
end %switch

set(handleSelSta, 'String', selStaList );
set(handleSelAct, 'String', selActList );
set(handleSelPri, 'String', selPriList );

machine = stationtomachine( stationName );

prm = sys_prm(machine);

rfFrequency =  prm.accel.wrf / (2 * pi);
harmonicNumber =  prm.accel.h;
samplesPerRev =  prm.rf.hcomb;
rfData = prm.files.rf_data;
tableDir = prm.files.rf_tbl;
rfFrequencyMHz = rfFrequency/1e6;

handles = struct( 'output', hObject, ...  % pointer to figure window 
    'rfData', rfData, ...                 % directory that contains the data files 
    'tableDir',tableDir, ...              % directory that contains the table files 
    'station',stationName, ...                 % rf station under investigation 
    'cavity' , 1, ...                     % rf station's cavity     
    'idAction', 1, ...                    % id of plotting routine 
    'labAction', 'RFP Cavity', ...        % label of plotting command 
    'fftFlag', 0, ...                     % yes/no flag to calculate fft  
    'signalMuxSetting', [], ...            % used by save/restore_RFP_mux 
    'cavityMuxSetting', [], ...            % used by save/restore_RFP_mux 
    'rfModule', [], ...                    % rf Module 
    'samplingFrequency', (rfFrequencyMHz*samplesPerRev)/harmonicNumber,...% Module sampling frequency in MHz 
    'Tsample', 1/((samplesPerRev*rfFrequency)/harmonicNumber), ...               % sample period for one revolution 
    'nTurns', inf, ...                    % number of turns to plot 
    'rfFrequency', rfFrequency,...           % RF frequency Hz.		  
    'h',harmonicNumber,...                %harmonic Number
    'samplesPerRev', samplesPerRev, ...   % samples per revolution (harmonic number of comb)
    'cavityQ', prm.rf.Q, ...              % unloaded cavity Q
    'cavityBeta', prm.rf.Beta, ...        % cavity beta
    'figHandles', [], ...                 % number of figures that are plotted 
    'fftFigHandles',[], ...               % number of figures that plot FFTs 
    'time', [], ...                       % time vector (abscissa) of data 
    'data', []);                          % matrix of data (ordinate) to plot 
 
% Choose default command line output for RFgui 
% handles.output = hObject; 
 
% Update handles structure 
guidata(hObject, handles); 

%Don't show cavity selector unless plot cavity is picked.
handleSelCav = findobj('Tag','selectCavity');
set(handleSelCav, 'Visible', 'off')
hanText4 = findobj('Tag','text4');
set(hanText4, 'Visible', 'off')


% UIWAIT makes RFgui wait for user response (see UIRESUME) 
% uiwait(handles.RFgui); 


% --- Outputs from this function are returned to the command line. 
function varargout = RFgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT); 
% hObject    handle to figure 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
 
% Get default command line output from handles structure 
varargout{1} = handles.output; 


% --- Executes during object creation, after setting all properties.
function selectStation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in selectStation.
function selectStation_Callback(hObject, eventdata, handles)
% hObject    handle to selectStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectStation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectStation
 
% get data from callback 
val = get( hObject, 'Value' ); 
switch val 
    case 1
        if (~strcmp(handles.station,'SRF1')) %Don't update station
                                             %if it's SRF1
        handles.station = 'HR41'; 
	end %if strcmp	
    case 2 
        handles.station = 'HR46';
    case 3 
        handles.station = 'HR81'; 
    case 4 
        handles.station = 'HR83'; 
    case 5 
        handles.station = 'HR85'; 
    case 6 
        handles.station = 'HR21'; 
    case 7 
        handles.station = 'HR22'; 
    case 8 
        handles.station = 'HR23'; 
    case 9 
        handles.station = 'HR24';
    case 10 
        handles.station = 'HR25'; 
    case 11
        handles.station = 'HR26'; 
    case 12 
        handles.station = 'LR42'; 
    case 13
        handles.station = 'LR43'; 
    case 14 
        handles.station = 'LR44'; 
    case 15 
        handles.station = 'LR45'; 
end % switch val 
 
% update  handles data 
guidata(handles.output, handles); 

% --- Executes during object creation, after setting all properties.
function selectAction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectAction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in selectAction.
function selectAction_Callback(hObject, eventdata, handles)
% hObject    handle to selectAction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectAction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectAction
 
% get data from callback 
val = get( hObject, 'Value' ); 
handles.idAction = val; 
str = get( hObject, 'String' ); 


%Only show cavity selector for plot cavity option.
hanText4 = findobj('Tag','text4');
handleSelCav = findobj('Tag','selectCavity');
if (val == 4 | val == 3)
   set(handleSelCav, 'Visible', 'on')
   set(hanText4, 'Visible', 'on')
else
   set(handleSelCav, 'Visible', 'off')
   set(hanText4, 'Visible', 'off')
end % if val.

switch val 
    case 1 
        handles.labAction = 'Measure Direct Closed'; 
    case 2  
        handles.labAction = 'Measure Ripple'; 
    case 3 
         handles.labAction = 'Measure Cavity'; 
    case 4 
        handles.labAction = 'Plot Cavity'; 
    case 5  
        handles.labAction = 'Plot Drive'; 
    case 6  
        handles.labAction = 'Plot Klystron Out'; 
    case 7  
        handles.labAction = 'Plot Noise'; 
    case 8  
        handles.labAction = 'Plot Total'; 
    case 9
        handles.labAction = 'Plot AIM';  
    case 10 
        handles.labAction = 'Measure Klystron TF'; 
    case 11
        handles.labAction = 'Plot Close TF';
    case 12
        handles.labAction = 'Plot Comb Out';

end % switch val 
 
% update data 
guidata(handles.output, handles); 

% --- Executes on button press in plotData.
function plotData_Callback(hObject, eventdata, handles)
% hObject    handle to plotData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.idAction 

     case 1 
        measure_direct_closed(hObject, eventdata, handles);     
     case 2  
        measure_ripple(hObject, eventdata, handles); 
     case 3 
        measure_cavity(hObject, eventdata, handles);  
     case 4 
        plot_cavity(hObject, eventdata, handles);  
     case 5 
        plot_drive(hObject, eventdata, handles); 
     case 6  
        plot_klys_out(hObject, eventdata, handles); 
     case 7  
        plot_noise(hObject, eventdata, handles); 
     case 8  
        plot_total(hObject, eventdata, handles); 
     case 9
        plot_aim(hObject, eventdata, handles); 
     case 10 
        measure_klystron_TF(hObject, eventdata, handles);  
     case 11
        plot_TFC2(hObject, eventdata, handles);
     case 12
        plot_comb_out(hObject, eventdata, handles); 
	
end % switch handles.idAction 


% --- Executes during object creation, after setting all properties.
function turnsZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to turnsZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in turnsZoom.
function turnsZoom_Callback(hObject, eventdata, handles)
% hObject    handle to turnsZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns turnsZoom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from turnsZoom


% --- Executes during object creation, after setting all properties.
function selectPrinter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectPrinter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in selectPrinter.
function selectPrinter_Callback(hObject, eventdata, handles)
% hObject    handle to selectPrinter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectPrinter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectPrinter


% --- Executes during object creation, after setting all properties.
function figuresToPrint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figuresToPrint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in figuresToPrint.
function figuresToPrint_Callback(hObject, eventdata, handles)
% hObject    handle to figuresToPrint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns figuresToPrint contents as cell array
%        contents{get(hObject,'Value')} returns selected item from figuresToPrint


% --- Executes during object creation, after setting all properties.
function figureNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figureNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function figureNumber_Callback(hObject, eventdata, handles)
% hObject    handle to figureNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of figureNumber as text
%        str2double(get(hObject,'String')) returns contents of figureNumber as a double

% --- Executes on button press in printData. 
function printData_Callback(hObject, eventdata, handles) 
% hObject    handle to printData (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
 
%Decide on figures to print  
h = findobj('Tag','figuresToPrint'); 
val = get(h,'Value')                        
 
switch val 
    case 1 
        figuresToPrint = [handles.figHandles handles.fftFigHandles];
    case 2
        h = findobj('Tag','figureNumber') 
        figuresToPrint = str2num( get(h,'string') ) 
end %switch val 
 
%Decide on printer to print to 
h = findobj('Tag','selectPrinter') 
val = get( h, 'Value' ); 
if ( strcmp(handles.station, 'SRF1' ) )
   switch val 
    case 1
        printerName ='-Pspear_color';
        printerDriver = '-dpsc';  
    case 2
        printerName = '-Pb270-hp4200'; 
        printerDriver = '-dps';
    case 3
        printerName = '-Plos246-hp4550'; 
        printerDriver = '-dpsc';
    case 4
        printerName = '-Plos3-hp8550'; 
        printerDriver = '-dpsc';
    case 5
        printerName = '-Plos3-hp4050'; 
        printerDriver = '-dps';
    case 6
        printerName = '-Pb120-hp5500'; 
        printerDriver = '-dpsc';
    case 7
        printerName = '-Phpamrf'; 
        printerDriver = '-dps';
    case 8
        printerName = '-Pspear3log'; 
        printerDriver = '-dps';
    case 9
        printerName = '-Pelog_rf'; 
        printerDriver = '-dpsc';
    end %switch val
else
  switch val
      case 1
        printerName ='-Ppeplog';
	printerDriver = '-dpsc';  
      case 2
        printerName ='-Pmcc_big';
        printerDriver = '-dps';      
      case 3
        printerName = '-Ptl4mv';
        printerDriver = '-dps';
      case 4
        printerName = '-Ptlclw';
        printerDriver = '-dpsc';
      case 5
        printerName = '-Phpamrf'; 
        prinerDriver = '-dps';
      case 6
        printerName = '-Pelog_rf'; 
        printerDriver = '-dpsc';
    end %switch val
end %if station == SRF1  

% find figure handles and print figures 
for ind = 1:length(figuresToPrint), 
    if ishandle( figuresToPrint(ind) ), 
        print(printerName,printerDriver,['-f',num2str(figuresToPrint(ind))]); 
    end % if ishandle( figuresToPrint(ind) ), 
end % for ind = 1:length(figuresToPrint), 
disp(['Printing ',num2str(length(figuresToPrint)),' figures to ',... 
        printerName(3:length(printerName))]) 
 

% --- Executes on button press in exitMatlab.
function exitMatlab_Callback(hObject, eventdata, handles)
% hObject    handle to exitMatlab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
 
% find figure handles and close figures 
figHandles = handles.figHandles; 
for ind = 1:length(figHandles), 
    if ishandle( figHandles(ind) ), 
        close(figHandles(ind)); 
    end % if ishandle( figHandles(ind) ), 
end % for ind = 1:length(figHandles), 
 
% find FFT figure handles and close FFT figures 
fftFigHandles = handles.fftFigHandles; 
for ind = 1:length(fftFigHandles), 
    if ishandle( fftFigHandles(ind) ), 
        close(fftFigHandles(ind)); 
    end % if ishandle( fftFigHandles(ind) ), 
end % for ind = 1:length(fftFigHandles), 
% close RFgui figure 
hRFgui = findobj( handles.output, 'Tag', 'RFgui' ); 
close( hRFgui ); 
return 


% --- Executes during object creation, after setting all properties.
function selectCavity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectCavity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in selectCavity.
function selectCavity_Callback(hObject, eventdata, handles)
% hObject    handle to selectCavity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectCavity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectCavity

% get data from callback 

handles.cavity = get( hObject, 'Value' );
% update data
guidata(handles.output, handles);
