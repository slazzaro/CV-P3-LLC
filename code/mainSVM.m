%function [ imgTrain, imgTest, trainLblVector, testLblVector] = main( mainDir ,imgCount)
function [ testLblVector, predictLblVector, mat, order] = mainSVM( mainDir ,imgCount)

dirContents = dir(mainDir); % all dir contents
subFolders=[dirContents(:).isdir]; % just subfolder
folderNames = {dirContents(subFolders).name};    %subfolder names
folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..

trainImgCount=0;
testImgCount=0;
scenceCount=0;

for i=1:length(folderNames)
    %each folder=new scene
    oneFolder=folderNames{i};
    if strcmp(oneFolder ,'dataLLC_K2048') == 1
        continue;
    end
    
    localTrainCount=0;
    localTestCount=0;
    scenceCount=scenceCount+1;
    sceneNameList{scenceCount}=oneFolder;
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing images for scence "',oneFolder,'"'));
    sceneDir = strcat(mainDir,'/',  oneFolder,'/');
    
    imgFiles = dir(strcat(sceneDir,'*.jpg'));
    
    for k = 1:imgCount
        trainImgCount=trainImgCount+1;
        localTrainCount=localTrainCount+1;
        imgTrain{trainImgCount}=strcat(oneFolder,'/',imgFiles(k).name);
        trainLblVector(trainImgCount,1)=scenceCount;
    end
    sceneTrainImageCounts(scenceCount, 1) = localTrainCount;
    
    for j=imgCount+1:length(imgFiles)
        testImgCount=testImgCount+1;
        localTestCount=localTestCount+1;
        imgTest{testImgCount}=strcat(oneFolder,'/',imgFiles(j).name);
        testLblVector(testImgCount,1)=scenceCount;
    end
    sceneTestImageCounts(scenceCount, 1) = localTestCount;
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Train Images :',num2str(localTrainCount)));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Test Images :',num2str(localTestCount)));
end

imgTrain=cellstr(imgTrain);
imgTest=cellstr(imgTest);
sceneNameList=cellstr(sceneNameList);

trainfeatureVector=zeros(trainImgCount,4200); %morework
testfeatureVector=zeros(testImgCount,4200); %morework

display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total scenes : ',num2str(length(folderNames))));
display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total train images : ',num2str(trainImgCount)));
display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total test images : ',num2str(testImgCount)));

outDir=strcat(mainDir,'/dataLLC_K2048');
mkdir(outDir);
display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
addpath('../SpatialPyramid');
trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir);
%K = [ (1:trainImgCount)', hist_isect(trainfeatureVector, trainfeatureVector)];
testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir);
%K2 = [ (1:testImgCount)', hist_isect(testfeatureVector, testfeatureVector)];
rmpath('../SpatialPyramid');

addpath('../liblinear/matlab');
display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model'));

accuracyMatrix = zeros(testImgCount,scenceCount);
for i = 1:length(sceneTrainImageCounts)
    %first create model
    trainLblVector = zeros(trainImgCount,1);
    indent = 0;
    for j = 1:i
        indent = indent + sceneTrainImageCounts(i,1);
    end
    trainLblVector(indent:sceneTrainImageCounts(i,1), 1) = 1;
    addpath('../SpatialPyramid');
    model = svmtrain(trainfeatureVector, trainLblVector, 'kernel_function', @hist_isect);
    rmpath('../SpatialPyramid');
    
    %now create predictions
    testLblVector = zeros(testImgCount,1);
    indent = 0;
    for j = 1:i
        indent = indent + sceneTestImageCounts(i,1);
    end
    testLblVector(indent:sceneTestImageCounts(i,1), 1) = 1;
    %[predictLblVector, accuracy, decision_values] = svmpredict(testfeatureVector, testLblVector, model);
    predictLblVector = svmclassify(model,testfeatureVector);
    display(predictLblVector);
    display('prediction finished');
    %finally update accuracies
    accuracyMatrix(:,i) = decision_values(:,1);
end

[maxProbVals, predictions] = max(accuracyMatrix,[],2);

correctPredictions = 0;
for i = 1:length(predictions)
    if predictions(i,1) == testLblVector(i,1)
        correctPredictions = correctPredictions + 1;
    end
end

accuracy = correctPredictions / length(predictions);
display(strcat('accuracy:',num2str(accuracy)));

% display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict'));
% [predictLblVector, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
% rmpath('../liblinear/matlab');
% accuracy

[ mat, order ] = confusionMat(testLblVector, predictLblVector);

%trainfeatureVector=htranspose(trainfeatureVector);
%deleteData(mainDir);
end
