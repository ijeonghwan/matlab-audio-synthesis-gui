% Generate a deterministic mono WAV without external audio assets/toolboxes.
% Run from the repository root:
%   run(fullfile('examples', 'generate_demo_audio.m'))

sampleRate = 8192;
durationSeconds = 2;
time = (0:round(sampleRate * durationSeconds)-1)' / sampleRate;
fade = sin(pi * time / durationSeconds).^2;
demoSignal = fade .* (0.35 * sin(2*pi*440*time) ...
    + 0.15 * sin(2*pi*880*time));
outputFile = fullfile(fileparts(mfilename('fullpath')), 'demo.wav');
audiowrite(outputFile, demoSignal, sampleRate);
fprintf('Demo audio saved to: %s\n', outputFile);
