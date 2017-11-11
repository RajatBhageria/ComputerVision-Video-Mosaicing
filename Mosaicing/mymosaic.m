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

max_pts = 500; 

img_mosaic = cell(m,1); 

%% Loop over all the frames
for i = 1:m 
    %% Find the image 
    img1 = img_input{i,1};
    img2 = img_input{i,2};
    img3 = img_input{i,3};
    
    %% Grayscale the image 
    img1G = rgb2gray(img1);
    img2G = rgb2gray(img2);
    img3G = rgb2gray(img3);

    %% find corners for image 
    cimg1 = corner_detector(img1G);
    cimg2 = corner_detector(img2G);
    cimg3 = corner_detector(img3G);

    %% Do adaptive non max supression 
    [y1,x1,~] = anms(cimg1,max_pts);
    [y2,x2,~] = anms(cimg2,max_pts); 
    [y3,x3,~] = anms(cimg3,max_pts); 

    %% Find the feature descriptors
    [descs1] = feat_desc(img1G,x1,y1); 
    [descs2] = feat_desc(img2G,x2,y2); 
    [descs3] = feat_desc(img3G,x3,y3); 

    %% Find match between last two images
    [match1_2] = feat_match(descs1,descs2);
    [match3_2] = feat_match(descs3,descs2);
    
    %% take the matches and the xs and ys of the matches 
    index = (1:size(x1,1))';
    
    %for the first warp 
    sourceIndexesOfMatched_12 = index(match1_2~=-1); 
    destIndexesOfMatched_12 = match1_2(sourceIndexesOfMatched_12); 
    matchedX1_12 = x1(sourceIndexesOfMatched_12); 
    matchedY1_12 = y1(sourceIndexesOfMatched_12); 
    matchedX2_12 = x2(destIndexesOfMatched_12);
    matchedY2_12 = y2(destIndexesOfMatched_12); 
    
    %for the second warp 
    sourceIndexesOfMatched_32 = index(match3_2~=-1); 
    destIndexesOfMatched_32 = match3_2(sourceIndexesOfMatched_32); 
    matchedX3_32 = x3(sourceIndexesOfMatched_32); 
    matchedY3_32 = y3(sourceIndexesOfMatched_32); 
    matchedX2_32 = x2(destIndexesOfMatched_32);
    matchedY2_32 = y2(destIndexesOfMatched_32); 
    
    %% RANSAC 
    thresh = 5; 
    % ransac from 1 to 2 
    %WHEN WANG NO HOLES BUT NEGATIVE 
    [H_12,inlier_ind_12] = ransac_est_homography(matchedX1_12,matchedY1_12,matchedX2_12,matchedY2_12,thresh); 
    %WHEN WANT HOLES BUT TRANSFORMATION CORRECG %[H_12,inlier_ind_12] = ransac_est_homography(matchedX1_12,matchedY1_12,matchedX2_12,matchedY2_12,thresh); 
    % ransac from 3 to 2 
    [H_32,inlier_ind_23] = ransac_est_homography(matchedX3_32,matchedY3_32,matchedX2_32,matchedY2_32,thresh);
    
    %% Make sure H33 is 1 
    H_12 = (1/H_12(3,3))*H_12;
    H_32 = (1/H_32(3,3))*H_32;

    %% Transform the two images 
    tformLeft = projective2d(H_12'); 
    leftWarped = imwarp(img1, tformLeft); 
    
    tformRight = projective2d(H_32'); 
    rightWarped = imwarp(img3, tformRight); 
    
    %% Stitch all the images togther 
    [n,m] = size(img2); 
    
        
    
    %% Add to the output 
    img_mosaic{i} = mosaic; 
end