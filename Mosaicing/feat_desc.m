% File name: feat_desc.m
% Author:
% Date created:

function [descs] = feat_desc(img, x, y)
% Input:
%    img = double (height)x(width) array (grayscale image) with values in the
%    range 0-255
%    x = nx1 vector representing the column coordinates of corners
%    y = nx1 vector representing the row coordinates of corners

% Output:
%   descs = 64xn matrix of double values with column i being the 64 dimensional
%   descriptor computed at location (xi, yi) in im


%define row as y and col as x for simpler debugging 
col = x;
row = y;

numCorners = size(x,1); 

%define a windowSize in each direction. 
windowSize = 20; 

%pad the image so that when we find 40x40 windows, we do not go out of
%bounds
img = padarray(img,[windowSize, windowSize],0,'both');

%initialize the final output
descs = zeros(64,numCorners); 

%find a feature descriptor for each of the corners
for corner = 1:numCorners
    corneri = row(corner); 
    cornerj = col(corner); 
        
    %find the windowSizex2 by windowSizex2 window 
    upI = corneri - windowSize;
    downI = corneri + windowSize-1; 
    
    leftJ = cornerj - windowSize; 
    rightJ = cornerj + windowSize-1; 
    
    %select the window 
    window = img(upI:downI, leftJ:rightJ); 
    
    %do a gaussian filter of window 
    gaussian = imgaussfilt(window);
    
    %Sample every 5th point in the 40x40 window to get an 8x8
    resized = gaussian(1:5:end, 1:5:end);
    
    %resize the 8x8 patch into a column 
    column  = resized(:); 
    
    %put the 64x1 column for each feature into the return matrix. 
    descs(:,corner) = column; 
end 

end