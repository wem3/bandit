function [pBomb, pGems] = makeDrifts(numTrials, numArms, driftRate, writeDrifts, plotDrifts)    
% MAKEDRIFTS.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Generate a [numTrials, numArms] vector of drifting reward probabilities 
% for k-armed bandit for each of two outcome tracks. 
% Optionally outputs two .csv files in current working directory.
%
% INPUT
% numTrials: number of trials for which to generate probabilities [integer]
% defaults to 360
%
% driftRate: determines how quickly probabilites change [double]
%            defaults to 0.2.
%
% writeDrifts: create a new .csv files? [logical]
% defaults to true (overwriting existing drift file)
%
% plotDrifts: generate plots of probabilities (y) by trial (x) [logical]
% defaults to true
%
%
% OUTPUT
% pBomb: [numTrials, numArms] vector of probability for bomb on each trial
%
% pGems: [numTrials, numArms] vector of probability for ore on each trial
%
% SUBFUNCTIONS
%
% [probVector] = getDriftProb - the function that actually computes the 
%                  drifting probability vector of interest
% 
% ~#wem3#~ [20161027]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    writeDrifts = true;
    plotDrifts  = true;
end

global dataDir;

ok=0;

while ok == 0
    
    for arm = 1:numArms
        bombDrifts(arm,:) = getDriftProb(numTrials, driftRate);
        gemsDrifts(arm,:) = getDriftProb(numTrials, driftRate);
    end
    % if selected, plot outcome probabilities for bombs (red) 
    % and ore (green) for each of the four arms
    if plotDrifts
        figure;
        subplot(4,1,1); plot(bombDrifts(1,:),'r'); hold on; plot(gemsDrifts(1,:),'g')
        subplot(4,1,2); plot(bombDrifts(2,:),'r'); hold on; plot(gemsDrifts(2,:),'g')
        subplot(4,1,3); plot(bombDrifts(3,:),'r'); hold on; plot(gemsDrifts(3,:),'g')
        subplot(4,1,4); plot(bombDrifts(4,:),'r'); hold on; plot(gemsDrifts(4,:),'g')
    end
    
    ok = input('Accept profile? 1 = Yes, 0 = No.\n');
    
end
pBomb = bombDrifts';
pGems = gemsDrifts';

if writeDrifts
    dlmwrite(fullfile(dataDir,'pBomb.csv'), pBomb, 'delimiter', ',');
    dlmwrite(fullfile(dataDir,'pGems.csv'), pGems, 'delimiter', ',');
end

function [probVector] = getDriftProb(numTrials, driftRate)
% subfunction GETDRIFTPROB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to generate a vector of drifting probabilities 
% with reflecting boundaries of 0 and 0.5. See above for input explanation
%
% Needs a more thorough explanation... 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dsigma = driftRate; % reward drift speed
% seed the random number generator
rand('state',sum(100*clock));

decay = sqrt(1-dsigma^2); % make stationary distribution N(0,1)
erfsigma = 1.1; % use probit just slightly fatter than stationary cdf to
                % keep things more linear

x(1) = randn;
p(1) = .5 * (1 + erf(x(1) / erfsigma / sqrt(2)));

for i =2:numTrials
    x(i) = x(i-1) * decay + dsigma * randn;
    p(i) = .5 * (1 + erf(x(i) / erfsigma / sqrt(2)));
end

probVector = p/2;
    
    
    
    
    
    