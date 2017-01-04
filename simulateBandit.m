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
%   simData(:,4) = reward outcome
%
% smxParams: [numSubs, 4] vector with subject specific softmax parameters
%   smxParams(:,1) = learning rate
%   smxParams(:,2) = iTemp
%   smxParams(:,3) = stick (stickiness parameter)
%
% NOTES
%
% Learning rate (alpha) sampled from beta distribution (M = 0.2857).
% Softmax temperature sampled from gamma distribution (M = check).
% stickiness sampled from ???

% ~#wem3#~ [20161027]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global dataDir;
% check for fixed learning rate & inverse temperature
if ~isempty(fixedParams)
learnRate = ones(numSubs,1)*fixedParams(1); 
iTemp     = ones(numSubs,1)*fixedParams(2);
stick     = ones(numSubs,1)*fixedParams(3);
else
    learnRate = betarnd(2, 5, numSubs, 1);
    iTemp     = gamrnd(2, 2, numSubs, 1); % changed from iTemp = gamrnd(2, .7, numSubs, 1);
    stick=randn(numSubs,1);
end

smxParams = [learnRate iTemp stick];

simData = [];

for i = 1:numSubs
    subData = generativeTD(i, learnRate(i), iTemp(i), stick(i));
    simData = [simData; subData];
end

if writeData
    filename = fullfile(dataDir,'simData.csv');
    dlmwrite(filename, simData, 'delimiter', ',');
    filename = fullfile(dataDir,'smxParams.csv');
    dlmwrite(filename, smxParams, 'delimiter', ',');    
end