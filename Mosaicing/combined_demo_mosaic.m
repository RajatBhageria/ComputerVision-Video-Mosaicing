% File name: combined_demo_mosaic.m
% Author: Kashish Gupta and Rajat Bhageria
% Date created: 11/7/17

function [output_video] = combined_demo_mosaic(video1, video2, video3)
%first need to pre-process these videos in order to make sure they are the
%same number of frames

video1 = 'videos/Video1.mp4';
video2 = 'videos/Video2.mp4';
video3 = 'videos/Video3.mp4';


numFrames = 30;
all_frames = cell(30,3);

v1 = VideoReader(video1);
v1.CurrentTime = 0;

v2 = VideoReader(video2);
v2.CurrentTime = 0;

v3 = VideoReader(video3);
v3.CurrentTime = 0;


for i = 1:numFrames
    all_frames{i, 1} = readFrame(v1);
    readFrame(v1);
    all_frames{i, 2} = readFrame(v2);
    readFrame(v2);
    all_frames{i, 3} = readFrame(v3);
    readFrame(v3);
end

img_mosaic = mymosaic(all_frames);
output_video = myvideomosaic(img_mosaic);
