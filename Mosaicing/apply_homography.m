% File name: apply_homography.m
% Author:
% Date created:

function [X, Y] = apply_homography(H, x, y)
% Input:
%   H : 3*3 homography matrix, refer to setup_homography
%   x : the column coords vector, n*1, in the source image
%   y : the column coords vector, n*1, in the source image

% Output:
%   X : the column coords vector, n*1, in the destination image
%   Y : the column coords vector, n*1, in the destination image

% Write Your Code Here

coordinates = [x'; y'; ones(size(x,1),1)'];
outputPoints = H * coordinates; 

x = outputPoints(1,:)';
y = outputPoints(2,:)';
Z = outputPoints(3,:)';

X = x./Z; 
Y = y./Z;

end