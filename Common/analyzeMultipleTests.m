run('C:\Users\KDsilva\Dropbox\Images_of_Device\Common\preprocess.m');

% Find circles
[centers, radii, metric] = imfindcircles(bwRed, [10 20], 'ObjectPolarity','dark', 'Sensitivity', 0.90);
if (length(centers) > 4)
    [centersUpdated, radiiUpdated] = findFourFiducials(centers, radii, metric);
    
    % Rough crop, with circles on original image found
    % figure(4 + i * nfiles)
    % imshow(croppedImage)
    % size(croppedImage)
    % hold on
    % viscircles(centersUpdated, radiiUpdated,'EdgeColor','b');
    % title('Original Image, Cropped - With Fiducials Found')
    
    % New points to be used for spatial transformation
    topLeftXY = roundn(centersUpdated(1,:), 1);
    bottomRightXY = roundn(centersUpdated(4,:), 1);
    
    % Creating a rectangle with the points
    newCenters = [topLeftXY; bottomRightXY(1), topLeftXY(2); topLeftXY(1), bottomRightXY(2); bottomRightXY];
    
    % Creating transformation matrix from new points
    [TFORM] = cp2tform (centersUpdated, newCenters , 'linear conformal');
    
    % Transforming image, new possible functions: imtransform & imwarp
    transformedImage = imtransform(croppedImage, TFORM);
    
    % Transformed image, with new cirles (before resizing)
    % figure(5 + i * nfiles)
    % hold on
    % imshow(transformedImage);
    % viscircles(newCenters, radiiUpdated,'EdgeColor','b');
    % title('Original Image, Cropped- Transformed using Fiducials Found')
    
    % Crop the image to the new coordinates
    transformedImageCropped = imcrop(transformedImage, [topLeftXY(1), topLeftXY(2), bottomRightXY(1) - topLeftXY(1), bottomRightXY(2) - topLeftXY(2)]);
    
    % figure(6 + i * nfiles)
    % imshow(transformedImageCropped);
    
    % Resizing (NaN: MATLAB computers number of # columns automatically
    %           to preserve the image aspect ratio)
    resizedImage = imresize(transformedImageCropped, [380, 1100], 'bilinear');
    
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
    firstRectangle = imcrop(resizedImage, testStrip1);
    secondRectangle = imcrop(resizedImage,testStrip2);
    thirdRectangle = imcrop(resizedImage,testStrip3);
    fourthRectangle = imcrop(resizedImage,testStrip4);
    fifthRectangle = imcrop(resizedImage,testStrip5);
    
    [height, width, dimensions]=size(firstRectangle);
    centerWidth = round(width/2);
    
    % Looks specifically at the red color channel
    avgIntensityOne = firstRectangle(1:height, centerWidth-20:centerWidth+20, 1);
    avgIntensityOne = mean(avgIntensityOne, 2);
    minOne = min(avgIntensityOne);
    
    avgIntensityTwo = secondRectangle(1:height, centerWidth-20:centerWidth+20, 1);
    avgIntensityTwo = mean(avgIntensityTwo, 2);
    minTwo = min(avgIntensityTwo);
    
    avgIntensityThree = thirdRectangle(1:height, centerWidth-20:centerWidth+20, 1);
    avgIntensityThree = mean(avgIntensityThree, 2);
    minThree = min(avgIntensityThree);
    
    avgIntensityFour = fourthRectangle(1:height, centerWidth-20:centerWidth+20, 1);
    avgIntensityFour = mean(avgIntensityFour, 2);
    minFour = min(avgIntensityFour);
    
    avgIntensityFive = fifthRectangle(1:height, centerWidth-20:centerWidth+20, 1);
    avgIntensityFive = mean(avgIntensityFive, 2);
    minFive = min(avgIntensityFive);
    
    
    % Plot normalized test strip intensities
    [height,width]=size(firstRectangle);
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
    
    % Returns the first index where the intensity of the test strip is
    % less than the minimum value
    pt1 = find(avgNormalizedOne   < minValue, 1);
    pt2 = find(avgNormalizedTwo   < minValue, 1);
    pt3 = find(avgNormalizedThree < minValue, 1);
    pt4 = find(avgNormalizedFour  < minValue, 1);
    pt5 = find(avgNormalizedFive  < minValue, 1);
    
    [slope_up_1, slope_down_1, sum_under_curve_1] = getSlopeAndArea(avgNormalizedOne,   pt1, minValue);
    [slope_up_2, slope_down_2, sum_under_curve_2] = getSlopeAndArea(avgNormalizedTwo,   pt2, minValue);
    [slope_up_3, slope_down_3, sum_under_curve_3] = getSlopeAndArea(avgNormalizedThree, pt3, minValue);
    [slope_up_4, slope_down_4, sum_under_curve_4] = getSlopeAndArea(avgNormalizedFour,  pt4, minValue);
    [slope_up_5, slope_down_5, sum_under_curve_5] = getSlopeAndArea(avgNormalizedFive,  pt5, minValue);
    
    
    % Write data to a csv file
    header = ['Name of file,', 'Blue Color Standard,', 'Black Color Standard,', 'White Color Standard,', 'Raw data Min- 1,', 'Raw data- Min 2,', 'Raw data- Min 3,', 'Raw data- Min 4,', 'Raw data- Min 5,', 'Normalized data- Min 1,', 'Normalized data- Min 2,', 'Normalized data- Min 3,', 'Normalized data- Min 4,', 'Normalized data- Min 5,','Slope Down- 1,','Slope Down- 2,','Slope Down- 3,','Slope Down- 4,','Slope Down- 5,','Slope Up- 1,','Slope Up- 2,','Slope Up- 3,','Slope Up- 4,','Slope Up- 5,', 'Sum under curve- 1,', 'Sum under curve- 2,', 'Sum under curve- 3,', 'Sum under curve- 4,', 'Sum under curve- 5,'];
    outid = fopen(strcat(pathFiles,'\Processed_Data\','Analysis_Updated_Algorithm', date, '.csv'), 'at');
    fprintf(outid, '\n%s\n', datestr(now));
    fprintf(outid, '%s\n', header);
    
    if(sum_under_curve_1 ~= -1 & sum_under_curve_2 ~= -1 & sum_under_curve_3 ~= -1 & sum_under_curve_4 ~= -1 & sum_under_curve_5 ~= -1)
        % Color standards
        rectangle('Position', blueRectCS,  'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', blackRectCS, 'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', whiteRectCS, 'LineWidth', 3, 'EdgeColor', 'r')
        
        % QR code
        rectangle('Position', qrCode, 'LineWidth', 3, 'EdgeColor', 'r')
        
        % Tests
        rectangle('Position', testStrip1, 'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', testStrip2, 'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', testStrip3, 'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', testStrip4, 'LineWidth', 3, 'EdgeColor', 'r')
        rectangle('Position', testStrip5, 'LineWidth', 3, 'EdgeColor', 'r')
        
        
        % New resized image
        processedImg1 = figure(7 + i * nfiles);
        hold on
        imshow(resizedImage);
        title_1 = strcat('Original Image, Cropped After Transformation: ',strrep(currentfilename,'_','\_'));
        title(title_1);
        
        figureTitle = strcat('ProcessedImg_', '1_', currentfilename);
        saveas(processedImg1,fullfile(dirProcessedImages, figureTitle),'jpg');
        
        % Plot images of 5 tests
        processedImage2 =  figure(8 + i * nfiles);
        title_2 = strcat('Transformed Image: ',strrep(currentfilename,'_','\_'));
        suptitle(title_2);
        hold on
        subplot(4,2,[1,2])
        imshow(resizedImage);
        subplot(4,2,3)
        imshow(firstRectangle)
        subplot(4,2,5)
        imshow(secondRectangle)
        subplot(4,2,7)
        imshow(thirdRectangle)
        subplot(4,2,4)
        imshow(fourthRectangle)
        subplot(4,2,6)
        imshow(fifthRectangle)
        
        strFirst = strcat('ProcessedImg_', '2_', currentfilename);
        saveas(processedImage2,fullfile(dirProcessedImages, strFirst),'jpg');
        
        %     % Plot test strip intensities
        %     averageIntensities = figure(9 + i * nfiles);
        %     title_3 = strcat('Transformed Image - Original: ',strrep(currentfilename,'_','\_'));
        %     suptitle(title_3);
        %     hold on
        %     subplot(4,2,[1,2])
        %     imshow(resizedImage);
        %     subplot(4,2,3)
        %     plot(1:length(avgIntensityOne),avgIntensityOne)
        %     subplot(4,2,5)
        %     plot(1:length(avgIntensityTwo),avgIntensityTwo)
        %     subplot(4,2,7)
        %     plot(1:length(avgIntensityThree),avgIntensityThree)
        %     subplot(4,2,4)
        %     plot(1:length(avgIntensityFour),avgIntensityFour)
        %     subplot(4,2,6)
        %     plot(1:length(avgIntensityFive), avgIntensityFive)
        %
        %     avgIntensitiesStr = strcat('ProcessedImg_', '3_', currentfilename);
        %     saveas(averageIntensities,fullfile(dirProcessedImages, avgIntensitiesStr),'jpg');
        
        combinedStr = strcat('Transformed Image - Normalized Test Strip Intensity: ',strrep(currentfilename,'_','\_'));
        
        processedImage = figure(10 + i * nfiles);
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
        
        normalizedStr = strcat('ProcessedImg_','4_', currentfilename);
        saveas(processedImage,fullfile(dirProcessedImages, normalizedStr),'jpg');
        
        outputarray = [blue_CS, black_CS, white_CS, minOne, minTwo, minThree, minFour, minFive, minNorm1, minNorm2, minNorm3, minNorm4, minNorm5, slope_up_1, slope_up_2, slope_up_3, slope_up_4, slope_up_5,slope_down_1,slope_down_2,slope_down_3,slope_down_4,slope_down_5, sum_under_curve_1, sum_under_curve_2, sum_under_curve_3, sum_under_curve_4, sum_under_curve_5];
        fprintf(outid, '%s', currentfilename);
        fprintf(outid, '%s', ',');
        for i = 1:length(outputarray)
            outputarray(i);
            fprintf(outid, '%i,', outputarray(i));
        end
        
    else
        string_to_print=strcat('Invalid tests, file: ',currentfilename);
        disp(string_to_print)
        fprintf(outid, '%s', 'Error processing image');
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
