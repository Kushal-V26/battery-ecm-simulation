function [I, t, pulseInfo] = generateHPPCProfile(dt, capacityAh)
% GENERATEHPPCPROFILE Build a Hybrid Pulse Power Characterization profile.
%
%   [I, t, pulseInfo] = generateHPPCProfile(dt, capacityAh)
%
%   Generates the classic HPPC test sequence used to characterize ECM
%   parameters across the SOC range: starting at 100% SOC, repeatedly
%   apply a short discharge pulse, rest, a short charge pulse, rest, then
%   remove 10% of capacity with a bulk discharge step before the next
%   pulse pair. Current sign convention: positive = discharge.
%
%   Outputs:
%     I         - current profile (A)
%     t         - time vector (s)
%     pulseInfo - struct array, one entry per discharge pulse, with
%                 sample indices pulseStart, pulseEnd, restEnd used by
%                 extractECMParameters.m

pulseCurrent   = capacityAh;        % 1C pulse
pulseDuration  = 10;                % s
restDuration   = 60;                % s
stepCurrent    = 0.5 * capacityAh;  % C/2 bulk discharge between test points
socStep        = 0.10;              % fraction of capacity removed per step
nSteps         = 9;                 % sweeps SOC from ~100% down to ~10%

pulseSamples = round(pulseDuration / dt);
restSamples  = round(restDuration / dt);
stepDuration = socStep * 3600 * capacityAh / stepCurrent; % s
stepSamples  = round(stepDuration / dt);

I = zeros(restSamples, 1); % initial rest at 100% SOC
pulseInfo = struct('pulseStart', {}, 'pulseEnd', {}, 'restEnd', {});

for i = 1:nSteps
    pulseStart = length(I) + 1;
    I = [I; pulseCurrent * ones(pulseSamples, 1)]; %#ok<AGROW>
    pulseEnd = length(I);

    I = [I; zeros(restSamples, 1)]; %#ok<AGROW>
    restEnd = length(I);

    pulseInfo(end+1) = struct('pulseStart', pulseStart, ...
                               'pulseEnd', pulseEnd, ...
                               'restEnd', restEnd); %#ok<AGROW>

    I = [I; -pulseCurrent * ones(pulseSamples, 1)];  % charge pulse (return) %#ok<AGROW>
    I = [I; zeros(restSamples, 1)];                  %#ok<AGROW>
    I = [I; stepCurrent * ones(stepSamples, 1)];      % bulk discharge step %#ok<AGROW>
    I = [I; zeros(restSamples, 1)];                  %#ok<AGROW>
end

t = (0:length(I)-1)' * dt;

end
