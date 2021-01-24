function [holeDetected,Circmcenter,circumradius,F3,F4]= holeDetection(TRI,nodes,...
                                                    F1,F2,Trange,area,figureno,flag)
%%
%flag= whether to plot or not; 1 to plot, 0 not to plot
%%

TR = triangulation(TRI,nodes.pos(:,1),nodes.pos(:,2));
[Circmcenter,circumradius] = circumcenter(TR);   % calculate the circumcenter of each triangle
% remove the circumcenter outside the area
% ind=Circmcenter(:,1)>area(1);
% Circmcenter(ind,:)=[];
% circumradius(ind,:)=[];
% ind1=Circmcenter(:,2)>area(2);
% Circmcenter(ind1,:)=[];
% circumradius(ind1,:)=[];
% TR.ConnectivityList(ind,:)=[];
% TR.ConnectivityList(ind1,:)=[];
% TRI(ind,:)=[];
% TRI(ind1,:)=[];
% calculate the adjacent traingle common side distance and detect holes
holeDetected=zeros(size(TRI,1),1);
for ii=1:size(TRI,1)
    % condition to check if circulcenter is  not outside the area
    if 0<Circmcenter(ii,1)&&Circmcenter(ii,1)<area(1)&&0<Circmcenter(ii,2)...
                                                     &&Circmcenter(ii,2)<area(2)
        ID = edgeAttachments(TR,TRI(ii,1),TRI(ii,end)); % neighboring traingle ID
        neighboringID=cell2mat(ID);
        if numel(neighboringID)~=1 % on condition if no adjacent traingle exist
            
            commonsideIndex=ismember(TRI(ii,:),TRI(neighboringID(2),:));
            commonside=TRI(ii,commonsideIndex);
            if ~isempty(commonside) % check if both traingles sides are common
                if flag==1
                    figure(figureno)
                    F3=line([TR.Points(commonside(1),1),TR.Points(commonside(2),1)],...
                        [TR.Points(commonside(1),2),TR.Points(commonside(2),2)],...
                        'Color','black','LineStyle','--');
                end
                
                commomnside_dist=pdist([TR.Points(commonside(1),:);TR.Points(commonside(2),:)]);
                
                %check if distance is greater than twice of sensor radius(paper[24])
                if commomnside_dist>2*Trange
                    holeDetected(ii,1)=1;
                    triangleNodes=TRI(ii,:);
                    if flag==1
                        for kk=1:3
                            x(kk)=TR.Points(triangleNodes(kk),1);
                            y(kk)=TR.Points(triangleNodes(kk),2);
                        end
                        
                        F4=fill(x,y,'c');
                        alpha 0.1
                    end
                else
                    holeDetected(ii,1)=0;
                end
            end
        end
    end
end

% plot the hole circle
if flag==1
    holeTriangleIndex=find(holeDetected);
    for ii=1:numel(holeTriangleIndex)
        [x,y]=circle(Circmcenter(holeTriangleIndex(ii),1),...
            Circmcenter(holeTriangleIndex(ii),2),abs(Trange-circumradius(holeTriangleIndex(ii))));
        F5=plot(x,y,'.g');
        clear x y
        hold on
    end
end

ylim([-area(2)/6,area(2)+area(2)/6])
xlim([-area(2)/6,area(1)+area(2)/6])
if flag==1
    if exist('F4','var')&& exist('F5','var')
%         legend([F1,F2,F3,F4,F5],{'nodes','covered Area','common side','holes','IESC'},'Location',...
%             'north','Orientation','Horizontal')
    else
%         legend([F1,F2,F3],{'nodes','covered Area','common side'},'Location',...
%             'north','Orientation','Horizontal')
        F4=[]; F5=[];
    end
end