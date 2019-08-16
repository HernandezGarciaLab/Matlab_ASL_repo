function varargout = fasl02_win(varargin)
% fasl02_win M-file for fasl02_win.fig
%      fasl02_win, by itself, creates a new fasl02_win or raises the existing
%      singleton*.
%
%      H = fasl02_win returns the handle to a new fasl02_win or the handle to
%      the existing singleton*.
%
%      fasl02_win('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in fasl02_win.M with the given input arguments.
%
%      fasl02_win('Property','Value',...) creates a new fasl02_win or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fasl02_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fasl02_win_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fasl02_win

% Last Modified by GUIDE v2.5 13-Aug-2019 14:03:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fasl02_win_OpeningFcn, ...
                   'gui_OutputFcn',  @fasl02_win_OutputFcn, ...
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

global args


% --- Executes just before fasl02_win is made visible.
function fasl02_win_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fasl02_win (see VARARGIN)

% Choose default command line output for fasl02_win
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fasl02_win wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fasl02_win_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in go_button.
function go_button_Callback(hObject, eventdata, handles)
% hObject    handle to go_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global args
str = get(findobj('Tag','inputData_edit'),'String');

if ~isempty(str)
    % Gather data from the interface into ARGS structure
    args.inFile = str;  

    args.doDespike = get(findobj('Tag','despiker_cb'),'Value');
    args.doRecon =   get(findobj('Tag','SpiralRecon_cb'),'Value');
    args.doZgrappa =   get(findobj('Tag','doZgrappa_cb'),'Value');

    args.doSliceTime = get(findobj('Tag','sliceTiming_cb'),'Value');
    args.doRealign = get(findobj('Tag','realignment_cb'),'Value');
    args.smoothSize = get(findobj('Tag','smoothing_cb'),'Value') *3 ;

    args.anat_img = get(findobj('Tag','anat_img_edit'),'String');  
    args.template_img = get(findobj('Tag','template_img_edit'),'String');
    args.spat_norm_series = get(findobj('Tag','spat_norm_series_cb'),'Value');

    
    tmp=get(findobj('Tag','subtraction_cb'),'Value');
    if tmp
        args.isSubtracted=1;
        set(findobj('Tag','isSubtracted_cb'),'Value',1);
        args.subType = get(findobj('Tag','subtraction_lb'),'Value');
    else
        args.subType = 0;
    end
    
    args.subOrder = 1;
    
    args.doQuant = get(findobj('Tag','quant_cbf_cb'),'Value');
    args.Diff_img = get(findobj('Tag','Diff_img_edit'),'String');  
    args.SpinDens_img = get(findobj('Tag','SpinDens_img_edit'), 'String');
 
   
    args.T1 = str2num(get(findobj('Tag','flip_edit'),'String'));
    args.T1 = str2num(get(findobj('Tag','t1_edit'),'String'));
    args.TR = str2num(get(findobj('Tag','tr_edit'),'String'));
    args.Ttag = str2num(get(findobj('Tag','Ttag_edit'),'String'));
    args.Tdelay = str2num(get(findobj('Tag','Tdelay_edit'),'String'));
    args.Ttransit = str2num(get(findobj('Tag','Ttransit_edit'),'String'));
    args.inv_alpha = str2num(get(findobj('Tag','alpha_edit'),'String'));
    args.M0frames = str2num(get(findobj('Tag','M0frames_edit'),'String'));
    
    args.CompCorr = get(findobj('Tag','CompCor_cb'),'Value');
    args.physCorr = get(findobj('Tag','physio_cb'),'Value');
    args.physFile = get(findobj('Tag','physioName_edit'),'String');

    args.doGlobalMean = 0;
    
    args.doGLM = get(findobj('Tag','doGLM_cb'),'Value');
    args.designMat = [];
    args.doQuant_GLM = get(findobj('Tag','doQuant_GLM_cb'),'Value');

    if args.doGLM ~= 0
        xname = get(findobj('Tag','loadDesignMatrix_edit'),'String');
        X = load(xname);
        c = eval(get(findobj('Tag','contrasts_edit'),'String'));
        
        args.contrasts = c;
        args.designMat = X;
        args.isSubtracted = get(findobj('Tag','isSubtracted_cb'),'Value');

        disp('Note Sizes of contrasts and Design Matrix:');
        whos c X
    end
    
    args.doLightbox = get(findobj('Tag','displayZmap_cb'),'Value');
    args.doOrtho = 0; % get(findobj('Tag','displayZmap_cb'),'Value');
    args.is_GE_asl = get(findobj('Tag','ge_cb'),'Value');
    
    %%  Here is the call to the main function:  %%%%%%%
    save asl_spm03_params.mat args
    asl_spm03(args);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    disp('NO DATA to WORK ON!')
end
% --- Executes on button press in inputData_button.
function inputData_button_Callback(hObject, eventdata, handles)
% hObject    handle to inputData_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f p]=uigetfile('*.*','Input Data (kpace OR image space)');
str = fullfile(p,f);
set(findobj('Tag','inputData_edit'),'String', str);

function inputData_edit_Callback(hObject, eventdata, handles)
% hObject    handle to inputData_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputData_edit as text
%        str2double(get(hObject,'String')) returns contents of inputData_edit as a double


% --- Executes during object creation, after setting all properties.
function inputData_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputData_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SpiralRecon_cb.
function SpiralRecon_cb_Callback(hObject, eventdata, handles)
% hObject    handle to SpiralRecon_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SpiralRecon_cb
if get(gco,'Value')==1
   set(findobj('Tag', 'despiker_cb'), 'Enable','on');
   set(findobj('Tag', 'doZgrappa_cb'), 'Enable','on');

else
   set(findobj('Tag', 'despiker_cb'), 'Enable','off');
   set(findobj('Tag', 'doZgrappa_cb'), 'Enable','off');
end

% --- Executes on button press in despiker_cb.
function despiker_cb_Callback(hObject, eventdata, handles)
% hObject    handle to despiker_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of despiker_cb


% --- Executes on button press in realignment_cb.
function realignment_cb_Callback(hObject, eventdata, handles)
% hObject    handle to realignment_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realignment_cb


% --- Executes on button press in smoothing_cb.
function smoothing_cb_Callback(hObject, eventdata, handles)
% hObject    handle to smoothing_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothing_cb


% --- Executes on button press in subtraction_cb.
function subtraction_cb_Callback(hObject, eventdata, handles)
% hObject    handle to subtraction_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subtraction_cb
if get(gco,'Value')==1
   set(findobj('Tag', 'subtraction_lb'), 'Enable','on');
   set(findobj('Tag','isSubtracted_cb'),'Value',1);
else
   set(findobj('Tag', 'subtraction_lb'), 'Enable','off');
end

% --- Executes on button press in physio_cb.
function physio_cb_Callback(hObject, eventdata, handles)
% hObject    handle to physio_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of physio_cb
if get(gco,'Value')==1
   set(findobj('Tag', 'loadPhysioData_txt'), 'Enable','on');
   set(findobj('Tag', 'physioName_edit'), 'Enable','on');
else
   set(findobj('Tag', 'loadPhysioData_txt'), 'Enable','off');
   set(findobj('Tag', 'physioName_edit'), 'Enable','off');
   
end

% --- Executes on selection change in subtraction_lb.
function subtraction_lb_Callback(hObject, eventdata, handles)
% hObject    handle to subtraction_lb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns subtraction_lb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subtraction_lb


% --- Executes during object creation, after setting all properties.
function subtraction_lb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subtraction_lb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadPhysioData_txt.
function loadPhysioData_txt_Callback(hObject, eventdata, handles)
% hObject    handle to loadPhysioData_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[f p] = uigetfile('*.*','Load Physio Data File');
str = fullfile(p,f);
set(findobj('Tag', 'loadPhysioData_edit'), 'String',str);

function loadDesignMatrix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to loadDesignMatrix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadDesignMatrix_edit as text
%        str2double(get(hObject,'String')) returns contents of loadDesignMatrix_edit as a double


% --- Executes during object creation, after setting all properties.
function loadDesignMatrix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadDesignMatrix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


   
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doGLM_cb.
function doGLM_cb_Callback(hObject, eventdata, handles)
% hObject    handle to doGLM_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doGLM_cb
tmp = get(gco,'Value');
state = 'off';
if tmp == 1
    state = 'on';
end
set(findobj('Tag', 'buildDesignMatrix_button'), 'Enable',state);
set(findobj('Tag', 'loadDesignMatrix_button'), 'Enable',state);
set(findobj('Tag', 'loadDesignMatrix_edit'), 'Enable',state);
set(findobj('Tag', 'contrasts_edit'), 'Enable',state);
set(findobj('Tag', 'contrasts_text'), 'Enable',state);
set(findobj('Tag', 'displayZmap_cb'), 'Enable',state);
set(findobj('Tag', 'isSubtracted_cb'), 'Enable',state);
set(findobj('Tag', 'doQuant_GLM_cb'), 'Enable',state);
set(findobj('Tag', 'doLightbox_cb'), 'Enable',state);


% --- Executes on button press in displayZmap_cb.
function displayZmap_cb_Callback(hObject, eventdata, handles)
% hObject    handle to displayZmap_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayZmap_cb


% --- Executes on button press in loadDesignMatrix_button.
function loadDesignMatrix_button_Callback(hObject, eventdata, handles)
% hObject    handle to loadDesignMatrix_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, pth]=uigetfile('*.*','Load Design Matrix File');
str = fullfile(pth,file);
set(findobj('Tag', 'loadDesignMatrix_edit'), 'String',str);
X=load(str);
figure; imagesc(X); colormap gray ; title('Design Matrix');

function physioName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to physioName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of physioName_edit as text
%        str2double(get(hObject,'String')) returns contents of physioName_edit as a double


% --- Executes during object creation, after setting all properties.
function physioName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to physioName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doQuant_GLM_cb.
function doQuant_GLM_cb_Callback(hObject, eventdata, handles)
% hObject    handle to doQuant_GLM_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doQuant_GLM_cb
if get(gco,'Value')==1
   set(findobj('Tag', 'doLightbox_cb'), 'Enable','on');
else
   set(findobj('Tag', 'doLightbox_cb'), 'Enable','off');
end

% --- Executes on button press in buildDesignMatrix_button.
function buildDesignMatrix_button_Callback(hObject, eventdata, handles)
% hObject    handle to buildDesignMatrix_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ASLmatBuilder01

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function contrasts_edit_Callback(hObject, eventdata, handles)
% hObject    handle to contrasts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrasts_edit as text
%        str2double(get(hObject,'String')) returns contents of contrasts_edit as a double


% --- Executes during object creation, after setting all properties.
function contrasts_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrasts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function alpha_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha_edit as text
%        str2double(get(hObject,'String')) returns contents of alpha_edit as a double


% --- Executes during object creation, after setting all properties.
function alpha_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ttransit_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ttransit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ttransit_edit as text
%        str2double(get(hObject,'String')) returns contents of Ttransit_edit as a double


% --- Executes during object creation, after setting all properties.
function Ttransit_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ttransit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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



function TR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TR_edit as text
%        str2double(get(hObject,'String')) returns contents of TR_edit as a double


% --- Executes during object creation, after setting all properties.
function TR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ttag_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ttag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ttag_edit as text
%        str2double(get(hObject,'String')) returns contents of Ttag_edit as a double


% --- Executes during object creation, after setting all properties.
function Ttag_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ttag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tdelay_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tdelay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tdelay_edit as text
%        str2double(get(hObject,'String')) returns contents of Tdelay_edit as a double


% --- Executes during object creation, after setting all properties.
function Tdelay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tdelay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sliceTiming_cb.
function sliceTiming_cb_Callback(hObject, eventdata, handles)
% hObject    handle to sliceTiming_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sliceTiming_cb


% --- Executes on button press in doLightbox_cb.
function doLightbox_cb_Callback(hObject, eventdata, handles)
% hObject    handle to doLightbox_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doLightbox_cb


% --- Executes on button press in isSubtracted_cb.
function isSubtracted_cb_Callback(hObject, eventdata, handles)
% hObject    handle to isSubtracted_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isSubtracted_cb


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14


% --- Executes on button press in ge_cb.
function ge_cb_Callback(hObject, eventdata, handles)
% hObject    handle to ge_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ge_cb


% --- Executes on button press in doZgrappa_cb.
function doZgrappa_cb_Callback(hObject, eventdata, handles)
% hObject    handle to doZgrappa_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doZgrappa_cb



function t1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to t1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t1_edit as text
%        str2double(get(hObject,'String')) returns contents of t1_edit as a double


% --- Executes during object creation, after setting all properties.
function t1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function M0frames_edit_Callback(hObject, eventdata, handles)
% hObject    handle to M0frames_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M0frames_edit as text
%        str2double(get(hObject,'String')) returns contents of M0frames_edit as a double


% --- Executes during object creation, after setting all properties.
function M0frames_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M0frames_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in anat_img_button.
function anat_img_button_Callback(hObject, eventdata, handles)
% hObject    handle to anat_img_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[f p] = uigetfile('*.*','Select Anatomical Image for Coregistration');
str = fullfile(p,f);
set(findobj('Tag','anat_img_edit'),'String', str);


function anat_img_edit_Callback(hObject, eventdata, handles)
% hObject    handle to anat_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of anat_img_edit as text
%        str2double(get(hObject,'String')) returns contents of anat_img_edit as a double


% --- Executes during object creation, after setting all properties.
function anat_img_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anat_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in template_img_button.
function template_img_button_Callback(hObject, eventdata, handles)
% hObject    handle to template_img_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p]=uigetfile('*.*','Select a Template for Spat. Normalization');
str = fullfile(p,f);
set(findobj('Tag','template_img_edit'),'String', str);


function template_img_edit_Callback(hObject, eventdata, handles)
% hObject    handle to template_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of template_img_edit as text
%        str2double(get(hObject,'String')) returns contents of template_img_edit as a double


% --- Executes during object creation, after setting all properties.
function template_img_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to template_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in quant_cbf_cb.
function quant_cbf_cb_Callback(hObject, eventdata, handles)
% hObject    handle to quant_cbf_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of quant_cbf_cb
tmp = get(findobj('Tag', 'quant_cbf_cb'), 'Value');
args.doQuant = tmp;
state = 'off';
if tmp
    state = 'on';
end
set(findobj('Tag', 'Diff_img_button'), 'Enable', state);
set(findobj('Tag', 'M0_img_button'), 'Enable', state);
set(findobj('Tag', 'Diff_img_edit'), 'Enable', state);
set(findobj('Tag', 'SpinDens_img_edit'), 'Enable', state);
set(findobj('Tag', 'label_type_list'), 'Enable', state);



% --- Executes on selection change in label_type_list.
function label_type_list_Callback(hObject, eventdata, handles)
% hObject    handle to label_type_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns label_type_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from label_type_list


% --- Executes during object creation, after setting all properties.
function label_type_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label_type_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CompCor_cb.
function CompCor_cb_Callback(hObject, eventdata, handles)
% hObject    handle to CompCor_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CompCor_cb



function bat_text_Callback(hObject, eventdata, handles)
% hObject    handle to bat_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bat_text as text
%        str2double(get(hObject,'String')) returns contents of bat_text as a double


% --- Executes during object creation, after setting all properties.
function bat_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bat_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flip_edit_Callback(hObject, eventdata, handles)
% hObject    handle to flip_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flip_edit as text
%        str2double(get(hObject,'String')) returns contents of flip_edit as a double


% --- Executes during object creation, after setting all properties.
function flip_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flip_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Diff_img_button.
function Diff_img_button_Callback(hObject, eventdata, handles)
% hObject    handle to Diff_img_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p]=uigetfile('*.*','Select the Subtraction Image for CBF quantification');
str = fullfile(p,f);
set(findobj('Tag','Diff_img_edit'),'String', str);

% --- Executes on button press in M0_img_button.
function M0_img_button_Callback(hObject, eventdata, handles)
% hObject    handle to M0_img_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p]=uigetfile('*.*','Select the Spin Density (M0) Image for CBF quantification');
str = fullfile(p,f);
set(findobj('Tag', 'SpinDens_img_edit'),'String', str);



function Diff_img_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Diff_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Diff_img_edit as text
%        str2double(get(hObject,'String')) returns contents of Diff_img_edit as a double


% --- Executes during object creation, after setting all properties.
function Diff_img_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Diff_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpinDens_img_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SpinDens_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpinDens_img_edit as text
%        str2double(get(hObject,'String')) returns contents of SpinDens_img_edit as a double


% --- Executes during object creation, after setting all properties.
function SpinDens_img_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpinDens_img_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spat_norm_series_cb.
function spat_norm_series_cb_Callback(hObject, eventdata, handles)
% hObject    handle to spat_norm_series_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spat_norm_series_cb
