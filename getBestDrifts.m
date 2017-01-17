% GETBESTDRIFTS%%%%%%.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script generates drifting reward probabilities for a k-armed bandit
% by calling makeDrifts.m, computes correlations b/w arms for each set of 
% reward probabilities, and identifies the least correlated sets.
%
% Currently configured for only one outcome type.
%
% Unless there is a specific reason to modify or directly call one of the 
% included functions, all relevant changes can be made within this script. 
%
% To generate drifts and identify the "best" ones, simply do
%
% >> getBestDrifts.m
%
% after making the appropriate adjustments within the script.
% 
% ~#wem3#~ [20170116]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of arms in the bandit for which to make drifting reward probabilities
numArms = 4;
% number of trials
numTrials = 360;
% rate of change for reward probabilities
driftRate = 0.2;
% number of sets of probabilities to generate
numDrifts = 1000;
% note: to make this generalizable for different numbers of arms is going to be
% nightmarish. Hardcoded for 4 arms (the number implemented in our experiment)
% initialize a [numTrials x numArms x numDrifts] matrix of NaNs to hold drifts
driftMat = nan(numTrials,numArms,numDrifts);
% initialize an empty matrix to hold drift correlations
corrMat = [];
% empty vector to hold summed correlations
corrSum = nan(numDrifts,1);

% loop over total number of drifts
for d = 1:numDrifts
    % actually generate the drifts
    [driftMat(:,:,d), ~] = makeDrifts(numTrials, driftRate, 0, 0);
    % get the absolute values of correlations b/w each set of drifts
    tmpCorr = abs(corr(driftMat(:,:,d)));
    % store correlations in corrMat
    corrVec = [tmpCorr(1,2),tmpCorr(1,3),tmpCorr(1,4),tmpCorr(2,3),tmpCorr(2,4),tmpCorr(3,4)];
    corrSum(d) = sum(corrVec);
    corrMat = [corrMat; corrVec];
end

% sort the matrix of summed correlations
corrSort = sort(corrSum);
% initialize an empty vector to hold drift indices
goodDrifts = [];
dCount = 1;
% loop until we get 8 acceptable drifts 
while length(goodDrifts) < 8
    checkDrift = 0;
    % loop till we fill up the driftDex
    while checkDrift == 0
        % get the indices of the 8 least correlated sets of drifts
        thisDrift = find(corrSum == corrSort(dCount));
        % plot each drift to make sure it looks normal
        figure;
        subplot(4,1,1); plot(driftMat(:,1,thisDrift),'r')
        subplot(4,1,2); plot(driftMat(:,2,thisDrift),'r')
        subplot(4,1,3); plot(driftMat(:,3,thisDrift),'r')
        subplot(4,1,4); plot(driftMat(:,4,thisDrift),'r')
        % display correlations between arms
        fSpec = 'Correlations between arms:\n%0.2f %0.2f %0.2f %0.2f %0.2f %0.2f';
        sprintf(fSpec, corrMat(thisDrift,:))
        checkDrift = input('Accept drift? 1 = Yes, 0 = No.\n');
        dCount = dCount + 1;
    end
    goodDrifts = [goodDrifts, thisDrift];
end
% loop over acceptable drifts and save .json files
for j = 1:length(goodDrifts)
    thisDrift = driftMat(:,:,goodDrifts(j))';
    fName = ['./data/pReward_',num2str(j),'.json'];
    savejson('',thisDrift,fName);
end
