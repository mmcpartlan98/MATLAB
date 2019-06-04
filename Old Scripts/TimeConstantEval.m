clear;
clc;
format compact;

movingAvg = 500;

sampleRef = csvread('Tek000.csv');
sampleTime = movmean(sampleRef(1:length(sampleRef), 1), movingAvg);
sampleVoltage = movmean(sampleRef(1:length(sampleRef), 2), movingAvg);

time_interp= linspace(sampleTime(1), sampleTime(length(sampleTime)));

plotVolts = interp1(sampleTime, sampleVoltage, time_interp, 'linear');

TCM = @(x, y, t) -t/(log(x/y));

taoSum = 0;
taoPts = 0;

for i = 1:length(plotVolts)
    if i == length(plotVolts)
    elseif plotVolts(i + 1) < plotVolts(i)
       taoSum = taoSum + TCM(plotVolts(i + 1), plotVolts(i), abs(abs(time_interp(i + 1)) - abs(time_interp(i))));
       taoPts = taoPts + 1;
    end
end

tao = taoSum/taoPts

figure;
hold on;
plot(sampleTime, sampleVoltage);
plot(time_interp, plotVolts);