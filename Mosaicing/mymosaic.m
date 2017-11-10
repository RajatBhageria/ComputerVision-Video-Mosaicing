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

max_points = 300; 

%% Loop over all the frames
for i = 1:m 
    %% Find the image 
    img1 = img_input{i,1};
    img2 = img_input{i,2};
    img3 = img_input{i,3};

    %% find corners for image 
    cimg1 = corner_detector(img1);
    cimg2 = corner_detector(img2);
    cimg3 = corner_detector(img3);

    %% Do adaptive non max supression 
    [y1,x1,rmax1] = anms(cimg1,max_pts);
    [y2,x2,rmax2] = anms(cimg2,max_pts); 
    [y3,x3,rmax3] = anms(cimg3,max_pts); 

    %% Find the feature descriptors
    [descs1] = feat_desc(img1,x1,y1); 
    [descs2] = feat_desc(img2,x2,y2); 
    [descs3] = feat_desc(img3,x3,y3); 

    %% Find match between last two images
    [match1_2] = feat_desc(descs1,descs2);
    [match3_2] = feat_desc(descs3,descs2);
    
    %% 
end