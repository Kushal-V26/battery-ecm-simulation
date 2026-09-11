function paramsTable = extractECMParameters(I, V, pulseInfo, dt, pulseDuration)
% EXTRACTECMPARAMETERS Estimate R0, R1, C1 from an HPPC voltage response.
%
%   paramsTable = extractECMParameters(I, V, pulseInfo, dt, pulseDuration)
%
%   For each discharge pulse described in pulseInfo (see
%   generateHPPCProfile.m):
%     - R0 is estimated from the instantaneous voltage step at the
%       moment the pulse current is applied.
%     - The relaxation voltage after the pulse ends is fitted to
%       V(t) = Vrelaxed - dV0*exp(-t/tau) using fminsearch (no
%       Optimization Toolbox required) to estimate the RC time
%       constant tau.
%     - R1 and C1 are then recovered from tau and the observed
%       polarization voltage dV0, accounting for the fact that a pulse
%       shorter than tau does not let V1 fully reach its steady value.
%
%   Returns a table with one row per pulse.

n = length(pulseInfo);
R0_est = zeros(n, 1);
R1_est = zeros(n, 1);
C1_est = zeros(n, 1);

for i = 1:n
    idxStart   = pulseInfo(i).pulseStart;
    idxEnd     = pulseInfo(i).pulseEnd;
    idxRestEnd = pulseInfo(i).restEnd;
    I_applied  = I(idxStart);

    % R0: instantaneous voltage step when the pulse current is applied
    R0_est(i) = (V(idxStart - 1) - V(idxStart)) / I_applied;

    % Relaxation segment after the pulse current returns to zero
    relaxIdx = (idxEnd + 1):idxRestEnd;
    Vjust    = V(idxEnd + 1);
    Vrelaxed = V(idxRestEnd);
    dV0      = Vrelaxed - Vjust;
    tRelax   = (0:(length(relaxIdx) - 1))' * dt;
    Vrelax   = V(relaxIdx);

    costFun = @(tau) sum((Vrelax - (Vrelaxed - dV0 * exp(-tRelax / tau))).^2);
    tau_est = fminsearch(costFun, 10);

    % Recover R1 from the (partial) polarization build-up during the
    % pulse: dV0 = R1*I*(1 - exp(-pulseDuration/tau))
    R1_est(i) = dV0 / (I_applied * (1 - exp(-pulseDuration / tau_est)));
    C1_est(i) = tau_est / R1_est(i);
end

paramsTable = table((1:n)', R0_est, R1_est, C1_est, ...
    'VariableNames', {'PulseIndex', 'R0_Ohm', 'R1_Ohm', 'C1_Farad'});

end
