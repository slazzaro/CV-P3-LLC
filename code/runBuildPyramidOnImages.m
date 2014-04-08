function [labels] = runBuildPyramidOnImages(directory)
% readImages : reads in image data and exposure values
%--------------------------------------------------------------------------
%   Author: Saikat Gomes
%           Steve Lazzaro
%   CS 766 - Assignment 1
%   Params: directory - relative directory of the *.info file
%
%   Return: pixelArray - a 4D array with the pixel data of all images read
%               pixelArray(n,r,c,rbg)
%                   n=image number
%                   r=row value
%                   c=column value
%                   rgb=1=R, 2=G, 3=B
%           T - a vector containing the log of shutter speeds
%           filenames - a vector containing the names of the files
%--------------------------------------------------------------------------

   
    
        