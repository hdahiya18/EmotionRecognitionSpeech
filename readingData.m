clear all; close all; clc;
%{
files = dir('*.wav');

for file = files'
    [s, fs] = wavread(file.name);
end
%}

filename = '03a01Wa.wav';
[s, fs] = wavread(filename);
frame = 25/1000; %25 ms
samples = fs * frame;
olap = samples / 2.5; %10 ms overlap
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
    fbE = zeros(1,fbN); %filter bank log energy
    for j=1:fbN
        fbE(j) = log(sum(pSpect'.*fb(j,:)));
    end
    dctCoeff = dct(fbE);
    mfcc = [mfcc;dctCoeff(1:13)];
end

for i=1:fbN
    plot(fb(i,:)), hold on;
end


