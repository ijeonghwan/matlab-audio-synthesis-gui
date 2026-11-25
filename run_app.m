function app = run_app
%RUN_APP Add the project source directory and launch the original GUI.
%   Run from MATLAB Desktop. Original DSP/UI source files are unchanged.

rootDir = fileparts(mfilename('fullpath'));
addpath(fullfile(rootDir, 'src'));

required = {'uifigure', 'uiaxes', 'resample', 'stft', 'istft', ...
    'bandpass', 'kaiser', 'hamming', 'hann', 'hanning', 'mag2db'};
missing = required(cellfun(@(name) isempty(which(name)), required));
if ~isempty(missing)
    error('AudioSynthesis:MissingDependencies', ...
        ['Required functions not found: %s. Use MATLAB Desktop with ' ...
         'Signal Processing Toolbox.'], strjoin(missing, ', '));
end

if isempty(which('reverberator'))
    warning('AudioSynthesis:OptionalAudioToolbox', ...
        'Reverb requires Audio Toolbox (reverberator).');
end
if isempty(which('drawfreehand')) || isempty(which('imshow'))
    warning('AudioSynthesis:OptionalImageToolbox', ...
        'Display Edit requires Image Processing Toolbox.');
end

app = GUI_NOV;
end
