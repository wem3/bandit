function [subData] = generativeTD(subNum, learnRate, iTemp)
% GENERATIVETD.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to choose arm, determine reward outcome,
% and update Q-values on each trial.
%
% INPUT
% subNum: subjects number (assuming loop over multiple subjects) [integer]
%
% learnRate: learning rate parameter (alpha) for softmax equation [float]
%
% iTemp: inverse temperature parameter (beta) for softmax equation [float]
%
% OUTPUT
% subData: [ numTrials , 5] vector with TD data
%   subData(:,1) = subject number
%   subData(:,2) = trial number
%   subData(:,3) = number of arm selected
%   subData(:,4) = binary reward outcome
%
% NOTES
%
% Called by simulateBandit.m
% 
% ~#wem3#~ [20161108]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global dataDir;

pReward = load(fullfile(dataDir,'bombProbDrift.csv')); % assumes extant .csv
% to use unique drifting probabilities for each subject, instead call
% [pReward, ~] = makeDrifts(numTrials, driftRate, writeDrifts, plotDrifts)

numTrials    = size(pReward,1);
numArms      = size(pReward,2);
choice       = nan(1,numTrials); 
rewardHist   = nan(1,numTrials);
Q            = repmat(1/numArms,1,numArms);
Qsamp        = Q;

% loop over trials
for i = 1:numTrials
   % convert Q to probability of choosing each arm
   % note: this is not the update, we just need a p to make the choice
   sMax(arm) = exp(iTemp*Q(arm)) ./ sum(exp(iTemp*Q));

   % choose the arm based on softmax p w/ some randomization for exploration
   [~, ~, choice(i)] = histcounts(rand(1),[0,cumsum(sMax)]);

   %update TD Qs:
   [~, reward] = max([rand(1), pReward(i, choice(i))]); 
   reward = reward - 1; % make 0s and 1s WHY IS THIS NOT A PROBLEM???
   rewardHist(i) = reward;
   Q(choice(i)) = Q(choice(i)) + learnRate * (reward - Q(choice(i)));
end

% a simple vector to index trial number
trial = 1:numTrials;
% set up subject output matrix for all trials:
subData = [subNum*ones(numTrials, 1) trial' choice', rewardHist'];