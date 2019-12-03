function varargout = MLP_3_G(varargin)
% MLP_3_G MATLAB code for MLP_3_G.fig
%      MLP_3_G, by itself, creates a new MLP_3_G or raises the existing
%      singleton*.
%
%      H = MLP_3_G returns the handle to a new MLP_3_G or the handle to
%      the existing singleton*.
%
%      MLP_3_G('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MLP_3_G.M with the given input arguments.
%
%      MLP_3_G('Property','Value',...) creates a new MLP_3_G or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MLP_3_G_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MLP_3_G_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MLP_3_G

% Last Modified by GUIDE v2.5 17-Nov-2015 04:07:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MLP_3_G_OpeningFcn, ...
                   'gui_OutputFcn',  @MLP_3_G_OutputFcn, ...
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


% --- Executes just before MLP_3_G is made visible.
function MLP_3_G_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MLP_3_G (see VARARGIN)

% Choose default command line output for MLP_3_G
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MLP_3_G wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MLP_3_G_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Start_btn.
function Start_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Start_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clear;
data=importdata('slice_localization_data.csv');
TotalNo=size(data,1);
ys_first=data(:,385);
ys=(1/(max(ys_first)-min(ys_first)))*(ys_first-min(ys_first));

try
    train_R=handles.Train_Ratio;
catch e
    train_R=0.7;
end

try
    valid_R=handles.Val_Ratio;
catch e
    valid_R=0.1
end

trainNo=floor(TotalNo*train_R);
valNo=floor(TotalNo*valid_R);

input_no=size(data,2)-1;

train_x=data(1:trainNo,1:384);
train_y=ys(1:trainNo);


valid_x=data(trainNo+1:trainNo+valNo,1:384);
valid_y=ys(trainNo+1:trainNo+valNo);

testNo=TotalNo-trainNo-valNo;

test_x=data(trainNo+valNo+1:end,1:384);
test_y=ys(trainNo+valNo+1:end);
try
    term_cond=handles.Stopping_Condition-1;
catch e
    term_cond=0;
end

try
    MaxEpochNo=handles.Max_Epoch;
catch e
    MaxEpochNo=100;
end

try
    MinErrorRate=handles.Max_Error;
catch e
    MinErrorRate=0.1;
end

try
    alpha=handles.LR;
catch e
    alpha=0.8;
end

try
    hid_lay_no=handles.hln;
catch e
    hid_lay_no=2;
end

hln=hid_lay_no;

try
    L(1)=handles.L1;
catch e
    L(1)=20;
end
try
    L(2)=handles.L2;
catch e
    L(2)=4;
end
try
    L(3)=handles.L3;
catch e
    L(3)=4;
end
try
    L(4)=handles.L4;
catch e
    L(4)=4;
end
try
    L(5)=handles.L5;
catch e
    L(5)=2;
end
hid_lay_size=[];
for i=1:hln
    hid_lay_size=[hid_lay_size L(i)];
end
 hid_lay_size=[hid_lay_size 1];
 
try
    InitMode=Handles.WIM;
catch e
    InitMode=0;
end

try
    BatchMode=handles.BatchOn;
catch e
    BatchMode=0;
end

try
    Momentum=handles.MomentumOn;
catch e
    Momentum=0;
end

try
    batch=handles.Batch;
catch e
    batch=10;
end

if(batch>MaxEpochNo)
    batch=MaxEpochNo;
end

if(batch<1)
    batch=1;
end

try
    mu=handles.MuVal;
catch e
    mu=0.5;
end

try
    AF=handles.AF;
catch e
    AF=1;
end

if(AF==1)
    func=@tanh;
    funcd=@tanhd;
else
    func=@sigmoid;
    funcd=@sigmoidd;
end
%% Initializing MLP Weights
Ws=cell(1,hln+1);
if(InitMode==0)
    Ws{1}=rand(input_no,hid_lay_size(1))-0.5;
    if(hln>1)
    for i=2:hln
        Ws{i}=rand(hid_lay_size(i-1),hid_lay_size(i))-0.5;
    end
    end
    Ws{hln+1}=rand(hid_lay_size(hln),1)-0.5;
else
    Ws=InitNW(hln,hid_lay_size,input_no);
end

%Ws_old=Ws;

TestError=zeros(1,MaxEpochNo);
TrainError=zeros(1,MaxEpochNo);

deltaW=cell(1,hln+1);

Train_Time=0;
Test_Time=0;
Error=0;
Batch_Counter=0;
if(term_cond==0)
%% Training with Max Epoch
    for z=1:MaxEpochNo
        Ws_old=Ws;
        disp('Epoch: ');
        disp(z); 
        tic
        for tn=1:trainNo
        deltaW=cell(1,hln+1);
        deltaW{1}=zeros(input_no,hid_lay_size(1));
        for i=2:hln+1
            deltaW{i}=zeros(hid_lay_size(i-1),hid_lay_size(i));
        end
        %% Feed Forwarding
        x=train_x(tn,:);
        delta=0;
        NInput=cell(1,hln+1);
        Output=cell(1,hln+1);

        for i=1:hln+1
            NInput{i}=x*Ws{i};
            Output{i}=func(NInput{i});
            x=Output{i};
        end
        t=train_y(tn);
        %% BackPropagating the output layer
        delta=t-Output{hln+1};
        Error=Error+delta;
        %% Batch Mode On
        if(BatchMode)
            if(Batch_Counter==batch)
                Batch_Counter=0;
                delta=Error/batch;
                Error=0;
                %% BackPropagating output & hidden layers
                for k=hln+1:-1:2
          %         g=1-Output{k}.*Output{k};
                    g=funcd(NInput{k});
                    g(g<0.001)=0.001;
                    g=g'.*delta;
                    delta=Ws{k}*g;
                    if(~Momentum)
                        Ws{k}=Ws{k}+alpha*Output{k-1}'*g';
                    else
                        deltaW{k}=alpha*Output{k-1}'*g'+mu*(Ws{k}-Ws_old{k});
                        Ws_old{k}=Ws{k};
                        Ws{k}=Ws{k}+deltaW{k};            
                    end
                end
                %% Backpropagating the first hidden layer
        %         g=1-Output{1}.*Output{1};
                g=funcd(NInput{1});
                g(g<0.001)=0.001;
                g=g'.*delta;
                if(~Momentum)
                    Ws{1}=Ws{1}+alpha*train_x(tn,:)'*g';
                else
                    deltaW{1}=alpha*train_x(tn,:)'*g'+mu*(Ws{1}-Ws_old{1});
                    Ws_old{1}=Ws{1};
                    Ws{1}=Ws{1}+deltaW{1};
                end
            else
                Batch_Counter=Batch_Counter+1;
            end
        else
        %% BackPropagating output & hidden layers
        for k=hln+1:-1:2
%         g=1-Output{k}.*Output{k};
        g=funcd(NInput{k});
        g(g<0.001)=0.001;
        g=g'.*delta;
        delta=Ws{k}*g;
        if(~Momentum)
            Ws{k}=Ws{k}+alpha*Output{k-1}'*g';
        else
            deltaW{k}=alpha*Output{k-1}'*g'+mu*(Ws{k}-Ws_old{k});
            Ws_old{k}=Ws{k};
            Ws{k}=Ws{k}+deltaW{k};            
        end
        end
        %% Backpropagating the first hidden layer
%         g=1-Output{1}.*Output{1};
        g=funcd(NInput{1});
        g(g<0.001)=0.001;
        g=g'.*delta;
        if(~Momentum)
            Ws{1}=Ws{1}+alpha*train_x(tn,:)'*g';
        else
            deltaW{1}=alpha*train_x(tn,:)'*g'+mu*(Ws{1}-Ws_old{1});
            Ws_old{1}=Ws{1};
            Ws{1}=Ws{1}+deltaW{1};
        end
        end
        end
        Train_Time=Train_Time+toc;
        err1=0;
        err2=0;
        tic
        %% Train Error
        for tn=1:trainNo
        NInput=cell(1,hln+1);
        NInput{1}=train_x(tn,:)*Ws{1};
        Output=cell(1,hln+1);
        Output{1}=func(NInput{1});

        for i=2:hln+1
            NInput{i}=Output{i-1}*Ws{i};
            Output{i}=func(NInput{i});
        end

        err1=err1+abs(train_y(tn)-Output{hln+1}(1));

        end
        TrainError(z)=err1/(trainNo);

        %% Test Error
        for testno=1:testNo
        NInput=cell(1,hln+1);
        NInput{1}=test_x(testno,:)*Ws{1};
        Output=cell(1,hln+1);
        Output{1}=func(NInput{1});

        for i=2:hln+1
            NInput{i}=Output{i-1}*Ws{i};
            Output{i}=func(NInput{i});
        end

        err2=err2+abs(test_y(testno)-Output{hln+1}(1));
        end
        TestError(z)=err2/(testNo);
        Test_Time=Test_Time+toc;
    end
else
    %% Training with Max Error
    MaxError=1;
    z=0;
    while(MaxError>MinErrorRate)
        z=z+1;
        Ws_old=Ws;
        disp('Epoch: ');
        disp(z); 
        tic
        for tn=1:trainNo
        deltaW=cell(1,hln+1);
        deltaW{1}=zeros(input_no,hid_lay_size(1));
        for i=2:hln+1
            deltaW{i}=zeros(hid_lay_size(i-1),hid_lay_size(i));
        end
        %% Feed Forwarding
        x=train_x(tn,:);
        delta=0;
        NInput=cell(1,hln+1);
        Output=cell(1,hln+1);

        for i=1:hln+1
            NInput{i}=x*Ws{i};
            Output{i}=func(NInput{i});
            x=Output{i};
        end
        t=train_y(tn);
        %% BackPropagating the output layer
        delta=t-Output{hln+1};
        Error=Error+delta;
        %% Batch Mode On
        if(BatchMode)
            if(Batch_Counter==batch)
                Batch_Counter=0;
                delta=Error/batch;
                Error=0;
                %% BackPropagating output & hidden layers
                for k=hln+1:-1:2
          %         g=1-Output{k}.*Output{k};
                    g=funcd(NInput{k});
                    g(g<0.001)=0.001;
                    g=g'.*delta;
                    delta=Ws{k}*g;
                    if(~Momentum)
                        Ws{k}=Ws{k}+alpha*Output{k-1}'*g';
                    else
                        deltaW{k}=alpha*Output{k-1}'*g'+mu*(Ws{k}-Ws_old{k});
                        Ws_old{k}=Ws{k};
                        Ws{k}=Ws{k}+deltaW{k};            
                    end
                end
                %% Backpropagating the first hidden layer
        %         g=1-Output{1}.*Output{1};
                g=funcd(NInput{1});
                g(g<0.001)=0.001;
                g=g'.*delta;
                if(~Momentum)
                    Ws{1}=Ws{1}+alpha*train_x(tn,:)'*g';
                else
                    deltaW{1}=alpha*train_x(tn,:)'*g'+mu*(Ws{1}-Ws_old{1});
                    Ws_old{1}=Ws{1};
                    Ws{1}=Ws{1}+deltaW{1};
                end
            else
                Batch_Counter=Batch_Counter+1;
            end
        else
        %% BackPropagating output & hidden layers
        for k=hln+1:-1:2
%         g=1-Output{k}.*Output{k};
        g=funcd(NInput{k});
        g(g<0.001)=0.001;
        g=g'.*delta;
        delta=Ws{k}*g;
        if(~Momentum)
            Ws{k}=Ws{k}+alpha*Output{k-1}'*g';
        else
            deltaW{k}=alpha*Output{k-1}'*g'+mu*(Ws{k}-Ws_old{k});
            Ws_old{k}=Ws{k};
            Ws{k}=Ws{k}+deltaW{k};            
        end
        end
        %% Backpropagating the first hidden layer
%         g=1-Output{1}.*Output{1};
        g=funcd(NInput{1});
        g(g<0.001)=0.001;
        g=g'.*delta;
        if(~Momentum)
            Ws{1}=Ws{1}+alpha*train_x(tn,:)'*g';
        else
            deltaW{1}=alpha*train_x(tn,:)'*g'+mu*(Ws{1}-Ws_old{1});
            Ws_old{1}=Ws{1};
            Ws{1}=Ws{1}+deltaW{1};
        end
        end
        end
        Train_Time=Train_Time+toc;
        err1=0;
        err2=0;
        err3=0;
        tic
        %% Train Error
        for tn=1:trainNo
        NInput=cell(1,hln+1);
        NInput{1}=train_x(tn,:)*Ws{1};
        Output=cell(1,hln+1);
        Output{1}=func(NInput{1});

        for i=2:hln+1
            NInput{i}=Output{i-1}*Ws{i};
            Output{i}=func(NInput{i});
        end

        err1=err1+abs(train_y(tn)-Output{hln+1}(1));

        end
        TrainError(z)=err1/(trainNo);

        %% Test Error
        for testno=1:testNo
        NInput=cell(1,hln+1);
        NInput{1}=test_x(testno,:)*Ws{1};
        Output=cell(1,hln+1);
        Output{1}=func(NInput{1});

        for i=2:hln+1
            NInput{i}=Output{i-1}*Ws{i};
            Output{i}=func(NInput{i});
        end

        err2=err2+abs(test_y(testno)-Output{hln+1}(1));
        end
        TestError(z)=err2/(testNo);
        %% Validation Error
        for testno=1:valNo
        NInput=cell(1,hln+1);
        NInput{1}=valid_x(testno,:)*Ws{1};
        Output=cell(1,hln+1);
        Output{1}=func(NInput{1});

        for i=2:hln+1
            NInput{i}=Output{i-1}*Ws{i};
            Output{i}=func(NInput{i});
        end

        err3=err3+abs(valid_y(testno)-Output{hln+1}(1));
        end
        MaxError=err3/(valNo);
        Test_Time=Test_Time+toc;
        
    end
end

handles.TrainError=TrainError;
guidata(hObject,handles);
handles.TestError=TestError;
guidata(hObject,handles);
handles.Weights=Ws;
guidata(hObject,handles);
set(handles.Train_Time,'String',num2str(Train_Time));
set(handles.Test_Time,'String',num2str(Test_Time));

set(handles.Result_Min_Error,'String',num2str(TrainError(end)));
set(handles.Result_Min_Error2,'String',num2str(TestError(end)));
axes(handles.LPlot);
plot(handles.LPlot,TrainError);
handles.LPlot.Title.String='Error Rates';
hold
plot(TestError);
legend(handles.LPlot,'Train Error','TestError');
hold





































% --- Executes on selection change in Stopping_Condition.
function Stopping_Condition_Callback(hObject, eventdata, handles)
% hObject    handle to Stopping_Condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Stopping_Condition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Stopping_Condition
handles.Stopping_Condition=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Stopping_Condition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Stopping_Condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Max_Epoch_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Max_Epoch_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max_Epoch_edit as text
%        str2double(get(hObject,'String')) returns contents of Max_Epoch_edit as a double
handles.Max_Epoch=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Max_Epoch_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_Epoch_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Max_Error_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Max_Error_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max_Error_edit as text
%        str2double(get(hObject,'String')) returns contents of Max_Error_edit as a double
handles.Max_Error=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Max_Error_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_Error_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Load_Name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Load_Name_edit as text
%        str2double(get(hObject,'String')) returns contents of Load_Name_edit as a double
handles.LoadName=get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Load_Name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Load_Name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Train_Ratio_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Train_Ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Train_Ratio_edit as text
%        str2double(get(hObject,'String')) returns contents of Train_Ratio_edit as a double
handles.Train_Ratio=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Train_Ratio_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Train_Ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Valid_Ratio_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Valid_Ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Valid_Ratio_edit as text
%        str2double(get(hObject,'String')) returns contents of Valid_Ratio_edit as a double
handles.Val_Ratio=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Valid_Ratio_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Valid_Ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_btn.
function Save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Name=handles.SaveName;
catch e
    Name='Untitled';
end

try
    Ws=handles.Ws;
catch e
    Ws=0;
end

try
    TrainError=handles.TrainError;
catch e
    TrainError=0;
end

try
    TestError=handles.TestError;
catch e
    TestError=0;
end

fID=fopen(strcat(Name,'.TrainError'),'w');
N=size(TrainError,2);
for i=1:N
    fprintf(fID,'%d\n',TrainError(i));
end
fclose(fID);

fID=fopen(strcat(Name,'.TestError'),'w');
N=size(TestError,2);

for i=1:N
    fprintf(fID,'%d\n',TestError(i));
end
fclose(fID);

function Save_Name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Save_Name_edit as text
%        str2double(get(hObject,'String')) returns contents of Save_Name_edit as a double
handles.SaveName=get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Save_Name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Save_Name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LR_edit as text
%        str2double(get(hObject,'String')) returns contents of LR_edit as a double
handles.LR=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function LR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_btn.
function Load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    Name=handles.LoadName;
catch e
    Name='Untitled';
end
TrainError=importdata(strcat(Name,'.TrainError'));


TestError=importdata(strcat(Name,'.TestError'));

set(handles.Result_Min_Error,'String',num2str(TrainError(end)));
set(handles.Result_Min_Error2,'String',num2str(TestError(end)));
axes(handles.RPlot);
plot(handles.RPlot,TrainError);
handles.RPlot.Title.String='Error Rates';
hold
plot(TestError);
legend(handles.RPlot,'Train Error','TestError');
hold


% --- Executes on selection change in WIM_select.
function WIM_select_Callback(hObject, eventdata, handles)
% hObject    handle to WIM_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WIM_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WIM_select
handles.WIM=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function WIM_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WIM_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AF_select.
function AF_select_Callback(hObject, eventdata, handles)
% hObject    handle to AF_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AF_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AF_select
handles.AF=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function AF_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AF_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Batch_Mode.
function Batch_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to Batch_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Batch_Mode
handles.BatchOn=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes on button press in Momentum.
function Momentum_Callback(hObject, eventdata, handles)
% hObject    handle to Momentum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Momentum
handles.MomentumOn=get(hObject,'Value');
guidata(hObject,handles);



% function f=tanh(data)
%     %f= 1- 2./(1+exp(2.*data));
%     f=tanh(data);
function f= tanhd(data)
    f= 1- tanh(data).^2;
function f= sigmoid(data)
    f= 1./(1+exp(-data));
function f= sigmoidd(data)
    f= ((data)).*(1 - (data));



function L1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to L1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L1_edit as text
%        str2double(get(hObject,'String')) returns contents of L1_edit as a double
handles.L1=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function L1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to L3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L3_edit as text
%        str2double(get(hObject,'String')) returns contents of L3_edit as a double
handles.L3=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function L3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L5_edit_Callback(hObject, eventdata, handles)
% hObject    handle to L5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L5_edit as text
%        str2double(get(hObject,'String')) returns contents of L5_edit as a double
handles.L5=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function L5_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L5_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to L2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L2_edit as text
%        str2double(get(hObject,'String')) returns contents of L2_edit as a double
handles.L2=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function L2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to L4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L4_edit as text
%        str2double(get(hObject,'String')) returns contents of L4_edit as a double
handles.L3=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function L4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hln_select.
function hln_select_Callback(hObject, eventdata, handles)
% hObject    handle to hln_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hln_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hln_select
handles.hln=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function hln_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hln_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function LPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate LPlot


% --- Executes during object creation, after setting all properties.
function RPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate RPlot



function Mu_Callback(hObject, eventdata, handles)
% hObject    handle to Mu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mu as text
%        str2double(get(hObject,'String')) returns contents of Mu as a double
handles.MuVal=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Mu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Batch_Callback(hObject, eventdata, handles)
% hObject    handle to Batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Batch as text
%        str2double(get(hObject,'String')) returns contents of Batch as a double
handles.Batch=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Batch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
