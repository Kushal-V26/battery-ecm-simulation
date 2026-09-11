function [I, t] = generateDriveCycleProfile(dt, duration)
% GENERATEDRIVECYCLEPROFILE Synthetic urban-style drive-cycle current.
%
%   [I, t] = generateDriveCycleProfile(dt, duration)
%
%   Produces a stand-in dynamic current profile with alternating
%   acceleration (discharge) and regenerative-braking (charge) events,
%   plus sensor-like noise. This is a placeholder for a standardized
%   cycle (e.g. UDDS or WLTP) -- swap in a real current trace here to
%   test the same pipeline against measured or published data.
%
%   Current sign convention: positive = discharge, negative = charge.

t = (0:dt:duration)';
N = length(t);

rng(1); % reproducible profile

basePattern = 3 * sin(2*pi*t/40) + 1.5 * sin(2*pi*t/13);
regenMask = mod(floor(t/40), 3) == 0 & mod(t, 40) > 30;

I = basePattern;
I(regenMask) = I(regenMask) - 4;   % regenerative braking events
I = I + 0.05 * randn(N, 1);        % small current-sensor noise

end
