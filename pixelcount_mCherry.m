function [TotalPixels, TotalPixels_AA] = pixelcount_mCherry(CS_results)
%function to count total number of pixels and alpha-actinin pixels for zline images
%channel: mCherry
Folder_path = CS_results.zline_path{1}; %extract folder path of images
Image_num = length(CS_results.zline_images); %determine total number of images
TotalPixels_image = zeros(1,Image_num); %initialize variable
ColoredPixels = zeros(1,Image_num); %initialize variable
for i=1:Image_num
    Image_filename = CS_results.zline_images{i}; %extract filename of image
    Image_path = [Folder_path Image_filename]; %combine folder path and filename to create absolute path
    Image_read = imread(Image_path); %read image
    [rows, columns, colorchannels] = size(Image_read); %determine total number of vertical and horizontal pixels
    TotalPixels_image(i) = rows*columns; %total number of pixels (black + colored)
    if colorchannels == 1
    BlackPixels = Image_read(:,:,1) == 0;
    elseif colorchannels == 3
    BlackPixels = Image_read(:,:,1) == 0 & Image_read(:,:,2) == 0 & Image_read(:,:,3) == 0;
    end
    numBlackPixels = sum(BlackPixels(:)); %number of black pixels
    ColoredPixels(i) = TotalPixels_image(i) - numBlackPixels; %number of colored pixels (alpha-actinin pixels)
    clear Image_filename Image_path Image_read TotalPixels BlackPixels numBlackPixels rows columns colorchannels
end
TotalPixels = sum(TotalPixels_image); %total number of pixels
TotalPixels_AA = sum(ColoredPixels); %total number of colored pixels
end