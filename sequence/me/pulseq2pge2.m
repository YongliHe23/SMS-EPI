function pulseq2pge2(fn,varargin)
% convert .seq file to .pge file
%   Input:
%       - fn: seq-file name
%   Optionals:
%       - blockRange: block range to be plotted by pge2.plot(); dflt = [1,10]

% convert to .pge
%%

p = inputParser;

addParameter(p,'doPlot',true)
addParameter(p,'blockRange',[1,10]);
addParameter(p,'pislquant',1);
addParameter(p,'System',mr.opts());

parse(p,varargin{:});
arg = p.Results;
%%
ceq = seq2ceq([fn '.seq']);   %, 'usesRotationEvents', false);

psd_rf_wait = 100e-6;  % RF-gradient delay, scanner specific (s)
psd_grd_wait = 100e-6; % ADC-gradient delay, scanner specific (s)
b1_max = 0.25;         % Gauss
g_max = 5;             % Gauss/cm
slew_max = 20;         % Gauss/cm/ms
coil = 'xrm';          % 'hrmbuhp' (UHP); 'xrm' (MR750)
sysGE = pge2.opts(psd_rf_wait, psd_grd_wait, b1_max, g_max, slew_max, coil);

wt = 1*[0.8 1 0.7];
%wt = [1 1 1];
params = pge2.check(ceq, sysGE, 'wt', wt);

bypass_slew_check = 1; % hard-coded to by pass the slew limit check in WTools simulation; better way is to set config file in simulation env
if bypass_slew_check
    params.smax = 0;
end

pge2.writeceq(ceq, [fn '.pge'], 'pislquant', arg.pislquant, 'params', params);

% plot
seq = mr.Sequence(arg.System);
seq.read([fn '.seq']);
if arg.doPlot
    pge2.plot(ceq, sysGE, 'blockRange', arg.blockRange, 'rotate', false, 'interpolate', false);
end
pge2.validate(ceq, sysGE, seq, [], 'row', [], 'plot', false);
%pge2.validate(ceq, sysGE, seq, [], 'row', 26, 'plot', true);
end