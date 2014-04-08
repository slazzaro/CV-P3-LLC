function [labels] = runBuildPyramidOnImages(directory,imgCount)
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

    display(directory);    
    
    imgFiles = dir(strcat(directory,'*.jpg')); 
    imgTrainIdx = randperm(length(imgFiles),imgCount);
    
    for i = 1:imgCount
        filename = imgFiles(imgTrainIdx(i)).name;
        imgTrain{i}=filename;
        %display(strcat(num2str(i),'] ',directory,filename));
    end
    imgTrain=cellstr(imgTrain)
    outDir=strcat(directory,'pry_',datestr(now,'mmddyyyy_HHMMSSFFF'));
    mkdir(outDir);
    addpath('../SpatialPyramid');
    results = BuildPyramid(imgTrain, directory, outDir);
    rmpath('../SpatialPyramid');
    
    
        