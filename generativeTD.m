function [subData] = generativeTD(subNum, learnRateGems, learnRateBomb, iTemp)
% GENERATIVETD.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to choose arm, determine reward outcome,
% and update Q-values on each trial.
%
% INPUT
% subNum: subjects number (assuming loop over multiple subjects) [integer]
%
% learnRateGems: learning rate parameter (alpha) for gems [float]
% learnRateBomb: learning rate parameter (alpha) for bomb [float]
%
% iTemp: inverse temperature parameter (beta) for softmax equation [float]
%
% OUTPUT
% subData: [ numTrials , 4] vector with TD data
%   subData(:,1) = subject number
%   subData(:,2) = trial number
%   subData(:,3) = number of arm selected
%   subData(:,4) = binary reward outcome: gems
%   subData(:,5) = binary reward outcome: bomb
%
% NOTES
%
% Called by simulateBandit.m
% 
% ~#wem3#~ [20161108]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global dataDir;
% needs to be adjusted to allow for new drifts or load old ones...
pGems = load(fullfile(dataDir,'pGems.csv')); % assumes extant .csv
pBomb = load(fullfile(dataDir,'pBomb.csv')); % assumes extant .csv
% to use unique drifting probabilities for each subject, instead call
% [pGems, pBomb] = makeDrifts(numTrials, driftRate, writeDrifts, plotDrifts)

numTrials    = size(pGems,1);  % number of rows in the drift vector
numArms      = size(pGems,2);  % number of columns in the drift vector
choice       = nan(numTrials,1); % stores arm choices, NaNs as placeholders
gemsHist     = nan(numTrials,1); % stores rewards, NaNs as placeholders
bombHist     = nan(numTrials,1); % stores rewards, NaNs as placeholders
Qgems        = [1 1 1 1];
Qbomb        = [1 1 1 1];
% loop over trials
for i = 1:numTrials
   Qarms = Qgems + Qbomb;
   % convert Q to probability of choosing each arm via softmax equation
   % note: this is not the update, we just need a p to make the choice
   smx = exp(iTemp*Qarms) ./ sum(exp(iTemp*Qarms));

   % choose the arm based on softmax probability, explanation at bottom
   [~, ~, choice(i)] = histcounts(rand(1),[0,cumsum(smx)]);

   % determine whether the chosen arm pays out, based on pReward for that trial
   [~, reward(1)] = max([rand(1), pGems(i, choice(i))]);
   [~, reward(2)] = max([rand(1), pBomb(i, choice(i))]);
   % Convert reward from 1 (random number) or 2 (chosen arm) to binary format 
   reward = reward - 1; 
   gemsHist(i)  = reward(1);
   bombHist(i) = reward(2);
   % Update Q values based on learning rate & prediction error
   Qgems(choice(i)) = Qgems(choice(i)) + learnRateGems * (reward(1) - Qgems(choice(i)));
   Qbomb(choice(i)) = Qbomb(choice(i)) + learnRateBomb * (reward(2) - Qbomb(choice(i)));

end

% a simple vector to index trial number
trial = 1:numTrials;
% set up subject output matrix for all trials:
subData = [subNum*ones(numTrials, 1) trial' choice, gemsHist, bombHist];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How are we choosing an arm via histcounts and cumsum?
%
% First, we convert the Q values to probabilities using softmax.       (line 47)
%
% Then, we use histcounts to see which of (numArms) bins 
% contains a randomly generated number.                                (line 50)
%
% The first argument, rand(1), simply sets a random number b/w 0 and 1
%
% The next argument is a vector ranging from 0 to  1. This creates four bins,  
% with the edges of those bins definied by the cumulative sum of the softmax
% probabilities. 
% 
% Histcounts asks "how many instances of x are in each bin,"
% and in this case, where x is randomly determined, we can use it decide 
% which arm to choose based on our Q values, which have been converted 
% into probabilities via the softmax equation.
%
% Example:
%
% x = rand(1)
%
% x = 
%     0.9134
%
% sMax = [.1 .4 .2 .3];
%
% [a,b,c] = histcounts(x,[0,cumsum])
%
% a =          % a logical vector indicating the bin in which x falls
%     0 1 0 0
%
% b =          % bin edges: 0 and the cumulative sum of our sMax probabilities
%     0   0.1   0.5   0.7   1.0
%
% c =
%     4        % just a numerical index of (a), the bin in which x falls
%
% Since we only really care about which arm is chosen, we only store the
% bin number (c) in the i-th row of our choice vector, ignoring a & b.
%
% Then we assess the reward outcome by comparing another random number
% to the probability of the chosen arm 'paying out' from pReward. If the random
% number is higher, no reward. If the value of pReward(i) is higher, reward!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

