function [pLLE] = LLE_Prior(params, choice, reward)
%wrapper to apply penalty to LLE_TD based on parameter priors (MAP)

LLE = LLE_TD(params, choice, reward);

learnRate = params(1);
iTemp = params(2);

pAlph = log(betapdf(learnRate,1.1,1.1));
piTemp = log(gampdf(iTemp,1.2,5));

p = abs(sum([pAlph piTemp]));    

pLLE = p + LLE;