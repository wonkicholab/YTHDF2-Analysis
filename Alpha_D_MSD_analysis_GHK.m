% Analyze the alpha value and diffusion coefficient from single particle tracking data generated using ImageJ TrackMate plug-in.
% In this code, we used MSD analyzer Matlab msdanalyzer class;
% Jean-Yves Tinevez (2022). Mean square displacement analysis of particles trajectories (https://github.com/tinevez/msdanalyzer), GitHub.


% Get the XML file of track.
samplename = input("Enter sample name of target XML file (ex)cell1: ",'s');
% Get whole tracks from XML file. clipZ option: true.
candidate = importTrackMateTracks(strcat(samplename, '_Tracks.xml'), true);

% Track filtering: tracks longer than threshold(20 frames).
[r,c]= cellfun(@size,candidate);
filtered_tracks = candidate(r>20);
% Track sorting: rows of each track in time sequence.
filtered_tracks = cellfun(@sortrows,filtered_tracks,'UniformOutput',false);

% wholetrack: msdanalyzer for whole length of tracks.
% track's dimensionality: 2, space_units: microns, time_units:frame.
wholetrack = msdanalyzer(2,'microns','frame');
wholetrack = wholetrack.addAll(filtered_tracks);

% Further filtering for msd analysis.
% Use only the ealier part of tracks.
% numofstep: the part of tracks that will be used for msd calculation.
numofstep = input("Enter the # of steps (ex) 21: ");
filtered_tracks = cellfun(@(x) x(1:numofstep,1:3),filtered_tracks,'UniformOutput',false);

% ma: msdanalyzer for processed track.
% track's dimensionality: 2, space_units: microns, time_units:frame.
ma = msdanalyzer(2, 'microns', 's');
ma=ma.addAll(filtered_tracks);


% MSD
ma = ma.computeMSD;
% msdmatrix: ma.msd output
%           [dt(delay for the MSD) mean(mean MSD value for this delay)
%           std(standard deviation) N(number of points in the average)]
% dtmsd: [dt mean_MSD] matrix for msd calculation
msdmatrix = cell2mat(ma.msd);
dtmsd = msdmatrix(:,2);
dtmsd = reshape(dtmsd,numofstep,[]);


% Distribution coefficient calculation with reference to MATLAB msdanalyzer class functions.
% store_p: gradient values of mean msd vs frame plot of each track.
% track_indices: save the indices of valid tracks having positive D values.
p = zeros;
store_p=[];
track_indices = [];
for i = 1 : size(dtmsd,2)
     y=dtmsd(:,i);
     % 1 frame = 200 ms
     x=(0:0.2:0.2*(numofstep-1));
     xre=reshape(x,numofstep,1);
     p=polyfit(xre,y,1);
     plot(xre,y);
     % Below line is for track filtering: only tracks that have p(1,1)>0.
     % Because distribution coefficient must be positive.
     if p(1,1) > 0
            coef=p(1,1)./4;
            slope=coef(1,1);
            store_p = [store_p slope];
            track_indices = [track_indices i];
      end
end
store_p = reshape(store_p,[],1);
writematrix(store_p,strcat(samplename,'_D_value.xlsx'),'WriteMode','append');


% Alpha calculation with reference to MATLAB msdanalyzer class functions.
ft = fittype('poly1');
alphas = [];
for i = 1: numel(track_indices)
    index = track_indices(i);
    t = msdmatrix((index-1)*numofstep+1:(index-1)*numofstep+numofstep,1); % dt
    y = msdmatrix((index-1)*numofstep+1:(index-1)*numofstep+numofstep,2); % mean MSD
    w = msdmatrix((index-1)*numofstep+1:(index-1)*numofstep+numofstep,4); % N(number of points in the average)
    xl = log(t);
    yl = log(y);
    % Thrash bad data
    bad_log =  isinf(xl) | isinf(yl);
    xl(bad_log) = [];
    yl(bad_log) = [];
    w(bad_log) = [];
    [fo, gof] = fit(xl, yl, ft, 'Weights', w);
    alphas = [alphas fo.p1];
end
alphas = reshape(alphas,[],1);
writematrix(alphas,strcat(samplename,'_alphas.xlsx'),'WriteMode','append');

%displacement
displacement = [];
for i = 1: numel(track_indices)
        index = track_indices(i);
        track = wholetrack.tracks{index};
        displacement = [displacement norm(track(end,2:3)-track(1,2:3))];
end
displacement = reshape(displacement,[],1);
delete(strcat(samplename,'_filtered_displacement.xlsx'));
writematrix(displacement,strcat(samplename,'_displacement.xlsx'),'WriteMode','append');
