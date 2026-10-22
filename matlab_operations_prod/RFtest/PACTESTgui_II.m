function varargout = PACTESTgui_II(varargin)
% PACTESTGUI_II M-file for PACTESTgui_II.fig
%      PACTESTGUI_II, by itself, creates a new PACTESTgui_II or raises the existing
%      singleton*.
%
%      H = PACTESTGUI_II returns the handle to a new PACTESTGUI_II or the handle to
%      the existing singleton*.
%
%      PACTESTGUI_II('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PACTESTGUI_II.M with the given input arguments.
%
%      PACTESTGUI_II('Property','Value',...) creates a new PACTESTGUI_II or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PACTESTgui_II_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PACTESTgui_II_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PACTESTgui_II

% Last Modified by GUIDE v2.5 09-Dec-2008 09:34:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PACTESTgui_II_OpeningFcn, ...
    'gui_OutputFcn',  @PACTESTgui_II_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PACTESTgui_II is made visible.
function PACTESTgui_II_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

%set the ClockSource to "external"
lcaPut('LIN-RF:FreqClockSetpt',0)
drawnow

%read and insert current data into the "static text" windows
set(handles.text1,'String',lcaGet('LIN-RF:FreqFWVersion'))
%reading the status of the CLOCK, TRIGGER and SSSB_Over_Temperature
a = lcaGet('LIN-RF:FreqClockStatus');
b = lcaGet('LIN-RF:FreqTrigStatus');
c = lcaGet('LIN-RF:SSSBOverTemp');
%display status in the text windows, change background color accordingly
if strcmp(a{1},'Present') %Clock Status
    set(handles.text2,'String',lcaGet('LIN-RF:FreqClockStatus'))
else
    set(handles.text2,'String',lcaGet('LIN-RF:FreqClockStatus'),...
        'BackgroundColor','red')
end

if strcmp(b{1},'Present') %External Trigger Status
    set(handles.text3,'String',lcaGet('LIN-RF:FreqTrigStatus'))
else
    set(handles.text3,'String',lcaGet('LIN-RF:FreqTrigStatus'),...
        'BackgroundColor','red')
end

if strcmp(c{1},'Normal') %SSSB Over Temperature
    set(handles.text4,'String',lcaGet('LIN-RF:SSSBOverTemp'))
else
    set(handles.text4,'String',lcaGet('LIN-RF:SSSBOverTemp'),...
        'BackgroundColor','red')
end

set(handles.text5,'String',lcaGet('B140-IOCLINPAC:CpuTemp'))
set(handles.text6,'String',lcaGet('LIN-RF:FreqIQTemp'))
set(handles.text7,'String',lcaGet('LIN-RF:SSSBTemp'))
set(handles.text8,'String',lcaGet('LIN-RF:SSSBFwdPwr'))
set(handles.text9,'String',lcaGet('LIN-RF:SSSBReflPwr'))
set(handles.text10,'String',lcaGet('LIN-RF:SSSBPwr'))
set(handles.text11,'String',lcaGet('LIN-RF:FreqPlus5Volt'))
set(handles.text12,'String',lcaGet('LIN-RF:FreqMinus12Volt'))

set(handles.slider1,'Value',lcaGet('LIN-RF:FreqIOffsetSetpt'))
set(handles.text44,'String',get(handles.slider1,'Value'))

set(handles.slider2,'Value',lcaGet('LIN-RF:FreqIGainSetpt'))
set(handles.text45,'String',get(handles.slider2,'Value'))

set(handles.slider3,'Value',lcaGet('LIN-RF:FreqIICoeffSetpt'))
set(handles.text46,'String',get(handles.slider3,'Value'))

set(handles.slider4,'Value',lcaGet('LIN-RF:FreqIQCoeffSetpt'))
set(handles.text47,'String',get(handles.slider4,'Value'))

set(handles.slider5,'Value',lcaGet('LIN-RF:FreqQOffsetSetpt'))
set(handles.text48,'String',get(handles.slider5,'Value'))

set(handles.slider6,'Value',lcaGet('LIN-RF:FreqQGainSetpt'))
set(handles.text49,'String',get(handles.slider6,'Value'))

set(handles.slider7,'Value',lcaGet('LIN-RF:FreqQICoeffSetpt'))
set(handles.text50,'String',get(handles.slider7,'Value'))

set(handles.slider8,'Value',lcaGet('LIN-RF:FreqQQCoeffSetpt'))
set(handles.text51,'String',get(handles.slider8,'Value'))

set(handles.edit10,'String',lcaGet('LIN-RF:FreqIQTrigDelaySetpt'))
set(handles.edit11,'String',lcaGet('LIN-RF:SSSBTrigDelaySetpt'))
set(handles.edit12,'String',lcaGet('LIN-RF:SSSBTrigWidthSetpt'))
set(handles.edit13,'String',lcaGet('LIN-RF:FreqOutTrigDelaySetpt'))
set(handles.edit14,'String',lcaGet('LIN-RF:FreqOutTrigWidthSetpt'))
set(handles.edit15,'String',lcaGet('LIN-RF:FreqIntTrigSetpt'))




%read the stored data in I and Q memory and display on the graph
I_mem = lcaGet('LIN-RF:FreqISetpt');
Q_mem = lcaGet('LIN-RF:FreqQSetpt');
% plot(1:2048,I_mem,1:2048,Q_mem,'r')
% grid on
Ph_shift=asin(Q_mem(1)/(2^15-1))*180/pi;
set(handles.edit16,'String',num2str(round(Ph_shift)))
p = phase(I_mem + i*Q_mem)*180/pi;
X = p(end) - p(1);
n= 0:2047;
N=max(n);
plot(0:X/(360*N):X/360,I_mem,0:X/(360*N):X/360,Q_mem,'r')
grid on
% Choose default command line output for PACTESTgui_II
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PACTESTgui_II wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PACTESTgui_II_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


% makes the I and Q array and display them on the graph
function edit1_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

X= 360*str2double(get(hObject,'String'));
Ph_shift = str2double(get(handles.edit16,'String'));
n= 0:2047;
N=max(n);
I_MEM = (2^15-1)*cos((X/360)*(n/2048)*2*pi+Ph_shift*pi/180);
Q_MEM = (2^15-1)*sin((X/360)*(n/2048)*2*pi+Ph_shift*pi/180);
lcaPut('LIN-RF:FreqISetpt',I_MEM)
lcaPut('LIN-RF:FreqQSetpt',Q_MEM)
drawnow
I_MEM = lcaGet('LIN-RF:FreqISetpt');
Q_MEM = lcaGet('LIN-RF:FreqQSetpt');
plot(0:X/(360*N):X/360,I_MEM,0:X/(360*N):X/360,Q_MEM,'r')
grid on

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit10_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqIQTrigDelaySetpt',str2double(get(hObject,'String')))
drawnow

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit11_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:SSSBTrigDelaySetpt',str2double(get(hObject,'String')))
drawnow

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit12_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:SSSBTrigWidthSetpt',str2double(get(hObject,'String')))
drawnow

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqOutTrigDelaySetpt',str2double(get(hObject,'String')))
drawnow

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqOutTrigWidthSetpt',str2double(get(hObject,'String')))
drawnow

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqIntTrigSetpt',str2double(get(hObject,'String')))
drawnow

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit16_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqClockStatusReset',1)
drawnow

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqTrigStatusReset',1)
drawnow

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
lcaPut('LIN-RF:SSSBOverTempReset',1)
drawnow

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)

Clock_source = get(hObject,'Value');
switch Clock_source
    case 0
        lcaPut('LIN-RF:FreqClockSetpt',0)
        set(hObject,'String','External Clock','ForegroundColor','black')
    case 1
        lcaPut('LIN-RF:FreqClockSetpt',1)
        set(hObject,'String','Internal Clock','ForegroundColor','r')
end
drawnow

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)

Trig_mode = get(hObject,'Value');
switch Trig_mode
    case 1
        lcaPut('LIN-RF:FreqTrigModeSetpt',0)
        set(hObject,'ForegroundColor','black')
    case 2
        lcaPut('LIN-RF:FreqTrigModeSetpt',1)
        set(hObject,'ForegroundColor','red')
    case 3
        lcaPut('LIN-RF:FreqTrigModeSetpt',2)
        set(hObject,'ForegroundColor','blue')
end
drawnow

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
lcaPut('LIN-RF:FreqTrigModeSetpt',0) %set the mode to "external"
drawnow

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7 - START/STOP
function pushbutton7_Callback(hObject, eventdata, handles)
Action = get(hObject,'String');

switch Action
    case 'STOP '
        set(hObject,'String','START');
        set(handles.text42,'Visible','Off')
    case 'START'
        set(hObject,'String','STOP ');
        set(handles.text42,'Visible','On')
        Action = get(hObject,'String');

        while Action == 'STOP '
            Action = get(hObject,'String');
            %reading the status of the CLOCK, TRIGGER and SSSB_Over_Temperature
            a = lcaGet('LIN-RF:FreqClockStatus');
            b = lcaGet('LIN-RF:FreqTrigStatus');
            c = lcaGet('LIN-RF:SSSBOverTemp');
            %display status in the text windows, change background color accordingly
            if strcmp(a{1},'Present') %Clock Status
                set(handles.text2,'String',lcaGet('LIN-RF:FreqClockStatus'),...
                    'BackgroundColor','white')
            else
                set(handles.text2,'String',lcaGet('LIN-RF:FreqClockStatus'),...
                    'BackgroundColor','red')
            end

            if strcmp(b{1},'Present') %External Trigger Status
                set(handles.text3,'String',lcaGet('LIN-RF:FreqTrigStatus'),...
                    'BackgroundColor','white')
            else
                set(handles.text3,'String',lcaGet('LIN-RF:FreqTrigStatus'),...
                    'BackgroundColor','red')
            end

            if strcmp(c{1},'Normal') %SSSB Over Temperature
                set(handles.text4,'String',lcaGet('LIN-RF:SSSBOverTemp'),...
                    'BackgroundColor','white')
            else
                set(handles.text4,'String',lcaGet('LIN-RF:SSSBOverTemp'),...
                    'BackgroundColor','red')
            end
            %update 8 "readback only" text windows
            set(handles.text5,'String',lcaGet('B140-IOCLINPAC:CpuTemp'))
            set(handles.text6,'String',lcaGet('LIN-RF:FreqIQTemp'))
            set(handles.text7,'String',lcaGet('LIN-RF:SSSBTemp'))
            set(handles.text8,'String',lcaGet('LIN-RF:SSSBFwdPwr'))
            set(handles.text9,'String',lcaGet('LIN-RF:SSSBReflPwr'))
            set(handles.text10,'String',lcaGet('LIN-RF:SSSBPwr'))
            set(handles.text11,'String',lcaGet('LIN-RF:FreqPlus5Volt'))
            set(handles.text12,'String',lcaGet('LIN-RF:FreqMinus12Volt'))

            pause(1) % wait 1 second before the next scan
        end % while  Action == 'STOP '
end         % switch Action

% --- Executes on button press in pushbutton8 - EXIT
function pushbutton8_Callback(hObject, eventdata, handles)

close all


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text44,'String',round(get(handles.slider1,'Value')))
lcaPut('LIN-RF:FreqIOffsetSetpt',round(get(hObject,'Value')))
drawnow

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
set(handles.text45,'String',round(get(handles.slider2,'Value')))
lcaPut('LIN-RF:FreqIGainSetpt',round(get(hObject,'Value')))
drawnow

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
set(handles.text46,'String',round(get(handles.slider3,'Value')))
lcaPut('LIN-RF:FreqIICoeffSetpt',round(get(hObject,'Value')))
drawnow
% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
set(handles.text47,'String',round(get(handles.slider4,'Value')))
lcaPut('LIN-RF:FreqIQCoeffSetpt',round(get(hObject,'Value')))
drawnow
% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
set(handles.text48,'String',round(get(handles.slider5,'Value')))
lcaPut('LIN-RF:FreqQOffsetSetpt',round(get(hObject,'Value')))
drawnow

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
set(handles.text49,'String',round(get(handles.slider6,'Value')))
lcaPut('LIN-RF:FreqQGainSetpt',round(get(hObject,'Value')))
drawnow

function slider6_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
set(handles.text50,'String',round(get(handles.slider7,'Value')))
lcaPut('LIN-RF:FreqQICoeffSetpt',round(get(hObject,'Value')))
drawnow

function slider7_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
set(handles.text51,'String',round(get(handles.slider8,'Value')))
lcaPut('LIN-RF:FreqQQCoeffSetpt',round(get(hObject,'Value')))
drawnow

function slider8_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
