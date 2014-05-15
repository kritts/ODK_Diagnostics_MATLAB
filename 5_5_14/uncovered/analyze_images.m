% Written by Krittika D'Silva (kdsilva@uw.edu)
% Code to automatically process one immunoassay test. 

% Naming convention: 
% 10c_12pt_bright1
% 10: "intensity" of line - 100 darkest black
% c: covered 
% 12pt: thickness of the paper used 
% bright1: lighting conditions + test number  

clear all
close all
clc


%%%%%%%%%%%%%%%%
% Paths
%%%%%%%%%%%%%%%%
% Current directory
pathFiles = pwd;
% Path to common functions
addpath('C:\Users\KDsilva\Dropbox\Images_of_Device\Common');
% Path of photos
path = strcat(pathFiles, '\*.jpg');  
% Directory in which processed images will be saved
dirProcessedImages = strcat(pathFiles, '\Processed');   
 
%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%
% Location of blue color standard
blueRectCS = [55,60,70,50];
% Location of black color standard
blackRectCS = [170,60,70,50];
% Location of white color standard
whiteRectCS = [280,60,70,50];
% Location of QR code
qrCode = [20,125,340,240];
% Locations of test strips
testStrip1 = [455,75,210,85];
testStrip2 = [455,150,210,85];
testStrip3 = [455,220,210,85];
testStrip4 = [695,85,210,85];
testStrip5 = [695,200,210,85];


% Point at which we're calculating the slope & area under the curve
minValue = 0.97;

imagefiles = dir(path);
nfiles = length(imagefiles);    % Number of files found

% Checks if folders for processed images exist 
if(~isequal(exist(dirProcessedImages, 'dir'),7))   
    mkdir('Processed');
end
  
if(~isequal(exist(strcat(pathFiles, '\Processed\Location_Fiducials'), 'dir'),7))   
    mkdir('Processed\Location_Fiducials');
end

if(~isequal(exist(strcat(pathFiles, '\Processed\Location_Tests'), 'dir'),7))   
    mkdir('Processed\Location_Tests');
end

if(~isequal(exist(strcat(pathFiles, '\Processed\Normalized_Tests'), 'dir'),7))   
    mkdir('Processed\Normalized_Tests');
end

if(~isequal(exist(strcat(pathFiles, '\Processed_Data'), 'dir'),7))   
    mkdir('Processed_Data');
end
tic;

for i = 9:nfiles                     % Files to process
    run('C:\Users\KDsilva\Dropbox\Images_of_Device\Common\analyzeMultipleTests.m');  
end

toc