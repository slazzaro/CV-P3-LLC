function [trainFeatures,testFeatures] = runBuildPyramidOnImages(pDir,directory,imgCount)
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

    %display(directory);    
    
    imgFiles = dir(strcat(directory,'*.jpg')); 
    %imgTrainIdx = randperm(length(imgFiles),imgCount);
    
    for i = 1:imgCount
        %filename = imgFiles(imgTrainIdx(i)).name;
        %imgTrain{i}=filename;
        imgTrain{i}=imgFiles(i).name;
        %display(strcat(num2str(i),'] ',directory,filename));
    end
    count=1;
    for j=imgCount+1:length(imgFiles)
       imgTest{count}=imgFiles(j).name;
       count=count+1;
    end
    imgTrain=cellstr(imgTrain);
    imgTest=cellstr(imgTest);
    %outDir=strcat(directory,'pry_',datestr(now,'mmddyyyy_HHMMSSFFF'));
    outDir=strcat(pDir,'/data');
    mkdir(outDir);
    addpath('../SpatialPyramid');
    trainFeatures = BuildPyramid(imgTrain, directory, outDir);
    testFeatures = BuildPyramid(imgTest, directory, outDir);
    rmpath('../SpatialPyramid');
    
    
        