function [LLE] = LLE_TD(params, choice, reward)

numArms       = length(unique(choice));
learnRateGems = params(1);
iTemp         = params(2);
stick         = params(3);
Q             = repmat(1,1,numArms);
smx           = zeros(length(choice), numArms);
lastChoice    = zeros(1,numArms);
LL = 0;
for i = 1:length(choice)
    %softmax: FIGURE OUT WOUTER's MODS!!!
    Qchoice = Q+stick*lastChoice;
    LL = LL + iTemp*Qchoice(choice(i))-logsumexp(iTemp*Qchoice);
    % smx(i) = exp(iTemp*Qchoice(choice(i))/(sum(exp(iTemp*Qchoice)))
    %smx(i) = exp(iTemp*Q(choice(i)) + stick*lastChoice(choice(i))) ./ (sum(exp(iTemp*Q + stick*lastChoice)));
    %smx(i, :) = exp(iTemp*Q + stick*lastChoice) ./ (sum(exp(iTemp*Q + stick*lastChoice)));
    %update Qs:
    Q(choice(i)) = Q(choice(i)) + learnRateGems * (reward(i) - Q(choice(i)));
    lastChoice   = zeros(1,numArms);
    lastChoice(choice(i)) = 1;
end

cp1 = smx(choice==1, 1);
cp2 = smx(choice==2, 2);
cp3 = smx(choice==3, 3);
cp4 = smx(choice==4, 4);
allProbs = [cp1; cp2; cp3; cp4];
LLE = abs(sum(log(allProbs)));