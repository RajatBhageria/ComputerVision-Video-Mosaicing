% File name: mymosaic.m
% Author:
% Date created:

function [img_mosaic] = mymosaic(img_input)
% Input:
%   img_input is a cell array of color images (HxWx3 uint8 values in the
%   range [0,255])
%
% Output:
% img_mosaic is the output mosaic

% m = total number of frames in the video 
% n = 3 if the number of input videos is 3 
[m,n] = size(img_input); 

max_pts = 300; 

%% Loop over all the images 
for i = 1:m 
    %% Find the image 
    img1 = img_input{i,1};
    img2 = img_input{i,2};
    img3 = img_input{i,3};

    %% find corners for image 
    cimg = corner_detector(img); 

    %% Do adaptive non max supression 
    [y,x,rmax] = anms(cimg,max_pts); 

    %% Find the feature descriptors
    [descs] = feat_desc(img,x,y); 

    %% Find match between last two images
    [match] = feat_desc(descs1,descs2);
end