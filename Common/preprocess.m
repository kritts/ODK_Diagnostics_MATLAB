currentfilename = imagefiles(i).name
currentimage = imread(strcat(pathFiles,'\',currentfilename));

% Erode and dilate the image 
se = strel('ball',1,1);
currentimage = imdilate(currentimage, se);
currentimage = imerode(currentimage, se);

% % Original image
%   figure(1 + i * nfiles)  % Numbering ensures figures are not overwritten
%   imshow(currentimage)
%   title('Original Image')

% Blue Data
blueChannel = currentimage(:, :, 1);

% Increase contrast
blueChannel = imadjust(blueChannel);

% New dimensions
[height,width]=size(blueChannel);
widthLeft = round(width / 8);
widthRight = round(width * 7/8);
heightTop = round(height * 3/8);
heightBottom = round(height * 7/8);

% Roughly cropped photo, red channel & cropped
regionOfInterestRed = blueChannel(heightTop:heightBottom, widthLeft:widthRight);
croppedImage = currentimage(heightTop:heightBottom, widthLeft:widthRight, :);

 % Original image, cropped
  figure(2 + i * nfiles)
  imshow(croppedImage)
  title('Original Image After a Rough Crop')

% Black and white
levelRed = graythresh(regionOfInterestRed);
bwRed = im2bw(regionOfInterestRed, levelRed);
  

% % Original image, cropped
figure(3 + i * nfiles)
imshow(bwRed)
title('Original Image, Cropped - B&W')
