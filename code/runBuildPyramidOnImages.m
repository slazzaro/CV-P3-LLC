function [featureMatrix, labelMatrix] = runBuildPyramidOnImages(directory)
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

    infoFile = dir(strcat(directory,'/*.info'));    %info file
    infoFileName=infoFile(1).name;

    fid=fopen(strcat(directory,'/',infoFileName));
    tLine=fgets(fid);   %file line is the pic count
    count=str2num(tLine);
    T = zeros(count,1);  %initialize vector
    tLine=fgets(fid);   %next line
    for i=1:count
        lineVal=strsplit(tLine);    %split each line on spaces
        img = strcat(directory,'',lineVal(1)); %name of image file
        %display(strcat('Reading Image: ',img));
        img=char(img);
        T(i)=1/str2double(lineVal(2)); %exposure value for this file
        currentImage=imread(img);   %get pixel data value for this pic
        if ~exist('pixelArray','var')   %initialize array first time
            row=size(currentImage,1);   %assume same row & col for all images
            col=size(currentImage,2);    
            pixelArray = zeros(i,row,col,3);
        end
        filenames{i}=img;
        pixelArray(i,:,:,:)=currentImage;
        pixelArray=uint8(pixelArray);
        tLine=fgets(fid);   %read next line
    end
    fclose(fid);
