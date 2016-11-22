% RUNBANDITSCRIPT.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script is for initializing variables and calling functions to simulate 
% performance on a k-armed bandit and estimating parameters of interest from the
% simulated data.
%
% Unless there is a specific reason to modify or directly call one of the 
% included functions, all relevant changes can be made within this script. 
%
% To simulate behavioral data and extract parameters, simply do
%
% >> runBanditScript.m
%
% after making the appropriate adjustments within the script.
% 
% ~#wem3#~ [20161101]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make these variables globally available to slim down other functions
global dataDir;
% set the directory where data will be written & read
dataDir = '/Volumes/crisp/hinl/bandit/wem3/data';                          % ~#~
% set the number of arms (choice options)
numArms   = 4;                                                             % ~#~
% set the number of trials (i.e., "pulls")
numTrials = 360;                                                           % ~#~
% set the number of subjects
numSubs   = 20;                                                            % ~#~
% set the driftRate, the speed with which reward probabilities change
driftRate = 0.2;     % note: unnecessary unless generating new drifts      % ~#~
% generate new probability drifts? if using extant probabilities
newDrifts = false;                                                         % ~#~
% generate new choice data? set to false if only extracting params
newChoices = true;                                                         % ~#~
% use fixed learning rate & inverse temperature or sample from distribution?
learnRate = 0.3;
iTemp     = 1.2;
% make fixedParams empty if you want unique per-subject learnRate & iTemp
fixedParams = [learnRate iTemp];                                           % ~#~
if newChoices; 
    writeData = true;
    % simData: rows = numTrials, 
    %          columns = [subNum, trialNum, choice (arm), reward (binary)]
    % smxParams: rows = numSubs
    %            columns[learning rate, inverse temperature] 
    [simData, smxParams]= simulateBandit(numSubs,writeData,fixedParams);
else
    simData = load(fullfile(dataDir,'simData.csv'));
end
if newDrifts
    makeDrifts(numTrials,driftRate,1,0);
end

% create a column vector of subject numbers
subList = unique(simData(:,1));

%% function optimization parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         (Less likely to require frequent adjustment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select optimization function: 'fmincon' or 'patternsearch'
optFunction = 'patternsearch';                                             % ~#~
% number of random initial start points for function optimization
nStPts    = 10;                                                            % ~#~

% set estimation method 
% 'MLE' = Maximum Likelihood Estimation
% 'MAP' = Maximum a Posteriori
estMethod = 'MAP';                                                         % ~#~

% point to chosen function accordingly
if strcmp(estMethod,'MLE')
    LLE_fun = @LLE_TD;
elseif strcmp(estMethod,'MAP')
    LLE_fun = @LLE_Prior;
end

% set boundaries for fmincon
lowerBound = [0,-Inf];
upperBound = [1,Inf];
% set random starting points for optimization
initParams = [rand(nStPts, 1) normrnd(1.5, 1, nStPts,1)];
% set appropriate options structure
if strcmp(optFunction,'fmincon')
    options = optimset(@fmincon); 
    options = optimset(options, 'TolX', 1e-06, 'TolFun', 1e-06, ...
                       'MaxFunEvals', 100000, 'LargeScale','off', ...
                       'GradObj','off','derivativecheck', 'off', ...
                       'display','notify', 'Algorithm', 'interior-point'); %sqp
elseif strcmp(optFunction,'patternsearch')
    options = psoptimset(@patternsearch);
    options = psoptimset(options,'display','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% extract parameters from simulated data                                     %%
%%         (no need to adjust unless there is a specific reason)              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create empty vectors to store model fit & SD
fits   = [];
stdevs = [];
% loop over subjects, optimizing likelihood function & storing fits/SDs
for subCount =  1:length(subList)
    curSub   = subList(subCount,1);
    sprintf('\nWorking on subject %d \n',curSub)
% parse current subject's data from simData
    subData = simData(find(simData(:,1) == curSub),:);
    choice = subData(:,3);
    reward = subData(:,4);
% initialize empty vectors to store learnRate, iTemp, LLEs, & exit flags    
    sub_params = [];
    sub_LLEs  = [];
    sub_flags = [];
    sub_hess  = [];
% loop over all start points (to get several different fits/LLEs)
    for reps = 1:nStPts
        % using fmincon
        if strcmp(optFunction,'fmincon')
            [params, LLE, exitflag, out]=fmincon(@(params)...
                LLE_fun(params, choice, reward), initParams(reps,:),...
                [],[],[],[], lowerBound, upperBound, [], options);
        % using patternsearch
        elseif strcmp(optFunction,'patternsearch')     
            [params, LLE, exitflag, out]=patternsearch(@(params)...
                LLE_fun(params, choice, reward), initParams(reps,:),...
                [],[],[],[], lowerBound, upperBound, [], options);
        end

        sub_params=[sub_params; params];
        sub_LLEs=[sub_LLEs; LLE];
        sub_flags=[sub_flags; exitflag];
        %sub mat
        sub_output = [ones(size(sub_params,1),1)*curSub sub_params ...
        sub_LLEs sub_flags];

    end
        %pull best params
        best_LLE = min(sub_output(:,end-1));
        best_fit = sub_output(find(sub_output(:,end-1)==best_LLE),:);

        if size(best_fit, 1)>1
            best_fit = best_fit(1,:);
        end 
    

    fits = [fits; best_fit];
    

end

fitFile = fullfile(dataDir,['subFits_',num2str(nStPts),'_StPts_',estMethod,'.csv']);
dlmwrite(fitFile, fits)