%% Intitial and constants
clearvars
addpath('..\Functions', '..\plotxx', '..\Figures', '..\DrosteEffect-BrewerMap-b6a6efc', '..\altmany-export_fig-9502702');
%Constants of the experiment
%Tau = 5;%5 Hz Linewidth
Linewidth = 1;
F = 1;
%Sweep = 1.3655;%MHz/ms 
%Decay time of metastable state
DecayTime = 35;
Graph3 = true;
%% Setup matrices
%Using Polarization, we can ignore +-1 transitions,
%so just +-2 transitions matter. b's we don't want, but they don't include
%an encoded state, blanks we don't want and include an encoded state, w's
%are transitions we want to make. Picked detuning frequency of -1092 MHz
TransSpread3level = [...
    "2:0" "2:+2.0" "b2:-1" "b2:+1.-1" "w1:-1" "1:0" "w1:+1" "b2:0.+2" ...
    "b2:-1+1" "2:+2" "b2:-2.0" "2:+1" "w2:0" "2:-1" "b2:+2.0" "2:-2" "b2:1.-1" "b2:0.-2"];
FreqsSpread = [...
    4000.431225 4007.011692 4011.11359 4017.699447 4020.050647 4037.321568 ...
    4054.150786 4058.065298 4062.327219 4064.645765 4066.428678 4068.913075 ...
    4073.019937 4076.887145 4079.600404 4080.376742 4083.473002 4086.968001 ...
    4026.636504 4047.56493]*1e6;
ClebschSpread = [...
    0 0.00745 0.01581 0.00527 0.035360338 0.070720676 0.035360338 0.010910894 0.013362742...
    0.026725484 0.010910894 0.013362742 0.026725484 0.013362742 0.010910894 0.026725484...
    0.013362742 0.010910894 ...
    0.035360338 0.035360338];
%3-level qudit encoded in levels
ThreeEncoded = [5 7 13];
%Other transitions that involve one of the 3 encoded levels
ThreeCare = [3 4 8 11 15 18 19 20];
ThreeCareTotal = [ThreeEncoded ThreeCare];
FreqsCare3level = zeros(length(ThreeCareTotal),1);
ClebschsCare3level = zeros(length(ThreeCareTotal),1);
%Generate all frequencies we care about
for i = 1:length(ThreeCareTotal)
    FreqsCare3level(i) = FreqsSpread(ThreeCareTotal(i));
    ClebschsCare3level(i) = ClebschSpread(ThreeCareTotal(i));
end 
TransSpread5level = [...
    "b2:0" "b2:+2.0" "b2:-1" "b2:+1.-1" "w1:-1" "1:0" "w1:+1" "b2:0.+2" ...
    "b2:-1+1" "w2:+2" "b2:-2.0" "2:+1" "w2:0" "2:-1" "b2:+2.0" "w2:-2" "b2:1.-1" "b2:0.-2"];
%5-level qudit encoded in levels
FiveEncoded = [5 7 10 13 16];
%Other transitions that involve one of the 5 encoded levels
FiveCare = [2 3 4 8 11 15 18 19 20];
FiveCareTotal = [FiveEncoded FiveCare];
FreqsCare5level = zeros(length(FiveCareTotal),1);
ClebschsCare5level = zeros(length(FiveCareTotal),1);
%Generate all frequencies we care about
for i = 1:length(FiveCareTotal)
    FreqsCare5level(i) = FreqsSpread(FiveCareTotal(i));
    ClebschsCare5level(i) = ClebschSpread(FiveCareTotal(i));
end 
TransSpread7level = [...
    "b2:0" "b2:+2.0" "b2:-1" "b2:+1.-1" "w1:-1" "w1:0" "w1:+1" "b2:0.+2" ...
    "b2:-1+1" "w2:+2" "b2:-2.0" "w2:+1" "w2:0" "w2:-1" "b2:+2.0" "2:-2" "b2:1.-1" "b2:0.-2"];
%7-level qudit encoded in levels
SevenEncoded = [5 6 7 10 12 13 14];
%Other transitions that involve one of the 7 encoded levels
SevenCare = [2 3 4 8 9 11 15 17 18 19 20];
SevenCareTotal = [SevenEncoded SevenCare];
FreqsCare7level = zeros(length(SevenCareTotal),1);
ClebschsCare7level = zeros(length(SevenCareTotal),1);
%Generate all frequencies we care about
for i = 1:length(SevenCareTotal)
    FreqsCare7level(i) = FreqsSpread(SevenCareTotal(i));
    ClebschsCare7level(i) = ClebschSpread(SevenCareTotal(i));
end 
%Setup sweep rate array
Sweep = logspace(8, 11, 1000);
Sweep = Sweep.';

%Setup Rabi Freqs
Rabi = 10e3:1e2:330e3;

%Different linewidths
Linewidths = [1 10 100 500 1000];

%Make a bunch of copies of the sweep rates and rabi freqs
SweepMat = repmat(Sweep, 1, length(Rabi));
RabiMat = repmat(Rabi, length(Sweep), 1);
%%
%Fluorescence calculations
Fluorescence3 = 2;
Fluorescence5 = 4;
Fluorescence7 = 6;
NA = 0.5;
Angle = asin(NA);
PercentCollected = sin(Angle/2)^2;
QE = 0.8;
P12Lifetime = 7.92e-9;
SaturationFluorescenceFreq = 1/(2*2*pi()*P12Lifetime);
AssumedFluorescenceFreq = SaturationFluorescenceFreq/4;
DetectionRate = AssumedFluorescenceFreq*PercentCollected*QE;
PhotonsToCollect = 10;
FluorescenceTime = PhotonsToCollect/DetectionRate;
format long g;

%Setup the figure
fig = figure(5);
set(fig,'defaultAxesColorOrder',[[26 146 186]/255; [50 181 107]/255]);
%Threshold to display
Thresh = 0.6;
%yyaxis left;
%Set background color white
set(gcf,'color','white');
%set(LevRight, 'line
ax5 = gca;
Leg = {};
numGraphs = 1;
%Calculate probabilities for each linewidth, graph
for i = 1:length(Linewidths)
    [ProbIdeal3Level, TotalTransferTime3] = Prob3level(Rabi, RabiMat, Linewidths(i), SweepMat, Sweep, FreqsCare3level, F, ClebschsCare3level, DecayTime);
    %Calculate overall fluorescence time, add in decay error during fluorescence
    if Graph3
        TotalfTime3 = FluorescenceTime*Fluorescence3;
        ProbIdeal3Level = ProbIdeal3Level.*exp(-TotalfTime3/DecayTime);
        IdealGateTimes3 = TotalTransferTime3;
        RabiGateTimeIdeal3 = [Rabi.' IdealGateTimes3' ProbIdeal3Level.'];
        %Get best probabilities for each Rabi, gate time, print the best fidelities
        %for each qudit, calculate total time for the whole measurement
        Fidelities3 = RabiGateTimeIdeal3(:,3);
        GateTimes3 = RabiGateTimeIdeal3(:,2);
        Rabis3 = RabiGateTimeIdeal3(:,1);
        disp(max(Fidelities3));
        TotalTime3 = GateTimes3 + TotalfTime3;
        Fidelities3(Fidelities3<Thresh) = -inf;
        %Graph
        Lev3 = semilogx(TotalTime3, Fidelities3);
        hold on;
        set(Lev3, 'Linewidth', 1.5, 'Color', [(128- 25*i) (0 + 40*i) 132]/255);
        Leg{numGraphs} = ['\Gamma = ' num2str(Linewidths(i))];
        numGraphs = numGraphs + 1;
    end
end
%% Graph the data

l3 = legend(Leg, 'Location', 'Northeast','FontSize',14);
%ax5.Title.String = 'Qudit measurement fidelity';
%ax5.Title.FontSize = 30;
ax5.FontSize = 14;
ax5.XLabel.String = 'Total measurement time (ms)';
ax5.XLabel.FontSize = 20;
ax5.YLabel.String = '3-level Fidelity';
ax5.YLabel.FontSize = 20;
set(ax5, 'YTick', 0:0.1:1,...
    'YMinorTick', 'on', 'TickDir', 'out',...
    'YGrid', 'on', 'XGrid', 'on',...
    'XTickLabel', [0.1 1 10 100 1000])
set(gcf, 'Position', [100 100 600 500]);
axis([0.0005 .3 0.6 1])
%xlim([0.1 1000]);
%set(gcf, 'Renderer', 'opengl');
%saveas(gcf, 'Overall_Measurement.pdf');
%export_fig Overall_Measurement.pdf
%export_fig('3-Level_Linewidth-Fidelity.pdf', '-pdf', '-opengl')