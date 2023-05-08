% this function is used to draw the convergence process graph
function plot_function(Data,Param,flag)

%% If flag is valid, only the L and Q curves of the optimal sample are drawn
if flag == 1
    figure()
    h1 = subplot(2,1,1);
    plot(Data.freq, Data.L(:,Data.best(end)),'linewidth',2);
    legend('L');
    title(h1,"the best L");
    xlabel("f(GHz)");
    ylabel("L(nH)");
    h2 = subplot(2,1,2);
    plot(Data.freq, Data.Q(:,Data.best(end)),'linewidth',2);
    legend('Q');
    title(h2,"the best Q");
    xlabel("f(GHz)");
    ylabel("Q");
    return;
end

%% Otherwise draw the following curves
close all;
figure()
h1 = subplot(2,2,1);
% drawing the maximum value of Q when maximizing Q
plot(h1,Data.Q(Param.numTarget(1),Data.best(Param.numSample+1:end)),'b-o','linewidth',1);
ylabel(h1,"Q");
title(h1,'Max Q');
xlabel(h1,'iter');
xlim(h1,[1 Param.numIter]);

% figure 2 draws the L at the target frequency
h2 = subplot(2,2,2);
plot(Data.preL(Param.numTarget(1),Param.numSample+1:end)-Data.preError(Param.numSample+1:end,1)','r-o','linewidth',1);
hold on
plot(Data.preL(Param.numTarget(1),Param.numSample+1:end),'r-x','linewidth',1);
ylabel("nH");
xlim([1 Param.numIter]);
xlabel(h2,'iter');
title(h2,"L");

% figure 3 draws the Q at the target frequency
h3 = subplot(2,2,3);
plot(Data.preQ(Param.numTarget(1),Param.numSample+1:end)-Data.preError(Param.numSample+1:end,2)','r-o','linewidth',1);
hold on
plot(Data.preQ(Param.numTarget(1),Param.numSample+1:end),'r-x','linewidth',1);
xlim([1 Param.numIter]);
xlabel(h3,'iter');
title(h3,"Q");

% figure 4 illustrates the Q at SRF
h4 = subplot(2,2,4);
plot(Data.preQ(Param.numTarget(2),Param.numSample+1:end)-Data.preError(Param.numSample+1:end,3)','r-o','linewidth',1);
hold on
plot(Data.preQ(Param.numTarget(2),Param.numSample+1:end),'b-x','linewidth',1);
xlim([1 Param.numIter]);
xlabel(h4,'iter');
title(h4,strcat("Q@",num2str(Param.targetSRF),"GHz"));

end