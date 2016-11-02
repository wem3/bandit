function [subData] = generativeTD(subNum, learnRate, iTemp)
% runs restless bandit task on TD model

global dataDir;

pReward = load(fullfile(dataDir,'bombProbDrift.csv'));
%use new rew prob drift for every sub:
% [payoff] = makeDrifts();

numTrials = size(pReward,1);
numArms   = size(pReward,2);
choice    = nan(1,numTrials);
rewHist   = nan(1,numTrials);
Q         = repmat(1/numArms,1,numArms);
Qsamp     = Q;

for i = 1:numTrials
   for arm = 1:numArms
      sMax(arm) = exp(iTemp*Q(arm)) ./ sum(exp(iTemp*Q));
   end

   %choose:
   [~, choice(i)] = histc(rand(1),[0,cumsum(sMax)]); 

   %update TD Qs:
   [~, reward] = max([rand(1), pReward(i, choice(i))]); 
   reward = reward - 1; % make 0s and 1s
   rewardHist(i) = reward;
   Q(choice(i)) = Q(choice(i)) + learnRate * (reward - Q(choice(i)));
end

%trial nums
trial = 1:numTrials;
%make output:
subData = [subNum*ones(numTrials, 1) trial' choice', rewardHist'];