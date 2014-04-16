function [ mat, order ] = confusionMat( actual, predicted )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    [mat,order] = confusionmat(actual,predicted);
    %plotconfusion(targets,outputs);
    %imshow(mat, 'InitialMagnification',2000);
    %colormap(jet);
    %plotconfusion(actual,predicted);
end

