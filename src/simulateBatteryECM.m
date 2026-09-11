function [V, SOC, V1] = simulateBatteryECM(I, dt, params, SOC0, V1_0)
% SIMULATEBATTERYECM Simulate a 1RC Thevenin equivalent-circuit model.
%
%   [V, SOC, V1] = simulateBatteryECM(I, dt, params, SOC0, V1_0)
%
%   Current sign convention: I > 0 is discharge, I < 0 is charge.
%
%   Inputs:
%     I       - column vector of current samples (A)
%     dt      - sample time (s)
%     params  - struct with fields:
%                 R0         series resistance (Ohm)
%                 R1         RC-branch resistance (Ohm)
%                 C1         RC-branch capacitance (F)
%                 CapacityAh nominal capacity (Ah)
%     SOC0    - initial state of charge (0 to 1)
%     V1_0    - initial RC-branch voltage (V)
%
%   Outputs:
%     V   - terminal voltage (V)
%     SOC - state of charge (0 to 1)
%     V1  - RC-branch (polarization) voltage (V)
%
%   Model equations:
%     V(t)      = OCV(SOC(t)) - I(t)*R0 - V1(t)
%     dSOC/dt   = -I(t) / (3600*CapacityAh)
%     dV1/dt    = -V1(t)/(R1*C1) + I(t)/C1
%
%   The RC branch is integrated exactly over each sample using the
%   zero-order-hold discretization exp(-dt/tau), which is stable for any
%   dt and is the standard approach for ECM battery simulation.

N = length(I);
SOC = zeros(N, 1);
V1  = zeros(N, 1);
V   = zeros(N, 1);

SOC(1) = SOC0;
V1(1)  = V1_0;

tau = params.R1 * params.C1;
alpha = exp(-dt / tau);

for k = 1:N
    V(k) = ocvSocLookup(SOC(k)) - I(k) * params.R0 - V1(k);

    if k < N
        SOC(k+1) = SOC(k) - I(k) * dt / (3600 * params.CapacityAh);
        V1(k+1)  = V1(k) * alpha + params.R1 * (1 - alpha) * I(k);
    end
end

end
