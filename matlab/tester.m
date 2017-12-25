function junk = tester()

% Returns nothing, just a tester for various images for the two methods
% To toggle between fast and best, comment/uncomment below
clear all
close all
clc
junk = 0;

%% Image Setup

bb = load('bboxes');

% Load left and right stereo images and bounding box
bbox = bb.cones_02.bbox;
Il = im2double(imread('../images/cones_image_02.png'));
Ir = im2double(imread('../images/cones_image_06.png'));
It = imread('../images/cones_disp_true_02.png');
It = It(:, bbox(1,1):bbox(1,2));

%% Fast
%Id = stereo_disparity_fast(Il, Ir, bbox)

%% Best
Id = stereo_disparity_better(Il, Ir, bbox)

% Cones with window_Size = 14 and sigma = 6: N = 133371, rms = 3.9663
% Cones with window_Size = 12 and sigma = 6: N = 133371, rms = 4.0673
% Cones with window_Size = 12 and sigma = 4: N = 133371, rms = 4.2096
% Cones with window_Size = 10 and sigma = 6: N = 133371, rms = 4.2158
% Cones with window_Size = 8 and sigma = 6: N = 133371, rms = 4.3366

%% Check
[N, rms] = stereo_disparity_score(It, Id)

subplot(1,2,1), imshow(Id)
subplot(1,2,2), imshow(It)

% Fast:
% Cones: N = 140789, rms = 4.8314

% Best(used window_size = 10, sigma = 6):
% Cones: N = 140789, rms = 4.1253
end