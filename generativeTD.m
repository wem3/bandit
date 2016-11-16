function [subData] = generativeTD(subNum, learnRateGems, iTempGems, learnRateBomb, iTempBomb)
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
pGems = load(fullfile(dataDir,'gemsProbDrift.csv')); % assumes extant .csv
pBomb = load(fullfile(dataDir,'bombProbDrift.csv')); % assumes extant .csv
% to use unique drifting probabilities for each subject, instead call
% [pGems, pBomb] = makeDrifts(numTrials, driftRate, writeDrifts, plotDrifts)

numTrials    = size(pReward,1);  % number of rows in the drift vector
numArms      = size(pReward,2);  % number of columns in the drift vector
choice       = nan(1,numTrials); % stores arm choices, NaNs as placeholders
rewardHist   = nan(2,numTrials); % stores rewards, NaNs as placeholders
Qgems        = zeros(1,numArms); % Qs for gems initialized to 0
Qbomb        = zeros(1,numArms); % Qs for bombs initialized to 0
Qarms        = zeros(1,numArms); % Qs for combo initialized to 0

% loop over trials
for i = 1:numTrials
   % convert Q to probability of choosing each arm via softmax equation
   % note: this is not the update, we just need a p to make the choice
   smx = exp(iTempGems*Qgems) ./ sum(exp(iTempGems*Qgems));


   % choose the arm based on softmax probability, explanation at bottom
   [~, ~, choice(i)] = histcounts(rand(1),[0,cumsum(sMax)]);

   % determine whether the chosen arm pays out, based on pReward for that trial
   [~, reward] = max([rand(1), pReward(i, choice(i))]);
   % Convert reward from 1 (random number) or 2 (chosen arm) to binary format 
   reward = reward - 1; 
   rewardHist(i) = reward;
   % Update Q values based on learning rate & prediction error
   Q(choice(i)) = Q(choice(i)) + learnRate * (reward - Q(choice(i)));
end

% a simple vector to index trial number
trial = 1:numTrials;
% set up subject output matrix for all trials:
subData = [subNum*ones(numTrials, 1) trial' choice', rewardHist'];

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

