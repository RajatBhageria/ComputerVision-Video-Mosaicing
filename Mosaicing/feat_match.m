% File name: feat_match.mfeat
% Author: Kashish Gupta and Rajat Bhageria
% Date created: 11/8/17

function [match] = feat_match(descs1, descs2)
% Input:
%   descs1 is a 64x(n1) matrix of double values
%   descs2 is a 64x(n2) matrix of double values

% Output:
%   match is n1x1 vector of integers where m(i) points to the index of the
%   descriptor in p2 that matches with the descriptor p1(:,i).
%   If no match is found, m(i) = -1

descs1 = descs1';
descs2 = descs2';

output = zeros(size(descs1, 1), 1);

[idx, d] = knnsearch(descs2, descs1, 'k', 2);

for i = 1:size(idx,1)
    if d(i,1)/d(i,2) < 0.8
        output(i) = idx(i,1);
    else
        output(i) = -1;
    end
end

match = output;

end