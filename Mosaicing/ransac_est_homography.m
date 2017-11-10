% File name: ransac_est_homography.m
% Author: Rajat Bhageria and Kashish Gupta
% Date created: Nov 8th 2017 

function [H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, thresh)
% Input:
%    y1, x1, y2, x2 are the corresponding point coordinate vectors Nx1 such
%    that (y1i, x1i) matches (x2i, y2i) after a preliminary matching
%    thresh is the threshold on distance used to determine if transformed
%    points agree

% Output:
%    H is the 3x3 matrix computed in the final step of RANSAC
%    inlier_ind is the nx1 vector with indices of points in the arrays x1, y1,
%    x2, y2 that were found to be inliers

% Write Your Code Here

nRANSAC = 1000; 

numFeatures = size(x1,1); 

%set a maxCost and a best Homography 
maxNumInliers = 0; 
%bestHomography = zeros(3,3); 

%initialize inlier_ind and list of all indexes 
indexes = (1:numFeatures)';
inlier_ind; 

%iterate over nRANSAC iterations 
for iter = 1:nRANSAC 
    minNumberOfPointsForHomo = 4; 
    
    %generate a list of 4 random numbers without repetition between 1 and numFeatures 
    randomNums  = randperm(numFeatures,minNumberOfPointsForHomo); 
    
    %find the four feature points X, Y for the destination
    %X and Y is a 4x1 vector 
    X = x2(randomNums); 
    Y = y2(randomNums);
    
    %find the four feature points x,y for the source 
    %x and y is a 4x1 vector 
    x = x1(randomNums); 
    y = y1(randomNums); 

    %find the homography using these four points
    homographyForSample = est_homography(X,Y,x,y); 
    
    %appply the homography.
    [XDest, YDest] = apply_homography(homographyForSample, x1, y1);
    
    %comptue the number of inliers for this iteration using SSD 
    %this line is just calculating the number of points that are within a
    %threshold distance between the actual points in our x2 and y2
    %destination feature points and the points that our homography would
    %predict. 
    numInliers = sum(((x2-XDest).^2 + (y2-YDest).^2 < thresh)==1);
        
    %if this homography leads to a lower cost than the lowest cost, set
    %lowest cost and best homography to this homography. 
    if (numInliers > maxNumInliers)
        maxNumInliers = numInliers; 
        %bestHomography = homographyForSample; 
        inlier_ind = indexes((x2-XDest).^2 + (y2-YDest).^2 < thresh);
    end 
end 
%H = bestHomography; 
H = est_homography(x1(inlier_ind),y1(inlier_ind), x2(inlier_ind), y2(inlier_ind));

end