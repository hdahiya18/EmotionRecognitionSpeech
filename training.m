close all; clc; clear all;

load('trainData');
load('testData');

numClasses = 7;
gmm = {};
for i=1:numClasses
    gmm{i} = gmdistribution.fit(trainData{i},3);
end

save('GMMmodel','gmm');



