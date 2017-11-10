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
[m,~] = size(img_input); 

max_pts = 300; 

img_mosaic = cell(m,1); 

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
    [y1,x1,~] = anms(cimg1,max_pts);
    [y2,x2,~] = anms(cimg2,max_pts); 
    [y3,x3,~] = anms(cimg3,max_pts); 

    %% Find the feature descriptors
    [descs1] = feat_desc(img1,x1,y1); 
    [descs2] = feat_desc(img2,x2,y2); 
    [descs3] = feat_desc(img3,x3,y3); 

    %% Find match between last two images
    [match1_2] = feat_match(descs1,descs2);
    [match3_2] = feat_match(descs3,descs2);
    
    %% take the matches and the xs and ys of the matches 
    index = (1:size(x1,1))';
    sourceIndexesOfMatched = index(match1_2~=0); 
    destIndexesOfMatched = match1_2(sourceIndexesOfMatched); 
    matchedX1 = x1(sourceIndexesOfMatched); 
    matchedYI = y1(sourceIndexesOfMatched); 
    matchedX2 = x2(destIndexesOfMatched);
    matchedY2 = y2(destIndexesOfMatched); 
    
    %% RANSAC 
    thresh = 10; 
    [H_12,inlier_ind_12] = ransac_est_homography(matchedX1,matchedYI,matchedX2,matchedY2,thresh); 
    [H_32,inlier_ind_23] = ransac_est_homography(x3,y3,x2,y2,thresh);
    
    %% Do Warping 
    leftWarped = imwarp(img1, projective2d(H_12)); 
    rightWarped = imwarp(img3, projective2d(H_32)); 
    
    %% Stitch all the images togther
    mosaic = [leftWarped img2 rightWarped]; 
    
    %% Add to the output 
    img_mosaic{i} = mosaic; 
end