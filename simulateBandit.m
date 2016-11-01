function [simData smxParams] = simulateBandit(numSubs,writeData)
% SIMULATEBANDIT.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Simulate [numSubs] subjects on 4-armed bandit (2 outcome) task.
%
% INPUT
% numSubs: number of subjects for whom to simulate performance [integer]
% defaults to 20
%
% writeData: create a new .csv file? [logical]
% defaults to true (overwriting existing banditSimData.csv file)
%
% OUTPUT
% simData: [ (numSubs*numTrials) , 5] vector with bandit simulation output
%   simData(:,1) = subject number
%   simData(:,2) = trial number
%   simData(:,3) = number of arm selected
%   simData(:,4) = ore outcome
%   simData(:,5) = bomb outcome
%
% smxParams: [numSubs, 4] vector with subject specific softmax parameters
%   simParams(:,1) = ore learning rate
%   simParams(:,2) = ore iTemp
%   simParams(:,3) = bomb learning rate
%   simParams(:,4) = bomb iTemp
%
% NOTES
%
% Learning rate (alpha) sampled from beta distribution (M = 0.2857).
% Softmax temperature sampled from gamma distribution (M = check).
% 
% ~#wem3#~ [20161027]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    numSubs = 50;
    writeData = true;
end

alph = betarnd(2, 5, numSubs, 1);
iTemp = gamrnd(2, .7, numSubs, 1); % changed from iTemp = gamrnd(2, 2, numSubs, 1);
smxParams = [alph iTemp];

simData = [];
for i = 1:numSubs
    subData = generativeTD(i, alph(i), iTemp(i));
    simData = [simData; subData];
end

if writeData
    filename = 'simData.csv';
    dlmwrite(filename, simData, 'delimiter', ',');
    filename = 'smxParams.csv';
    dlmwrite(filename, smxParams, 'delimiter', ',');    
end