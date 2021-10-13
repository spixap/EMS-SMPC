classdef DataX < handle
    % DataX class can perform the following operations on its objects:
    % 1) --Group
    % 2) --Ungroup
    % 3) --Interpolate
    % 4) --Average
    % 5) --Pick Scenario
    % 6) --Calculate reduced scenario set
    % 7) --Rank scenarios based on Kantorovich distance index
    % 8) --Cluster grouped data
    % 9) --Draw Elbow plot
    % 10)--Sample a fitted Copula function and calculate the sample's Energy Score
    % 11)--Perform the 2-dimensional mapping based on Kantorovich metric
    %
    % Static Methods:
    % 1) --Calculate the Energy Score for a set of generated trajectories
    %-------------------------------------------------------
    % Example of creating an onject (test1) of this class:
    % test1 = DataX(GFA.P_Active_Total);
    %
    % DataX Properties:
    %   iniVec      - Initial "vector" of data
    %   iniVecResol - Initial time "resolution" of data
    %   iniVecUnits - Initial "Units" of data (y variable)
    %   figControl  - Control to display the figures or not
    %
    % DataX Methods:
    %   GroupSamplesBy
    %   UnGroupSamples
    %   InterpDataBy
    %   AverageSamplesBy
    %   PickScenario
    %   ReduceScenariosBy
    %   RankScenarios
    %   SelfClusterData
    %   DoElbowPlot
    %   DoCopula
    %   AverageSamplesByV2
    %   EnSco
    %   KantorMap2D
   
    
    % Remember i can have categorical variavles !!!
    % ---------------------------------------------------------------------
    properties
        iniVec;
        iniVecResol {mustBeMember(iniVecResol,{'Hours','Halves','Quarters',...
            'Minutes','Seconds'})}= 'Hours'
        iniVecUnits {mustBeMember(iniVecUnits,{'MW','kW','m/s'})}= 'MW'
        figControl = 0;
        
        % 		samples2Average;
    end % properties
    % ---------------------------------------------------------------------
    methods
        % standard constructor
        function objData = DataX(inputData)
            % Summary of constructor
            if nargin == 0
                %
                objData.iniVec = [];
            else
%                 objData.iniVec = inputData./max(inputData,[],'all');
                objData.iniVec = inputData;

            end
        end % standard constructor
        %
    end % normal methods
    %
    %
    % ---------------------------------------------------------------------
    methods(Static = true)
      % static methods
        function EnergynScore = EnSco(obs,traj)
            %EnSco Calculate the energy score
            %   This calculates the energy score given a set of generated scenario
            %   trajectories (traj) and the initial observations (obs)
            J  = size(traj,2);
            s2 = 0;
            for i=1:J
                for j=1:J
                    s2=s2+norm(traj(:,i)-traj(:,j));
                end
            end
            EnergynScoreTemp = zeros(size(obs,2),1);
            for d=1:size(obs,2)
                s1 = 0;
                for j=1:J
                    s1=s1+norm(obs(:,d)-traj(:,j));
                end
                EnergynScoreTemp(d) = (1/J)*s1-(1/2/J^2)*s2;
            end
            EnergynScore = mean(EnergynScoreTemp);
        end
                
        function  changedVec = AverageSamplesByV2(inData,samples2Average)
            % AverageSamplesByV2 Average unfolded data with specified
            % resolution - Static method version
            % Example: Windp=DataX.AverageSamplesByV2(60)
            % (We need no object - Windp will be used as inData)
            
            if size(inData,2) > 1
                % CASE OF DATA VECTOR
                disp('You gave grouped data and this method requires unfolded data (vector)');
                changedVec = inData;
            else
                changedResol=1;
                L=length(inData);
                changedVec=zeros(L/samples2Average,1);
                for i=1:samples2Average:L
                    Suma=0;
                    for j=i:1:i+samples2Average-1
                        Suma=Suma+inData(j);
                    end
                    format longG
                    changedVec(changedResol)=Suma/samples2Average;
                    changedResol=changedResol+1;
                end
            end
        end
    end	% static methods
    
    methods
        % ---Method 1:   
        function grouped = GroupSamplesBy(objData,samples2Average)
            % GroupSamplesBy Goups vector data by a specified group length
            % Example: test1.iniVec=test1.GroupSamplesBy(96);
            % (test1 is the object)

            L=length(objData.iniVec);
            grouped=zeros(samples2Average,L/samples2Average);
            igroup=1;
            for i=1:samples2Average:L
                igroupjsample =1;
                for j=i:1:i+samples2Average-1
                    grouped(igroupjsample,igroup)=objData.iniVec(j);
                    igroupjsample = igroupjsample+1;
                end
                igroup = igroup+1;
            end
        end
        % -----------------------------------------------------------------

        % ---Method 2:
        function ungroupedVec = UnGroupSamples(objData)
            % UnGroupSamples Unfold grouped data to a vector form
            % Example: test1.iniVec = UnGroupSamples(test1);
            % (test1 is the object)
            
            if size(objData.iniVec,2) ==1
                disp('You gave already ungrouped data');
                ungroupedVec = objData.iniVec;
            else
                ungroupedVec=zeros(size(objData.iniVec,1)*size(objData.iniVec,2),1);
                isample=1;
                for i=1:size(objData.iniVec,2)
                    for j=1:size(objData.iniVec,1)
                        ungroupedVec(isample)=objData.iniVec(j,i);
                        isample = isample+1;
                    end
                end
            end
        end
        % -----------------------------------------------------------------

        % ---Method 3:
        function dataInterpolated = InterpDataBy(objData,Nquerrypoints)
            % InterpDataBy Interpolate grouped data (Give how many samples you want per group)
            % Example: test1.iniVec = test1.InterpDataBy(1440);
            % (test1 is the object)
            
            if size(objData.iniVec,2) ==1
                disp('You gave ungrouped data and this method requires grouped data');
                dataInterpolated = objData.iniVec;
            else
                iniResol = size(objData.iniVec,1);
                x=(1:iniResol)';
                stepN=(iniResol-1)/(Nquerrypoints-1);
                xq=(1:stepN:iniResol)';
                dataInterpolated = zeros(Nquerrypoints,size(objData.iniVec,2));
                for i = 1:size(objData.iniVec,2)
                    dataInterpolated(:,i) =interp1(x,objData.iniVec(:,i),xq,'spline');
                end
                figure;
                plot(x,objData.iniVec(:,1),'o',xq,dataInterpolated(:,1),':.');
                xlim([1 iniResol]);grid on;
                title('Example plot for the 1st group');
            end
        end
        % -----------------------------------------------------------------

        % ---Method 4:
        function  changedVec = AverageSamplesBy(objData,samples2Average)
            % AverageSamplesBy Average unfolded data with specified resolution 
            % Example: test1.iniVec=test1.AverageSamplesBy(15);
            % (test1 is the object)
            
            if size(objData.iniVec,2) > 1 
                % CASE OF DATA VECTOR
                disp('You gave grouped data and this method requires unfolded data (vector)');
                changedVec = objData.iniVec;
            else
                changedResol=1;
                L=length(objData.iniVec);
                changedVec=zeros(L/samples2Average,1);
                for i=1:samples2Average:L
                    Suma=0;
                    for j=i:1:i+samples2Average-1
                        Suma=Suma+objData.iniVec(j);
                    end
                    format longG
                    changedVec(changedResol)=Suma/samples2Average;
                    changedResol=changedResol+1;
                end
            end
        end
        % -----------------------------------------------------------------

        % ---Method 5:
        function xScen = PickScenario(objData,igroupSel)
            % PickScenario Pick a scenario out of the grouped data
            % Example: y = test1.PickScenario(1);
            % (test1 is the object)
            
            if size(objData.iniVec,2) == 1
                % CASE OF DATA VECTOR
                disp('You gave ungrouped data and this method requires grouped data');
                xScen = objData.iniVec;
            else
                % CASE OF DATA MATRIX
                xScen = objData.iniVec(:,igroupSel);
%                 ToDisp01 = [' The input grouped data matrix contained scenarios of ',num2str(size(objData.iniVec,1)),' samples'];
%                 disp(ToDisp01)
                ScenDuration = size(objData.iniVec,1);
%                 figure;

                if objData.figControl == 1
                    plot(xScen,'DisplayName',['Scenario #' num2str(igroupSel)]);
                    xlim([1 ScenDuration]);
                    grid on;
                    ylabel('Power Values [MW]');
                    xlabel('Scenario time components');
                    legend;
                end
            end

        end
        % -----------------------------------------------------------------

        % ---Method 6:
        function [selScen,reassignedProbs,orderedIndexes] = ReduceScenariosBy(objData,UglyOrUsual,HowMany)
            % ReduceScenariosBy Create the reduced set of scenarios (either usual or unusual scenarios)
            % UglyOrUsual ([0]: Keep usual scenarios | [1]: Keep unusual scenarios)
            % Example 1: [z1,z2,z3]=test1.ReduceScenariosBy(0,3);
            % (Keep the 3 most usual scenarios = Reject the most 365-3 unusual scenarios)
            % Example 2: [z1,z2,z3]=test1.ReduceScenariosBy(1,365-3); 
            % (Keep the 3 most unusual scenarios)
            % (test1 is the object)
            
            if size(objData.iniVec,2)==1 && size(objData.iniVec,1)>24
                prompt0 = 'Give group size: ';
                groupSize  = input(prompt0);
                datini = GroupSamplesBy(objData,groupSize);
            else
                datini=objData.iniVec;
                groupSize = size(objData.iniVec,1);
                peak = max(objData.iniVec,[],'all');
            end
            DesiredScenNmr = HowMany;
            
            %----- ITER=1 (find the most similar scenario) ----------------------------
            scen1=datini; % ALL POSSIBLE SCENARIOS
            scen_temp=scen1; % CURRENT POOL OF SCENARIOS
            indexes=1:size(scen1,2);
            indexes_vec=indexes'; % VECTOR TO KEEP INDEXES
            int_var=indexes;
            iter=1; % ITERATION INDEX
            
            %-----C Matrix creation-----
            C=zeros(size(scen1,2),size(scen1,2)); % COST MATRIX INITIALIZATION
            costM=zeros(size(scen1,2),size(scen1,2));
            for t=1:size(scen1,1)
                for s1=1:size(scen1,2)
                    i=s1;
                    for s2=1:size(scen1,2)
                        costM(i,s2)=abs(scen_temp(t,i)-scen_temp(t,s2)); % COST UPDATES
                    end
                end
                C=C+costM;
            end
            %-----Pr vector creation-----
            Cini=C;
            Pr(1:size(scen1,2),1)=1/size(scen1,2); % SCENARIOS ARE EQUIPROPABLE
            Pr_iter=Pr; % PROBABILITY VECTOR FOR EACH SCENARIO
            d=C*Pr_iter; % DISTANCE METRIC VECTOR CALCULATION
            id_min=find(d==min(d)); % INDEX OF SCENARIO WITH MIN DISTANCE METRIC
            if size(id_min,1)>1
                id_min=id_min(1); % CHECK FOR DRAWS AND CHOOSE THE 1ST
            end
            Pr_iter(id_min)=0; % PROBABILITY OF THE SCENARIO WITH MIN DISTANCE METRIC
            
            %-----Selected and reJected  sets creation-----
            %             Ws = zeros(size(scen1,1),DesiredScenNmr);
            Ws=scen_temp(:,id_min);  % SET OF SELECTED SCENARIOS (Selected)
            Ws_index(1,iter)=id_min; % SET OF INDEXES OF SELECTED SCENARIOS
            Ws_index_vec=Ws_index'; % VECTOR OF OF INDEXES OF SELECTED SCENARIOS
            scen_temp(:,id_min)=[]; % SELECTED SCENARIO REMOVAL FROM THE POOL
            Wj=scen_temp; % SET OF REJECTED SCENARIOS (reJected)
            Wj_index=setdiff(indexes_vec,Ws_index_vec); % SET OF INDEXES OF REJECTED SCENARIOS
            costMnew=zeros(size(scen1,2),size(scen1,2)); % UPDATE THE COST MATRIX
            %----- END ITER=1 ---------------------------------------------------------
            
            %----- ITERATIONS UPDATES -------------------------------------------------
            
            while size(Ws,2)<DesiredScenNmr
                iter=iter+1;
                for s2=1:size(scen1,2)
                    costMnew(:,s2)=min(C(:,int_var(id_min)),C(:,s2));
                end
                costMnew(int_var(id_min),:)=C(int_var(id_min),:);
                C=costMnew;
                d= zeros(size(Wj_index,1),1);
                %                 d=[]; % RE-INITIALIZE DISTANCE METRIC VECTOR
                
                int_var(id_min)=[]; % INTERMEDIATE VARIABLE OF SCENARIO INDEXES HAVING REMOVED THE INDEX OF ITER-1
                for i=1:size(Wj_index,1)
                    d(i,1)=C(Wj_index(i),:)*Pr_iter; % RE-CALCUATE THE DISTANCE VECTOR FOR THE REMAINING SCENARIOS
                end
                id_min=find(d==min(d)); % INDEX OF NEXT SCENARIO WITH MIN DISTANCE METRIC
                if size(id_min,1)>1
                    id_min=id_min(1); % CHECK FOR DRAWS AND CHOOSE THE 1ST
                end
                Ws=[Ws scen1(:,int_var(id_min))]; % INCREASE THE SET OF SELECTED SCENARIOS
                scen_temp(:,id_min)=[]; % SELECTED SCENARIO REMOVAL FROM THE POOL
                Wj=scen_temp; % UPDATED SET OF REJECTED SCENARIOS
                Ws_index(1,iter)=int_var(id_min); % UPDATED SET OF INDEXES OF SELECTED SCENARIOS
                Ws_index_vec=Ws_index'; % UPDATED VECTOR OF OF INDEXES OF SELECTED SCENARIOS
                Wj_index=setdiff(indexes_vec,Ws_index_vec); % UPDATED SET OF INDEXES OF REJECTED SCENARIOS
                %Pr_iter(id_min)=0; % SELECTED (REMOVED) SCENARIO HAS ZERO PROBABILITY NOW
                Pr_iter(int_var(id_min))=0; % SELECTED (REMOVED) SCENARIO HAS ZERO PROBABILITY NOW
            end
            %----- END ITERATIONS UPDATES ---------------------------------------------
            
            %----- RE-ASSIGN PROPABILITIES TO THE SELECTED SCENARIOS ------------------
            % Initialize the prob of each selected scenario as the default prob
            prob = zeros(size(Ws,2),1);
            for s=1:size(Ws,2)
                selected_scen=Ws_index(s);
                prob(s)=Pr(selected_scen);
            end
            % Transfer prob of the rejected scenarios to the closest selected ones
            distance = zeros(size(Ws,2),1);
            for j=1:size(Wj,2)
                for s=1:size(Ws,2)
                    selected_scen=Ws_index(s);
                    distance(s)=Cini(Wj_index(j),selected_scen);
                end
                mindist_s=find(distance==min(distance));
                prob(mindist_s)=prob(mindist_s)+Pr(Wj_index(j));
            end
            %----- END RE-ASSIGN PROPABILITIES ----------------------------------------
            
            %------- PLOT THE SELECTED AND REJECTED SCENRIOS --------------------------
%             if objData.figControl == 1
            %{
                figure;
                axScen=gca;
                if UglyOrUsual == 0
                set(gcf,'Name','Forward Selection Usual','NumberTitle','off')
                    hold on;
                    for s=1:size(Ws,2)
                        p2=plot(Ws(:,s)./peak,'-b','LineWidth',1.8);
                    end
                    for j=1:size(Wj,2)
                        p3=plot(Wj(:,j)./peak,'--r','LineWidth',0.4);
                    end
                    hold off;
                    h=[p2(1);p3(1)];
                    grid on;
                    
                    
                    axScen.XLabel.Interpreter = 'latex';
                    axScen.XLabel.String ='$t\:[h]$';
                    axScen.XLabel.Color = 'black';
                    axScen.XAxis.FontSize  = 24;
                    axScen.XAxis.FontName = 'Times New Roman';
                    axScen.XLim = [1 size(objData.iniVec,1)];
                    xticks(4:4:24);
                    
                    axScen.YLabel.Interpreter = 'latex';
                    axScen.YLabel.String ='$\widehat{\xi}^{\ell}\:[pu]$';
                    axScen.XLabel.Color = 'black';
                    axScen.YAxis.FontSize  = 24;
                    axScen.YAxis.FontName = 'Times New Roman';
%                     axScen.YLim = [8 82];
                    axScen.YLim = [0 1];
                    yticks(0:0.25:1);
                    
                    legend(h,{'$ \widehat{\bf \xi}^{\ell}(\omega) \in \Omega_s$','$\widehat{\bf \xi}^{\ell}(\omega) \in \Omega_j = \Omega \setminus \Omega_s$'},'FontSize',16,...
                                    'Fontname','Times New Roman','interpreter','latex','Location','northeast');
                    
%                     legend(h,'Sel','Rej');
%                     xlabel('Samples');ylabel('Power [MW]');
%                     xlim([1 groupSize]);
                    
%                     caption = sprintf('Scenarios = %d, Selected = %.2f, Rejected = %.2f', DesiredScenNmr, size(Ws,2), size(Wj,2));
%                     title(caption,'FontSize',10);
                else
                set(gcf,'Name','Forward Selection Ugly','NumberTitle','off')
                    hold on;
                    for s=1:size(Ws,2)
                        p2=plot(Ws(:,s)./peak,'-b','LineWidth',0.4);
                    end
                    for j=1:size(Wj,2)
                        p3=plot(Wj(:,j)./peak,'--r','LineWidth',2);
                    end
                    hold off;
                    h=[p2(1);p3(1)];
                    grid on;
                    
                    
                    axScen.XLabel.Interpreter = 'latex';
                    axScen.XLabel.String ='$t\:[h]$';
                    axScen.XLabel.Color = 'black';
                    axScen.XAxis.FontSize  = 24;
                    axScen.XAxis.FontName = 'Times New Roman';
                    axScen.XLim = [1 size(objData.iniVec,1)];
                    xticks(4:4:24);
                    
                    axScen.YLabel.Interpreter = 'latex';
                    axScen.YLabel.String ='$\widehat{\xi}^{\ell}\:[pu]$';
                    axScen.XLabel.Color = 'black';
                    axScen.YAxis.FontSize  = 24;
                    axScen.YAxis.FontName = 'Times New Roman';
%                     axScen.YLim = [8 82];
                    axScen.YLim = [0 1];
                    yticks(0:0.25:1);
                    
                    legend(h,{'$ \widehat{\bf \xi}^{\ell}(\omega) \in \Omega_j = \Omega \setminus \Omega_s$','$ \widehat{\bf \xi}^{\ell}(\omega) \in \Omega_s$'},'FontSize',16,...
                                    'Fontname','Times New Roman','interpreter','latex','Location','southwest');
                   
                    
%                     legend(h,'Rej','Sel');
%                     xlabel('Samples');ylabel('Power [MW]');
%                     xlim([1 groupSize]);
%                     caption = sprintf('Scenarios = %d, Selected = %.2f, Rejected = %.2f', DesiredScenNmr, size(Wj,2),size(Ws,2));
%                     title(caption,'FontSize',10);
%                 end
                end
                %}
            %------- END PLOT ---------------------------------------------------------
            
            %------- MAIN OUTPUT ------------------------------------------------------
            % test1.iniVec = UnGroupSamples(test1);  (Ungroup to initial vector)
            Wj_obj = DataX(Wj);
            Ws_obj = DataX(Ws);
            if UglyOrUsual == 0
                % OUTPUT: SELECTED SCENARIOS (The most usual-similar ones)
                %                 selScen=days2ScenVec(Ws);
                selScen = UnGroupSamples(Ws_obj);
                reassignedProbs=prob;
                orderedIndexes=Ws_index;
            else
                % OUTPUT: REJECTED SCENARIOS (The most unusual-different ones)
                %                 selScen=days2ScenVec(Wj);
                selScen = UnGroupSamples(Wj_obj);
%                 prob(1:size(Ws,2))=1/size(Wj,2);
                reassignedProbs(1:size(Wj,2),1)=1/size(Wj,2);
                orderedIndexes=Wj_index;
                %------- END OUTPUT -------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------

        % ---Method 7:
        function rankedScens = RankScenarios(objData)
            % RankScenarios Rank scenarios of the dataset based on the Kantorovich similarity index
            % Example: k = RankScenarios(test1);
            % (test1 is the object)
            
%             [~,~,orderedIndexes]=objData.ReduceScenariosBy(0,size(objData.iniVec,2)-1);
            if size(objData.iniVec,2)==1 || size(objData.iniVec,1)==1
                prompt0 = 'Give group size: ';
                groupSize  = input(prompt0);
                datini = GroupSamplesBy(objData,groupSize);
                datini2 = DataX(datini);
                [~,~,orderedIndexes]=datini2.ReduceScenariosBy(0,size(datini,2)-1);
            else
                [~,~,orderedIndexes]=objData.ReduceScenariosBy(0,size(objData.iniVec,2)-1);
            end
%             [~,~,orderedIndexes]=objData.ReduceScenariosBy(0,364);

            score_scale = 1;
            iscen=1;
            Linear_score = linspace(score_scale,0,size(orderedIndexes,2));
            rankedScens = zeros(size(Linear_score,2),1);
            while iscen<=size(Linear_score,2)
                for i=1:size(Linear_score,2)
                    if orderedIndexes(i) == iscen
                        rankedScens(iscen) = Linear_score(i);
                    end
                end
                iscen=iscen+1;
            end
        end    
        
        % -----------------------------------------------------------------

        % ---Method 8:
        function [clusterdData,centroidScenarios,centroidProb] = ...
                SelfClusterData(objData,cluster_number,clustMethod)
            % SelfClusterData Self cluster the grouped input data matrix
            % clustMethod ([1]: k-means | [2]: Hierarchical)
            % Example: y1 = test1.SelfClusterData(8,1);
            % (test1 is the object)
            
%             objData.iniVec = objData.iniVec';
            XclusterData = objData.iniVec';
            if size(objData.iniVec,2) == 1 || size(objData.iniVec,1) == 1
                disp('You gave ungrouped data and clustering requires grouped data');
                clusterdData = objData.iniVec;
            else
                replicates_mnr=100;
                tplot=(1:size(XclusterData,2))';
                clr=zeros(cluster_number,3);
                for i=1:cluster_number
                    s1 = {'Region'};
                    s2 = {num2str(i)};
                    lgd(i)=strcat(s1,s2);
                    clr=jet(cluster_number);
                end
                if clustMethod == 1
                    %% ---------------------- K-MEANS CLUSTERING ------------------------------
                    [idx,C,sumDist1] = kmeans(XclusterData,cluster_number,'Distance','sqeuclidean');
                    if objData.figControl == 1
                        figure;
                        for i=1:cluster_number
                            p{i} = plot(tplot,XclusterData(idx==i,:),'.-','Color',clr(i,:),'MarkerSize',12);
                            hold on
                        end
                        plot(tplot,C(:,:),'k-',...
                            'MarkerSize',15,'LineWidth',2)
                        title(['Clustered Loads, 1 initialization, Sum of Distances '...
                            num2str(sum(sumDist1))]);
                        xlabel('time [h]');ylabel('Load');
                        xlim([1 size(XclusterData,2)]);
                        grid on;
                        for j=1:cluster_number
                            lgd0(1,j) = p{1,j}(1,:);
                        end
                        legend(lgd0,lgd);
                        hold off
                    end
                    % Choose best out of many intiializations
                    opts = statset('Display','final');
                    [idx,C,sumDistRep] = kmeans(XclusterData,cluster_number,'Distance',...
                        'sqeuclidean','Replicates',replicates_mnr,'Options',opts);
                    if objData.figControl == 1
                        figure;
                        for i=1:cluster_number
                            p{i} = plot(tplot,XclusterData(idx==i,:),'.-','Color',clr(i,:),'MarkerSize',12);
                            hold on
                        end
                        plot(tplot,C(:,:),'k-',...
                            'MarkerSize',15,'LineWidth',2)
                        title(['Clustering after ' num2str(replicates_mnr) ...
                            ' initializations, Sum of Distances ' num2str(sum(sumDistRep))]);
                        xlabel('time [h]');ylabel('Load');
                        xlim([1 size(XclusterData,2)]);
                        grid on;
                        for j=1:cluster_number
                            lgd0(1,j) = p{1,j}(1,:);
                        end
                        legend(lgd0,lgd);
                        hold off
                    end
                    centroidProb = zeros(cluster_number,1);
                    % Plot Individual clusters
                    if objData.figControl == 1
                        for i=1:cluster_number
                            figure;
                            plot(tplot,XclusterData(idx==i,:),'.-','Color',clr(i,:),'MarkerSize',12);
                            centroidProb(i) = size(XclusterData(idx==i,:),1)/size(XclusterData,1);
                            xlabel('time [h]');ylabel('Load');
                            legend(lgd(i));
                            title(['Clusted group of load curves ' num2str(i)]);
                            xlim([1 size(XclusterData,2)]);
                            grid on;
                        end
                    end
                    clusterdData = idx;
                    centroidScenarios = C';
                    
                else
                    %% ---------------------HIERARCHICAL CLUSTERING ---------------------------
                    Z = linkage(XclusterData,'ward','euclidean');
                    T = cluster(Z,'maxclust',cluster_number);
                    
                    cutoff = median([Z(end-cluster_number+1,3) Z(end-cluster_number+2,3)]);
                    %{
                    if objData.figControl == 1
                        figure;
                        dendrogram(Z,'ColorThreshold',cutoff)
                    
                        figure;
                        for i=1:cluster_number
                            ph{i} = plot(tplot,XclusterData(T==i,:),'.-','Color',clr(i,:),'MarkerSize',12);
                            hold on
                        end
                        
                        
                        title('Hierarchical Clustering visualization');
                        xlabel('time [h]');ylabel('Load');
                        xlim([1 size(XclusterData,2)]);
                        grid on;
                        for j=1:cluster_number
                            lgd1(1,j) = ph{1,j}(1,:);
                        end
                        legend(lgd1,lgd);
                        hold off
                    end
                    %}
                    centroidProb = zeros(cluster_number,1);
                    centroidScenarios = zeros(size(XclusterData,2),cluster_number);
                    %Plot Individual clusters
%                     if objData.figControl == 1
                        for i=1:cluster_number
%                             figure;
%                             plot(tplot,XclusterData(T==i,:),'.-','Color',clr(i,:),'MarkerSize',12);
                            centroidProb(i) = size(XclusterData(T==i,:),1)/size(XclusterData,1);
                            centroidScenarios(:,i) = mean(XclusterData(T==i,:),1);
                            
%                             xlabel('time [h]');ylabel('Load');
%                             legend(lgd(i));
%                             title(['Clusted group of load curves ' num2str(i)]);
%                             xlim([1 size(XclusterData,2)]);
%                             grid on;
                        end
%                     end
                    clusterdData = T;
                end
            end
        end
        % -----------------------------------------------------------------

        % ---Method 9:
        function [elbow_x,elbow_y]=DoElbowPlot(objData)
            % DoElbowPlot Draws the Elbow plot for self-clustered data
            % Example: test1.DoElbowPlot();
            % (test1 is the object)
            
            default_clust_mnr = 40;
            replicates_mnr =10;
            for it=1:1:default_clust_mnr
                % Choose best out of many intiializations
                opts = statset('Display','final');
                [~,~,sumdistN] = kmeans(objData.iniVec,it,'Distance','sqeuclidean',...
                    'Replicates',replicates_mnr,'Options',opts);
                elbow_y(it)=sum(sumdistN);
                elbow_x(it)=it;
            end
            if objData.figControl == 1
                figure;
                scatter(elbow_x,elbow_y);
                title 'Elbow Plot'
                xlabel('Number of Clusters');
                ylabel('Total sum of squared distances inside the clusters');
            end
        end
        % -----------------------------------------------------------------

        % ---Method 10:
        function [sampledRandVarXcopul,uniformRandVarU,EnSc,R24]=DoCopula(objData,Nsamples,copulMethod)
            % DoCopula Estimates a copula pdf from the input grouped data and samples from this Nsamples random scenarios
            % copulMethod ([1]: T-copula| [2]: Gaussian)
            % Example: z4=test1.DoCopula(10,2);
            % (test1 is the object)
            if size(objData.iniVec,2) == 1 || size(objData.iniVec,1) == 1
                disp('You gave ungrouped data and clustering requires grouped data');
                sampledRandVarXcopul = objData.iniVec;
            else
                % ---Estimate pdf of my multivariate input grouped data
                if objData.figControl == 1
                    figure;plot(objData.iniVec);title('Initial Grouped data'); grid on;
                    xlabel('Time');ylabel('Variable');xlim([1 size(objData.iniVec,1)]);
                    ytickformat('%4.0f')
                end
                    randVarX = objData.iniVec';
                    % Transform the data to the copula scale (unit square) using a kernel estimator of the cumulative distribution function.
                    uniformRandVarU = zeros(size(objData.iniVec,2),size(objData.iniVec,1));
%                     if objData.figControl == 1
%                         figure; hold on;
                        for i=1:size(objData.iniVec,1)
                            uniformRandVarU(:,i)=ksdensity(randVarX(:,i),randVarX(:,i),'function','cdf','Bandwidth',2);
                            [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
%                             plot(xi,f);grid on;
%                             axpdf=gca;
%                             set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
%                             histogram(LoadA.iniVec,'Normalization','pdf');hold on;
%                             plot(Xi,Yi,'--r','LineWidth',2);
%                             legend(axpdf,{'$\{ \xi^{l} \}_i$','$\hat{f}_h^l$'},'FontSize',12,...
%                                 'Fontname','Times New Roman','interpreter','latex','Location','northeast');
%                             hold off
                            
                            axpdf.XLabel.Interpreter = 'latex';
                            axpdf.XLabel.String ='$\xi^{l}$';
                            axpdf.XLabel.Color = 'black';
                            axpdf.XAxis.FontSize  = 12;
                            axpdf.XAxis.FontName = 'Times New Roman';
                            
                            axpdf.YLabel.Interpreter = 'latex';
                            axpdf.YLabel.String ='$f(\xi^{l})$';
                            axpdf.XLabel.Color = 'black';
                            axpdf.YAxis.FontSize  = 12;
                            axpdf.YAxis.FontName = 'Times New Roman';
%                             title({'Esimated predictive densities';'based on Kernel probability densities for Grouped data'});
%                                                 xlim([1 size(objData.iniVec,1)]);
%                             ylabel('Density (pdf)');xlabel(['Units of random variable X: ','[',objData.iniVecUnits,']']);
                        end
                        hold off;
%                     end
                %%
                if copulMethod == 1
                    %-----T-COPULA
                    [Rho1,nu] = copulafit('t',uniformRandVarU,'Method','ApproximateML');
                    copulTRandU = copularnd('t',Rho1,nu,Nsamples);
                    % Transform the random sample back to the original scale of the data.
                    for i=1:size(objData.iniVec,1)
                        sampledRandVarXcopulT(:,i)=ksdensity(randVarX(:,i),copulTRandU(:,i),'function','icdf','Support','positive','Bandwidth',2);
                    end
                    if objData.figControl == 1
                        figure;plot(sampledRandVarXcopulT');title('T Copula scenarios');xlim([1 size(objData.iniVec,1)]);
                        ylabel(['Stochastic variable: ','[',objData.iniVecUnits,']']);xlabel('Time');
             
                        disp('T copula Rho & T copula nu ')
                        disp(num2str(Rho1))
                        disp(num2str(nu))
                    end
                        sampledRandVarXcopul = sampledRandVarXcopulT';
                        R24 = Rho1;
                    
                else
                    %-----GAUSSIAN COPULA-----
                    Rho2 = copulafit('Gaussian',uniformRandVarU);
                    copulGRandU = copularnd('Gaussian',Rho2,Nsamples);
                    % Transform the random sample back to the original scale of the data.
                    for i=1:size(objData.iniVec,1)
                        sampledRandVarXcopulG(:,i)=ksdensity(randVarX(:,i),copulGRandU(:,i),'function','icdf','Bandwidth',2);
                    end
                    if objData.figControl == 1
                        figure;
                        axGen=gca;
                        set(gcf,'Name','Gen-load','NumberTitle','off')
                        plot(sampledRandVarXcopulG','-b','LineWidth',0.1);
%                         title('Gaussian Copula scenarios');
                        grid on;
                        axGen.XLabel.Interpreter = 'latex';
                        axGen.XLabel.String ='$t\:[h]$';
                        axGen.XLabel.Color = 'black';
                        axGen.XAxis.FontSize  = 12;
                        axGen.XAxis.FontName = 'Times New Roman';
                        axGen.XLim = [1 size(objData.iniVec,1)];
                        xticks(2:2:24);

                        axGen.YLabel.Interpreter = 'latex';
                        axGen.YLabel.String ='$\xi^{l}\:[MW]$';
                        axGen.XLabel.Color = 'black';
                        axGen.YAxis.FontSize  = 12;
                        axGen.YAxis.FontName = 'Times New Roman';
                        axGen.YLim = [10 80];
%                         ylabel(['Stochastic variable: ','[',objData.iniVecUnits,']']);xlabel('Time');
%                         xlim([1 size(objData.iniVec,1)]);
                        
                        disp('Gaussian copula parameter (Correlation matrix): ')
                        disp(num2str(Rho2))
                    end
                    sampledRandVarXcopul = sampledRandVarXcopulG';
                    R24 = Rho2;

                end
                    %-----ENERGY SCORE-----
                    if max(objData.iniVec,[],'all')>1
                        NormFact = max(objData.iniVec,[],'all');
                    else
                        NormFact=1;
                    end
                    traj = sampledRandVarXcopul./NormFact;
                    obs = objData.iniVec./NormFact;
                    EnSc = DataX.EnSco(obs,traj);
                    disp(['Energy Score for the scenarios generated based on the estimated multivariate pdf (copula): ', num2str(EnSc)])
            end
        end
        % -----------------------------------------------------------------
      
        % ---Method 11:
        function [mappedCoords,closestPoints,RESselScens,...
                LOADselScens,probVec,mapVars] = KantorMap2D(objDataRES,objDataLOAD,clustersNum)
            %KantorMap2D Performs the 2D mapping
            %   This actually created the 2D map with a ranked RES power
            %   variable on one axis and a platform's LOAD on the other
            %   Example: [coords,points]=KantorMap2D(LoadC,DataX(WF1.WindPower));
            x = RankScenarios(objDataLOAD);
            y = RankScenarios(objDataRES);
            
%             if objData.figControl == 1
%                 scatter(x,y);
%                 a = [1:numel(x)]'; b = num2str(a); c = cellstr(b);
%                 dx = 0.003; dy = 0.003; % displacement so the text does not overlay the data points
%                 text(x+dx, y+dy, c);
%                 xlabel('Load Score');ylabel('Wind Power Score');
%                 xlim([0 1]);
%                 ylim([0 1]);
%                 title('1: Most representative scenario | 0: Least representative scenario','FontSize',16);
%             end
            X = [x y];
            mapVars.x = x;
            mapVars.y = y;
            mapVars.points = X;
            
%             clustersNum = 10;
            replicatesNum = 10;
            % ------------------ K-MEANS ELBOW PLOT -----------------------
            Xobj=DataX(X);
%             Xobj.DoElbowPlot
            [mapVars.elbowPlotX,mapVars.elbowPlotY]= Xobj.DoElbowPlot;

            % ----------------- K-MEANS ELBOW PLOT - END ------------------
            
            % ------------------ K-MEANS CLUSTERING -----------------------
            [idx,C] = kmeans(X,clustersNum);
            
            x1 = min(X(:,1)):0.001:max(X(:,1));
            x2 = min(X(:,2)):0.001:max(X(:,2));
            [x1G,x2G] = meshgrid(x1,x2);
            XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the plot
            
            idx2Region = kmeans(XGrid,clustersNum,'MaxIter',1,'Start',C);
            
            
%             if objData.figControl == 1
%                 figure;
%                 clr=zeros(clustersNum,3);
%                 for i=1:clustersNum
%                     s1 = {'Region'};
%                     s2 = {num2str(i)};
%                     lgd(i)=strcat(s1,s2);
%                     clr=jet(clustersNum);
%                 end
%                 gscatter(XGrid(:,1),XGrid(:,2),idx2Region,clr,'..');
%                 hold on;
%                 plot(X(:,1),X(:,2),'k*','MarkerSize',5);
%                 title 'Scenarios Clusters Regions';
%                 xlabel 'Load Score';
%                 ylabel 'Wind Power Score';
%                 legend(lgd);
%                 hold off;
%                 
%                 figure;
%                 for i=1:clustersNum
%                     plot(X(idx==i,1),X(idx==i,2),'.','Color',clr(i,:),'MarkerSize',12)
%                     hold on
%                 end
%                 plot(C(:,1),C(:,2),'kx',...
%                     'MarkerSize',15,'LineWidth',3)
%                 title 'Cluster Assignments and Centroids'
%                 text(x+dx, y+dy, c);
%                 xlabel('Load Score');ylabel('Wind Power Score');
%                 legend(lgd);
%                 hold off
%             end
            
            % Choose best out of many intiializations
            opts = statset('Display','final');
            [idx,C,~] = kmeans(X,clustersNum,'Distance','sqeuclidean',...
                'Replicates',replicatesNum,'Options',opts);
            
            mapVars.clusterID = idx;
            mapVars.centroids = C;
            
            
%             x1 = min(X(:,1)):0.001:max(X(:,1));
%             x2 = min(X(:,2)):0.001:max(X(:,2));
%             [x1G,x2G] = meshgrid(x1,x2);
%             XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the plot
            
            mapVars.gridPoints = XGrid;
            
            idx3Region = kmeans(XGrid,clustersNum,'MaxIter',1,'Start',C);
            
            mapVars.gridPointsCluster = idx3Region;
            
            
            
%             if objData.figControl == 1
%                 figure;
%                 for i=1:clustersNum
%                     plot(X(idx==i,1),X(idx==i,2),'.','Color',clr(i,:),'MarkerSize',12)
%                     hold on
%                 end
%                 plot(C(:,1),C(:,2),'kx',...
%                     'MarkerSize',15,'LineWidth',3)
%                 title(['Clustering after ' num2str(replicatesNum) ' initializations']);
%                 text(x+dx, y+dy, c);
%                 xlabel('Load Score');ylabel('Wind Power Score');
%                 legend(lgd);
%                 hold off
%             end
            % --------- K-MEANS FIXED NUMBER OF CLUSTERS - END ------------
            
            %------------- FIND CLOSEST TO CENTROIDS POINTS ---------------
            % loop through all clusters
            closestIdx = zeros(max(idx),1);
            size_iCluster=zeros(max(idx),1);
            for iCluster = 1:max(idx)
                %# find the points that are part of the current cluster
                currentPointIdx = find(idx==iCluster);
                %# find the index (among points in the cluster)
                %# of the point that has the smallest Euclidean distance from the centroid
                %# bsxfun subtracts coordinates, then you sum the squares of
                %# the distance vectors, then you take the minimum
                [~,minIdx] = min(sum(bsxfun(@minus,X(currentPointIdx,:),C(iCluster,:)).^2,2));
                %# store the index into X (among all the points)
                closestIdx(iCluster) = currentPointIdx(minIdx);
                size_iCluster(iCluster,1) = length(X(idx==iCluster,1));
            end
            
            for iCluster = 1:max(idx)
                coordinates_closest(iCluster,:) = X(closestIdx(iCluster),:);
            end
            
            
            mappedCoords  = coordinates_closest;
            closestPoints = closestIdx;
            probVec =size_iCluster./(size(objDataRES.iniVec,2)-1);
            
%             if objData.figControl == 1
%                 figure;
                for iCluster = 1:max(idx)
                    clustVarSel1(:,iCluster) = objDataRES.PickScenario(closestPoints(iCluster));
%                     hold on;
                end
%                 title('Clustered picked scenarios for RES generation');
%                 hold off;
%                 figure;
                for iCluster = 1:max(idx)
                    clustVarSel2(:,iCluster) = objDataLOAD.PickScenario(closestPoints(iCluster));
%                     hold on;
                end
%                 title('Clustered picked scenarios for LOAD generation');
%                 hold off;
%             end

            selectedScensClustVar1 = DataX(clustVarSel1);
            RESselScens = UnGroupSamples(selectedScensClustVar1);
            
            selectedScensClustVar2 = DataX(clustVarSel2);
            LOADselScens = UnGroupSamples(selectedScensClustVar2);

            
                      
        end
                    
                    
                    
        
    end
    %    
    %
end % classdef

