function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 14-May-2017 09:23:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% set(handles.closeBttn,'BackgroundColor',[0.960, 0, 0.576]);
% set(handles.exitBttn,'BackgroundColor',[0.960, 0, 0.062]);
set(handles.showSub,'BackgroundColor',[0.909, 0.909, 0.909]);
set(handles.showPath,'Enable','off');
set(handles.showPath,'BackgroundColor',[0.909, 0.909, 0.909]); 
set(handles.showSub,'Enable','off');
set(handles.showSub,'BackgroundColor',[0.909, 0.909, 0.909]);
set(handles.vorDiagram,'Enable','off');
set(handles.vorDiagram,'BackgroundColor',[0.909, 0.909, 0.909]);
set(handles.showEnvBttn,'Enable','on');

% textLabel = sprintf('P A U S E');
% set(handles.pauseBttn, 'String', textLabel);
% set(handles.pauseBttn,'Enable','off');
% set(handles.pauseBttn,'BackgroundColor',[0.909, 0.909, 0.909]);

textLabel = sprintf('');
set(handles.showEnvFeedback, 'String', textLabel);
set(handles.subDivFeedback, 'String', textLabel);
set(handles.showPathFeedback, 'String', textLabel);
set(handles.vorFeedback, 'String', textLabel);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in closeBttn.
function closeBttn_Callback(hObject, eventdata, handles)
% hObject    handle to closeBttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all; % closes all the figures that are currently displayed in MatlaB

% --- Executes on button press in exitBttn.
function exitBttn_Callback(hObject, eventdata, handles)
% hObject    handle to exitBttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exit;

function envInput_Callback(hObject, eventdata, handles)
% hObject    handle to envInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of envInput as text
%        str2double(get(hObject,'String')) returns contents of envInput as a double
filename = get(hObject, 'String');
% disp(filename);
textLabel = sprintf('environment file has been changed to: %s', filename);
set(handles.envFeedback, 'String', textLabel);
set(handles.showPath,'Enable','off');
set(handles.showPath,'BackgroundColor',[0.909, 0.909, 0.909]); 
set(handles.showSub,'Enable','off');
set(handles.showSub,'BackgroundColor',[0.909, 0.909, 0.909]);
textLabel = sprintf('');
set(handles.showEnvFeedback, 'String', textLabel);
set(handles.subDivFeedback, 'String', textLabel);
set(handles.showPathFeedback, 'String', textLabel);


% --- Executes during object creation, after setting all properties.
function envInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to envInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end

% --- Executes on button press in showEnvBttn.
function showEnvBttn_Callback(hObject, eventdata, handles)
% hObject    handle to showEnvBttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pause;

pause = false;
textLabel = sprintf('... displaying environment ...');
set(handles.showEnvFeedback, 'String', textLabel);
filename = get(handles.envInput, 'String');
axes(handles.plot);

flag = SSS.test(1, filename, handles);

set(handles.showSub,'Enable','on');
set(handles.showSub,'BackgroundColor',[0.650, 0.368, 0.819]);
set(handles.vorDiagram,'Enable','on');
set(handles.vorDiagram,'BackgroundColor',[0.945, 0.219, 0.360]);
textLabel = sprintf('Environment displayed!');
set(handles.showEnvFeedback, 'String', textLabel);


% --- Executes on button press in showSub.
function showSub_Callback(hObject, eventdata, handles)
% hObject    handle to showSub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textLabel = sprintf('... finding start box...');
set(handles.subDivFeedback, 'String', textLabel);
global pathS;
global pause;

pause = false;
textLabel = sprintf(['P A U S E']);
set(handles.pauseBttn, 'String', textLabel);
set(handles.pauseBttn,'Enable','on');

filename = get(handles.envInput, 'String');
axes(handles.plot);
tic;
pathS = SSS.test(2, filename, handles);
time = toc;
disp(time);
% disp('pathS?')
% disp(pathS.hasPath)
if pathS.hasPath == 1
    set(handles.showPath,'Enable','on');
    set(handles.showPath,'BackgroundColor',[0.184, 0.788, 0.678]);
    textLabel = sprintf(['Time elapsed: ', num2str(time),' seconds']);
    set(handles.subDivFeedback, 'String', textLabel);
    textLabel = sprintf('S H O W   P A T H  :  H W 4   S S S');
    set(handles.showPath, 'String', textLabel);
end


% --- Executes on button press in showPath.
function showPath_Callback(hObject, eventdata, handles)
% hObject    handle to showPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathS;
filename = get(handles.envInput, 'String');
axes(handles.plot);
SSS.test(3, filename, handles, pathS);


% --- Executes on key press with focus on showPath and none of its controls.
function showPath_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to showPath (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in vorDiagram.
function vorDiagram_Callback(hObject, eventdata, handles)
% hObject    handle to vorDiagram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textLabel = sprintf('... finding start box ...');
set(handles.vorFeedback, 'String', textLabel);
global pathS;
global pause;

pause = false;
textLabel = sprintf(['P A U S E']);
set(handles.pauseBttn, 'String', textLabel);
set(handles.pauseBttn,'Enable','on');

filename = get(handles.envInput, 'String');
axes(handles.plot);

tic;
pathS = SSS.test(4, filename, handles);
time = toc;
disp(time);

if pathS.hasPath == 1
    set(handles.showPath,'Enable','on');
    set(handles.showPath,'BackgroundColor',[0.184, 0.788, 0.678]);
    textLabel = sprintf(['Time elapsed: ', num2str(time),' seconds']);
    set(handles.vorFeedback, 'String', textLabel);
    textLabel = sprintf('S H O W   P A T H  :  V O R O N O I');
    set(handles.showPath, 'String', textLabel);
end

% --- Executes on button press in pauseBttn.
function pauseBttn_Callback(hObject, eventdata, handles)
% hObject    handle to pauseBttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pause;
pause = ~pause;
if pause == true
    textLabel = sprintf('U N P A U S E');
    set(handles.pauseBttn, 'String', textLabel);
    set(handles.pauseBttn, 'ForegroundColor', [0.278, 0.901, 0.705]);
    set(handles.pauseBttn, 'BackgroundColor', [1,1,1]);
    uiwait
elseif pause == false
    textLabel = sprintf('P A U S E');
    set(handles.pauseBttn, 'String', textLabel);
    set(handles.pauseBttn, 'ForegroundColor', [1, 0.631, 0.160]);
    set(handles.pauseBttn, 'BackgroundColor', [1,1,1]);
    uiresume
end
