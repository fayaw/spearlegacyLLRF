function varargout = faultFile(varargin) 
% FAULTFILE M-file for faultFile.fig 
%      FAULTFILE, by itself, creates a new FAULTFILE or raises the existing 
%      singleton*. 
% 
%      H = FAULTFILE returns the handle to a new FAULTFILE or the handle to 
%      the existing singleton*. 
% 
%      FAULTFILE('CALLBACK',hObject,eventData,handles,...) calls the local 
%      function named CALLBACK in FAULTFILE.M with the given input arguments. 
% 
%      FAULTFILE('Property','Value',...) creates a new FAULTFILE or raises the 
%      existing singleton*.  Starting from the left, property value pairs are 
%      applied to the GUI before faultFile_OpeningFunction gets called.  An 
%      unrecognized property name or invalid value makes property application 
%      stop.  All inputs are passed to faultFile_OpeningFcn via varargin. 
% 
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one 
%      instance to run (singleton)". 
% 
% See also: GUIDE, GUIDATA, GUIHANDLES 
 
% Edit the above text to modify the response to help faultFile 
 
% Last Modified by GUIDE v2.5 22-Apr-2004 09:27:24
 
% Begin initialization code - DO NOT EDIT 
gui_Singleton = 1; 
gui_State = struct('gui_Name',       mfilename, ... 
                   'gui_Singleton',  gui_Singleton, ... 
                   'gui_OpeningFcn', @faultFile_OpeningFcn, ... 
                   'gui_OutputFcn',  @faultFile_OutputFcn, ... 
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


% --- Executes just before faultFile is made visible. 
function faultFile_OpeningFcn(hObject, eventdata, handles, varargin) 
% This function has no output args, see OutputFcn. 
% hObject    handle to figure 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
% varargin   command line arguments to faultFile (see VARARGIN) 

set(hObject,'Color',[0.839,0.878,0.878]) 

%Use hostMachine to select pull down menu options.

hostMachine = getenv('HOST');
handleSelSta = findobj('Tag', 'selectStationPop');
handleSelAct = findobj('Tag', 'selectActionPop' );
handleSelPri = findobj('Tag', 'selectPrinterPop');
handleSelTrn = findobj('Tag', 'zoomPop');
%Set defaults.
selStaList = {'SRF1'};
selActList = {'RFP Cavity'; 'RFP Signal'; ...
	      'IQA 1'; 'IQA 2'; 'IQA 3'; 'AIM Module' }; 
selPriList = {'Printer: Spear Color'; ...
	      'Printer: B270 HP4200'; ...
	      'Printer: LOS246 HP4550'; ...
	      'Printer: LOS3 HP8550'; ...
	      'Printer: LOS3 HP4050'; ...
	      'Printer: B120 HP5500'; ...
	      'Printer: AMRF'; ...
	      'Printer: spear3log'; ...
	      'Printer: elog_rf'};	   
selTurnList = {'Turns Displayed: 2';'Turns Displayed: 5';'Turns Displayed: 10';...
	      'Turns Displayed: 20';'Turns Displayed: 50';'Turns Displayed: 100';...
	      'Turns Displayed: 1000';'Turns Displayed: all'};
switch hostMachine
   case { 'pepii' }
      stationName = 'HR41';      
      selStaList = {'HR41'; 'HR46';'HR81'; 'HR83'; 'HR85'; ...
	            'HR21'; 'HR22'; 'HR23'; 'HR24'; 'HR25'; 'HR26'; ...
	            'LR42'; 'LR43'; 'LR44'; 'LR45'};
      selActList = {'RFP Cavity'; 'RFP Signal'; 'IQA 1'; 'IQA 2'; ...
	            'IQA 3'; 'AIM Module' ; 'GPIB Waveforms';  'Comb Filter Module'; ...
	            'Gap Voltage Feed Foward'; 'Cavity Probes';...
	            'Ring Klystron Forward'}; 
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
set(handleSelTrn, 'String', selTurnList);

machine = stationtomachine( stationName );

prm = sys_prm(machine);

rfFrequency =  prm.accel.wrf / (2 * pi);
harmonicNumber =  prm.accel.h;
samplesPerRev =  prm.rf.hcomb;
rfData = prm.files.rf_data;
if (strcmp(getenv('HOST'),'slcs2'))
   rfData = '/nfs/mccfs0/u1/pepii/ctrl/' %for Testing 
end %if

rfFrequencyMHz = rfFrequency/1e6;

handles = struct( 'output', hObject, ...  % pointer to figure window 
    'rfData', rfData, ...                 % directory that contains the files 
    'station',stationName, ...                 % rf station under investigation 
    'idAction', 1, ...                    % id of plotting routine 
    'labAction', 'RFP Cavity', ...        % label of plotting command 
    'fftFlag', 0, ...                     % yes/no flag to calculate fft  
    'samplingFrequency', (rfFrequencyMHz*samplesPerRev)/harmonicNumber,...% Module sampling frequency in MHz.
    'Tsample', 1/((samplesPerRev*rfFrequency)/harmonicNumber), ...               % sample period for one revolution 
    'nTurns', inf, ...                    % number of turns to plot 
    'figHandles', [], ...                 % number of figures that are plotted 
    'fftFigHandles',[], ...               % number of figures that plot FFTs 
    'maxTime',[], ...                     % Vector of maximum time per plot
    'time', [], ...                       % time vector (abscissa) of data 
    'data', [], ...                          % matrix of data (ordinate) to plot 
    'faultNumber', '1' );                  % fault file number to plot.

% read the latest file number from EPICS 
[status,latestFileNumber] = caShell(['caget -t -w 20 ', handles.station,':STN:FAULT:NUM']);
if status ~=0
   fprintf(1,'Error - unable to read latest fault file number\n');
   return
end

h1 = findobj('Tag','latestFaultNumber');           
set(h1,'String',['Latest = ', latestFileNumber]); %Updates GUI information.

handles.faultNumber = latestFileNumber ;
h2 = findobj('Tag','faultNumberPop');
set(h2,'Value', str2num(latestFileNumber));

% read the date and time stamp for the file from EPICS 
[status,dateTime] = caShell(['caget -t -w 20 ', handles.station,':STN:FAULT:TIME', ...
                             num2str(handles.faultNumber)]);

if status ~=0
   fprintf(1,'Error - unable to read selected fault file date/time stamp\n');
   return
end
dateTimeForm = [dateTime(1:6), ' ', dateTime(7:10), ' ', dateTime(11:18) ];

% Display dateTime on the GUI

h1 = findobj('Tag','faultTime');
set(h1,'String',dateTimeForm); 


% Update handles structure 
guidata(hObject, handles); 


% UIWAIT makes faultFile wait for user response (see UIRESUME) 
% uiwait(handles.figure1); 
 
 
% --- Outputs from this function are returned to the command line. 
function varargout = faultFile_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT); 
% hObject    handle to figure 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
 
% Get default command line output from handles structure 
varargout{1} = handles.output; 


% --- Executes during object creation, after setting all properties.
function selectStationPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectStationPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in selectStationPop.
function selectStationPop_Callback(hObject, eventdata, handles)
% hObject    handle to selectStationPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectStationPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectStationPop
 
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

% read the latest file number from EPICS 
[status,latestFileNumber] = caShell(['caget -t -w 20 ', handles.station,':STN:FAULT:NUM']);
if status ~=0
   fprintf(1,'Error - unable to read latest fault file number\n');
   return
end

h1 = findobj('Tag','latestFaultNumber');           
set(h1,'String',['Latest = ', latestFileNumber]); %Updates GUI information.

handles.faultNumber = latestFileNumber ;
h2 = findobj('Tag','faultNumberPop');
set(h2,'Value', str2num(latestFileNumber));

% read the date and time stamp for the file from EPICS 
[status,dateTime] = caShell(['caget -t -w 20 ', handles.station,':STN:FAULT:TIME', ...
                             num2str(handles.faultNumber)]);

if status ~=0
   fprintf(1,'Error - unable to read selected fault file date/time stamp\n');
   return
end
dateTimeForm = [dateTime(1:6), ' ', dateTime(7:10), ' ', dateTime(11:18) ];

% Display dateTime on the GUI

h1 = findobj('Tag','faultTime');
set(h1,'String',dateTimeForm); 


% update data
guidata(handles.output, handles);


% --- Executes during object creation, after setting all properties.
function selectActionPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectActionPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in selectActionPop.
function selectActionPop_Callback(hObject, eventdata, handles)
% hObject    handle to selectActionPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectActionPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectActionPop

% get data from callback 
val = get( hObject, 'Value' ); 
handles.idAction = val; 
str = get( hObject, 'String' ); 
 
switch val
    case 1
        handles.labAction = 'RFP Cavity';
    case 2
        handles.labAction = 'RFP Signal';
    case 3
        handles.labAction = 'IQA 1';
    case 4
        handles.labAction = 'IQA 2';
    case 5
        handles.labAction = 'IQA 3';
    case 6
        handles.labAction = 'AIM Module' ; 
    case 7
        handles.labAction = 'GPIB Waveforms';
    case 8
        handles.labAction = 'Comb Filter Module';
    case 9
        handles.labAction = 'Gap Voltage Feed Foward';
    case 10
        handles.labAction = 'Cavity Probes';	
    case 11
        handles.labAction = 'Ring Klystron Forward';
end % switch val 
 
% update data 
guidata(handles.output, handles); 
 
return 
 

% --- Executes on button press in loadDataPb.
function loadDataPb_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.idAction
     case 1
        plot_RFP_cavity(hObject, eventdata, handles);
     case 2
        plot_RFP_signal(hObject, eventdata, handles);    
     case 3
        plot_IQA1(hObject, eventdata, handles);
     case 4
        plot_IQA2(hObject, eventdata, handles);
     case 5
        plot_IQA3(hObject, eventdata, handles);
     case 6
        plot_AIM(hObject, eventdata, handles);
     case 7
        plot_GPIB_scope(hObject, eventdata, handles);
     case 8
        plot_COMBS(hObject, eventdata, handles);
     case 9 
        plot_GAP(hObject, eventdata, handles);	
     case 10 
        plot_all_cavities_probe(hObject, eventdata, handles);
     case 11
        plot_ring_KlysFrwd(hObject, eventdata, handles);
     otherwise 
        t = 100*pi*(0:.00001:1); 
        x = [cos(t); 
            2*sin(2*t) 
        ]; 
        % update data 
        handles.time = t; 
        handles.data = x; 
        guidata(handles.output, handles); 
end % switch handles.idAction 

return 

 
% --- Executes on button press in togglebutton1. 
function togglebutton1_Callback(hObject, eventdata, handles) 
% hObject    handle to togglebutton1 (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
 
% Hint: get(hObject,'Value') returns toggle state of togglebutton1 
 
button_state = get(hObject,'Value'); 
if button_state == get(hObject,'Max') 
    handles.fftFlag = 1; 
    set(hObject,'String','Yes'); 
elseif button_state == get(hObject,'Min') 
    handles.fftFlag = 0; 
    set(hObject,'String','No'); 
end %button_state 
 
% update data 
guidata(handles.output, handles); 
 
return
% --- Executes during object creation, after setting all properties.
function zoomPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in zoomPop.
function zoomPop_Callback(hObject, eventdata, handles)
% hObject    handle to zoomPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns zoomPop contents as cell array 
%        contents{get(hObject,'Value')} returns selected item from zoomPop 
 
% get data from callback 
val = get( hObject, 'Value' );  
switch val 
    case 1 
        handles.nTurns = 2; 
    case 2 
        handles.nTurns = 5; 
    case 3 
        handles.nTurns = 10; 
    case 4 
        handles.nTurns = 20; 
    case 5 
        handles.nTurns = 50; 
    case 6 
        handles.nTurns = 100;    
    case 7 
        handles.nTurns = 1000; 
    case 8 
        handles.nTurns = inf; 
end % switch val 
 
% cycle through figures and plot 
% exit if no data 
if isempty( handles.time ), 
    return 
end % if isempty( handles.time ), 
oneTurn = 7.336e-6; %One PEP II turn
tSpan = oneTurn*(handles.nTurns);
tSpan = tSpan * 1000;
for ind = 1:length(handles.figHandles), 
    if ishandle( handles.figHandles(ind) ),
      maxTime = handles.maxTime(ind) * 1000;
      hC = get( handles.figHandles(ind), 'Children' );
	for ind1 = 1:length(hC),
	  %ignore legend axes
	  if (strcmp(get(hC(ind1),'Tag'),'legend')), continue , end 
          xLim = get(hC(ind1),'xLim'); 
          minTime = max(0,maxTime-tSpan);
          set(hC(ind1),'xLim',[minTime maxTime])
	  legend
        end %for ind1

    end % if ishandle( handles.figHandles(ind) ), 
end % for ind = 1:length(handles.figHandles;), 

% update data 
guidata( handles.output, handles ); 
 
return 


% --- Executes during object creation, after setting all properties.
function selectPrinterPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectPrinterPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in selectPrinterPop.
function selectPrinterPop_Callback(hObject, eventdata, handles)
% hObject    handle to selectPrinterPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectPrinterPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectPrinterPop
  

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
 

% --- Executes on button press in exitPb.
function exitPb_Callback(hObject, eventdata, handles)
% hObject    handle to exitPb (see GCBO)
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
% close faultFile figure 
hFaultFile = findobj( handles.output, 'Tag', 'faultFile' ); 
close( hFaultFile ); 
return 



% --- Executes on button press in plotDataPb. 
% function plotDataPb_Callback(hObject, eventdata, handles) 
% hObject    handle to plotDataPb (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
 
% % retrieve figure data 
% figHandles = handles.figHandles; 
% % exit if no data 
% if isempty( handles.time ), 
%     return 
% end % if isempty( handles.time ), 
%  
% % requested action label in handles.labAction 
%  
% % calculate maximum time of plot 
% tMax = min((handles.tSample)*(handles.nTurns), handles.time(length(handles.time))); 
%  
% figInd=length(figHandles); 
% figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd; 
% plot(handles.time, handles.data(1,:)); 
% title(['cos(x) data in ', handles.rfData, '/', handles.station, ... 
%         ' the action selected is ', handles.labAction]); 
% xlabel('sin time'); ylabel('sin amplitude'); 
% v = axis; axis([ 0 tMax v(3:4) ]); 
% figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd; 
% subplot(2,1,1) 
% plot(handles.time, handles.data(2,:)) 
% title(['sin(x) data in ', handles.rfData, '/', handles.station, ... 
%         ' the action selected is ', handles.labAction]); 
% xlabel('sin time'); ylabel('sin amplitude'); 
% v = axis; axis([ 0 tMax v(3:4) ]); 
% subplot(2,1,2) 
% plot(handles.time, 2*(handles.data(2,:) + handles.data(1,:)) ) 
% title(['sin(x) data in ', handles.rfData, '/', handles.station, ... 
%         ' the action selected is ', handles.labAction]); 
% xlabel('sin time'); ylabel('sin amplitude'); 
% v = axis; axis([ 0 tMax v(3:4) ]); 
%  
% % update data 
% handles.figHandles = figHandles; 
% guidata(handles.output, handles); 
 
% return


% --- Executes during object creation, after setting all properties.
function faultNumberPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to faultNumberPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc
%    set(hObject,'BackgroundColor','white');
%else
%    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
%end


% --- Executes on selection change in faultNumberPop.
function faultNumberPop_Callback(hObject, eventdata, handles)
% hObject    handle to faultNumberPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns faultNumberPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from faultNumberPop

handles.faultNumber = num2str(get( hObject, 'Value' ));

% read the date and time stamp for the file from EPICS 
[status,dateTime] = caShell(['caget -t -w 20 ', handles.station,':STN:FAULT:TIME', ...
                             num2str(handles.faultNumber)]);

if status ~=0
   fprintf(1,'Error - unable to read selected fault file date/time stamp\n');
   return
end
dateTimeForm = [dateTime(1:6), ' ', dateTime(7:10), ' ', dateTime(11:18) ];

% Display dateTime on the GUI

h1 = findobj('Tag','faultTime');
set(h1,'String',dateTimeForm); 
% update data
guidata(handles.output, handles);


% --- Executes on button press in printDataPb. 
function printDataPb_Callback(hObject, eventdata, handles) 
% hObject    handle to printDataPb (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 

%Decide on figures to print  
h = findobj('Tag','figuresToPrint');
val = get(h,'Value');                      

switch val 
    case 1 
        figuresToPrint = [handles.figHandles handles.fftFigHandles];
    case 2 
        figuresToPrint = handles.figHandles;
    case 3 
        figuresToPrint = handles.fftFigHandles;
    case 4
        h = findobj('Tag','figureNumber')
        figuresToPrint = str2num( get(h,'string') )
end %switch val

%Decide on printer to print to
h = findobj('Tag','selectPrinterPop');
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
