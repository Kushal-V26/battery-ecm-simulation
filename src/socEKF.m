function [socEst, V1Est] = socEKF(I, Vmeas, dt, params, soc0Est, V1_0Est, Q, R, P0)
% SOCEKF Extended Kalman Filter for SOC estimation with a 1RC ECM.
%
%   [socEst, V1Est] = socEKF(I, Vmeas, dt, params, soc0Est, V1_0Est, Q, R, P0)
%
%   State vector x = [SOC; V1]. The state transition is linear; the
%   nonlinearity is in the measurement equation through the OCV(SOC)
%   lookup curve, so the measurement Jacobian is obtained by numerical
%   differentiation of ocvSocLookup.
%
%   Inputs:
%     I        - current profile (A), positive = discharge
%     Vmeas    - measured terminal voltage (V), same length as I
%     dt       - sample time (s)
%     params   - ECM parameter struct (R0, R1, C1, CapacityAh)
%     soc0Est  - initial SOC estimate (0 to 1), may be biased/wrong
%     V1_0Est  - initial RC-branch voltage estimate (V)
%     Q        - 2x2 process noise covariance
%     R        - measurement noise variance (scalar)
%     P0       - 2x2 initial state covariance
%
%   Outputs:
%     socEst - estimated SOC trajectory
%     V1Est  - estimated RC-branch voltage trajectory

N = length(I);
socEst = zeros(N, 1);
V1Est  = zeros(N, 1);
socEst(1) = soc0Est;
V1Est(1)  = V1_0Est;

tau = params.R1 * params.C1;
alpha = exp(-dt / tau);
A = [1, 0; 0, alpha];
B = [-dt / (3600 * params.CapacityAh); params.R1 * (1 - alpha)];

P = P0;
dSOC = 1e-4; % step for numerical OCV derivative

for k = 1:N-1
    % --- Predict ---
    xPred = A * [socEst(k); V1Est(k)] + B * I(k);
    Ppred = A * P * A' + Q;

    socPred = xPred(1);
    V1Pred  = xPred(2);

    % --- Measurement Jacobian (numerical dOCV/dSOC) ---
    dOCV = (ocvSocLookup(socPred + dSOC) - ocvSocLookup(socPred - dSOC)) / (2 * dSOC);
    H = [dOCV, -1];

    yPred = ocvSocLookup(socPred) - I(k+1) * params.R0 - V1Pred;
    yResidual = Vmeas(k+1) - yPred;

    % --- Update ---
    S = H * Ppred * H' + R;
    K = Ppred * H' / S;
    xUpd = xPred + K * yResidual;
    P = (eye(2) - K * H) * Ppred;

    socEst(k+1) = xUpd(1);
    V1Est(k+1)  = xUpd(2);
end

end
