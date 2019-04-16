function varargout = ASLmatBuilder01(varargin)
% ASLMATBUILDER01 M-file for ASLmatBuilder01.fig
%      ASLMATBUILDER01, by itself, creates a new ASLMATBUILDER01 or raises the existing
%      singleton*.
%
%      H = ASLMATBUILDER01 returns the handle to a new ASLMATBUILDER01 or the handle to
%      the existing singleton*.
%
%      ASLMATBUILDER01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASLMATBUILDER01.M with the given input arguments.
%
%      ASLMATBUILDER01('Property','Value',...) creates a new ASLMATBUILDER01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASLmatBuilder01_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASLmatBuilder01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASLmatBuilder01

% Last Modified by GUIDE v2.5 20-Aug-2010 13:32:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASLmatBuilder01_OpeningFcn, ...
                   'gui_OutputFcn',  @ASLmatBuilder01_OutputFcn, ...
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

global onsets durations N 


% --- Executes just before ASLmatBuilder01 is made visible.
function ASLmatBuilder01_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASLmatBuilder01 (see VARARGIN)

% Choose default command line output for ASLmatBuilder01
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ASLmatBuilder01 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global onsets durations N 
N=0;
onsets={};
durations={};

% --- Outputs from this function are returned to the command line.
function varargout = ASLmatBuilder01_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global onsets durations N isUnsubtracted X
clear onsets durations N isUnsubtracted X


function onsets_edit_Callback(hObject, eventdata, handles)
% hObject    handle to onsets_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of onsets_edit as text
%        str2double(get(hObject,'String')) returns contents of onsets_edit as a double



% --- Executes during object creation, after setting all properties.
function onsets_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to onsets_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function durations_edit_Callback(hObject, eventdata, handles)
% hObject    handle to durations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of durations_edit as text
%        str2double(get(hObject,'String')) returns contents of durations_edit as a double


% --- Executes during object creation, after setting all properties.
function durations_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addToMatrix_button.
function addToMatrix_button_Callback(hObject, eventdata, handles)
% hObject    handle to addToMatrix_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global onsets durations N isUnsubtracted X X1 X2

N=N+1;


exp_duration = str2num(get(findobj('Tag','expDuration_edit'), 'String'));
TR = str2num(get(findobj('Tag','expTR_edit'), 'String'));

tmpstring = char(get(findobj('Tag','predefined_txt'), 'String'));

if isempty(tmpstring) 
    onsets{N} = eval(char(get(findobj('Tag','onsets_edit'), 'String')));
    durations{N} = eval(char(get(findobj('Tag','durations_edit'), 'String')));

    doASLmod = get(findobj('Tag','isUnsubtracted_cb'), 'Value');
    X = buildDesMat(TR, exp_duration, onsets, durations, doASLmod);
    set(findobj('Tag','onsets_edit'), 'String',[])
    set(findobj('Tag','durations_edit'), 'String',[])
else
    customReg = eval(tmpstring);
    customReg = reshape(customReg, max(size(customReg)), min(size(customReg)));
    X = [X customReg];
    set(findobj('Tag','predefined_txt'), 'String', []);
    
    % make the onset fields invisible when you start adding custom
    % regressors
    set(findobj('Tag','onsets_edit'), 'Visible','off')
    set(findobj('Tag','durations_edit'), 'Visible','off')
end
imagesc(X); colormap gray;

% --- Executes on button press in isUnsubtracted_cb.
function isUnsubtracted_cb_Callback(hObject, eventdata, handles)
% hObject    handle to isUnsubtracted_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isUnsubtracted_cb
global onsets durations N isUnsubtracted X

doASLmod = get(findobj('Tag','isUnsubtracted_cb'), 'Value');
TR = str2num(get(findobj('Tag','expTR_edit'), 'String'));
exp_duration = str2num(get(findobj('Tag','expDuration_edit'), 'String'));

if ~isempty(X)
    X = buildDesMat(TR, exp_duration, onsets, durations, doASLmod);
    imagesc(X); colormap gray;
end

function removeRegressor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to removeRegressor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of removeRegressor_edit as text
%        str2double(get(hObject,'String')) returns contents of removeRegressor_edit as a double
global onsets durations N isUnsubtracted X

r = str2num(get(gco,'String'));

% 
% cnums=[1:r-1 r+1:N];
% 
% o2 = cell(1,N-1);
% d2 = cell(1,N-1);
% 
% for c=1:N-1
%     o2{c} = onsets{cnums(c)};
%     d2{c} = durations{cnums(c)};
% end
% 
% onsets=o2;
% durations=d2;
% N=N-1;
% 
% doASLmod = get(findobj('Tag','isUnsubtracted_cb'), 'Value');
% 
% exp_duration = str2num(get(findobj('Tag','expDuration_edit'), 'String'));
% TR = str2num(get(findobj('Tag','expTR_edit'), 'String'));
% X = buildDesMat(TR, exp_duration, onsets, durations, doASLmod);
% 

X = X( :,  [1:r-1  r+1:end]);
set(gco,'String',[]);
imagesc(X); colormap gray;


% --- Executes during object creation, after setting all properties.
function removeRegressor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to removeRegressor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fileName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileName_edit as text
%        str2double(get(hObject,'String')) returns contents of fileName_edit as a double


% --- Executes during object creation, after setting all properties.
function fileName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X
fname = get(findobj('Tag','fileName_edit'), 'String');
if isempty(fname)
    [fname, p, filt]=uiputfile('','Save Design Matrix as ASCII');
end
if ~isempty(fname)
    save(fname, 'X', '-ascii')
end

function tr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to tr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tr_edit as text
%        str2double(get(hObject,'String')) returns contents of tr_edit as a double


% --- Executes during object creation, after setting all properties.
function tr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expDuration_edit_Callback(hObject, eventdata, handles)
% hObject    handle to expDuration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expDuration_edit as text
%        str2double(get(hObject,'String')) returns contents of expDuration_edit as a double


% --- Executes during object creation, after setting all properties.
function expDuration_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expDuration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global onsets durations N isUnsubtracted X

onsets={};
durations={};
N=0;
X=[];
cla
    set(findobj('Tag','onsets_edit'), 'Visible','on')
    set(findobj('Tag','durations_edit'), 'Visible','on')


function expTR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to expTR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expTR_edit as text
%        str2double(get(hObject,'String')) returns contents of expTR_edit as a double


% --- Executes during object creation, after setting all properties.
function expTR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expTR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function predefined_txt_Callback(hObject, eventdata, handles)
% hObject    handle to predefined_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of predefined_txt as text
%        str2double(get(hObject,'String')) returns contents of predefined_txt as a double


% --- Executes during object creation, after setting all properties.
function predefined_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to predefined_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


