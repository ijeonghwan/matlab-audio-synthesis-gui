classdef GUI_NOV < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        AdditionalFeaturesandEditsPanel  matlab.ui.container.Panel
        DisplayEditButton          matlab.ui.control.Button
        ReversingButton            matlab.ui.control.Button
        LoopingButton              matlab.ui.control.Button
        NoLoopEditField            matlab.ui.control.NumericEditField
        NoLoopEditFieldLabel       matlab.ui.control.Label
        AudioEffectPanel           matlab.ui.container.Panel
        EnvelopeButton             matlab.ui.control.Button
        AddButton                  matlab.ui.control.Button
        DropDown_2                 matlab.ui.control.DropDown
        LayerConvolutionPanel      matlab.ui.container.Panel
        File2Button                matlab.ui.control.Button
        File1Button                matlab.ui.control.Button
        ComputeButton_2            matlab.ui.control.Button
        GranularConvolutionPanel   matlab.ui.container.Panel
        ComputeButton              matlab.ui.control.Button
        PlayBackPanel              matlab.ui.container.Panel
        GenerateButton             matlab.ui.control.Button
        TempoSlider                matlab.ui.control.Slider
        TempoSliderLabel           matlab.ui.control.Label
        PitchSlider                matlab.ui.control.Slider
        PitchSliderLabel           matlab.ui.control.Label
        STFTPanel                  matlab.ui.container.Panel
        DropDown                   matlab.ui.control.DropDown
        BandPassFilterOptionLabel  matlab.ui.control.Label
        FilterButton               matlab.ui.control.Button
        f_upperHzEditField         matlab.ui.control.NumericEditField
        f_upperHzEditFieldLabel    matlab.ui.control.Label
        f_lowerHzEditField         matlab.ui.control.NumericEditField
        f_lowerHzEditFieldLabel    matlab.ui.control.Label
        TransformButton            matlab.ui.control.Button
        SelectionPanel             matlab.ui.container.Panel
        RESETButton                matlab.ui.control.Button
        SaveButton                 matlab.ui.control.Button
        PlayButton                 matlab.ui.control.Button
        UploadFileButton           matlab.ui.control.Button
        UIAxes2                    matlab.ui.control.UIAxes
        UIAxes                     matlab.ui.control.UIAxes
    end


    properties (Access = public)
        % Description
        x
        t
        fs
        
        filename

        x1
        fs1

        x2
        fs2
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadFileButton
        function UploadFileButtonPushed(app, event)
            [app.filename,path] = uigetfile({'*.wav;*.waV;','Wav Files'; ...
                '*.*', 'All files (*.*)'}, ...
                'Select a sound file');
            addpath(path)
            [app.x,app.fs]=audioread(app.filename);
            [P,Q] = rat(8192/app.fs);
            app.fs=8192 ;
            app.x = resample(app.x,P,Q);
            app.t = (0:size(app.x,1)-1)/app.fs;
        end

        % Button pushed function: TransformButton
        function TransformButtonPushed(app, event)
            app.t=0:1/app.fs:1/app.fs*(numel(app.x)-1);
            if app.DropDown.Value=="kaiser"
                win=kaiser(256,5);
                OLL=220;
                FFTL=512;
            elseif app.DropDown.Value=="hamming"
                win=hamming(256,'periodic');
                OLL=220;
                FFTL=512;
            elseif app.DropDown.Value=="hann"
                win=hann(256);
                OLL=220;
                FFTL=512;
            end
            [s,f,t1]=stft(app.x,app.fs,"Window",win,"OverlapLength",OLL,"FFTLength",FFTL);
            sdb = mag2db(abs(s));
            mesh(app.UIAxes,t1,f/1000,sdb);
            view(app.UIAxes,2)
            colormap(app.UIAxes,"jet")
            colorbar(app.UIAxes)
            xlabel(app.UIAxes,'Time (sec)')
            ylabel(app.UIAxes,'Frequency (kHz)')
            title(app.UIAxes,'Time-Frequency Distribution')
        end

        % Button pushed function: FilterButton
        function FilterButtonPushed(app, event)
            % Apply band pass filter
            app.x=bandpass(app.x,[app.f_lowerHzEditField.Value app.f_upperHzEditField.Value],app.fs);
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            app.t = (0:size(app.x,1)-1)/app.fs;
            plot(app.UIAxes2,app.t,app.x)
            xlabel(app.UIAxes2,'t')
            ylabel(app.UIAxes2,'x')
            title(app.UIAxes2,'Audio Signal')
            sound(app.x,app.fs)
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            [file,path] = uiputfile('*.wav');
            addpath(path)
            audiowrite(file,app.x,app.fs)
        end

        % Button pushed function: RESETButton
        function RESETButtonPushed(app, event)
            [app.x,app.fs]=audioread(app.filename);
        end

        % Button pushed function: GenerateButton
        function GenerateButtonPushed(app, event)
            % Playback and pitch/tempo control
            nsemitones=app.PitchSlider.Value;
            
            if nsemitones~=0
                xpvoc=pvoc(app.x, nsemitones);
                [a,b]=rat(nsemitones);
                app.x = resample(xpvoc,a,b);
            else
                app.x=app.x;
            end

            tempo=app.TempoSlider.Value;

            app.x = pvoc(app.x,tempo,1024); 

            app.t = (0:size(app.x,1)-1)/app.fs;
        end

        % Button pushed function: ComputeButton
        function ComputeButtonPushed(app, event)
            app.x=ST_granular_Conv (app.x,app.fs);
        end

        % Button pushed function: File1Button
        function File1ButtonPushed(app, event)
            [app.filename,path] = uigetfile({'*.wav;*.waV;','Wav Files'; ...
                '*.*', 'All files (*.*)'}, ...
                'Select a sound file');
            addpath(path)
            [app.x1,app.fs1]=audioread(app.filename);
            [P,Q] = rat(8192/app.fs1);
            app.fs1=8192 ;
            app.x1 = resample(app.x1,P,Q);
        end

        % Button pushed function: File2Button
        function File2ButtonPushed(app, event)
            [app.filename,path] = uigetfile({'*.wav;*.waV;','Wav Files'; ...
                '*.*', 'All files (*.*)'}, ...
                'Select a sound file');
            addpath(path)
            [app.x2,app.fs2]=audioread(app.filename);
            [P,Q] = rat(8192/app.fs2);
            app.fs2=8192 ;
            app.x2 = resample(app.x2,P,Q);
        end

        % Button pushed function: ComputeButton_2
        function ComputeButton_2Pushed(app, event)
            app.x=conv(app.x1,app.x2);
            Fs=8192;
            app.fs=Fs;
            app.t=(0:size(app.x,1)-1)/Fs;
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)
            if app.DropDown_2.Value=="reverb"
                % Reverb
                reverb = reverberator('SampleRate',app.fs);
                app.x=reverb(app.x);
            elseif app.DropDown_2.Value=="flanger"
                app.x=flanger([app.x app.x],app.fs);
            end
            app.x=app.x(:,1);
        end

        % Button pushed function: LoopingButton
        function LoopingButtonPushed(app, event)
            Nloop=app.NoLoopEditField.Value;
            X=[];
            for i=1:Nloop
                X=[app.x ; X];
            end
            app.x=X;
            app.t = (0:size(app.x,1)-1)/app.fs;
        end

        % Button pushed function: ReversingButton
        function ReversingButtonPushed(app, event)
            % Reverse audio
            app.x=flipud(app.x);
            app.t = (0:size(app.x,1)-1)/app.fs;
        end

        % Button pushed function: DisplayEditButton
        function DisplayEditButtonPushed(app, event)
            
            if app.DropDown.Value=="kaiser"
                win=kaiser(256,5);
                OLL=220;
                FFTL=512;
            elseif app.DropDown.Value=="hamming"
                win=hamming(256,'periodic');
                OLL=220;
                FFTL=512;
            elseif app.DropDown.Value=="hann"
                win=hann(256);
                OLL=220;
                FFTL=512;
            end
            
            [s,~,~]=stft(app.x,app.fs,"Window",win,"OverlapLength",OLL,"FFTLength",FFTL);

            sdb = mag2db(abs(s));
            figure(1)
            imshow((flipud(s)),'Colormap',jet)
            xlabel('Time')
            ylabel('Frequency')
            title('Select Spectrogram')
            h=drawfreehand;
            mask=h.createMask();
            close all
            Ymod=flipud(1-mask).*s; %apply mask
            ymod=istft(Ymod,app.fs,"Window",win,"OverlapLength",OLL,"FFTLength",FFTL);
            app.x=real(ymod);
            app.t = (0:size(app.x,1)-1)/app.fs;
        end

        % Button pushed function: EnvelopeButton
        function EnvelopeButtonPushed(app, event)
            Fs=440;
            Tend=max(app.t);
            numel(synth(Fs,Tend,[0 1],app.fs,'fm'))
            app.x=app.x+synth(Fs,Tend,[0 1],app.fs,'fm')';
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1154 473];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [16 238 366 222];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [409 238 332 222];

            % Create SelectionPanel
            app.SelectionPanel = uipanel(app.UIFigure);
            app.SelectionPanel.Title = 'Selection';
            app.SelectionPanel.Position = [27 23 131 201];

            % Create UploadFileButton
            app.UploadFileButton = uibutton(app.SelectionPanel, 'push');
            app.UploadFileButton.ButtonPushedFcn = createCallbackFcn(app, @UploadFileButtonPushed, true);
            app.UploadFileButton.Position = [17 131 100 30];
            app.UploadFileButton.Text = 'Upload File';

            % Create PlayButton
            app.PlayButton = uibutton(app.SelectionPanel, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [17 91 100 30];
            app.PlayButton.Text = 'Play';

            % Create SaveButton
            app.SaveButton = uibutton(app.SelectionPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [18 52 100 30];
            app.SaveButton.Text = 'Save';

            % Create RESETButton
            app.RESETButton = uibutton(app.SelectionPanel, 'push');
            app.RESETButton.ButtonPushedFcn = createCallbackFcn(app, @RESETButtonPushed, true);
            app.RESETButton.Position = [17 12 100 30];
            app.RESETButton.Text = 'RESET';

            % Create STFTPanel
            app.STFTPanel = uipanel(app.UIFigure);
            app.STFTPanel.Title = 'STFT';
            app.STFTPanel.Position = [202 22 242 201];

            % Create TransformButton
            app.TransformButton = uibutton(app.STFTPanel, 'push');
            app.TransformButton.ButtonPushedFcn = createCallbackFcn(app, @TransformButtonPushed, true);
            app.TransformButton.Position = [123 139 100 30];
            app.TransformButton.Text = 'Transform';

            % Create f_lowerHzEditFieldLabel
            app.f_lowerHzEditFieldLabel = uilabel(app.STFTPanel);
            app.f_lowerHzEditFieldLabel.Interpreter = 'latex';
            app.f_lowerHzEditFieldLabel.HorizontalAlignment = 'right';
            app.f_lowerHzEditFieldLabel.Position = [29 79 64 22];
            app.f_lowerHzEditFieldLabel.Text = '$f_{lower}$ (Hz)';

            % Create f_lowerHzEditField
            app.f_lowerHzEditField = uieditfield(app.STFTPanel, 'numeric');
            app.f_lowerHzEditField.Position = [108 79 100 22];

            % Create f_upperHzEditFieldLabel
            app.f_upperHzEditFieldLabel = uilabel(app.STFTPanel);
            app.f_upperHzEditFieldLabel.Interpreter = 'latex';
            app.f_upperHzEditFieldLabel.HorizontalAlignment = 'right';
            app.f_upperHzEditFieldLabel.Position = [28 52 65 22];
            app.f_upperHzEditFieldLabel.Text = '$f_{upper}$ (Hz)';

            % Create f_upperHzEditField
            app.f_upperHzEditField = uieditfield(app.STFTPanel, 'numeric');
            app.f_upperHzEditField.Position = [108 52 100 22];

            % Create FilterButton
            app.FilterButton = uibutton(app.STFTPanel, 'push');
            app.FilterButton.ButtonPushedFcn = createCallbackFcn(app, @FilterButtonPushed, true);
            app.FilterButton.Position = [109 12 100 30];
            app.FilterButton.Text = 'Filter';

            % Create BandPassFilterOptionLabel
            app.BandPassFilterOptionLabel = uilabel(app.STFTPanel);
            app.BandPassFilterOptionLabel.Position = [80 104 129 22];
            app.BandPassFilterOptionLabel.Text = 'BandPass Filter Option';

            % Create DropDown
            app.DropDown = uidropdown(app.STFTPanel);
            app.DropDown.Items = {'kaiser', 'hamming', 'hann'};
            app.DropDown.Position = [11 143 100 22];
            app.DropDown.Value = 'kaiser';

            % Create PlayBackPanel
            app.PlayBackPanel = uipanel(app.UIFigure);
            app.PlayBackPanel.Title = 'PlayBack';
            app.PlayBackPanel.Position = [496 22 245 201];

            % Create PitchSliderLabel
            app.PitchSliderLabel = uilabel(app.PlayBackPanel);
            app.PitchSliderLabel.HorizontalAlignment = 'right';
            app.PitchSliderLabel.Position = [19 152 32 22];
            app.PitchSliderLabel.Text = 'Pitch';

            % Create PitchSlider
            app.PitchSlider = uislider(app.PlayBackPanel);
            app.PitchSlider.Limits = [0 2];
            app.PitchSlider.MajorTicks = [0 0.5 1 1.5 2];
            app.PitchSlider.MajorTickLabels = {'0', '0.5', '1', '1.5', '2'};
            app.PitchSlider.MinorTicks = [0 0.5 1 1.5 2];
            app.PitchSlider.Position = [72 161 150 3];

            % Create TempoSliderLabel
            app.TempoSliderLabel = uilabel(app.PlayBackPanel);
            app.TempoSliderLabel.HorizontalAlignment = 'right';
            app.TempoSliderLabel.Position = [13 99 42 22];
            app.TempoSliderLabel.Text = 'Tempo';

            % Create TempoSlider
            app.TempoSlider = uislider(app.PlayBackPanel);
            app.TempoSlider.Limits = [0.5 1.5];
            app.TempoSlider.MajorTicks = [0.5 0.75 1 1.25 1.5];
            app.TempoSlider.MinorTicks = [0.5 0.75 1 1.25 1.5];
            app.TempoSlider.Position = [76 108 150 3];
            app.TempoSlider.Value = 1;

            % Create GenerateButton
            app.GenerateButton = uibutton(app.PlayBackPanel, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.Position = [97 22 100 31];
            app.GenerateButton.Text = 'Generate';

            % Create GranularConvolutionPanel
            app.GranularConvolutionPanel = uipanel(app.UIFigure);
            app.GranularConvolutionPanel.Title = 'Granular Convolution ';
            app.GranularConvolutionPanel.Position = [783 132 121 123];

            % Create ComputeButton
            app.ComputeButton = uibutton(app.GranularConvolutionPanel, 'push');
            app.ComputeButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeButtonPushed, true);
            app.ComputeButton.Position = [18 37 81 31];
            app.ComputeButton.Text = 'Compute';

            % Create LayerConvolutionPanel
            app.LayerConvolutionPanel = uipanel(app.UIFigure);
            app.LayerConvolutionPanel.Title = 'Layer Convolution';
            app.LayerConvolutionPanel.Position = [783 23 356 91];

            % Create ComputeButton_2
            app.ComputeButton_2 = uibutton(app.LayerConvolutionPanel, 'push');
            app.ComputeButton_2.ButtonPushedFcn = createCallbackFcn(app, @ComputeButton_2Pushed, true);
            app.ComputeButton_2.Position = [238 22 100 31];
            app.ComputeButton_2.Text = 'Compute';

            % Create File1Button
            app.File1Button = uibutton(app.LayerConvolutionPanel, 'push');
            app.File1Button.ButtonPushedFcn = createCallbackFcn(app, @File1ButtonPushed, true);
            app.File1Button.Position = [30 22 69 31];
            app.File1Button.Text = 'File 1';

            % Create File2Button
            app.File2Button = uibutton(app.LayerConvolutionPanel, 'push');
            app.File2Button.ButtonPushedFcn = createCallbackFcn(app, @File2ButtonPushed, true);
            app.File2Button.Position = [135 22 68 31];
            app.File2Button.Text = 'File 2';

            % Create AudioEffectPanel
            app.AudioEffectPanel = uipanel(app.UIFigure);
            app.AudioEffectPanel.Title = 'Audio Effect';
            app.AudioEffectPanel.Position = [931 131 209 124];

            % Create DropDown_2
            app.DropDown_2 = uidropdown(app.AudioEffectPanel);
            app.DropDown_2.Items = {'reverb', 'flanger'};
            app.DropDown_2.Position = [118 64 69 22];
            app.DropDown_2.Value = 'reverb';

            % Create AddButton
            app.AddButton = uibutton(app.AudioEffectPanel, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Position = [118 17 72 34];
            app.AddButton.Text = 'Add';

            % Create EnvelopeButton
            app.EnvelopeButton = uibutton(app.AudioEffectPanel, 'push');
            app.EnvelopeButton.ButtonPushedFcn = createCallbackFcn(app, @EnvelopeButtonPushed, true);
            app.EnvelopeButton.Position = [21 16 75 35];
            app.EnvelopeButton.Text = 'Envelope';

            % Create AdditionalFeaturesandEditsPanel
            app.AdditionalFeaturesandEditsPanel = uipanel(app.UIFigure);
            app.AdditionalFeaturesandEditsPanel.Title = 'Additional Features and Edits';
            app.AdditionalFeaturesandEditsPanel.Position = [785 287 354 137];

            % Create NoLoopEditFieldLabel
            app.NoLoopEditFieldLabel = uilabel(app.AdditionalFeaturesandEditsPanel);
            app.NoLoopEditFieldLabel.HorizontalAlignment = 'right';
            app.NoLoopEditFieldLabel.Position = [26 77 54 22];
            app.NoLoopEditFieldLabel.Text = 'No. Loop';

            % Create NoLoopEditField
            app.NoLoopEditField = uieditfield(app.AdditionalFeaturesandEditsPanel, 'numeric');
            app.NoLoopEditField.Position = [95 77 43 22];

            % Create LoopingButton
            app.LoopingButton = uibutton(app.AdditionalFeaturesandEditsPanel, 'push');
            app.LoopingButton.ButtonPushedFcn = createCallbackFcn(app, @LoopingButtonPushed, true);
            app.LoopingButton.Position = [32 20 100 31];
            app.LoopingButton.Text = 'Looping';

            % Create ReversingButton
            app.ReversingButton = uibutton(app.AdditionalFeaturesandEditsPanel, 'push');
            app.ReversingButton.ButtonPushedFcn = createCallbackFcn(app, @ReversingButtonPushed, true);
            app.ReversingButton.Position = [200 20 100 31];
            app.ReversingButton.Text = 'Reversing';

            % Create DisplayEditButton
            app.DisplayEditButton = uibutton(app.AdditionalFeaturesandEditsPanel, 'push');
            app.DisplayEditButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayEditButtonPushed, true);
            app.DisplayEditButton.Position = [200 69 100 31];
            app.DisplayEditButton.Text = 'Display Edit';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUI_NOV

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end