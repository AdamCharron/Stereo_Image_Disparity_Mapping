function [N, rms] = stereo_disparity_score(It, Id)
% STEREO_DISPARITY_SCORE Compute score for accuracy of disparity image.
%
%   STEREO_DISPARITY_SCORE(It, Id) computes the RMS error between a true
%   (known) disparity map and a map produced by a stereo matching algorithm.
%   This can be used to evaluate the accuracy of the matching algorithm.
%
%   Inputs:
%   -------
%    It  - Ground truth disparity image, m x n pixels, greyscale.
%    Id  - Computer disparity image, m x n pixels, greyscale.
%
%   Outputs:
%   --------
%    N    - Number of valid depth measurements.
%    rms  - Test score, RMS error between Id and It.

It = double(It);
Id = double(Id);

mask = (It ~= 0);    % Ignore points where ground truth is unknown.
N = sum(mask(:));    % Total number of valid pixels.

rms = sum(sum((Id(mask) - It(mask)).^2));
rms = sqrt(rms/N);