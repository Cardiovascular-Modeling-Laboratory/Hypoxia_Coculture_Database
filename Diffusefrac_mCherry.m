function [Overlay_int, AA_int] = Diffusefrac_mCherry(CS_results,Drive_letter)
%function to calculate diffuse fraction from zline detect analyzed images
%channel: mCherry
Folder_path = CS_results.zline_path{1}; %extract folder path of images from CS summary file
Split_folder_path = split(Folder_path,':');
Partial_folder_path = Split_folder_path{2}; %folder path without drive letter
Complete_folder_path = [Drive_letter ':' Partial_folder_path]; %reconstruct path to account for possible changes in drive letters 
Image_num = length(CS_results.zline_images); %determine total number of images
for i=1:Image_num
    Image_filename = CS_results.zline_images{i}; %extract filename of image
    Image_path = [Complete_folder_path Image_filename]; %combine folder path and filename to create absolute path
    Image_read = imread(Image_path); %read image mCherry image
    
    Image_filename_zsk_partial = extractBefore(Image_filename,'.tif'); %extract partial name of zline skeleton image
    Image_filename_zsk = [Image_filename_zsk_partial '_SkeletonMasked.tif']; %full name of zline skeleton image
    Folder_path_zsk = [Complete_folder_path '/' Image_filename_zsk_partial '/']; %folder path of zline skeleton image
    Image_path_zsk = [Folder_path_zsk Image_filename_zsk]; %absolute path of zline skeleton image
    Image_read_zsk = imread(Image_path_zsk); %read zline skeleton image
    
    [rows, columns, colorchannels] = size(Image_read); %determine total number of vertical and horizontal pixels and number of color channels
    Overlay_image = im2double(Image_read).*im2double(Image_read_zsk);
    if colorchannels == 1
        Overlay_int_image(i) = sum(sum(Overlay_image)); %integral of pixel color values over overlaid image
        AA_int_image(i) = sum(sum(Image_read))./double(max(max(Image_read))); %integral of pixel color values over mCherry image normalized by maximum pixel value
    else
        Overlay_int_image(i) = sum(sum(sum(Overlay_image)));
        AA_int_image(i) = sum(sum(sum(Image_read)))./double(max(max(max(Image_read)))); %integral of pixel color values over mCherry image normalized by maximum pixel value
    end
    
    clear Image_filename Image_path Image_read rows columns colorchannels Image_read_zsk Image_filename_zsk Image_path_zsk Overlay_image
end
Overlay_int = sum(Overlay_int_image);
AA_int = sum(AA_int_image);
end