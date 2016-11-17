function [LLE] = LLE_TD(params, choice, reward)

numArms       = length(unique(choice));
learnRateGems = params(1);
learnRateBomb = params(2);
iTemp         = params(3);
Qgems         = repmat(1,1,numArms);
Qbomb         = repmat(1,1,numArms);
smx           = zeros(length(choice), numArms);

for i = 1:length(choice)
    Q = Qgems + Qbomb;
    %softmax:
    smx(i, choice(i)) = exp(iTemp*Q(choice(i)))./(sum(exp(iTemp*Q)));
    %update Qs:
    Qgems(choice(i)) = Qgems(choice(i)) + learnRateGems * (reward(i,1) - Qgems(choice(i)));
    Qbomb(choice(i)) = Qbomb(choice(i)) + learnRateBomb * (reward(i,2) - Qbomb(choice(i)));
end

cp1 = smx(choice==1, 1);
cp2 = smx(choice==2, 2);
cp3 = smx(choice==3, 3);
cp4 = smx(choice==4, 4);
allProbs = [cp1; cp2; cp3; cp4];
LLE = abs(sum(log(allProbs)));