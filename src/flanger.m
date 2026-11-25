function yout=flanger(y,fs)
% lower freq
low_n = ceil(0.0*fs);
high_n = ceil(0.0057*fs);
% higher freq
dpvary_p = 8;
dpstep = (dpvary_p/4)/(1/fs);
dp1 = ceil(linspace(low_n,high_n,dpstep));
dp2 = ceil(linspace(high_n,low_n,dpstep));
dp = [dp1 dp2];
% number of points
no_points = length(y(:,1));
n_rep = ceil(no_points/length(dp));
dp = repmat(dp,1,n_rep);
dp = [dp dp(1:no_points-length(dp))];
% Initialize output
yout(:,1) = zeros(1,no_points);
yout(:,2) = zeros(1,no_points);
% Add flanger effect
for i=1:no_points
    n = i-dp(i);
    if n>0
        yout(i,1) = y(i,1)+y(n,1);
        yout(i,2) = y(i,2)+y(n,2);
    else
        yout(i,1) = y(i,1);
        yout(i,2) = y(i,2);
    end
end
end