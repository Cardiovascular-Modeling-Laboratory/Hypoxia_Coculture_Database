function [Overlay_int, AA_int] = Diffusefrac_mCherry_NEW(CS_results,Drive_letter,CS_path)
%function to calculate diffuse fraction from zline detect analyzed images
%channel: mCherry
Folder_path = CS_results.zline_path{1}; %extract folder path of images from CS summary file
Split_folder_path = split(Folder_path,':');
Partial_folder_path = Split_folder_path{2}; %folder path without drive letter
Complete_folder_path = [Drive_letter ':' Partial_folder_path]; %reconstruct path to account for possible changes in drive letters 
if exist(Complete_folder_path,'dir') == 7
else %change path to reflect CS summary file path if image cannot be located
    clear Partial_folder_path Complete_folder_path
    [Split_CS_path, ~, ~] = fileparts(CS_path);
    Partial_folder_path = Split_CS_path;
    Complete_folder_path = [Drive_letter ':' Partial_folder_path '\']; %reconstruct path to account for possible changes in drive letters
end
Image_num = length(CS_results.zline_images); %determine total number of images
for i=1:Image_num
    Image_filename = CS_results.zline_images{i}; %extract filename of image
    Image_path = [Complete_folder_path Image_filename]; %combine folder path and filename to create absolute path
    Image_read = imread(Image_path); %read image mCherry image
    Image_filename_zsk_partial = extractBefore(Image_filename,'.tif'); %extract partial name of zline skelton image
    Image_filename_zsk = [Image_filename_zsk_partial '_SkeletonMasked.tif']; %full name of zline skeleton image
    Folder_path_zsk = [Complete_folder_path Image_filename_zsk_partial '\']; %folder path of zline skeleton image
    Image_path_zsk = [Folder_path_zsk Image_filename_zsk]; %absolute path of zline skeleton image
    Image_read_zsk = imread(Image_path_zsk); %read zline skeleton image
    Image_path_background = [Folder_path_zsk Image_filename_zsk_partial '_OrientationAnalysis.mat'];
    load(Image_path_background,'im_struct')
    Background = im_struct.background;

    [rows, columns, colorchannels] = size(Image_read); %determine total number of vertical and horizontal pixels and number of color channels
    Overlay_image = double(Image_read).*double(Image_read_zsk).*double(Background); %overlay of original image, z-line skeleton, and background estimation image (from _OrientationAnalysis output)
    Original_image = double(Image_read).*double(Background); %overaly of original image and background estimation image
    if colorchannels == 1
        Overlay_int_image(i) = sum(sum(Overlay_image)); %integral of pixel color values over overlaid image
        AA_int_image(i) = sum(sum(Original_image)); %integral of pixel color values over mCherry overlaid with estimated background
    else
        Overlay_int_image(i) = sum(sum(sum(Overlay_image)));
        AA_int_image(i) = sum(sum(sum(Original_image))); %integral of pixel color values over mCherry image normalized by maximum pixel value
    end
    
    clear Image_filename Image_path Image_read rows columns colorchannels Image_read_zsk Image_filename_zsk Image_path_zsk Overlay_image Original_image Image_path_background im_struct Background
end
Overlay_int = sum(Overlay_int_image);
AA_int = sum(AA_int_image);
end