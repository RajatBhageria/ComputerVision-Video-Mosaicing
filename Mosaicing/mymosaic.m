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
    [H_12,inlier_ind_12] = ransac_est_homography(matchedX1_12,matchedY1_12,matchedX2_12,matchedY2_12,thresh); 
    % ransac from 3 to 2 
    [H_32,inlier_ind_23] = ransac_est_homography(matchedX3_32,matchedY3_32,matchedX2_32,matchedY2_32,thresh);
    
    %% Do Warping for left image 
    [r,c,n] = size(img1);
    [img1_x,img1_y] = meshgrid(1:c,1:r);
    H_12 = (1/H_12(3,3))*H_12;
    [warped_img1_x, warped_img1_y] = apply_homography(H_12, img1_x(:), img1_y(:));
    
    %round the coordinates  
    warped_img1_x = round(warped_img1_x); 
    warped_img1_y = round(warped_img1_y); 
    
    %take care of negatives 
    leftWarped = zeros(size(img1));
    warped_img1_x(warped_img1_x<1) = 1;
    warped_img1_y(warped_img1_y<1) = 1; 
    
    for ind = 1:size(warped_img1_x(:),1)
        leftWarped(warped_img1_y(ind), warped_img1_x(ind),:) = img1(img1_y(ind), img1_x(ind),:);
    end
    leftWarped = uint8(leftWarped); 
    
    %% do warping for the right image 
    [r,c,n] = size(img3);
    [img3_x,img3_y] = meshgrid(1:c,1:r);
    H_32 = (1/H_32(3,3))*H_32;
    [warped_img3_x, warped_img3_y] = apply_homography(H_32, img3_x(:), img3_y(:));
    
    %round the coordinates  
    warped_img3_x = round(warped_img3_x); 
    warped_img3_y = round(warped_img3_y); 
    
    %take care of negatives 
    rightWarped = zeros(size(img3));
    warped_img3_x(warped_img3_x<1) = 1;
    warped_img3_y(warped_img3_y<1) = 1; 
    
    for ind = 1:size(warped_img3_x(:),1)
        rightWarped(warped_img3_y(ind), warped_img3_x(ind),:) = img3(img3_y(ind), img3_x(ind),:);
    end
    rightWarped = uint8(rightWarped); 
    
    %% Stitch all the images togther
    mosaic = [leftWarped img2 rightWarped]; 
    
    %% Add to the output 
    img_mosaic{i} = mosaic; 
end