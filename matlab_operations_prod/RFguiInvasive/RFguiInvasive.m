function varargout = RFguiInvasive(varargin)
% RFGUIINVASIVE M-file for RFguiInvasive.fig
%      RFGUIINVASIVE, by itself, creates a new RFGUIINVASIVE or raises the existing
%      singleton*.
%
%      H = RFGUIINVASIVE returns the handle to a new RFGUIINVASIVE or the handle to
%      the existing singleton*. 
% 
%      RFGUIINVASIVE('CALLBACK',hObject,eventData,handles,...) calls the local 
%      function named CALLBACK in RFGUIINVASIVE.M with the given input arguments. 
% 
%      RFGUIINVASIVE('Property','Value',...) creates a new RFGUIINVASIVE or raises the 
%      existing singleton*.  Starting from the left, property value pairs are 
%      applied to the GUI before RFguiInvasive_OpeningFunction gets called.  An 
%      unrecognized property name or invalid value makes property application 
%      stop.  All inputs are passed to RFguiInvasive_OpeningFcn via varargin. 
% 
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one 
%      instance to run (singleton)". 
% 
% See also: GUIDE, GUIDATA, GUIHANDLES 
 
% Edit the above text to modify the response to help RFguiInvasive 
 
% Last Modified by GUIDE v2.5 22-Jul-2004 14:51:44
 
% Begin initialization code - DO NOT EDIT 
gui_Singleton = 1; 
gui_State = struct('gui_Name',       mfilename, ... 
                   'gui_Singleton',  gui_Singleton, ... 
                   'gui_OpeningFcn', @RFguiInvasive_OpeningFcn, ... 
                   'gui_OutputFcn',  @RFguiInvasive_OutputFcn, ... 
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
 
 
% --- Executes just before RFguiInvasive is made visible. 
function RFguiInvasive_OpeningFcn(hObject, eventdata, handles, varargin) 
% This function has no output args, see OutputFcn. 
% hObject    handle to figure 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA) 
% varargin   command line arguments to RFguiInvasive (see VARARGIN) 
 
set(hObject,'Color',[0.839,0.878,0.878]) 

hostMachine = getenv('HOST');
handleSelSta = findobj('Tag', 'selectStation');
handleSelAct = findobj('Tag', 'selectAction' );
handleSelPri = findobj('Tag', 'selectPrinter');

%Set defaults.
selStaList = {'SRF1'};
selActList = {'Tune Cavities'; 'Configure Direct'; 'Make Polynomials' ; 'Measure Group Delay'};      
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
      selStaList = { 'HR41'; 'HR46'; 'HR81'; 'HR83'; 'HR85'; ...
	             'HR21'; 'HR22'; 'HR23'; 'HR24'; 'HR25'; 'HR26'; ...
	             'LR42'; 'LR43'; 'LR44'; 'LR45';};
      selActList = {'Tune Cavities'; 'Configure Direct'; 'Make Polynomials';  'Measure Group Delay'; ...
	            'Configure Combs'; 'Comb Filter Freq.'};
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

rfFrequency      = prm.accel.wrf / (2 * pi);
rfFrequencyMHz   = rfFrequency/1e6;
harmonicNumber   = prm.accel.h;
revolutionFreq   = rfFrequency/harmonicNumber;
ringEnergy       = prm.accel.Ebeam;
compactionFactor = prm.accel.alpha;
samplesPerRev    = prm.rf.hcomb;
rfData           = prm.files.rf_data;
tableDir         = prm.files.rf_tbl;
dspFile          = prm.files.dsp_rip;
allStations      = prm.rf.st;

handles = struct( 'output', hObject, ...  % pointer to figure window 
    'rfData', rfData, ...                 % directory that contains the data files 
    'tableDir',tableDir, ...              % directory that contains the table files
    'combIir',prm.files.comb_iir,...      % directory that contains comb filter files
    'dspFile',dspFile, ...                % file used for ripple calculations
    'station',stationName, ...            % default rf station under investigation 
    'cavity' , 1, ...                     % rf station's cavity     
    'idAction', 1, ...                    % id of plotting routine 
    'labAction', 'RFP Cavity', ...        % label of plotting command  
    'signalMuxSetting', [], ...           % used by save/restore_RFP_mux 
    'cavityMuxSetting', [], ...           % used by save/restore_RFP_mux 
    'rfModule', [], ...                   % rf Module 
    'samplesPerRev',prm.rf.hcomb,...      % number of clock samples pre revolution
    'samplingFrequency',(rfFrequencyMHz*samplesPerRev)/harmonicNumber,...% Module sampling frequency in MHz 
    'Tsample', 1/((samplesPerRev*rfFrequency)/harmonicNumber), ...               % sample period for one revolution 
    'rfFrequency', rfFrequency,...        % rf frequency in Hz
    'rfFrequencyMHz', rfFrequencyMHz,...  % rf frequency in MHz
    'revolutionFreq', revolutionFreq,...  % revolution frequency in Hz
    'harmonicNumber',prm.accel.h,...      % harmonic number
    'nTurns', inf, ...                    % number of turns to plot
    'figHandles', [], ...                 % number of figures that are plotted
    'ringEnergy',ringEnergy,...           % energy of the ring in eV
    'synchRadLoss',prm.rf.Uo,...          % machine total synchrotron radiation loss [V] 
    'beamCurrent',prm.accel.Io,...        % DC beam current, [mA]
    'lossFactorHOM',prm.rf.C,...          %losses from HOM in cavity
    'compactionFactor',compactionFactor,...%compaction factor alpha
    'machine', machine, ...               % machine name
    'allStations',allStations);           % list of all RF stations  

%display(handles)

% Update handles structure 
guidata(hObject, handles); 
 
% UIWAIT makes RFguiInvasive wait for user response (see UIRESUME) 
% uiwait(handles.RFguiInvasive); 
 
%Don't show ring selector unless Change Comb File is picked.
hanSelCav = findobj('Tag','selectMachine');
set(hanSelCav, 'Visible', 'off')
hanText4 = findobj('Tag','text6');
set(hanText4, 'Visible', 'off')
 

% --- Outputs from this function are returned to the command line. 
function varargout = RFguiInvasive_OutputFcn(hObject, eventdata, handles) 
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

machine = stationtomachine( handles.station ); %change machine name according 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         to the selected station
prm = sys_prm(machine);

handles.machine          = machine;
handles.rfFrequency      = prm.accel.wrf / (2 * pi);
handles.rfFrequencyMHz   = handles.rfFrequency/1e6;
handles.harmonicNumber   = prm.accel.h;
handles.revolutionFreq   = handles.rfFrequency/handles.harmonicNumber;
handles.ringEnergy       = prm.accel.Ebeam;
handles.synchRadLoss     = prm.rf.Uo;
handles.beamCurrent      = prm.accel.Io;
handles.lossFactorHOM    = prm.rf.C;
handles.compactionFactor = prm.accel.alpha;
handles.samplesPerRev    = prm.rf.hcomb;
handles.samplingFrequency= handles.rfFrequencyMHz*prm.rf.hcomb/prm.accel.h;
handles.Tsample          = 1/(prm.rf.hcomb*handles.rfFrequency/prm.accel.h);
handles.rfData           = prm.files.rf_data;
handles.tableDir         = prm.files.rf_tbl;
handles.combIir          = prm.files.comb_iir;
handles.dspFile          = prm.files.dsp_rip;
handles.allStations      = prm.rf.st;

guidata(handles.output,handles) %this updates all systems depending on machine
%display(handles)

% --- Executes during object creation, after setting all properties.
function selectAction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu1.
function selectAction_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
 
% Get the information about selected station in the popup window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectedStation = findobj('Tag','selectStation');
stationNumber = get(selectedStation,'Value');
switch stationNumber 
   
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

% get data from callback 
val = get( hObject, 'Value' ); 
handles.idAction = val; 
str = get( hObject, 'String' );
 
% Show the machines selection window only for "Change Comb File", hide "Station Selector"
% at the same time.
%******************************
hanText6 = findobj('Tag','text6');
hanSelRing = findobj('Tag','selectMachine');
hanText4 = findobj('Tag','text4');
hanSelSta = findobj('Tag','selectStation');
if (val == 6)
   set(hanSelRing, 'Visible', 'on')
   set(hanText6, 'Visible', 'on')
   set(hanSelSta, 'Visible', 'off')
   set(hanText4, 'Visible', 'off')
else
   set(hanSelRing, 'Visible', 'off')
   set(hanText6, 'Visible', 'off')
   set(hanSelSta, 'Visible', 'on')
   set(hanText4, 'Visible', 'on')
   
   %restoring the setting according to the selected station in GUI window
        machine = stationtomachine( handles.station ); %change machine name according 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            to the selected station
        prm = sys_prm(machine);
        %reset handles to HER
        handles.machine          = machine;
        handles.rfFrequency      = prm.accel.wrf / (2 * pi);
        handles.rfFrequencyMHz   = handles.rfFrequency/1e6;
        handles.harmonicNumber   = prm.accel.h;
        handles.revolutionFreq   = handles.rfFrequency/handles.harmonicNumber;
        handles.ringEnergy       = prm.accel.Ebeam;
        handles.synchRadLoss     = prm.rf.Uo;
        handles.beamCurrent      = prm.accel.Io;
        handles.lossFactorHOM    = prm.rf.C;
        handles.compactionFactor = prm.accel.alpha;
        handles.samplesPerRev    = prm.rf.hcomb;
        handles.samplingFrequency= handles.rfFrequencyMHz*prm.rf.hcomb/prm.accel.h;
        handles.Tsample          = 1/(prm.rf.hcomb*handles.rfFrequency/prm.accel.h);
        handles.rfData           = prm.files.rf_data;
        handles.tableDir         = prm.files.rf_tbl;
        handles.combIir          = prm.files.comb_iir;
        handles.dspFile          = prm.files.dsp_rip;
        handles.allStations      = prm.rf.st;

        guidata(handles.output,handles) %this restore system to HER handles
   
end % if/else val.
%******************************

switch val 
    case 1 
        handles.labAction = 'Tune Cavities';
    case 2 
        handles.labAction = 'Configure Direct'; 
    case 3 
        handles.labAction = 'Make Polynomials'; 
    case 4 
        handles.labAction = 'Group Delay'; 
    case 5
        handles.labAction = 'Configure Combs'; 
    case 6
        handles.labAction = 'Comb Filter Freq.';
        %reset machine according to the string in the machine window
        selectedMachine = findobj('Tag','selectMachine');
        machineNumber = get(selectedMachine,'Value');
        switch machineNumber
            case 1 
                handles.machine = 'pepii-HER'; 
            case 2 
                handles.machine = 'pepii-LER'; 
        end
        
        %reset handles according to selected machine 
        prm = sys_prm(handles.machine);
        handles.station          = prm.rf.st(1).name;
        handles.rfFrequency      = prm.accel.wrf / (2 * pi);
        handles.rfFrequencyMHz   = handles.rfFrequency/1e6;
        handles.harmonicNumber   = prm.accel.h;
        handles.revolutionFreq   = handles.rfFrequency/handles.harmonicNumber;
        handles.ringEnergy       = prm.accel.Ebeam;
        handles.synchRadLoss     = prm.rf.Uo;
        handles.beamCurrent      = prm.accel.Io;
        handles.lossFactorHOM    = prm.rf.C;
        handles.compactionFactor = prm.accel.alpha;
        handles.samplesPerRev    = prm.rf.hcomb;
        handles.samplingFrequency= handles.rfFrequencyMHz*prm.rf.hcomb/prm.accel.h;
        handles.Tsample          = 1/(prm.rf.hcomb*handles.rfFrequency/prm.accel.h);
        handles.rfData           = prm.files.rf_data;
        handles.tableDir         = prm.files.rf_tbl;
        handles.combIir          = prm.files.comb_iir;
        handles.dspFile          = prm.files.dsp_rip;
        handles.allStations      = prm.rf.st;

        guidata(handles.output,handles) %this restore system to HER
        
end % switch val 

% update data 
guidata(handles.output, handles); 
%display(handles)

% --- Executes on button press in plotData.
function plotData_Callback(hObject, eventdata, handles)
% hObject    handle to plotData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.idAction 
     case 1 
       tune_cavities(hObject, eventdata, handles); 
     case 2 
       configure_direct(hObject, eventdata, handles);     
     case 3 
       make_polynomials(hObject, eventdata, handles); 
     case 4  
       measure_group_delay(hObject, eventdata, handles);
     case 5
       configure_comb(hObject, eventdata, handles); 
     case 6
       comb_filter_freq(hObject, eventdata, handles);
end % switch handles.idAction 

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
        figuresToPrint = [handles.figHandles handles.fftFigHandles] 
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
end %  if station == SRF1  
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
figHandles = handles.figHandles 
for ind = 1:length(figHandles), 
    if ishandle( figHandles(ind) ), 
        close(figHandles(ind)); 
    end % if ishandle( figHandles(ind) ), 
end % for ind = 1:length(figHandles), 
 
% close RFguiInvasive figure 
hRFguiInv = findobj( handles.output, 'Tag', 'RFguiInvasive' ); 
close( hRFguiInv ); 
return 


% --- Executes during object creation, after setting all properties.
function selectMachine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectMachine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in selectMachine.
function selectMachine_Callback(hObject, eventdata, handles)
% hObject    handle to selectMachine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectMachine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectMachine
val_machine = get( hObject, 'Value' ); 
switch val_machine 
    case 1 
        handles.machine = 'pepii-HER'; 
    case 2 
        handles.machine = 'pepii-LER'; 
end

%update handles data
guidata(handles.output,handles) %this updates the machine choice in RFgui

prm=sys_prm(handles.machine);

handles.station          = prm.rf.st(1).name;
handles.rfFrequency      = prm.accel.wrf / (2 * pi);
handles.rfFrequencyMHz   = handles.rfFrequency/1e6;
handles.harmonicNumber   = prm.accel.h;
handles.revolutionFreq   = handles.rfFrequency/handles.harmonicNumber;
handles.ringEnergy       = prm.accel.Ebeam;
handles.synchRadLoss     = prm.rf.Uo;
handles.beamCurrent      = prm.accel.Io;
handles.lossFactorHOM    = prm.rf.C;
handles.compactionFactor = prm.accel.alpha;
handles.samplesPerRev    = prm.rf.hcomb;
handles.samplingFrequency= handles.rfFrequencyMHz*prm.rf.hcomb/prm.accel.h;
handles.Tsample          = 1/(prm.rf.hcomb*handles.rfFrequency/prm.accel.h);
handles.rfData           = prm.files.rf_data;
handles.tableDir         = prm.files.rf_tbl;
handles.combIir          = prm.files.comb_iir;
handles.dspFile          = prm.files.dsp_rip;
handles.allStations      = prm.rf.st;

guidata(handles.output,handles) %this updates all systems depending on machine

%display(handles)
