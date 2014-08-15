function [ out ] = rgbd( r, g, b )
%RGBD - Returns rgb between 0 and 1 for standard rgb values
%
% SYNTAX:
%   [ [r,g,b] ] = rgbd( [240,234,222] )
%
% Description:
%
% INPUTS:
%   rgb - [r,g,b] values between 0 and 255
%
% OUTPUTS:
%   rgbd - [r,g,b] values between 0 and 1
%
% EXAMPLES:
%
% SEE ALSO: 
% 
% Author:       nick roth
% email:        nick.roth@nou-systems.com
% Matlab ver.:  8.3.0.532 (R2014a)
% Date:         14-Aug-2014
    
out = [r/255 g/255 b/255];
      
end
