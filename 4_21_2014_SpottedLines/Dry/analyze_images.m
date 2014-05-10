% Written by Krittika D'Silva (kdsilva@uw.edu)
% Code to automatically process one immunoassay test. 

clear all, close all, clc

%%%%%%%%%%%%%%%%
% Paths
%%%%%%%%%%%%%%%%
% Path to common functions
addpath('C:\Users\KDsilva\Dropbox\Images_of_Device\Common');
% Path of photos
path = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\*.jpg';
% Path of directory
pathFiles = pwd;
% Directory in which processed images will be saved
dirProcessedImages = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\Processed';


%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%
% Location of blue color standard
blueRectCS = [120,80,100,50];
% Location of black color standard
blackRectCS = [120,185,100,50];
% Location of white color standard
whiteRectCS = [120,295,100,50];
% Location of QR code
qrCode = [730,30,360,350];
% Location of test strip
testStrip = [530,110,185,150];
% Point at which we're calculating the slope & area under the curve
minValue = 0.97;


imagefiles = dir(path);
nfiles = length(imagefiles);    % Number of files found

tic;

for i = 1                       % Files to process
    run('C:\Users\KDsilva\Dropbox\Images_of_Device\Common\analyzeOneTest.m');  
end

toc