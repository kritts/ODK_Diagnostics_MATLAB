% Written by Krittika D'Silva (kdsilva@uw.edu)

% Code to automatically process immunoassay tests.
% Modified version of original code - assumes only one strip on each test

clear all, close all, clc

% Path of photos
path = 'C:\Users\KDsilva\Dropbox\Images_of_Device\UpdatedDesign4_28_14\*.jpg';
% Point at which we're calculating the slope & area under the curve
minValue = 0.97;
% Directory in which processed images will be saved
dirProcessedImages = 'C:\Users\KDsilva\Dropbox\Images_of_Device\UpdatedDesign4_28_14\Processed';

imagefiles = dir(path);
nfiles = length(imagefiles);    % Number of files found

tic;

for i = 1             % Files to process
    currentfilename = imagefiles(i).name
    currentimage = imread(currentfilename);
    size(currentimage);
    
    % % Original image
    %figure(1 + i * nfiles)  % Numbering ensures figures are not overwritten
    %imshow(currentimage)
    %title('Original Image')
    
    % Blue Data
    blueChannel = currentimage(:, :, 1);
    
    % New dimensions
    [height,width]=size(blueChannel);
    widthLeft = round(width / 8);
    widthRight = round(width * 7/8);
    heightTop = round(height * 3/8);
    heightBottom = round(height * 3/4);
    
    % Roughly cropped photo, red channel & cropped
    regionOfInterestRed = blueChannel(heightTop:heightBottom, widthLeft:widthRight);
    croppedImage = currentimage(heightTop:heightBottom, widthLeft:widthRight, :);
    
    % % Original image, cropped
    %figure(2 + i * nfiles)
    %imshow(croppedImage)
    %title('Original Image After a Rough Crop')
    
    % Black and white
    levelRed = graythresh(regionOfInterestRed);
    bwRed = im2bw(regionOfInterestRed, levelRed);
    
    % Original image, cropped
    %figure(3 + i * nfiles)
    %imshow(bwRed)
    %title('Original Image, Cropped - B&W')
    
    % Find circles
    [centers, radii, metric] = imfindcircles(bwRed, [10 20], 'ObjectPolarity','dark', 'Sensitivity', 0.90);
    
    if (length(centers) > 4)
        [centersUpdated, radiiUpdated] = findFourFiducials(centers, radii, metric);
        
        % % Rough crop, with circles on original image found
        %figure(4 + i * nfiles)
        %imshow(croppedImage)
        %size(croppedImage)
        %hold on
        %viscircles(centersUpdated, radiiUpdated,'EdgeColor','b');
        %title('Original Image, Cropped - With Fiducials Found')
        
        % New points to be used for spatial transformation
        topLeftXY = roundn(centersUpdated(1,:), 1);
        bottomRightXY = roundn(centersUpdated(4,:), 1);
        
        % Creating a rectangle with the points
        newCenters = [topLeftXY; bottomRightXY(1), topLeftXY(2); topLeftXY(1), bottomRightXY(2); bottomRightXY];
        
        % Creating transformation matrix from new points
        [TFORM] = cp2tform (centersUpdated, newCenters , 'linear conformal');
        
        % Transforming image, new possible functions: imtransform & imwarp
        transformedImage = imtransform(croppedImage, TFORM);
        
        % % Transformed image, with new cirles (before resizing)
        %figure(5 + i * nfiles)
        %hold on
        %imshow(transformedImage);
        %viscircles(newCenters, radiiUpdated,'EdgeColor','b');
        %title('Original Image, Cropped- Transformed using Fiducials Found')
        
        % Crop the image to the new coordinates
        transformedImageCropped = imcrop(transformedImage, [topLeftXY(1), topLeftXY(2), bottomRightXY(1) - topLeftXY(1), bottomRightXY(2) - topLeftXY(2)]);
        
        %figure(6 + i * nfiles)
        %imshow(transformedImageCropped);
        
        % Resizing (NaN: MATLAB computers number of # columns automatically
        %           to preserve the image aspect ratio)
        resizedImage = imresize(transformedImageCropped, [380, 1100], 'bilinear');
        
        size(resizedImage);
        
        % % New resized image
        processedImg1 = figure(7 + i * nfiles);
        hold on
        imshow(resizedImage);
        imshow(resizedImage);
        title_1 = strcat('Original Image, Cropped After Transformation: ',strrep(currentfilename,'_','\_'))
        title(title_1);
        
        % Location of blue color standard
        blueRectCS = [70,60,70,50];
        % Location of black color standard
        blackRectCS = [190,60,70,50];
        % Location of white color standard
        whiteRectCS = [300,60,70,50];
        % Location of test strip
        testStrip = [480,150,185,150];
        
        % Color standards
        rectangle('Position', blueRectCS, 'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position', blackRectCS,'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position', whiteRectCS, 'LineWidth',3, 'EdgeColor', 'r')
        
        % QR code
        rectangle('Position',[20,140,360,300],'LineWidth',3, 'EdgeColor', 'r')
        
        % Tests
        rectangle('Position', testStrip,'LineWidth',3, 'EdgeColor', 'r')
        
        % Blue color standard
        RGB_blue_CS =  mean((mean(imcrop(resizedImage, blueRectCS))));
        blue_CS = mean(RGB_blue_CS);
        
        % Black color standard
        RGB_black_CS = mean((mean(imcrop(resizedImage, blackRectCS))));
        black_CS = mean(RGB_black_CS);
        
        % White color standard
        RGB_white_CS = mean((mean(imcrop(resizedImage, whiteRectCS))));
        white_CS = mean(RGB_white_CS);
        
        % Location of 5 tests on the strip
        firstRectangle = imcrop(resizedImage,testStrip);
        figureTitle = strcat('ProcessedImg_', '1_', currentfilename);
        
        saveas(processedImg1,fullfile(dirProcessedImages, figureTitle),'jpg');
        
        % Plot image of test
        processedImage2 =  figure(8 + i * nfiles);
        title_2 = strcat('Transformed Image: ',strrep(currentfilename,'_','\_'));
        suptitle(title_2);
        hold on
        subplot(2,2,[1,2])
        imshow(resizedImage);
        subplot(2,2,[3,4])
        imshow(firstRectangle)
        
        strFirst = strcat('ProcessedImg_', '2', currentfilename);
        saveas(processedImage2,fullfile(dirProcessedImages, strFirst),'jpg');
        
        [height, width]=size(firstRectangle);
        centerWidth = round(width/2);
        
        avgIntensityOne = firstRectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityOne = mean(avgIntensityOne, 2);
        minOne = min(avgIntensityOne);
        
        % Plot test strip intensities
        averageIntensities = figure(9 + i * nfiles);
        title_3 = strcat('Transformed Image - Original: ',strrep(currentfilename,'_','\_'));
        suptitle(title_3);
        hold on
        subplot(2,2,[1,2])
        imshow(resizedImage);
        subplot(2,2,[3,4])
        plot(1:length(avgIntensityOne), avgIntensityOne)
        
        avgIntensitiesStr = strcat('ProcessedImg_', '3_', currentfilename);
        saveas(averageIntensities,fullfile(dirProcessedImages, avgIntensitiesStr),'jpg');
        
        % Plot normalized test strip intensities
        [height,width]=size(firstRectangle);
        centerWidth = round(width/2);
        centerHeight = round(height/2);
        
        avgNormalizedOne = (avgIntensityOne - black_CS) / (white_CS - black_CS);
        minNorm1 = min(avgNormalizedOne);
        combinedStr = strcat('Transformed Image - Normalized Test Strip Intensity: ',strrep(currentfilename,'_','\_'))
        
        processedImage = figure(10 + i * nfiles);
        suptitle(combinedStr);
        hold on
        subplot(2,2,[1,2])
        imshow(resizedImage);
        subplot(2,2,[3,4])
        plot(1:length(avgIntensityOne),avgNormalizedOne)
        
        normalizedStr = strcat('ProcessedImg_','4_', currentfilename);
        saveas(processedImage,fullfile(dirProcessedImages, normalizedStr),'jpg');
        
        
        % Returns the first index where the intensity of the test strip is
        % less than the minimum value
        pt1 = find(avgNormalizedOne < minValue,1);
        
        [slope_up_1, slope_down_1, sum_under_curve_1] = getSlopeAndArea(avgNormalizedOne, pt1, minValue);
        
        header = ['Name of file,', 'Blue Color Standard,', 'Black Color Standard,', 'White Color Standard,', 'Raw data,', 'Normalized data,', 'Slope Down,','Slope Up,','Sum under curve,'];
        outid = fopen('Analysis_Updated_Algorithm_4_25.csv', 'at');
        fprintf(outid, '\n%s\n', datestr(now));
        fprintf(outid, '%s\n', header);
        outputarray = [blue_CS, black_CS, white_CS, minOne, minNorm1, slope_up_1, slope_down_1,sum_under_curve_1];
        fprintf(outid, '%s', currentfilename);
        fprintf(outid, '%s', ',');
        for i = 1:length(outputarray)
            outputarray(i);
            fprintf(outid, '%i,', outputarray(i));
        end
        fprintf(outid, '\n', '');
        fclose(outid);
        
    else
        % Less than 4 fiducials found
        figure(3)
        imshow(croppedImage)
        hold on
        viscircles(centers, radii,'EdgeColor','r');
        string_to_print=strcat('Less than 4 fiducial markers found, file: ',currentfilename);
        disp(string_to_print)
    end
end

toc