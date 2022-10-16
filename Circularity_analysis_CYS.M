clc; clear; close all;

for j=1:3
    % Get the tif file of sample.
    img_name = ['agg_1',int2str(j),'.tif'];
    i = imread(img_name);
    
    % Save as pixels with brightness >10 as 1 and brightness <= 10 as 0
    % bw = 0 or 1
    bw = i>10;
    
    % Remove all object containing fewer than 300 pixels
    bw = bwareaopen(bw,300);
    
    % Fill a gap to complete the disk-shaped structure
    se = strel('disk',100);
    bw = imclose(bw,se);
    
    % Fills holes in the input binary image bw
    bw = imfill(bw,'holes');
    
    % Find the boundaries
    [B,L] = bwboundaries(bw,'noholes');
    figure;
    
    % Draw each boundary
    imshow(i)
    hold on
    for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2),boundary(:,1),'r','LineWidth',2)
    end
    
    % Use regionprops to obtain estimates of the area and centroid for all of the objects 
    stats = regionprops(L,'Area','Centroid');

    % loop over the boundaries
    for k = 1:length(B)

      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};

      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));

      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;

      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;

      % display the results
      metric_string = sprintf('%2.2f',metric);

      text(boundary(1,2)+40,boundary(1,1)+13,metric_string,'Color','r',...
           'FontSize',14,'FontWeight','bold')
    end
end