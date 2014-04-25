clear all, close all, clc
% Remember to change this path * 
path = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\*.jpg';     
imagefiles = dir(path);
% Number of files found
nfiles = length(imagefiles);    

save_proc_images_to = 'C:\Users\KDsilva\Dropbox\Images_of_Device\4_21_2014_SpottedLines\Dry\Processed';


tic;

for i = 1:nfiles
    currentfilename = imagefiles(i).name
    currentimage = imread(currentfilename);
    size(currentimage);
%   %Original image
%    figure(1)
%    imshow(currentimage)
%    title('Original Image')
    
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
 
%    % Original image, cropped 
%     figure(2)
%     imshow(croppedImage)
%     title('Original Image After a Rough Crop')
%     
    % Black and white
    level_red = graythresh(regionOfInterest_red);
    bw_red = im2bw(regionOfInterest_red, level_red);     
 
%     % Original image, cropped 
%     figure(3)
%     imshow(bw_red)
%     title('Original Image, Cropped - B&W')
    
    % Find circles
    [centers, radii,metric] = imfindcircles(bw_red,[10 20],'ObjectPolarity','dark', 'Sensitivity',0.90);
         
    if (length(centers) > 4)
        [centersUpdated,radiiUpdated] = findFourFiducials(centers,radii,metric);
        % Rough crop, with circles on original image found
%        figure(i)
%        imshow(croppedImage)
%        size(croppedImage)
%        hold on
%        viscircles(centersUpdated, radiiUpdated,'EdgeColor','b');
%        title('Original Image, Cropped - With Fiducials Found')
        
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
%        figure(4) 
%        hold on
%        imshow(transformedImage);   
%        viscircles(newCenters, radiiUpdated,'EdgeColor','b');
%        title('Original Image, Cropped- Transformed using Fiducials Found')
        % Crop the image to the new coordinates 
        transformedImageCropped = imcrop(transformedImage,[topLeftXY(1),topLeftXY(2),bottomRightXY(1) - topLeftXY(1),bottomRightXY(2) - topLeftXY(2)]);
         
%        figure(5)
%        imshow(transformedImageCropped);   
      
        % Resizing (NaN: MATLAB computers number of # columns automatically
        %           to preserve the image aspect ratio)
        resizedImage = imresize(transformedImageCropped, [380, 1100],'bilinear'); 
   
%      New resized image 
       transformed =  figure(i+100)
       hold on
       imshow(resizedImage);  
       title_1 = strcat('Original Image, Cropped After Transformation: ',strrep(currentfilename,'_','\_'))
       title(title_1);
        
%       Color standards
       rectangle('Position',[120,80,100,50],'LineWidth',3, 'EdgeColor', 'r')  
       rectangle('Position',[120,185,100,50],'LineWidth',3, 'EdgeColor', 'r')  
       rectangle('Position',[120,295,100,50],'LineWidth',3, 'EdgeColor', 'r')  
          
%       QR code
       rectangle('Position',[730,30,360,350],'LineWidth',3, 'EdgeColor', 'r')  

%      Tests 
       rectangle('Position',[530,110,185,150],'LineWidth',3, 'EdgeColor', 'r')   
        
      
      % Blue color standard
      RGB_blue_CS =  mean((mean(imcrop(resizedImage,[120,80,100,50]))));
      blue_CS = mean(RGB_blue_CS);
      
      % Black color standard
      RGB_black_CS = mean((mean(imcrop(resizedImage,[120,185,100,50]))));
      black_CS = mean(RGB_black_CS);
      
      % White color standard
      RGB_white_CS = mean((mean(imcrop(resizedImage,[120,295,100,50]))));  
      white_CS = mean(RGB_white_CS); 
       
      fourth_rectangle = imcrop(resizedImage,[[530,110,185,150]]); 
      
      trasnformedImageStr = strcat('ProcessedImg_', '1_', currentfilename); 
      saveas(transformed,fullfile(save_proc_images_to, trasnformedImageStr),'jpg');
        
      % Plot images of 5 tests 
      croppedImages =  figure(i+200) 
      title_2 = strcat('Transformed Image: ',strrep(currentfilename,'_','\_'));
      suptitle(title_2); 
      hold on
      subplot(2,2,[1,2]) 
      imshow(resizedImage);  
      subplot(2,2,[3,4]) 
      imshow(fourth_rectangle) 
      
      croppedImagesStr = strcat('ProcessedImg_', '2_', currentfilename);  
      saveas(croppedImages,fullfile(save_proc_images_to, croppedImagesStr),'jpg');
 
      [height,width]=size(fourth_rectangle); 
      centerWidth = round(width/2); 
       
      avgIntensityFour = fourth_rectangle(1:height, centerWidth-20:centerWidth+20);
      avgIntensityFour = mean(avgIntensityFour, 2);   
      minFour = min(avgIntensityFour); 
      
%      Plot test strip intensities 
      averageIntensities = figure(i+300)
      title_3 = strcat('Transformed Image - Original: ',strrep(currentfilename,'_','\_'));
      suptitle(title_3);  
      hold on
      subplot(2,2,[1,2])
      imshow(resizedImage);  
      
      subplot(2,2,[3,4])
      plot(1:length(avgIntensityFour),avgIntensityFour)  
      
      avgIntensitiesStr = strcat('ProcessedImg_', '3_', currentfilename);  
      saveas(averageIntensities,fullfile(save_proc_images_to, avgIntensitiesStr),'jpg');
 

%      Plot normalized test strip intensities 
      [height,width]=size(avgIntensityFour); 
      centerWidth = round(width/2);
      centerHeight = round(height/2); 
      
      avgNormalizedFour = (avgIntensityFour - black_CS) / (white_CS - black_CS);  
      minNorm4 = min(avgNormalizedFour); 
      
      combinedStr = strcat('Transformed Image - 5 Normalized Test Strip Intensities: ',strrep(currentfilename,'_','\_'))
       
      normalized = figure(i+400)  
      suptitle(combinedStr); 
      hold on
      subplot(2,2,[1,2])
      imshow(resizedImage);   
      subplot(2,2,[3,4])  
      plot(1:length(avgIntensityFour),avgNormalizedFour)   
      
      normalizedStr = strcat('ProcessedImg_','4_', currentfilename);
      saveas(normalized,fullfile(save_proc_images_to, normalizedStr),'jpg');


      % Point at which we're calculating the slope & area under the curve
      minValue = 0.97;
      
      % Returns the first index where the intensity of the test strip is 
      % less than the minimum value  
      pt4 = find(avgNormalizedFour < minValue,1); 
       
      
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
      
        
        header = ['Name of file,', 'Blue Color Standard,', 'Black Color Standard,', 'White Color Standard,', 'Raw data,', 'Normalized data,', 'Slope Down,','Slope Up,','Sum under curve,'];  
        outid = fopen('Analysis_Updated_Algorithm_4_25.csv', 'at');
        fprintf(outid, '\n%s\n', datestr(now));
        fprintf(outid, '%s\n', header);
        outputarray = [blue_CS, black_CS, white_CS, minFour, minNorm4, slope_up_4, slope_down_4,sum_under_curve_4];
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