% File name: corner_detector.m
% Author:
% Date created:

function [cimg] = corner_detector(img)
% Input:
% img is an image

% Output:
% cimg is a corner matrix

% Write Your Code Here

%convert the image to grayscale 
img = rgb2gray(img); 

%find the Harris features 
points = detectHarrisFeatures(img); 

%create a new return image with initial values of zero 
cimg = zeros(size(img)); 

%find the coordinates of all the corners 
coordinates = round(points.Location);

%find the values of the corners 
strength = points.Metric; 

%put the strengths into the new image 
cimg(coordinates(:,2),coordinates(:,1)) = strength(:);


end