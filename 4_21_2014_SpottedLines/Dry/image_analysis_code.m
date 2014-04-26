% Krittika D'Silva

clear all, close all, clc

% Path of photos
path = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\*.jpg';
% Point at which we're calculating the slope & area under the curve
minValue = 0.97;
% Directory in which processed images will be saved
dir_processed_images = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\Processed';

imagefiles = dir(path);
nfiles = length(imagefiles);    % Number of files found

tic;

for i = 1:nfiles
    currentfilename = imagefiles(i).name
    currentimage = imread(currentfilename);
    size(currentimage);
    % % Original image
    %   figure(1 + i * nfiles)
    %   imshow(currentimage)
    %   title('Original Image')
    
    % Blue Data
    blueChannel = currentimage(:,:,1);
    
    % New dimensions
    [height,width]=size(blueChannel);
    width_left = round(width/8);
    width_right = round(width*7/8);
    height_top = round(height*3/8);
    height_bottom = round(height*3/4);
    
    % Roughly cropped photo, red channel & cropped
    regionOfInterest_red = blueChannel(height_top:height_bottom,width_left:width_right);
    croppedImage = currentimage(height_top:height_bottom,width_left:width_right, :);
    
    % % Original image, cropped
    %   figure(2 + i * nfiles)
    %   imshow(croppedImage)
    %   title('Original Image After a Rough Crop')
    %
    % Black and white
    level_red = graythresh(regionOfInterest_red);
    bw_red = im2bw(regionOfInterest_red, level_red);
    
    % % Original image, cropped
    %   figure(3 + i * nfiles)
    %   imshow(bw_red)
    %   title('Original Image, Cropped - B&W')
    
    % Find circles
    [centers, radii,metric] = imfindcircles(bw_red,[10 20],'ObjectPolarity','dark', 'Sensitivity',0.90);
    
    if (length(centers) > 4)
        [centersUpdated,radiiUpdated] = findFourFiducials(centers,radii,metric);
        
        % Rough crop, with circles on original image found
        %       figure(4 + i * nfiles)
        %       imshow(croppedImage)
        %       size(croppedImage)
        %       hold on
        %       viscircles(centersUpdated, radiiUpdated,'EdgeColor','b');
        %       title('Original Image, Cropped - With Fiducials Found')
        
        % New points to be used for spatial transformation
        topLeftXY = roundn(centersUpdated(1,:),1);
        bottomRightXY = roundn(centersUpdated(4,:),1);
        
        % Creating a rectangle with the points
        newCenters = [topLeftXY; bottomRightXY(1), topLeftXY(2); topLeftXY(1), bottomRightXY(2); bottomRightXY];
        
        % Creating transformation matrix from new points
        [TFORM] = cp2tform (centersUpdated, newCenters , 'linear conformal');
        
        % Transforming image, new possible functions: imtransform & imwarp
        transformedImage = imtransform(croppedImage, TFORM);
        
        % Transformed image, with new cirles (before resizing)
        %       figure(5 + i * nfiles)
        %       hold on
        %       imshow(transformedImage);
        %       viscircles(newCenters, radiiUpdated,'EdgeColor','b');
        %       title('Original Image, Cropped- Transformed using Fiducials Found')
        
        % Crop the image to the new coordinates
        transformedImageCropped = imcrop(transformedImage,[topLeftXY(1),topLeftXY(2),bottomRightXY(1) - topLeftXY(1),bottomRightXY(2) - topLeftXY(2)]);
        
        %       figure(6 + i * nfiles)
        %       imshow(transformedImageCropped);
        
        % Resizing (NaN: MATLAB computers number of # columns automatically
        %           to preserve the image aspect ratio)
        resizedImage = imresize(transformedImageCropped, [380, 1100],'bilinear');
        
        size(resizedImage);
        
        % New resized image
        plt1 =  figure(7 + i * nfiles)
        hold on
        imshow(resizedImage);
        title('Original Image, Cropped After Transformation');
        
        % Color standards
        rectangle('Position',[120,80,100,50],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[120,185,100,50],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[120,295,100,50],'LineWidth',3, 'EdgeColor', 'r')
        
        % QR code
        rectangle('Position',[730,30,360,350],'LineWidth',3, 'EdgeColor', 'r')
        
        % Tests
        rectangle('Position',[325,85,185,70],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[325,170,185,70],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[325,250,185,70],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[530,90,185,80],'LineWidth',3, 'EdgeColor', 'r')
        rectangle('Position',[530,240,185,80],'LineWidth',3, 'EdgeColor', 'r')
        
        
        % Blue color standard
        RGB_blue_CS =  mean((mean(imcrop(resizedImage,[120,80,100,50]))));
        blue_CS = mean(RGB_blue_CS);
        
        % Black color standard
        RGB_black_CS = mean((mean(imcrop(resizedImage,[120,185,100,50]))));
        black_CS = mean(RGB_black_CS);
        
        % White color standard
        RGB_white_CS = mean((mean(imcrop(resizedImage,[120,295,100,50]))));
        white_CS = mean(RGB_white_CS);
        
        % Location of 5 tests on the strip
        first_rectangle = imcrop(resizedImage,[325,85,185,70]);
        second_rectangle = imcrop(resizedImage,[325,170,185,70]);
        third_rectangle = imcrop(resizedImage,[325,250,185,70]);
        fourth_rectangle = imcrop(resizedImage,[530,90,185,80]);
        fifth_rectangle = imcrop(resizedImage,[530,240,185,80]);
        
        str1 = strcat('ProcessedImg_', 'Rectanges_Location', currentfilename);
        
        saveas(plt1,fullfile(dir_processed_images, str1),'jpg');
        
        % Plot images of 5 tests
        plt =  figure(i+12)
        suptitle('Transformed Image - All 5 Tests');
        hold on
        subplot(4,2,[1,2])
        imshow(resizedImage);
        
        subplot(4,2,3)
        imshow(first_rectangle)
        
        subplot(4,2,5)
        imshow(second_rectangle)
        
        subplot(4,2,7)
        imshow(third_rectangle)
        
        subplot(4,2,4)
        imshow(fourth_rectangle)
        
        subplot(4,2,6)
        imshow(fifth_rectangle)
        
        
        strFirst = strcat('ProcessedImg_', 'Location', currentfilename);
        
        saveas(plt,fullfile(dir_processed_images, strFirst),'jpg');
        
        [height,width]=size(first_rectangle);
        centerWidth = round(width/2);
        
        avgIntensityOne = first_rectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityOne = mean(avgIntensityOne, 2);
        avgIntensityTwo = second_rectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityTwo = mean(avgIntensityTwo, 2);
        avgIntensityThree = third_rectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityThree = mean(avgIntensityThree, 2);
        avgIntensityFour = fourth_rectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityFour = mean(avgIntensityFour, 2);
        avgIntensityFive = fifth_rectangle(1:height, centerWidth-20:centerWidth+20);
        avgIntensityFive = mean(avgIntensityFive, 2);
        
        
        minOne = min(avgIntensityOne);
        minTwo = min(avgIntensityTwo);
        minThree = min(avgIntensityThree);
        minFour = min(avgIntensityFour);
        minFive = min(avgIntensityFive);
        
        
        % Plot test strip intensities
        %       figure(i+100)
        %       suptitle('Transformed Image - 5 Test Strip Intensities');
        %       hold on
        %       subplot(4,2,[1,2])
        %       imshow(resizedImage);
        %
        %       subplot(4,2,3)
        %       plot(1:length(avgIntensityOne),avgIntensityOne)
        %
        %       subplot(4,2,5)
        %       plot(1:length(avgIntensityTwo),avgIntensityTwo)
        %
        %       subplot(4,2,7)
        %       plot(1:length(avgIntensityThree),avgIntensityThree)
        %
        %       subplot(4,2,4)
        %       plot(1:length(avgIntensityFour),avgIntensityFour)
        %
        %       subplot(4,2,6)
        %       plot(1:length(avgIntensityFive), avgIntensityFive)
        
        % Plot normalized test strip intensities
        [height,width]=size(first_rectangle);
        centerWidth = round(width/2);
        centerHeight = round(height/2);
        
        
        avgNormalizedOne = (avgIntensityOne - black_CS) / (white_CS - black_CS);
        avgNormalizedTwo = (avgIntensityTwo - black_CS) / (white_CS - black_CS);
        avgNormalizedThree = (avgIntensityThree - black_CS) / (white_CS - black_CS);
        avgNormalizedFour = (avgIntensityFour - black_CS) / (white_CS - black_CS);
        avgNormalizedFive = (avgIntensityFive - black_CS) / (white_CS - black_CS);
        
        minNorm1 = min(avgNormalizedOne);
        minNorm2 = min(avgNormalizedTwo);
        minNorm3 = min(avgNormalizedThree);
        minNorm4 = min(avgNormalizedFour);
        minNorm5 = min(avgNormalizedFive);
        
        
        combinedStr = strcat('Transformed Image - 5 Normalized Test Strip Intensities: ',strrep(currentfilename,'_','\_'))
        
        
        h = figure(i+16)
        
        suptitle(combinedStr);
        hold on
        subplot(4,2,[1,2])
        imshow(resizedImage);
        
        subplot(4,2,3)
        plot(1:length(avgIntensityOne),avgNormalizedOne)
        
        subplot(4,2,5)
        plot(1:length(avgIntensityTwo),avgNormalizedTwo)
        
        subplot(4,2,7)
        plot(1:length(avgIntensityThree),avgNormalizedThree)
        
        subplot(4,2,4)
        plot(1:length(avgIntensityFour),avgNormalizedFour)
        
        subplot(4,2,6)
        plot(1:length(avgIntensityFive), avgNormalizedFive)
        str = strcat('ProcessedImg_', currentfilename);
        
        saveas(h,fullfile(dir_processed_images, str),'jpg');
        
        
        % Returns the first index where the intensity of the test strip is
        % less than the minimum value
        pt1 = find(avgNormalizedOne < minValue,1);
        pt2 = find(avgNormalizedTwo < minValue,1);
        pt3 = find(avgNormalizedThree < minValue,1);
        pt4 = find(avgNormalizedFour < minValue,1);
        pt5 = find(avgNormalizedFive < minValue,1);
        
        if(~isempty(pt1))
            slope_up_1 = (avgNormalizedOne(pt1 + 5) - avgNormalizedOne(pt1))/5;
            pt1_down = find(avgNormalizedOne > minValue);
            pt1_down_index = find(pt1_down > pt1,1);
            pt1_d = pt1_down(pt1_down_index);
            slope_down_1 = (avgNormalizedOne(pt1_d) - avgNormalizedOne(pt1_d - 5))/5;
            sum_under_curve_1 = sum(avgNormalizedOne(pt1:pt1_d));
        else
            slope_up_1 = 0;
            slope_down_1 = 0;
            sum_under_curve_1 = 0;
        end
        
        if(~isempty(pt2))
            slope_up_2 = (avgNormalizedTwo(pt2 + 5) - avgNormalizedTwo(pt2))/5;
            pt2_down = find(avgNormalizedTwo > minValue);
            pt2_down_index = find(pt2_down > pt2,1);
            pt2_d = pt2_down(pt2_down_index);
            slope_down_2 = (avgNormalizedTwo(pt2_d) - avgNormalizedTwo(pt2_d - 5))/5;
            sum_under_curve_2 = sum(avgNormalizedTwo(pt2:pt2_d));
        else
            slope_up_2 = 0;
            slope_down_2 = 0;
            sum_under_curve_2 = 0;
        end
        
        if(~isempty(pt3))
            slope_up_3 = (avgNormalizedThree(pt3 + 5) - avgNormalizedThree(pt3))/5;
            pt3_down = find(avgNormalizedThree > minValue);
            pt3_down_index = find(pt3_down > pt3,1);
            pt3_d = pt3_down(pt3_down_index);
            slope_down_3 = (avgNormalizedThree(pt3_d) - avgNormalizedThree(pt3_d - 5))/5;
            sum_under_curve_3 = sum(avgNormalizedThree(pt3:pt3_d));
        else
            slope_up_3 = 0;
            slope_down_3 = 0;
            sum_under_curve_3 = 0;
        end
        
        if(~isempty(pt4))
            slope_up_4 = (avgNormalizedFour(pt4 + 5) - avgNormalizedFour(pt4))/5;
            pt4_down = find(avgNormalizedFour > minValue);
            pt4_down_index = find(pt4_down > pt4,1);
            pt4_d = pt4_down(pt4_down_index);
            slope_down_4 = (avgNormalizedFour(pt4_d) - avgNormalizedFour(pt4_d - 5))/5;
            sum_under_curve_4 = sum(avgNormalizedFour(pt4:pt4_d));
        else
            slope_up_4 = 0;
            slope_down_4 = 0;
            sum_under_curve_4 = 0;
        end
        
        if(~isempty(pt5))
            slope_up_5 = (avgNormalizedFive(pt5 + 5) - avgNormalizedFive(pt5))/5;
            pt5_down = find(avgNormalizedFive > minValue);
            pt5_down_index = find(pt5_down > pt5,1);
            pt5_d = pt5_down(pt5_down_index);
            slope_down_5 = (avgNormalizedFive(pt5_d) - avgNormalizedFive(pt5_d - 5))/5;
            sum_under_curve_5 = sum(avgNormalizedFive(pt5:pt5_d));
        else
            slope_up_5 = 0;
            slope_down_5 = 0;
            sum_under_curve_5 = 0;
        end
        
        
        
        
        header = ['Name of file,', 'Blue Color Standard,', 'Black Color Standard,', 'White Color Standard,', 'Raw data Min- 1,', 'Raw data- Min 2,', 'Raw data- Min 3,', 'Raw data- Min 4,', 'Raw data- Min 5,', 'Normalized data- Min 1,', 'Normalized data- Min 2,', 'Normalized data- Min 3,', 'Normalized data- Min 4,', 'Normalized data- Min 5,','Slope Down- 1,','Slope Down- 2,','Slope Down- 3,','Slope Down- 4,','Slope Down- 5,','Slope Up- 1,','Slope Up- 2,','Slope Up- 3,','Slope Up- 4,','Slope Up- 5,', 'Sum under curve- 1,', 'Sum under curve- 2,', 'Sum under curve- 3,', 'Sum under curve- 4,', 'Sum under curve- 5,'];
        outid = fopen('Analysis_Updated_Algorithm.csv', 'at');
        fprintf(outid, '\n%s\n', datestr(now));
        fprintf(outid, '%s\n', header);
        outputarray = [blue_CS, black_CS, white_CS, minOne, minTwo, minThree, minFour, minFive, minNorm1, minNorm2, minNorm3, minNorm4, minNorm5, slope_up_1, slope_up_2, slope_up_3, slope_up_4, slope_up_5,slope_down_1,slope_down_2,slope_down_3,slope_down_4,slope_down_5, sum_under_curve_1, sum_under_curve_2, sum_under_curve_3, sum_under_curve_4, sum_under_curve_5];
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