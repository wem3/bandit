function [LLE] = LLE_TD(params, choice, reward)

numArms   = length(unique(choice));
learnRate = params(1);
iTemp     = params(2);
Q         = repmat(0,1,numArms);

smxProb   = zeros(length(choice), numArms);

for i = 1:length(choice)
    %softmax:
    smxProb(i, choice(i)) = exp(iTemp*Q(choice(i)))./(sum(exp(iTemp*Q)));
    %update Qs:
    Q(choice(i)) = Q(choice(i)) + learnRate * (reward(i) - Q(choice(i)));
    %Q(3-choice(i)) = (1-lr) * Q(3-choice(i)); %decay unchosen
end

cp1 = smxProb(choice==1, 1);
cp2 = smxProb(choice==2, 2);
cp3 = smxProb(choice==3, 3);
cp4 = smxProb(choice==4, 4);
allProbs = [cp1; cp2; cp3; cp4];
LLE = abs(sum(log(allProbs)));