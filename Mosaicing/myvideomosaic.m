function [video_mosaic] = myvideomosaic(img_mosaic)
% INPUT: img_mosaic is an mx1 cell array of all the image files 

% OUTPUT: video_mosaic is the video file in .avi format

h_avi = VideoWriter('finalVideo.avi', 'Uncompressed AVI');
h_avi.FrameRate = 10;
h_avi.open();

for i = 1:size(img_mosaic,1)
    writeVideo(h_avi,uint8(img_mosaic{i}))
end 

close(h_avi);

%%CHECK!!! 
video_mosaic = h_avi.path; 

end

