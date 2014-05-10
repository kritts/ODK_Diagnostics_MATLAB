% Written by Krittika D'Silva (kdsilva@uw.edu)
% Code to automatically process one immunoassay test. 

clear all, close all, clc

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
blueRectCS = [70,60,70,50];
% Location of black color standard
blackRectCS = [190,60,70,50];
% Location of white color standard
whiteRectCS = [300,60,70,50];
% Location of QR code
qrCode = [20,140,360,300]
% Location of test strip
testStrip = [480,150,185,150];
% Point at which we're calculating the slope & area under the curve
minValue = 0.97;

imagefiles = dir(path);
nfiles = length(imagefiles);    % Number of files found

% Checks if folders for processed images exist 
if(~isequal(exist(dirProcessedImages, 'dir'),7))   
    mkdir('Processed');
end

if(~isequal(exist(strcat(pathFiles, '\Processed_Data'), 'dir'),7))   
    mkdir('Processed_Data');
end

tic;

for i = 26                     % Files to process
    run('C:\Users\KDsilva\Dropbox\Images_of_Device\Common\analyzeOneTest.m');  
end

toc