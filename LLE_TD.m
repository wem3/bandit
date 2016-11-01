function [LLE] = LLE_TD(params, choice, rew)
 
lr = params(1);
beta = params(2);
numArms = 4;
Q=repmat(1/numArms,1,numArms);

smxProb = zeros(length(choice), length(Q));

for i = 1:length(choice)
    %softmax:
    smxProb(i, :) = exp(beta*Q)./(sum(exp(beta*Q)));
    
    %update Qs:
    Q(choice(i)) = Q(choice(i)) + lr * (rew(i) - Q(choice(i)));
    %Q(3-choice(i)) = (1-lr) * Q(3-choice(i)); %decay unchosen
end

cp1 = smxProb(choice==1, 1);
cp2 = smxProb(choice==2, 2);
cp3 = smxProb(choice==3, 3);
cp4 = smxProb(choice==4, 4);
allProbs = [cp1; cp2; cp3; cp4];
LLE = abs(sum(log(allProbs)));