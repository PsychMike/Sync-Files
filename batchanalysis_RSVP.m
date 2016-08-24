function batchresults = batchanalysis_blank()

%Image RSVP batchanalysis script written by Michael Hess, May '16

%This code compensates for your operation systems preferences when accessing data files.
if IsOSX    %On a Mac or PC, choose the right data directory
    datadir='data/';
else
    datadir='data\';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define data to be analyzed

%Add in the subject numbers of the data files that you wish to analyze:
subnumlist = [1 2 3 4 5 6 7 8 9 10 11 12 14 15 17 20 21 22 23];  %list here the subject numbers that you wish to use
numsubs = length(subnumlist);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Begin Analysis

%Rater number
rater = 1;

subject_count = 1;
correct_count = 1; %count of correct trials
total_count = 1; %count of all trials
%Loops through all of the subjects' data files
for sub_length = 1:numsubs
    sprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    
    sub = subnumlist(subject_count);
    subject = sub %outputs subject number
    
    datafilename = sprintf('%sExpSub_compact_%d_judged%d.mat',datadir,sub,rater);
    
    Userdata = load(datafilename);
    Userdata = Userdata.Userdata;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Block #1 Analysis
    
    %Analysis of block #1  (there is only one block in this data file
    block = 1;
    
    numtrials = length(Userdata.Blocks(block).Trials)-3;
    
    correct_trials = 0; %reset correct trial count for each subject
    
    trial_count = 0; %counts # of single target trials
    
    %Loop through all of the trials in this block
    for trial = 4:numtrials
        
        %         if Userdata.Blocks.Trials(trial).Trial_Export.second_target == 0
        
        trial_count = trial_count + 1;
        
        %Importing rater responses
        user_review_item = Userdata.Blocks.Trials(trial).Trial_Export.review_item1;
        
        %Importing which target category
        target_category = Userdata.Blocks.Trials(trial).Trial_Export.which_target_category;
        
        %Importing which target
        target = Userdata.Blocks.Trials(trial).Trial_Export.first_target;
        
        
        if strcmp(user_review_item,'y')
            correct_trials = correct_trials + 1;
            
            category_array(correct_count) = target_category;
            
            correct_target_count(correct_count,target_category) = sprintf(['%d'],target);
            
            correct_count = correct_count + 1;
        end
        
        category_count(total_count) = target_category;
        
        total_target_count(total_count,target_category) = sprintf(['%d'],target);
        
        total_count = total_count + 1;
        
        if trial == numtrials
            correct_trials %outputs number of correct trials
        end
        %         end
    end
    subject_count = subject_count + 1;
    subject_accuracy = (correct_trials/(trial_count))*100
    total_accuracy(subject_count) = subject_accuracy;
    
    if subject == subnumlist(numsubs);
        if trial == numtrials
            sprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
            %             average_accuracy = sum(total_accuracy)/numsubs %outputs average accuracy of all subs
            %             min_accuracy = min(total_accuracy) %outputs min accuracy
            %             max_accuracy = max(total_accuracy) %outputs max accuracy
            %             x = size(correct) %check size of correct trial output
            %             csvwrite('sub_correct_trials',correct)
            %             save('correct_trials','correct');
        end
    end
end
for i = 1:27
    accurate(i) = sum(category_array(:)==i);
    total(i) = sum(category_count(:)==i);
end

category_accuracy = accurate./total
c = 0;
for i = 1:27
    median_cat_accuracy = median(category_accuracy);
    if category_accuracy(i) >= median_cat_accuracy
        c = c + 1;
        top_50_cats(c) = i;
    end
end
top_50_cats
save top_50_cats
median_sub_accuracy = median(total_accuracy)
category_accuracy_graph = bar(category_accuracy)
title('Category Accuracy');


for i = 1:27
    
    target_correct_column = (correct_target_count(:,i));
    target_correct_column = cellstr(target_correct_column);
    target_correct_column = target_correct_column(~cellfun('isempty',target_correct_column));
    target_correct_column = cell2mat(target_correct_column);
    target_correct_column = str2num(target_correct_column);
    
    target1_correct(:,i) = sum(target_correct_column==1);
    target2_correct(:,i) = sum(target_correct_column==2);
    target3_correct(:,i) = sum(target_correct_column==3);
    target4_correct(:,i) = sum(target_correct_column==4);
    
    target_count_column = (total_target_count(:,i));
    target_count_column = cellstr(target_count_column);
    target_count_column = target_count_column(~cellfun('isempty',target_count_column));
    target_count_column = cell2mat(target_count_column);
    target_count_column = str2num(target_count_column);
    
    target1_count(:,i) = sum(target_count_column==1);
    target2_count(:,i) = sum(target_count_column==2);
    target3_count(:,i) = sum(target_count_column==3);
    target4_count(:,i) = sum(target_count_column==4);
    
    target_accuracy1(:,i) = (target1_correct(:,i))/(target1_count(:,i));
    target_accuracy2(:,i) = (target2_correct(:,i))/(target2_count(:,i));
    target_accuracy3(:,i) = (target3_correct(:,i))/(target3_count(:,i));
    target_accuracy4(:,i) = (target4_correct(:,i))/(target4_count(:,i));
end

see_counts = 0;

if see_counts
    target1_correct
    target1_count
    target2_correct
    target2_count
    target3_correct
    target3_count
    target4_correct
    target4_count
    total_count
    sca
    keyboard
end

targ_scores(:,1) = target_accuracy1;
targ_scores(:,2) = target_accuracy2;
targ_scores(:,3) = target_accuracy3;
targ_scores(:,4) = target_accuracy4;
targ_scores
target_accuracy_mean = (mean(mean(targ_scores))/2)

for i = 1:108
    if targ_scores(i) >= target_accuracy_mean
        top_targs(i) = 1;
        bottom_targs(i) = 0;
    else
        top_targs(i) = 0;
        bottom_targs(i) = 1;
    end
end
cd ..
cd Stimuli
targets = xlsread('targets2.xls');

targets = reshape(targets,1,108);

see_good_targs = 0;

if see_good_targs == 1
    for i = 1:108
        if top_targs(i) == 1
            top_targs(i) = targets(i);
        end
    end
    top_targs = reshape(top_targs,27,4)
else
    for i = 1:108
        if bottom_targs(i) == 1
            bottom_targs(i) = targets(i);
        end
    end
    bottom_targs = reshape(bottom_targs,27,4)
end