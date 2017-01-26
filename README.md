bandit: matlab
============

Functions and scripts for simulating choices in a k-armed bandit and estimating reinforcement learning parameters with a variety of methods.  

**runBanditScript.m**: script that sets parameters for and executes simulation of data and subsequent extraction of learning rate and inverse temperature parameters. Start here!  

**simulateBandit.m**: function that simulates performance on the task via call to generativeTD.m  

**generativeTD.m**: function that chooses an arm, determines reward outcome, & updates value of chosen arm on each trial  

**makeDrifts.m**: function to create drifting probabilities of reward outcome for each arm  

**LLE_TD.m**: likelihood function using MLE  

**LLE_Prior.m**: likelihood function using MAP  

Structured in the style [Bradley Doll's 2-armed bandit code] (https://github.com/dollbb/estRLParam/tree/master/matlab "Bradley Doll's estRLParam"), with thanks to Ben Seymour and Amy Krosch.
