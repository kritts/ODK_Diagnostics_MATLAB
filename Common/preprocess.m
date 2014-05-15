currentfilename = imagefiles(i).name
currentimage = imread(strcat(pathFiles,'\',currentfilename));
size(currentimage);

% % Original image
%   figure(1 + i * nfiles)  % Numbering ensures figures are not overwritten
%   imshow(currentimage)
%   title('Original Image')

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
%   figure(2 + i * nfiles)
%   imshow(croppedImage)
%   title('Original Image After a Rough Crop')
%
% Black and white
levelRed = graythresh(regionOfInterestRed);
bwRed = im2bw(regionOfInterestRed, levelRed);

% % Original image, cropped
%   figure(3 + i * nfiles)
%   imshow(bw_red)
%   title('Original Image, Cropped - B&W')
