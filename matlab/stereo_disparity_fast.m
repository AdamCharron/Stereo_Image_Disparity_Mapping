function [Id] = stereo_disparity_fast(Il, Ir, bbox)
% STEREO_DISPARITY_FAST Fast stereo correspondence algorithm.
%
%  Id = STEREO_DISPARITY_FAST(Il, Ir, bbox) computes a stereo disparity image
%  from left stereo image Il and right stereo image Ir.
%
%  Inputs:
%  -------
%   Il    - Left stereo image, m x n pixels, colour or greyscale.
%   Ir    - Right stereo image, m x n pixels, colour or greyscale.
%   bbox  - Bounding box, relative to left image, top left corner, bottom
%           right corner (inclusive). Width is v.
%
%  Outputs:
%  --------
%   Id  - Disparity image (map), m x v pixels, greyscale.

% Parameters
window_size = 14;    % On either side of midpoint, 2*window_size+1 total size
max_disparity = 64;  % Max amount a pixel could have shifted

% Convert to grayscale
Il = rgb2gray(Il);
Ir = rgb2gray(Ir);

% Pad images so that we can easily perfrom convolution without going out of
% bounds
Il_pad = im2double(padarray(Il,[window_size,window_size], 'replicate'));
Ir_pad = im2double(padarray(Ir,[window_size,window_size], 'replicate'));

Id = ones(size(Il));
for r = 1:size(Il,1)       % 1 to 375
    for c = 1:size(Il,2)   % 1 to 450
        % Perform local matching
        % This will be done by going over every pixel in Il and checking to
        % see if it matches with the same corresponding pixel in Ir. This
        % check happens for all pixel disparities ranging from 0 (in place)
        % to 64 (max disparity as per problem statement). A window will be
        % formed around the Il pixel, and the iterating Ir pixel with
        % disparity offset, and then Sum Squared Difference will be
        % computed over the entirety of both windows. The disparity that 
        % yields the smallest SSD value will be the assigned as a pixel 
        % value to the Id image at the coords of the Il pixel.
        sub_Il = Il_pad(r:r+2*window_size, c:c+2*window_size);  % Create window
        disp_matrix = [100000, 1];      % Assign default value in case the window shifting runs the coordinates off the image
        for disp = 0:(max_disparity-1)
            if (c-disp) < 1     % Window shifting ran coords off the image
                break
            else
                % Use SSD to compare the two image windows
                % Store SSD val and its disparity val if it is a new min
                sub_I2 = Ir_pad(r:r+2*window_size, c-disp:c+2*window_size-disp);
                SSD = sum(sum((sub_Il - sub_I2).^2));
                if SSD < disp_matrix(1)
                    disp_matrix = [SSD;disp+1]; 
                end
            end
        end
        % Set the disparity image value at this coord to be minimum-
        % SSD-yielding disparity value
        Id(r,c) = disp_matrix(2);
    end
end
% Convert to unsigned int, scaled from 0-64
Id = uint8(Id);

% Return only the horizontal boudning box region of Id (as per function
% requirements)
Id = Id(:, bbox(1,1):bbox(1,2));
end