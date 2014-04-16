function [predictLblVector] = kNN(trainLblVector, trainFeatureVector, testLblVector, testFeatureVector, k)
% K-nearest neighbor classifier

predictLblVector = zeros(size(testLblVector,1) , 1);

addpath('../SpatialPyramid');
dist_mat = sp_dist2(testFeatureVector, trainFeatureVector);
rmpath('../SpatialPyramid');
[sortedMat, indexes] = sort(dist_mat, 2);
for testInst = 1:size(testFeatureVector,1)
    minLabels = zeros(k,1);
    for i = 1:k
        minLabels(i,1) = trainLblVector(indexes(testInst,i) , 1);
    end
    
    %now find majority value for prediction
    predictedVal = mode(minLabels);
    
    %finally add predictedVal to the predicted label vector
    predictLblVector(testInst, 1) = predictedVal;
end

end

