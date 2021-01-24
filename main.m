close all
clear
clc
addpath(genpath(cd))
warning('off')
%%
N=10;                       % number of nodes
area=[10,10];              % nodes deployment area in meter
Trange=2;                   % transmission range of sensor node in meter
nodes.pos=area(1).*rand(N,2);% nodes geographical locations
lambda=0.125;                % signal wavelength in meter
nodes.major = Trange;        % major axis for ellpitical range in meter
nodes.minor = lambda*Trange;  % minro axis for ellipitical range in meter
% redundantNo=9;               % number of healing nodes   
redundantNo=round(10*N/100);
%% plot the nodes deployment
cnt=1;
for ii=1:N      
    for jj=1:N
        if ii~=jj
            nodes.distance(ii,jj)=pdist([nodes.pos(ii,:);nodes.pos(jj,:)]);
            if nodes.distance(ii,jj)<Trange || nodes.distance(ii,jj)==Trange
                nodes.inrange(ii,jj)=1;
            else
                nodes.inrange(ii,jj)=0;
            end
        end
    end
end

figure
F5=plot(nodes.pos(:,1),nodes.pos(:,2),'.','color','r');
hold on
for ii=1:N                   % plot the circular transmission range
    [nodes.circle.x(ii,:),nodes.circle.y(ii,:)]=circle(nodes.pos(ii,1),nodes.pos(ii,2),Trange);
    F6=fill(nodes.circle.x(ii,:),nodes.circle.y(ii,:),[0.25,0.25,0.25]);
    alpha 0.3
    hold on
end
axis on
xlabel('x(m)')
ylabel('y(m)')
title('Initial Placement of Nodes with circular transmission range')
%% plot delauny triangle
TRI = delaunay(nodes.pos(:,1),nodes.pos(:,2));
figure(2)
F5 = plot(nodes.pos(:,1),nodes.pos(:,2),'.','color','r');
hold on
for ii=1:N                   % plot the circular transmission range
    [nodes.circle.x(ii,:),nodes.circle.y(ii,:)]=circle(nodes.pos(ii,1),nodes.pos(ii,2),Trange);
    F6=fill(nodes.circle.x(ii,:),nodes.circle.y(ii,:),[0.25,0.25,0.25]);
    alpha 0.3
    hold on
end
axis on
xlabel('x(m)')
ylabel('y(m)')
title('Coverage hole in initila position of Nodes')
hold on
triplot(TRI,nodes.pos(:,1),nodes.pos(:,2))
%% Hole detection
[holeDetected.circle,Circmcenter.circle,circumradius.circle]=holeDetection(TRI,nodes,F5,F6,Trange,area,2,1);
display(['--> No of detected Holes for Circular = ',num2str(numel(find(holeDetected.circle)))])
%% PSO optimize position of rest wsn nodes to cover the hole
nvars = 2*(N);
fun=@(x)objf(x,Trange,area);
lb=zeros(nvars,1);
ub=area(1).*ones(nvars,1);
options = optimoptions(@particleswarm,'Display','iter','MaxIterations',100,'PlotFcn','pswplotbestf');
[x,fval] = particleswarm(fun,nvars,lb,ub,options);
finalPos = reshape(x,[numel(x)/2,2]);
% plot the final tuned Node' pos
figure
plot(finalPos(:,1),finalPos(:,2),'o','color','r');
hold on
for ii=1:N                 % plot the circular transmission range
    [finalcircle.x(ii,:),finalcircle.y(ii,:)]=circle(finalPos(ii,1),finalPos(ii,2),Trange);
    fill(finalcircle.x(ii,:),finalcircle.y(ii,:),[0.25,0.25,0.25]);
    alpha 0.3
    hold on
end
axis on
xlabel('x(m)')
ylabel('y(m)')
title('Optimized location of Nodes with circular transmission range')