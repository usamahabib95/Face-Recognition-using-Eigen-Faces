function varargout = eigenAlgo(varargin)
% EIGENALGO MATLAB code for eigenAlgo.fig
%      EIGENALGO, by itself, creates a new EIGENALGO or raises the existing
%      singleton*.
%
%      H = EIGENALGO returns the handle to a new EIGENALGO or the handle to
%      the existing singleton*.
%
%      EIGENALGO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EIGENALGO.M with the given input arguments.
%
%      EIGENALGO('Property','Value',...) creates a new EIGENALGO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eigenAlgo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eigenAlgo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eigenAlgo

% Last Modified by GUIDE v2.5 18-May-2019 15:46:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eigenAlgo_OpeningFcn, ...
                   'gui_OutputFcn',  @eigenAlgo_OutputFcn, ...
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


% --- Executes just before eigenAlgo is made visible.
function eigenAlgo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eigenAlgo (see VARARGIN)

% Choose default command line output for eigenAlgo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eigenAlgo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eigenAlgo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadTestImage.
function LoadTestImage_Callback(hObject, eventdata, handles)
% hObject    handle to LoadTestImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fName, pName] = uigetfile('*.jpg; *.jpeg; *.png; *.tif; *.*; ', 'Select an Image');
global testimg;
global testvect;
if pName ~= 0
	path = [pName fName];
	testimg = imread(path);
 	testvect=testimg(:);
end
axes(handles.TestImage);
imshow(testimg)

% --- Executes on button press in runAlgo.
function runAlgo_Callback(hObject, eventdata, handles)
% hObject    handle to runAlgo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd 'D:\\BSCS\\6 Semester\DIP\\project\\yale-face-database'
filenames = dir('D:\\BSCS\\6 Semester\\DIP\\project\\yale-face-database\\*.*');
global testvect;
filenames(1:2,:)=[]
% reading files from directory and converting them in a column vector and
% storing them row wise in imgvector
for i=1:length(filenames)
    currentfilename = filenames(i).name;
    img = imread(currentfilename);
     [m, n, b]=size(img);
    if b==3
        img=rgb2gray(img);
    end
    imgvector{i}=img(:);
end
len=length(imgvector);
for n=1:10
    [eigenFace,NormalizedFace,average_face]=getEigenFaces(imgvector,img,n);
    [weightTrain]=getTrainingWeights(eigenFace,NormalizedFace,len);
    [weightTest]= getTestWeights(average_face,eigenFace,testvect);
    for j=1:length(weightTrain)
        dist(j)=norm(weightTest-weightTrain(:,j));
    end
    [mindist index]=min(dist);
end
axes(handles.res1);
imshow(imread(filenames(index).name));
function [eigenFace,NormalizedFace,average_face]=getEigenFaces(imgvector,img,numeig)
    %finding average face by sumation of all the images divided by total  no of
    %images
    len=length(imgvector);
    numofimages=length(cell2mat(imgvector));
    [m,n]=size(img);
    sum=double(zeros(m*n,1));
    for i=1:len
        sum=sum+double(cell2mat(imgvector(i)));
    end
    average_face=sum/numofimages;
     NormalizedFace=[];
     for i=1:len
         difftemp=double(cell2mat(imgvector(i)))-average_face;
         NormalizedFace=[NormalizedFace difftemp];
     end
     %calculating eigenvectors
    covar_matrix=double(transpose(NormalizedFace))*double(NormalizedFace);
    [eigenVect D]=eigs(covar_matrix,numeig);
    %calculation of eigen face
    eigenFace=double(NormalizedFace)*eigenVect;

function [weightTrain]=getTrainingWeights(eigenFace,NormalizedFace,len)
%calulating weights of trainging images
    for i=1:len
        temp=double(NormalizedFace(:,i));
        weightTrain(:,i)=double(eigenFace)'*temp;
    end

function [weightTest]= getTestWeights(average_face,eigenFace,testvect)
    %for test img
    testvect=double(testvect)-average_face;
    weightTest=double(eigenFace)'*testvect;


