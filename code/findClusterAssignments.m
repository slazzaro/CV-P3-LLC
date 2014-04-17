function [cluster1, cluster2] = findClusterAssignments( trainfeatureVector, folderNames, imgCount, mainDir )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%NEW CODE
%% perform clustering
options = zeros(1,14);
options(1) = 1; % display
options(2) = 1;
options(3) = 0.1; % precision
options(5) = 0; % initialization
options(14) = 1000; % maximum iterations
numClusters = 2;
centers = zeros(numClusters, size(trainfeatureVector,2));

%% run kmeans
addpath('../SpatialPyramid');
fprintf('\nRunning k-means\n');
clusters = sp_kmeans(centers, trainfeatureVector, options);

%clusterAssignments
%Number of clusters x 1 column vector which has the counts of columns
%for each cluster
totalColsForEachCluster = zeros(numClusters,1);
sceneNum = 0;
totalCount = 1;

dist_mat = sp_dist2(trainfeatureVector, clusters);
totalCorrect = 0;
for i=1:length(folderNames)
    %each folder=new scene
    oneFolder=folderNames{i};
    if strcmp(oneFolder ,'dataTREE') == 1
        continue;
    end
    if strcmp(oneFolder ,'dataLLCTREE') == 1
        continue;
    end
    if strcmp(oneFolder ,'data') == 1
        continue;
    end
    if strcmp(oneFolder ,'dataLLC') == 1
        continue;
    end
    
    sceneNum=sceneNum+1;
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Finding cluster for scene "',oneFolder,'"'));
    sceneDir = strcat(mainDir,'/',  oneFolder,'/');    
    imgFiles = dir(strcat(sceneDir,'*.jpg')); 
    
    %find the count for each cluster in the specific image bin
    countForClusters = zeros(numClusters,1);
    for k = 1:imgCount
        minDist = realmax;
        minCluster = 0;
        for cluster = 1:numClusters
%             dist = norm(trainfeatureVector(totalCount,:) , clusters(cluster,:));
%             dist = dist ^ 2;
            dist = dist_mat(totalCount, cluster);
            if (dist < minDist)
                minDist = dist;
                minCluster = cluster;
            end
        end
        countForClusters(minCluster,1) = countForClusters(minCluster,1) + 1;
        totalCount = totalCount + 1;
    end
    
    %get the cluster that has the largest number and add this image bin to
    %its list of image matches
    [maxVal, maxCluster] = max(countForClusters);
    if (maxCluster == 1)
        cluster1(1,totalColsForEachCluster(maxCluster) + 1) = sceneNum;
        totalColsForEachCluster(1, 1) = totalColsForEachCluster(1, 1) + 1;
    else
        cluster2(1,totalColsForEachCluster(maxCluster) + 1) = sceneNum;
        totalColsForEachCluster(2, 1) = totalColsForEachCluster(2, 1) + 1;
    end
    totalCorrect = totalCorrect + maxVal;
end

accuracy = (totalCorrect / size(trainfeatureVector,1)) * 100;
display(strcat(num2str(accuracy), '%'));

rmpath('../SpatialPyramid');

end

