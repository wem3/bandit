function [simData smxParams] = simulateBandit(numSubs,writeData,fixedParams)
% SIMULATEBANDIT.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Simulate [numSubs] subjects on k-armed bandit
%
% INPUT
% numSubs: number of subjects for whom to simulate performance [integer]
%
% writeData: create a new .csv file? [logical]
% defaults to true (overwriting existing banditSimData.csv file)
%
% OUTPUT
% simData: [ (numSubs*numTrials) , 5] vector with bandit simulation output
%   simData(:,1) = subject number
%   simData(:,2) = trial number
%   simData(:,3) = number of arm selected
%   simData(:,4) = gems outcome
%   simData(:,5) = bomb outcome
%
% smxParams: [numSubs, 4] vector with subject specific softmax parameters
%   smxParams(:,1) = gems learning rate
%   smxParams(:,2) = gems iTemp
%   smxParams(:,3) = bomb learning rate
%   smxParams(:,4) = bomb iTemp
%
% NOTES
%
% Learning rate (alpha) sampled from beta distribution (M = 0.2857).
% Softmax temperature sampled from gamma distribution (M = check).
% 
% ~#wem3#~ [20161027]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global dataDir;
% check for fixed learning rate & inverse temperature
if ~isempty(fixedParams)
learnRateGems = ones(numSubs,2)*fixedParams(1);
iTempGems     = ones(numSubs,2)*fixedParams(2);
learnRateBomb = ones(numSubs,2)*fixedParams(1);
iTempBomb     = ones(numSubs,2)*fixedParams(2);
else
    learnRateGems = betarnd(2, 5, numSubs, 1);
    iTempGems     = gamrnd(2, .7, numSubs, 1);
    learnRateBomb = betarnd(2, 5, numSubs, 1);
    iTempBomb     = gamrnd(2, .7, numSubs, 1);
end

smxParams = [learnRateGems iTempGems learnRateBomb iTempBomb];

simData = [];

for i = 1:numSubs
    subData = generativeTD(i, learnRateGems(i), iTempGems(i),...
                              learnRateBomb(i), iTempBomb(i));
    simData = [simData; subData];
end

if writeData
    filename = fullfile(dataDir,'simData.csv');
    dlmwrite(filename, simData, 'delimiter', ',');
    filename = fullfile(dataDir,'smxParams.csv');
    dlmwrite(filename, smxParams, 'delimiter', ',');
end