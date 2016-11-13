clear all; close all; clc;

frame = 30/1000; %30 ms
fs = 16000;
samples = fs * frame;
olap = samples / 3; %10 ms overlap
nfft = 512;
sfft = 257; %select fft
fbN = 26;   %number of filter banks
freq = [300, 8000]; %range of frequency

fmel = 1125*log((1 + freq./700));   %freq in mel scale
m = linspace(fmel(1),fmel(2),fbN+2);
h = 700 * (exp(m./1125) - 1);   %freq in hz scale
f = floor((nfft+1)* h./fs); %binned freq

%creating filter banks
fb = zeros(fbN,sfft);
for j=2:fbN+1
    for k=1:sfft
        if (k < f(j-1))
            fb(j-1,k) = 0;
        elseif (k >= f(j-1) && k <= f(j))
            fb(j-1,k) = (k-f(j-1))/(f(j)-f(j-1));
        elseif (k >= f(j) && k <= f(j+1))
            fb(j-1,k) = (f(j+1)-k)/(f(j+1)-f(j));
        elseif (k > f(j+1))
            fb(j-1,k) = 0;
        end
    end
end


files = dir('train/*.wav');
numClasses = 7;
mapGertoEng = containers.Map();
mapGertoEng('W') = 'anger';
mapGertoEng('L') = 'boredom';
mapGertoEng('E') = 'disgust';
mapGertoEng('A') = 'fear';
mapGertoEng('F') = 'happiness';
mapGertoEng('T') = 'sadness';
mapGertoEng('N') = 'neutral';
mapEngtoNum = containers.Map();
mapEngtoNum('anger') = 1;
mapEngtoNum('boredom') = 2;
mapEngtoNum('disgust') = 3;
mapEngtoNum('fear') = 4;
mapEngtoNum('happiness') = 5;
mapEngtoNum('sadness') = 6;
mapEngtoNum('neutral') = 7;

trainData = {};

for i = 1:numClasses
    trainData{i} = [];
 end

for file = files'
    fileName = file.name;
    ger = fileName(6);  %6th position represent emotion in german
    emo = mapEngtoNum(mapGertoEng(ger));  %emo target for given speech
    [s, fs] = wavread(strcat('train/',fileName));
    mfcc = [];
    for i=1:samples-olap:length(s)-samples
        sframe = s(i:i+samples-1);
        t = [1:1:length(sframe)]/fs;
        hamm = window(@hamming, length(sframe));
        sframe = sframe.*hamm;
        dftFrame = fft(sframe,nfft);  %512 length dft
        magFrame = abs(dftFrame);
        pSpect = (magFrame.^2)/samples;
        pSpect = pSpect(1:sfft);  %taking only first 257 values
        fbEne = zeros(1,fbN); %filter bank log energy
        for j=1:fbN
            fbEne(j) = log(sum(pSpect'.*fb(j,:)));
        end
        dctCoeff = dct(fbEne);  %dct of log energy
        mfcc = [mfcc;dctCoeff(1:13)];   %taking first 13 mfcc's
    end
    
    trainData{emo} = [trainData{emo};mfcc];

end
save('trainData','trainData');
%clear all;
%{
for i=1:fbN
    plot(fb(i,:)), hold on;
end
%}


%http://stackoverflow.com/questions/28246614/how-to-classsify-with-gaussian-mixture-models-gmm





