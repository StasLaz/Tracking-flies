% Tracking flies
% Files
%   readfr                  - Read video file and show one frame or find flies in the frame using masks from regionsmasks.m
%   regionsmasks            - Define masks for color zones in the video.
%   delete_masks            - Delete regions in existing mask and writes a new file.
%   colorpref               - Find number of flies in the video in each color (defined by masks) every minute.
%   trackfly                - Finds positions of flies in the video every minute. Outputs coordinates in .xls file for each video.
%   plot_colorpref          - Plot fractions of flies in each color versus time.
%   preference_calculation  - Averages mutliple days fractions into one day and calculates average blue avoidance.
