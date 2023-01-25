% By this code, we generate mean MSD, mean alpha, mean diffusion coefficient matrix for whole particle
% and mean MSD, mean alpha, mean diffusion coefficient matrix, mean displacement matrix per cell.


% In this code, we used MSD analyzer Matlab msdanalyzer class;
% Jean-Yves Tinevez (2022). Mean square displacement analysis of particles trajectories
% (https://github.com/tinevez/msdanalyzer), GitHub.


% Input data: single particle tracking data generated using ImageJ TrackMate plug-in.

%output 1: 'target_ctrl(or siRNA)_cell#_****.xlsx', ****: D, alpha, msd, displacement
%        data of all particles per cell
%output 2: 'per_cell_target_ctrl(or siRNA)_****.xlsx', ****: D, alpha, msd, displacement
%       mean data
%output 3: 'whole_target_ctrl(or siRNA)_****.xlsx', ****: D, alpha, msd, displacement, track length
%        data of all particles of whole input cells

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the XML file of track.
% target: target protein;
% con_si: ctrl or siRNA sample;
% numofstep: the number of frames that will be used for msd calculation.
% In this study, we use 21 frames (4 seconds) for analysis.
% clip_factor: portion of tracks that used for calculation.

samplename = input("Enter start sample number of target XML file: ");
samplename2 = input("Enter end sample number of target XML file: ");
target = input("target?",'s');
con_si = input("control or siRNA?",'s');
numofstep = input("Enter the # of steps (ex) 21: ");
clip_factor = [0.25, 0.5, 1];

% matrices for output 2.
mean_alpha_per_cell = [];
mean_D_per_cell = [];
mean_msd_per_cell = [];
mean_displacement_per_cell =[];

% matrices for output 3.
whole_alpha=[];
whole_displacement = [];
whole_D=[];
whole_MSD=[];
track_length =[];

for sam_num = samplename:1:samplename2
    name = strcat(num2str(sam_num), '.xml');
    candidate = importTrackMateTracks(strcat(num2str(sam_num), '.xml'), true);
    
    % matrices for output 1.
    dis_per_p=[];
    msd_per_p=[];
    alpha_per_p =[];
    D_per_p =[];
    
    valid_track_indices=[];

    % Track filtering: tracks longer than threshold.
    [r,c]= cellfun(@size,candidate);
    filtered_tracks = candidate(r>(numofstep-1));

    % Track sorting: rows of each track in time sequence.
    filtered_tracks = cellfun(@sortrows,filtered_tracks,'UniformOutput',false);

    % Converting Track data as correct unit.
    % space_units: pixel(0.13µm) to µm, time_units:frames(0.2s) to s.
    for k = 1: numel(filtered_tracks)
        filtered_tracks{k}(:,1) = filtered_tracks{k}(:,1).*(0.2);
        filtered_tracks{k}(:,2:3) = filtered_tracks{k}(:,2:3).*(0.13);
    end

    % Get whole tracks from XML file. clipZ option: true.
    % wholetrack: msdanalyzer of whole length of tracks (for displacement calculation).
    wholetrack = msdanalyzer(2,'µm','s');
    wholetrack = wholetrack.addAll(filtered_tracks);

    % Use only the ealier part of tracks.
    % ma: msdanalyzer for processed track.
    filtered_tracks = cellfun(@(x) x(1:numofstep,1:3),filtered_tracks,'UniformOutput',false);
    ma = msdanalyzer(2, 'µm', 's');
    ma=ma.addAll(filtered_tracks);

    %fit log(meanMSD) vs log(t) by linear fitting
    % to get each Diffusion coefficients and alpha values.
    % Reference: MATLAB msdanalyzer class functions
    ma = ma.computeMSD;
    ft = fittype('poly1');
    ind=0;
    for j = clip_factor
        ind=ind+1;
        valid_ind=0;
        for k = 1 : numel(ma.msd)
            msd_spot = ma.msd{k};
            t = msd_spot(:,1);
            y = msd_spot(:,2);
            w = msd_spot(:,4);
            t_limit = 1 : (round((numel(t)-1) * j)+1);
            t = t(t_limit);
            y = y(t_limit);
            w = w(t_limit);
            xl = log(t);
            yl = log(y);
            % Thrash bad data
            bad_log =  isinf(xl) | isinf(yl);
            xl(bad_log) = [];
            yl(bad_log) = [];
            w(bad_log) = [];
            if numel(xl) < 2
                continue
            end
            [fo, gof] = fit(xl, yl, ft);
            % Diffusion coefficient = (10^intercept)/4
            D = power(10,fo.p2)/4;
            if D>0
                valid_ind=valid_ind+1;
                if ind == 1
                    valid_track_indices = [valid_track_indices k];
                end
                alpha_per_p(valid_ind,ind) = fo.p1;
                D_per_p(valid_ind,ind) = D;
            end
        end
        mean_alpha_per_cell(sam_num-samplename+1,ind)=[mean(alpha_per_p(:,ind))];
        mean_D_per_cell(sam_num-samplename+1,ind) = [mean(D_per_p(:,ind))];
    end
    whole_alpha = [whole_alpha; alpha_per_p];
    whole_D = [whole_D; D_per_p];

    %msd
    for i = 1:numel(valid_track_indices)
        index = valid_track_indices(i);
        msd_spot = ma.msd{index};
        msd_per_p= [msd_per_p msd_spot(:,2)];
    end
    mean_msd_per_cell =[mean_msd_per_cell mean(msd_per_p,2)];
    whole_MSD = [whole_MSD msd_per_p];
    
    %storing output 1...
    writematrix(alpha_per_p, strcat(target,'_',con_si,'_',num2str(sam_num),'_alpha.xlsx'),'WriteMode','append');
    writematrix(D_per_p, strcat(target,'_',con_si,'_',num2str(sam_num),'_D.xlsx'),'WriteMode','append');
    writematrix(msd_per_p, strcat(target,'_',con_si,'_',num2str(sam_num),'_msd.xlsx'),'WriteMode','append');

    %displacement, track_size
    for i = 1:numel(valid_track_indices)
            index = valid_track_indices(i);
            track = wholetrack.tracks{index};
            dis_per_p = [dis_per_p; norm(track(end,2:3)-track(1,2:3))];
            [r1,c1]=size(track);
            track_length =[track_length; r1];
    end
    mean_displacement_per_cell = [mean_displacement_per_cell; mean(dis_per_p)];
    whole_displacement = [whole_displacement; dis_per_p];
    
    %storing output 1...
    writematrix(dis_per_p,strcat(target,'_',con_si,'_',num2str(sam_num),'_displacement.xlsx'),'WriteMode','append');
end

%storing output 2...
writematrix(mean_alpha_per_cell,strcat('per_cell_',target,'_',con_si,'_alpha.xlsx'),'WriteMode','append');
writematrix(mean_D_per_cell,strcat('per_cell_',target,'_',con_si,'_D.xlsx'),'WriteMode','append');
writematrix(mean_displacement_per_cell,strcat('per_cell_',target,'_',con_si,'_displacement.xlsx'),'WriteMode','append');
writematrix(mean_msd_per_cell,strcat('per_cell_',target,'_',con_si,'_msd.xlsx'),'WriteMode','append');

%storing output 3...
writematrix(whole_alpha,strcat('whole_',target,'_',con_si,'_alpha.xlsx'),'WriteMode','append');
writematrix(whole_D,strcat('whole_',target,'_',con_si,'_D.xlsx'),'WriteMode','append');
writematrix(whole_displacement,strcat('whole_',target,'_',con_si,'_displacement.xlsx'),'WriteMode','append');
writematrix(whole_MSD,strcat('whole_',target,'_',con_si,'_msd.xlsx'),'WriteMode','append');
writematrix(track_length,strcat('whole_',target,'_',con_si,'_track_length.xlsx'),'WriteMode','append');
