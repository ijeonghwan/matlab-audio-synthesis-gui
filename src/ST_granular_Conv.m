function y=ST_granular_Conv (x,fs)
% Short term granualr convolution synthesis
Ly=length(x);  y=zeros(Ly,1);   %output signal

timex = Ly/fs;
% Constants
nEv=500; maxL=round(fs*0.02);  minL=round(fs*0.01);  Lw=round(fs*0.01);
% Initializations
L = round((maxL-minL)*rand(nEv,1))+minL;   %grain length
initIn = ceil((Ly-maxL)*rand(nEv,1));      %init grain
initOut= ceil((Ly-maxL)*rand(nEv,1));      %init out grain
a = rand(nEv,1);                           %ampl. grain
endOut=initOut+L-1;
% Synthesis
for k=1:nEv
  grain=grainSh(x,initIn(k),L(k));
  y(initOut(k):endOut(k))=x(initOut(k):endOut(k))+ grain;
end
end