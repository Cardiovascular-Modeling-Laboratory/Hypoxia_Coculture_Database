function [TotalPixels, TotalPixels_AA] = Confluency_background(CS_results,Drive_letter,CS_path)
%function to count total number of pixels and alpha-actinin pixels for zline images
%channel: mCherry
Folder_path = CS_results.zline_path{1}; %extract folder path of images from CS summary file
Split_folder_path = split(Folder_path,':');
Partial_folder_path = Split_folder_path{2}; %folder path without drive letter
Complete_folder_path = [Drive_letter ':' Partial_folder_path]; %reconstruct path to account for possible changes in drive letters 
if exist(Complete_folder_path,'dir') == 7
else %change path to reflect CS summary file path if directory cannot be located
    clear Partial_folder_path Complete_folder_path
    [Split_CS_path, ~, ~] = fileparts(CS_path);
    Partial_folder_path = Split_CS_path;
    Complete_folder_path = [Drive_letter ':' Partial_folder_path '\']; %reconstruct path to account for possible changes in drive letters
end
Image_num = length(CS_results.zline_images); %determine total number of images

TotalPixels_image = zeros(1,Image_num); %initialize variable
ColoredPixels = zeros(1,Image_num); %initialize variable
for i=1:Image_num
    Image_filename = CS_results.zline_images{i}; %extract filename of image
    Image_path = [Complete_folder_path Image_filename]; %combine folder path and filename to create absolute path
    Image_filename_partial = extractBefore(Image_filename,'.tif'); %extract partial name of image without extension to locate subfolder
    Image_filename_background = [Image_filename_partial '_OrientationAnalysis.mat']; %full name of orientation analysis .mat file
    Folder_path_background = [Complete_folder_path Image_filename_partial '\']; %folder path of orientation analysis .mat file
    Image_path_background = [Folder_path_background Image_filename_background]; %absolute path of orientation analysis .mat file
    load(Image_path_background,'im_struct')
    Background = im_struct.background;
    [rows, columns] = size(Background); %determine total number of vertical and horizontal pixels
    TotalPixels_image(i) = rows*columns; %total number of pixels (black + white)
    Background_double = double(Background);
    ColoredPixels(i) = length(find(Background_double==1));
    clear Image_filename Image_path Image_filename_partial Image_filename_background Folder_path_background Image_path_background TotalPixels_image BlackPixels numBlackPixels rows columns colorchannels Background Background_double
end
TotalPixels = sum(TotalPixels_image); %total number of pixels
TotalPixels_AA = sum(ColoredPixels); %total number of colored pixels
end