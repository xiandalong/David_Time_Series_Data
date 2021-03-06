clear;clc;close all;
%% Preprocessing 
% %%%%%% their version %%%%%%%%%%%%%%%%%%%%%%%
% load('DATA.mat');
% % isaA_otu=interpotu(days,saA_otu(1:100,:));
% isaA_otu=interpotu(days,saA_otu);
% isaA_notu=normotu(isaA_otu);
% % istA_otu=interpotu(stA_day,stA_otu(1:100,:));
% istA_otu=interpotu(stA_day,stA_otu);
% istA_notu=normotu(istA_otu);
% % istB_otu=interpotu(stB_day,stB_otu(1:100,:));
% istB_otu=interpotu(stB_day,stB_otu);
% istB_notu=normotu(istB_otu);
% [isaA_phy,saA_label]=phylumotu(isaA_notu,OTU_label);
% [istA_phy,stA_label]=phylumotu(istA_notu,OTU_label);
% [istB_phy,stB_label]=phylumotu(istB_notu,OTU_label);
% 
% plot(isaA_phy');
% print('Figures/raw TS plots/norm_interp_OTU_phy_TS_saliva_A_stu','-dtiff');
% plot(istA_phy');
% print('Figures/raw TS plots/norm_interp_OTU_phy_TS_stool_A_stu','-dtiff');
% plot(istB_phy');
% print('Figures/raw TS plots/norm_interp_OTU_phy_TS_stool_B_stu','-dtiff');

%%%%%% my version %%%%%%%%%%%%%%%%%%%%%%%%%%
load('DATA.mat');
% 1. combine the absolute abundance together
[saA_phy,saA_label]=phylumotu(saA_otu,OTU_label);
[stA_phy,stA_label]=phylumotu(stA_otu,OTU_label);
[stB_phy,stB_label]=phylumotu(stB_otu,OTU_label);
% 2. interpolation for the days with missing values
isaA_phy=interpotu(saA_day,saA_phy);
istA_phy=interpotu(stA_day,stA_phy);
istB_phy=interpotu(stB_day,stB_phy);
% 3. normalization for each day to get relative abundance
isaA_nphy=normotu(isaA_phy);
istA_nphy=normotu(istA_phy);
istB_nphy=normotu(istB_phy);

% plot(days(1):days(end),i_nphy');
% xlabel('Day in a year');
% ylabel('Relative Abundance(%)');
% print('Figures/raw TS plots/norm_cubicinterp_OTU_phy_TS_saliva_A_mine','-dtiff');
% plot(stA_day(1):stA_day(end),istA_nphy');
% xlabel('Day in a year');
% ylabel('Relative Abundance(%)');
% print('Figures/raw TS plots/norm_cubicinterp_OTU_phy_TS_stool_A_mine','-dtiff');
% plot(stB_day(1):stB_day(end),istB_nphy');
% xlabel('Day in a year');
% ylabel('Relative Abundance(%)');
% print('Figures/raw TS plots/norm_cubicinterp_OTU_phy_TS_stool_B_mine','-dtiff');


% subject A relocated to Southeast Asia between day 71 and 122

% the indices for most abundant phylums:
% saliva A: [10 17 5 2 20];
% stool A: [10 5 2 24 17];
% stool B: [5 10 24 17 26 2];

% t_range = 26:70;
% t_range = 71:122;
% t_range = 123:364;



%%%%% choose sample %%%%%%%%%%%%%%%%%%%%%%%%%
%%%% saliva A %%%%%%%%%%%%%%%%%%% 
% days = saA_day; 
% i_nphy = isaA_nphy; 
% sample_name = 'saliva A';
% phy_label = saA_label;
% top_phys = [10 17 5 2 20];
% time_ranges = [26 70;71 122;123 364];
%%%% stool A %%%%%%%%%%%%%%%%%%%%
% days = stA_day; 
% i_nphy = istA_nphy; 
% sample_name = 'stool A';
% phy_label = stA_label;
% top_phys = [10 5 2 24 17];
% time_ranges = [0 70;71 122;123 364];

%%%% stool B %%%%%%%%%%%%%%%%%%%%
days = stB_day; 
interp_nphy = istB_nphy; 
sample_name = 'stool B';
phy_label = stB_label;
top_phys = [5 10 24 17 26 2];
time_ranges = [0 150;151 159;160 318];

%%%%% choose sample %%%%%%%%%%%%%%%%%%%%%%%%%

Fs = 1; % data were sampled once per day
T = 3; %%%%% choose time region %%%%%%%%%%%%%
t_range = time_ranges(T,1):time_ranges(T,2);

%%%%%% get time series of phylums with NaNs (raw data wo interpolation)
% get the day indices for missing days
days_all = days(1):days(end);
NaN_days = setdiff(days_all,days)-days(1)+1;

% set the days with missing values to NaN (on normalized phylum series)
nphy_wNaN = interp_nphy;
nphy_wNaN(:,NaN_days)=NaN;

%%%%%%%%%%%%%%  plotting raw data %%%%%%%%%%%%%%%%%%%%%
phy_index = 10;

figure
hold on
for i = top_phys
plotTimeSeries(time_ranges,nphy_wNaN(i,:));
end
legend(saA_label(top_phys));
plot([time_ranges(2,1) time_ranges(2,1)],[0 max(max(nphy_wNaN))],'k--');
plot([time_ranges(3,1) time_ranges(3,1)],[0 max(max(nphy_wNaN))],'k--');
xlabel('days')
ylabel('relative abundance')
print(['Figures/raw TS plots/',sample_name,' top 5'],'-dtiff')
savefig(['Figures/raw TS plots/',sample_name,' top 5'])


%% getting the periodiocity information


%%%%%%%%%%%%%%%%%%%% FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT on the whole time series (interpolated)
%%%% a. plotting magnitude of signal %%%%%%%%%%%%%%%%%%%%%%%%

figure
hold on
for i = top_phys
    ts= interp_nphy(i,t_range-(time_ranges(1)-1));
    plotFFTPSD(ts,Fs);
end
ax = gca;
ax.XLim = [0 0.5];
xlabel('Frequency (cycles/day)')
ylabel('PSD')
title('FFT power spectrum')
legend(saA_label(top_phys))
% print('Figures/periodicity/FFT PSD example','-dtiff');
print(['Figures/periodicity/FFT PSD ',sample_name,' T',num2str(T)],'-dtiff');
savefig(['Figures/periodicity/FFT PSD ',sample_name,' T',num2str(T)]);

%%%% b. plotting phase of signal %%%%%%%%%%%%%%%%%%%%%%%%%%
figure
hold on
for i = top_phys
    ts= interp_nphy(i,t_range-(time_ranges(1)-1));
    plotFFTPhase(ts,Fs);
end
ax = gca;
ax.XLim = [0 0.5];
xlabel('Frequency (cycles/day)')
ylabel('radians')
title('FFT Phase response')
legend(saA_label(top_phys))
print(['Figures/periodicity/FFT phase response ',sample_name,' T',num2str(T)],'-dtiff');
savefig(['Figures/periodicity/FFT phase response ',sample_name,' T',num2str(T)]);

%%%%%%%%%%%%%%%%%%%% Lomb-Scargle method %%%%%%%%%%%%%%%%%
% set the interpolated values back to NaNs
figure
hold on
for i = top_phys
    ts_wNaN= nphy_wNaN(i,t_range-(time_ranges(1)-1));
    plotLSPSD(ts_wNaN,Fs);
end
xlabel('Frequency (day^{-1})');
ylabel('PSD')
title('Lomb-Scargle Power Spectrum')
legend(saA_label(top_phys))
ax = gca;
ax.XLim = [0 0.5];
print(['Figures/periodicity/Lomb-Scargle PSD ',sample_name,' T',num2str(T)],'-dtiff');
savefig(['Figures/periodicity/Lomb-Scargle PSD ',sample_name,' T',num2str(T)]);

%%%%%%%%%%%%%%%%%%%% auto-correlation %%%%%%%%%%%%%%%%%%%%
figure
hold on
for i = top_phys
    plotAuto(interp_nphy(i,t_range-(time_ranges(1)-1)),Fs);
end
xlabel('Lag (days)')
ylabel('Autocorrelation')
legend(saA_label(top_phys))
print(['Figures/periodicity/autocorrelation ',sample_name,' T',num2str(T)],'-dtiff');
savefig(['Figures/periodicity/autocorrelation ',sample_name,' T',num2str(T)]);

% axis([-21 21 -0.4 1.1])
