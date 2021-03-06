function varargout = FirstGUI(varargin)
addpath(genpath('view'));
addpath(genpath('model'));

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FirstGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FirstGUI_OutputFcn, ...
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


% --- Executes just before FirstGUI is made visible.
function FirstGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global channel; global encoder; global decoder;

handles.output = hObject;
guidata(hObject, handles);
movegui(hObject,'center');
set(handles.rbIdealChannel,'value',1);
channel = IdealChannel();
encoder = EthernetCoder();
decoder = EthernetDecoder();
    

% --- Outputs from this function are returned to the command line.
function varargout = FirstGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in sendButton.
function sendButton_Callback(hObject, eventdata, handles)
global channel; global workingSignal; global entrySignal;

channel.send(workingSignal);
workingSignal = channel.receive();
set(handles.receivedSignal, 'String', workingSignal.toString());
resetBackgroundColorsToGrey(handles);
set(handles.receivedSignal, 'BackgroundColor', [0.91 0.99 0.91]);
set(handles.berValue, 'String', Helper.calculateBER(entrySignal,workingSignal));


% --- Executes on button press in scrambleButton.
function scrambleButton_Callback(hObject, eventdata, handles)
global LFSRFileVar; global workingSignal;
if LFSRFileVar == 0
    disp('bezpliku');
    scrambler = Scrambler();
else
    disp('zplikiem');
    scrambler = Scrambler(LFSRFileVar);
end
workingSignal = scrambler.scramble(workingSignal.copy());
resetBackgroundColorsToGrey(handles);
set(handles.scrambledSignal, 'BackgroundColor', [0.91 0.96 0.91]);
set(handles.scrambledSignal, 'String', workingSignal.toString());
scrambler.disp();


% --- Executes on button press in descrambleButton.
function descrambleButton_Callback(hObject, eventdata, handles)
global workingSignal; global LFSRFileVar; global entrySignal;
if LFSRFileVar == 0
    disp('bezpliku');
    descrambler = Descrambler();
else
    disp('zplikiem');
    descrambler = Descrambler(LFSRFileVar);
end
%descrambler = Descrambler();
workingSignal = descrambler.descramble(workingSignal);
resetBackgroundColorsToGrey(handles);
set(handles.descrambledSignal, 'BackgroundColor', [0.91 0.96 0.91]);
set(handles.descrambledSignal, 'String', workingSignal.toString());
set(handles.berValue, 'String', Helper.calculateBER(entrySignal,workingSignal));


% --- Executes on button press in encodeButton.
function encodeButton_Callback(hObject, eventdata, handles)
global workingSignal; global encoder; 

workingSignal = encoder.encode(Helper.appendToAlign64(workingSignal));
resetBackgroundColorsToGrey(handles);
set(handles.encodedSignal, 'BackgroundColor', [0.91 0.96 0.91]);
set(handles.encodedSignal, 'String', workingSignal.toString());


% --- Executes on button press in decodeButton.
function decodeButton_Callback(hObject, eventdata, handles)
global workingSignal; global entrySignal; global decoder;
workingSignal = decoder.decode(workingSignal); 
resetBackgroundColorsToGrey(handles);
set(handles.decodedSignal, 'BackgroundColor', [0.91 0.96 0.91]);
set(handles.decodedSignal, 'String', workingSignal.toString());
set(handles.berValue, 'String', Helper.calculateBER(entrySignal,workingSignal));

if decoder.wasGood()
    set(handles.desyncIndicator, 'BackgroundColor', [0 1 0]);
else
    set(handles.desyncIndicator, 'BackgroundColor', [1 1 0]);
end



% --- Executes on button press in wrongBitsButton.
function wrongBitsButton_Callback(hObject, eventdata, handles)
WrongBits();


% --- Executes on button press in btnConfigureChannel.
function btnConfigureChannel_Callback(hObject, eventdata, handles)

if get(handles.rbIdealChannel, 'Value') == 1
    % ideal channel selected
elseif get(handles.rbCustomChannel, 'Value') == 1
    ConfigureCustomChannel();
elseif get(handles.rbBSChannel, 'Value') == 1
    ConfigureBSC();
end

% --- Executes on button press in rbIdealChannel.
function rbIdealChannel_Callback(hObject, eventdata, handles)
global channel;

set(handles.btnConfigureChannel,'enable','off');
channel = IdealChannel();


% --- Executes on button press in rbCustomChannel.
function rbCustomChannel_Callback(hObject, eventdata, handles)
global channel;

set(handles.btnConfigureChannel,'enable','on');
channel = CustomChannel();


% --- Executes on button press in rbBSChannel.
function rbBSChannel_Callback(hObject, eventdata, handles)
global channel;

set(handles.btnConfigureChannel,'enable','on');
channel = BSChannel();



function fileInput_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in loadLFSRButton.
function loadLFSRButton_Callback(hObject, eventdata, handles)
global LFSRFileVar;
[fn, fp] = uigetfile('*.txt', 'Select LFSR file');
LFSRFileVar = importdata(fullfile(fp,fn));


% --- Executes on button press in clearAllButton.
function clearAllButton_Callback(hObject, eventdata, handles)
set(handles.originalSignal, 'String', '');
set(handles.scrambledSignal, 'String', '');
set(handles.encodedSignal, 'String', '');
set(handles.receivedSignal, 'String', '');
set(handles.decodedSignal, 'String', '');
set(handles.descrambledSignal, 'String', '');
set(handles.rbSignalFromFile,'value',1);
set(handles.rbIdealChannel,'value',1);
set(handles.btnConfigureChannel,'enable','off');
set(handles.tbSignalRandomSize,'enable','off');
set(handles.btnSignalOK,'enable','on');
set(handles.btnSignalOK,'string','Load');
resetBackgroundColorsToGrey(handles);
global LFSRFileVar;
LFSRFileVar = 0;


% --- Executes on button press in btnSignalOK.
function btnSignalOK_Callback(hObject, eventdata, handles)
global entrySignal; global workingSignal; global random;

if get(handles.rbSignalRandom,'value') == 1
    entrySignal = random.generate(64 * str2num(get(handles.tbSignalRandomSize, 'String')));
    
elseif get(handles.rbSignalFromFile,'value') == 1
    [fn, fp] = uigetfile('*.txt', 'Select signal file');
    entrySignal = Signal(fullfile(fp,fn));
end

workingSignal = entrySignal.copy();
resetBackgroundColorsToGrey(handles);
set(handles.originalSignal, 'BackgroundColor', [0.91 0.96 0.91]);
set(handles.originalSignal, 'string', entrySignal.toString());


% --- Executes during object creation, after setting all properties.
function tbSignalRandomSize_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in rbSignalRandom.
function rbSignalRandom_Callback(hObject, eventdata, handles)
global random;

random = RandomGenerator();
random.duplProb = 0.5;
set(handles.tbSignalRandomSize,'enable','on');
set(handles.configureRandom,'enable','on');
set(handles.btnSignalOK,'enable','on');
set(handles.btnSignalOK,'string','Generate');


function tbSignalRandomSize_Callback(hObject, eventdata, handles)


% --- Executes on button press in rbSignalFromFile.
function rbSignalFromFile_Callback(hObject, eventdata, handles)

set(handles.tbSignalRandomSize,'enable','off');
set(handles.configureRandom,'enable','off');
set(handles.btnSignalOK,'enable','on');
set(handles.btnSignalOK,'string','Load');


% --- Executes during object creation, after setting all properties.
function rbSignalFromFile_CreateFcn(hObject, eventdata, handles)

set(hObject,'value',1);


% --- Executes during object creation, after setting all properties.
function rbIdealChannel_CreateFcn(hObject, eventdata, handles)

set(hObject,'value',1);

function resetBackgroundColorsToGrey(handles)
set(handles.receivedSignal, 'BackgroundColor', [0.9 0.9 0.9]);
set(handles.scrambledSignal, 'BackgroundColor', [0.9 0.9 0.9]);
set(handles.descrambledSignal, 'BackgroundColor', [0.9 0.9 0.9]);
set(handles.originalSignal, 'BackgroundColor', [0.9 0.9 0.9]);
set(handles.encodedSignal, 'BackgroundColor', [0.9 0.9 0.9]);
set(handles.decodedSignal, 'BackgroundColor', [0.9 0.9 0.9]);
set(handles.desyncIndicator, 'BackgroundColor', [0.9 0.9 0.9]);



% --- Executes on button press in btnResetTransm.
function btnResetTransm_Callback(hObject, eventdata, handles)
global workingSignal; global entrySignal;
set(handles.scrambledSignal, 'String', '');
set(handles.encodedSignal, 'String', '');
set(handles.receivedSignal, 'String', '');
set(handles.decodedSignal, 'String', '');
set(handles.descrambledSignal, 'String', '');
set(handles.berValue, 'String', '-');

workingSignal = entrySignal.copy();
resetBackgroundColorsToGrey(handles);
set(handles.originalSignal, 'BackgroundColor', [0.91 0.96 0.91]);
set(handles.originalSignal, 'string', entrySignal.toString());


% --- Executes on button press in configureRandom.
function configureRandom_Callback(hObject, eventdata, handles)
ConfigureRandom();


% --- Executes during object creation, after setting all properties.
function configureRandom_CreateFcn(hObject, eventdata, handles)
set(hObject,'enable','off');


% --- Executes during object creation, after setting all properties.
function desyncIndicator_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', [0.9 0.9 0.9]);
