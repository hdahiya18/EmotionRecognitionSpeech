clear all; clc; close all;

load('testData');
load('GMMmodel');

numClasses = 7;
correct = 0;
predicted = [];
finalClass = [];
finalPrediction = [];

for t=1:size(targets,1)
    posteriorSample = [];
    for f=1:size(testData{t},1)
        posteriorOnemfcc = [];
        for i=1:numClasses
            posteriorOnemfcc = [posteriorOnemfcc,log(pdf(gmm{i},testData{t}(f,:)))];%posterior(gmm{i},test)]
        end
        posteriorSample = [posteriorSample;posteriorOnemfcc];
    end
    [~,pred] = max(sum(posteriorSample));
    predicted = [predicted;pred];
    class = zeros(1,numClasses);
    class(targets(t)) = 1;
    prediction = zeros(1,numClasses);
    prediction(pred) = 1;
    finalClass = [finalClass;class];
    finalPrediction = [finalPrediction;prediction];
    if pred == targets(t)
        correct = correct + 1;
    end
end

[c,cm,ind,per] = confusion(finalClass',finalPrediction');
ConfusionMatrix = cm
Accuracy = correct/size(targets,1)





