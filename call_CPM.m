%%% This script will run CPM (linear) and CPM (classifier) on the PTSD
%%% datasets. Each iteration of CPM will be outputted as a variable
%%% corresponding with the name of the variable we're trying to predict.
clc; clear; close all;

%% Load X (connectome) and Y (clinical) data
TASK = {'Resting','Domino','Hariri'};
TPOINT = {'T1','T2','T3'};
DSET = {'TelAviv'};  %{'AURORA','TelAviv','Combined'};

PATH = '/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/';

for d = 1:length(DSET)
    isTA = strcmp(DSET{d},'TelAviv');
    for t = 1:length(TPOINT)
        if isTA
            for ts = 1:length(TASK)
                %load connectome
                load(sprintf('%s/%s/%s/CPM_data/connectome.mat',PATH,DSET{d},TASK{ts}));
                x = conn;
                
                %load survey
                load(sprintf('%s/%s/%s/CPM_data/%s_PCL.mat',PATH,DSET{d},TASK{ts},TPOINT{t}));

                % remove NaNs
                for i = length(y):-1:1
                    if isnan(y(i))
                        y(i) = [];
                        x(:,:,i) = [];
                    elseif isinf(y(i))   %this is only relevant when using % change scores as 'y'
                        isneg = sign(y(i)) .* isinf(y(i));
                        if isneg == 1
                            y(i) = 5000;
                        elseif isneg == -1
                            y(i) = -5000;
                        end
                    end
                end

                %Run CPM -- continuous variables
                eval(sprintf('CPMcorr_%s_%s_%s = main(x,y,10);',DSET{d},TASK{ts},TPOINT{t}));

                % plot actual vs predicted variables
                figure;
                color='b';
                style='filled';
                scatter(y,eval(sprintf('CPMcorr_%s_%s_%s.Y',DSET{d},TASK{ts},TPOINT{t})),color,style);
                xlabel('Actual PCL score','FontSize',20)
                ylabel('Predicted PCL score','FontSize',20)
                title(sprintf('%s %s %s PCL',DSET{d},TASK{ts},TPOINT{t}),'FontSize',20)
                hold on

                % add in fit line
                actvpred = polyfit(y,eval(sprintf('CPMcorr_%s_%s_%s.Y',DSET{d},TASK{ts},TPOINT{t})),1);

                % loop through number of possible fluid intelligence scores (x axis)
                ix=0;
                for i = floor(min(y)):ceil(max(y))
                    ix=ix+1;
                    if i == 0
                        %fline(1,i+1) = actvpred(2);
                        fline(1,ix) = actvpred(2);
                    else
                        %fline(1,i+1) = actvpred(2) + (i*actvpred(1));
                        fline(1,ix) = actvpred(2) + (i*actvpred(1));
                    end
                end

                plot(floor(min(y)):ceil(max(y)),fline,'k');

                % add coefficient and p-value to plot
                str = {['Rho = ', num2str(eval(sprintf('CPMcorr_%s_%s_%s.r_rank',DSET{d},TASK{ts},TPOINT{t})))]}; 
                annotation('textbox', [0.91, 0.9, 0, 0], 'String', str,'FitBoxToText','off','FontSize',14);

                clear actvpred fline str

                %Run CPM -- SVM for classification PTSD or no PTSD
                if t == 3   % PTSD criteria needs to be met at T3 for diagnosis

                    % Classify as 'PTSD' or 'not PTSD' based on a PCL
                    % cutoff of 35
                    for i = 1:length(y)
                        if y(i) > 35
                            ptsd(i,1) = 2;
                        else 
                            ptsd(i,1) = 1;
                        end
                    end

                    [ptsd_pred, acc, sensitivity, specificity, precision] = cpm_classifier_main(x,ptsd,'per_feat',0.1,'kfolds',10,'learner','svm');
                    
                    eval(sprintf('SVM_%s_acc_PCLcriteria = acc;',TASK{ts}));
                    eval(sprintf('SVM_%s_sensitivity_PCLcriteria = sensitivity;',TASK{ts}));
                    eval(sprintf('SVM_%s_specificity_PCLcriteria = specificity;',TASK{ts}));
                    eval(sprintf('SVM_%s_precision_PCLcriteria = precision;',TASK{ts}));

                    %plot ROC
                    [XROC,YROC,~,AUC] = perfcurve(ptsd_pred,ptsd,2);
                    figure;
                    plot(XROC,YROC);
                    hold on;
                    plot([0:1],[0:1],':','color','k')
                    xlabel('False positive rate');
                    ylabel('True positive rate');
                    title(sprintf('ROC for Classification by SVM -- %s -- PCL criteria',TASK{ts}));

                    eval(sprintf('ROC_%s_AUC_PCLcriteria = AUC;',TASK{ts}));

                    clear AUC XROC YROC y ptsd ptsd_pred acc sensitivity specificity precision

                    %Run SVM again, except use the clinician's criteria to
                    %categorize PTSD
                    load(sprintf('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/%s/%s/CPM_data/T3_Is PTSD_Final.mat',DSET{d},TASK{ts}))
                    
                    %load connectome
                    load(sprintf('%s/%s/%s/CPM_data/connectome.mat',PATH,DSET{d},TASK{ts}));
                    x = conn;

                    %remove NaNs
                    for i = length(y):-1:1
                        if isnan(y(i))
                            y(i) = [];
                            x(:,:,i) = [];
                        elseif y(i) == 0   %the SVM code won't work if a category is defined as 0, so we're changing 0 -> 1 and 1 -> 2
                            y(i) = 1;
                        elseif y(i) == 1
                            y(i) = 2;
                        end
                    end
                    
                    ptsd = y;
                    
                    [ptsd_pred, acc, sensitivity, specificity, precision] = cpm_classifier_main(x,ptsd,'per_feat',0.1,'kfolds',10,'learner','svm');
                    
                    eval(sprintf('SVM_%s_acc_CliniciansCriteria = acc;',TASK{ts}));
                    eval(sprintf('SVM_%s_sensitivity_CliniciansCriteria = sensitivity;',TASK{ts}));
                    eval(sprintf('SVM_%s_specificity_CliniciansCriteria = specificity;',TASK{ts}));
                    eval(sprintf('SVM_%s_precision_CliniciansCriteria = precision;',TASK{ts}));

                    %plot ROC
                    [XROC,YROC,~,AUC] = perfcurve(ptsd_pred,ptsd,2);
                    figure;
                    plot(XROC,YROC);
                    hold on;
                    plot([0:1],[0:1],':','color','k')
                    xlabel('False positive rate');
                    ylabel('True positive rate');
                    title(sprintf('ROC for Classification by SVM -- %s -- clinicians criteria',TASK{ts}));

                    eval(sprintf('ROC_%s_AUC_CliniciansCriteria = AUC;',TASK{ts}));

                    clear AUC XROC YROC y ptsd ptsd_pred acc sensitivity specificity precision conn x
               
                end  % if t==3
            end   %for ts = 1:length(TASK)
        else   % if this isn't Tel Aviv
            %load connectome
            load(sprintf('%s/%s/CPM_data/connectome.mat',PATH,DSET{d}));
            x = conn;

            %load survey
            load(sprintf('%s/%s/CPM_data/%s_PCL.mat',PATH,DSET{d},TPOINT{t}));

            % remove NaNs
            for i = length(y):-1:1
                if isnan(y(i))
                    y(i) = [];
                    x(:,:,i) = [];
                elseif isinf(y(i))   %this is only relevant when using % change scores as 'y'
                    isneg = sign(y(i)) .* isinf(y(i));
                    if isneg == 1
                        y(i) = 5000;
                    elseif isneg == -1
                        y(i) = -5000;
                    end
                end
            end
            
            %Run CPM -- continuous variables
            eval(sprintf('CPMcorr_%s_Resting_%s = main(x,y,10);',DSET{d},TPOINT{t}));

            % plot actual vs predicted variables
            figure;
            color='b';
            style='filled';
            scatter(y,eval(sprintf('CPMcorr_%s_Resting_%s.Y',DSET{d},TPOINT{t})),color,style);
            xlabel('Actual PCL score','FontSize',20)
            ylabel('Predicted PCL score','FontSize',20)
            title(sprintf('%s Resting %s PCL',DSET{d},TPOINT{t}),'FontSize',20)
            hold on

            % add in fit line
            actvpred = polyfit(y,eval(sprintf('CPMcorr_%s_Resting_%s.Y',DSET{d},TPOINT{t})),1);

            % loop through number of possible x axis values
            ix=0;
            for i = floor(min(y)):ceil(max(y))
                ix=ix+1;
                if i == 0
                    %fline(1,i+1) = actvpred(2);
                    fline(1,ix) = actvpred(2);
                else
                    %fline(1,i+1) = actvpred(2) + (i*actvpred(1));
                    fline(1,ix) = actvpred(2) + (i*actvpred(1));
                end
            end

            plot(floor(min(y)):ceil(max(y)),fline,'k');

            % add coefficient and p-value to plot
            str = {['Rho = ', num2str(eval(sprintf('CPMcorr_%s_Resting_%s.r_rank',DSET{d},TPOINT{t})))]};
            annotation('textbox', [0.91, 0.9, 0, 0], 'String', str,'FitBoxToText','off','FontSize',14);

            clear actvpred fline str conn x y

        end   %if isTA
    end   %for t = 1:length(TPOINT)
end   %for d = 1:length(DSET)
