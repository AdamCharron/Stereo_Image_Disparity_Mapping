function [Id] = stereo_disparity_better(Il, Ir, bbox)
%
%  Id = STEREO_DISPARITY_BEST(Il, Ir, bbox) computes a stereo disparity image 
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
sigma = 6;             % For gaussian blur
window_size = 10;       % On either side of midpoint, 2*window_size+1 total size
max_disparity = 64;  % Max amount a pixel could have shifted
[map1, map2] = meshgrid(-window_size:window_size, -window_size:window_size);
gauss = exp(-(map1.^2+map2.^2)/(2*sigma^2));

% Convert to grayscale
Il = rgb2gray(Il);
Ir = rgb2gray(Ir);

% Pad images so that we can easily perfrom convolution without going out of
% bounds
Il_pad = im2double(padarray(Il,[window_size,window_size], 'replicate'));
Ir_pad = im2double(padarray(Ir,[window_size,window_size], 'replicate'));

Id = ones(size(Il));
for r = 1:size(Il,1)       % 1 to 375
    for c = 1:size(Il,2)    % 1 to 450
        % Perform local matching
        % Check for pixel matches between the 2 images, for all Il pixels
        % across disparity values ranging from 0 to 63 (as per the dataset
        % provided). Sum Absolute Difference acts as the similarity measure
        % of subwindows for comparison
        % Winner-Take-All approach to determining a best match
        sub_Il = Il_pad(r:r+2*window_size, c:c+2*window_size);  % Create window
        disp_matrix = [100000000, 1];      % Assign default value in case the window shifting runs the coordinates off the image
        for disp = 0:(max_disparity-1)
            if (c-disp) < 1     % Window shifting ran coords off the image
                break
            else
                % For debugging
                debug = 0;
                if (c > 5000) && (r > 18)
                    debug = 1;
                end
                if (c >= bbox(1,1)) && (c <= bbox(1,2)) && (debug == 1)
                    subplot(1,2,1), imshow(Il_pad)
                    rectangle('Position',[c,r,2*window_size,2*window_size], 'EdgeColor','r');
                    hold on;
                    subplot(1,2,2), imshow(Ir_pad)                
                    hold on;
                    rectangle('Position',[c-disp,r,2*window_size,2*window_size], 'EdgeColor','y');
                end
                    
                sub_I2 = Ir_pad(r:r+2*window_size, c-disp:c+2*window_size-disp);
                SAD = abs(sub_Il - sub_I2);
                gauss_val = sum(sum(gauss*SAD));
                if gauss_val < disp_matrix(1)
                    disp_matrix = [gauss_val;disp+1];
                    if debug == 1
                        fprintf('New min for r:%d c:%d at d=%d and gauss_val=%f\n', r, c, disp+1, gauss_val)
                        q = 1;
                    end
                end
            end
        end
        % Set the disparity image value at this coord to be minimum-
        % Gaussian-sum-yielding disparity value
        Id(r,c) = disp_matrix(2);
    end
end
% Convert to unsigned int, scaled from 0-64
Id = uint8(Id);

% Return only the horizontal boudning box region of Id (as per function
% requirements)
Id = Id(:, bbox(1,1):bbox(1,2));
end