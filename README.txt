In MATLAB, wrote a script that computes a stereo disparity image from two images.
Two different implementations were used, first using a sum-squared-difference cost function across windows along the disparity lines ("stereo_disparity_fast"), and then using sum-absolute-difference with gaussian blurring ("stereo_disparity_better").

The images were pulled from datasets created by Daniel Scharstein, Alexander Vandenberg-Rodes, and Rick Szeliski, and consisting of high-resolution stereo sequences with complex geometry and pixel-accurate ground-truth disparity data. They can be found at: http://vision.middlebury.edu/stereo/data/scenes2003/ 

Initial image files are included in images/cones_image_02.png and images/cones_image_06.png.
"Golden" image files are included in images/cones_disp_true_02.png and images/cones_disp_true_06.png (normalized in images/cones_disp_02.png and images/cones_disp_06.png)

RMS scores between golden and output are computed in matlab/stereo_disparity_score.m
tester.m is the main function