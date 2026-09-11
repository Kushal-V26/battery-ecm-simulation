function ocv = ocvSocLookup(soc)
% OCVSOCLOOKUP Open-circuit voltage as a function of state of charge.
%
%   ocv = ocvSocLookup(soc) returns the open-circuit voltage (V) for a
%   given state of charge (0 to 1), based on a representative NMC-type
%   Li-ion cell OCV-SOC curve (illustrative values, not a specific
%   datasheet). Replace this table with manufacturer/measured data for
%   a real cell.

socTable = [0 0.05 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 0.95 1.00];
ocvTable = [3.00 3.35 3.45 3.55 3.62 3.68 3.72 3.76 3.80 3.85 3.92 3.98 4.10];

soc = min(max(soc, 0), 1); % clamp to the physically valid range
ocv = interp1(socTable, ocvTable, soc, 'pchip');

end
