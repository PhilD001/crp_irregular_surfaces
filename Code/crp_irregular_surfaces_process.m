function crp_irregular_surfaces_process
% This code computes continuous relative phase metrics for the uneven walking surface dataset. 



%% STEP 0: SET DEFAULTS ============================================================================

% initial path to data folder ----------------------------------------------------------------------
[p, ~] = fileparts(mfilename('fullpath'));
indx = strfind(p, filesep);
fld_data_root = [p(1:indx(end)), 'Data', filesep, 'raw'];
fld_stats = [p(1:indx(end)), 'Statistics'];


% create copy of data for processing ---------------------------------------------------------------
indx = strfind(fld_data_root, filesep);
fld_data_proc = [fld_data_root(1:indx(end)), 'processed'];

if exist(fld_data_proc, 'dir')
    disp('function previously run...overwritting previous run')
    rmdir(fld_data_proc, 's')
    rmdir(fld_stats, 's')
end

mkdir(fld_data_proc);
copyfile(fld_data_root,fld_data_proc)


%% STEP 1: COMPUTE CRP FOR EACH TRIAL ==============================================================

limb = {'Right', 'Left'};
group = {'Old', 'Young'};
surface = {'Flat', 'Uneven'};
for g = 1:length(group)
    
    for s = 1:length(surface)
        
        participant = GetSubDirsFirstLevelOnly([fld_data_proc, filesep, group{g}]);
        for p = 1:length(participant)
            
            fld_gsp = [fld_data_proc, filesep, group{g}, filesep, participant{p}, filesep, surface{s}];
            fl = engine('fld', fld_gsp, 'extension', 'zoo');
            
            disp(' ')
            disp(['extracting data from ', num2str(length(fl)), ' trials for subject ', ...
                 participant{p}, ' on surface ', surface{s}, ' ...'])

            % initialize stk for each CRP metric for a given group/surface/participant -------------
            RightKHStanceCRP_stk = ones(length(fl), 101);     
            RightKHSwingCRP_stk = ones(length(fl), 101);      
            
            RightAKStanceCRP_stk = ones(length(fl), 101);      
            RightAKSwingCRP_stk = ones(length(fl), 101);       
            
            LeftKHStanceCRP_stk = ones(length(fl), 101);      
            LeftKHSwingCRP_stk = ones(length(fl), 101);       
            
            LeftAKStanceCRP_stk = ones(length(fl), 101);     
            LeftAKSwingCRP_stk = ones(length(fl), 101);       
            
            vel_stk = ones(length(fl), 1);     

            % loop through all trials for a given group/surface/participant ------------------------
            for f = 1:length(fl)
                [file_pth, file_name, ext] = fileparts(fl{f});
                disp(file_name)
                data = load(fl{f}, '-mat');
                data = data.data;
                
                % Checks which limb side is associated with the middle step (apex) -----------------
                ApexFoot=data.zoosystem.CompInfo.ApexFoot;
                                
                % Extracts Stance and Swing phase indices based on existing gait events ------------
                FSapex = data.SACR.event.FSapex(1);      % middle portion
                FSminus1 = data.SACR.event.FSminus1(1);  % step before apex
                FSplus1 = data.SACR.event.FSplus1(1);    % step after apex

                if strcmp(ApexFoot, 'Left')
                    Stance = FSminus1(1):FSapex(1);
                    Swing = FSapex(1):FSplus1(1);
                elseif strcmp(ApexFoot, 'Right')
                    Stance = FSapex(1):FSplus1(1);
                    Swing = FSminus1(1):FSapex(1);
                end
                
                % extract SACR position and compute speed ------------------------------------------
                SACR = data.SACR.line(FSminus1:FSplus1, :);  
                SACR_mag = sqrt(SACR(:,1).* SACR(:,1) + SACR(:,2).* SACR(:,2) + SACR(:,3).* SACR(:,3));
                SACR_mag = SACR_mag/1000;                             % convert to meters
                time = length(SACR_mag)/data.zoosystem.Video.Freq;    % get time from frequecy
                vel_stk(f) = abs((SACR_mag(end)-SACR_mag(1))/time);   % velocity in m/s
                
                for l = 1:length(limb)
                    
                    % Extract Joint Angles ---------------------------------------------------------
                    Hip = data.([limb{l}, 'HipAngle_x']).line;
                    Knee = data.([limb{l}, 'KneeAngle_x']).line;
                    Ankle = data.([limb{l}, 'AnkleAngle_x']).line;
                    
                    % Hip, knee, and ankle phase angle padded to nearest event on either side ------
                    HipCyclePhase  = Phase_Angle(Hip);
                    HipStancePhase = HipCyclePhase(Stance);
                    HipSwingPhase  = HipCyclePhase(Swing);
                    
                    KneeCyclePhase  = Phase_Angle(Knee);
                    KneeStancePhase = KneeCyclePhase(Stance);
                    KneeSwingPhase  = KneeCyclePhase(Swing);
                    
                    AnkleCyclePhase  = Phase_Angle(Ankle);
                    AnkleStancePhase = AnkleCyclePhase(Stance);
                    AnkleSwingPhase  = AnkleCyclePhase(Swing);
                    
                    % CRP calculations -------------------------------------------------------------
                    KHStanceCRP = CRP(KneeStancePhase,HipStancePhase);
                    KHSwingCRP  = CRP(KneeSwingPhase,HipSwingPhase);
                    
                    AKStanceCRP = CRP(AnkleStancePhase, KneeStancePhase);
                    AKSwingCRP  = CRP(AnkleSwingPhase, KneeSwingPhase);
                    
                    % Time Normalizes CRP curves to 100 percent (101 points) -----------------------
                    KHStanceCRP_Norm = TimeNorm(KHStanceCRP, 'spline');
                    KHSwingCRP_Norm  = TimeNorm(KHSwingCRP, 'spline');
                    
                    AKStanceCRP_Norm = TimeNorm(AKStanceCRP, 'spline');
                    AKSwingCRP_Norm  = TimeNorm(AKSwingCRP, 'spline');
                    
                    if strcmp(limb{l}, 'Right')
                        RightKHStanceCRP_stk(f, :) = KHStanceCRP_Norm;
                        RightKHSwingCRP_stk(f, :) = KHSwingCRP_Norm;
                        RightAKStanceCRP_stk(f, :) = AKStanceCRP_Norm;
                        RightAKSwingCRP_stk(f, :) = AKSwingCRP_Norm;
                    elseif strcmp(limb{l}, 'Left')
                        LeftKHStanceCRP_stk(f, :) = KHStanceCRP_Norm;
                        LeftKHSwingCRP_stk(f, :) = KHSwingCRP_Norm;
                        LeftAKStanceCRP_stk(f, :) = AKStanceCRP_Norm;
                        LeftAKSwingCRP_stk(f, :) = AKSwingCRP_Norm;
                    end
                end
            end
            
            % delete temp files --------------------------------------------------------------------
            for f = 1:length(fl)
                java.io.File(fl{f}).delete();
            end
            
            % compute mean absolute relative phase (MARP) ------------------------------------------
            RightKHStance_MARP = mean(RightKHStanceCRP_stk);
            RightKHSwing_MARP  = mean(RightKHSwingCRP_stk);
            RightAKStance_MARP = mean(RightAKStanceCRP_stk);
            RightAKSwing_MARP  = mean(RightAKSwingCRP_stk);
            
            LeftKHStance_MARP = mean(LeftKHStanceCRP_stk);
            LeftKHSwing_MARP  = mean(LeftKHSwingCRP_stk);
            LeftAKStance_MARP = mean(LeftAKStanceCRP_stk);
            LeftAKSwing_MARP  = mean(LeftAKSwingCRP_stk);
            
            % Compute deviation phase (DP) ---------------------------------------------------------
            RightKHStance_DP = std(RightKHStanceCRP_stk);
            RightKHSwing_DP  = std(RightKHSwingCRP_stk);
            RightAKStance_DP = std(RightAKStanceCRP_stk);
            RightAKSwing_DP  = std(RightAKSwingCRP_stk);
            
            LeftKHStance_DP = std(LeftKHStanceCRP_stk);
            LeftKHSwing_DP  = std(LeftKHSwingCRP_stk);
            LeftAKStance_DP = std(LeftAKStanceCRP_stk);
            LeftAKSwing_DP  = std(LeftAKSwingCRP_stk);
            
            % compute mean velocity
            vel_mean = mean(vel_stk);
            
            % create new zoo file for ensembled (mean, std) data -----------------------------------
            fl_ens = [file_pth, filesep, file_name(1:end-2), 'ens', ext];
            data_ens = struct;
            
            % save time series info to file --------------------------------------------------------
            data_ens.RightKHStance_MARP.line = RightKHStance_MARP;
            data_ens.RightKHSwing_MARP.line = RightKHSwing_MARP;
            data_ens.RightAKStance_MARP.line =RightAKStance_MARP;
            data_ens.RightAKSwing_MARP.line = RightAKSwing_MARP;
            
            data_ens.LeftKHStance_MARP.line = LeftKHStance_MARP;
            data_ens.LeftKHSwing_MARP.line = LeftKHSwing_MARP;
            data_ens.LeftAKStance_MARP.line = LeftAKStance_MARP;
            data_ens.LeftAKSwing_MARP.line = LeftAKSwing_MARP;
            
            data_ens.RightKHStance_DP.line = RightKHStance_DP;
            data_ens.RightKHSwing_DP.line = RightKHSwing_DP;
            data_ens.RightAKStance_DP.line =RightAKStance_DP;
            data_ens.RightAKSwing_DP.line = RightAKSwing_DP;
            
            data_ens.LeftKHStance_DP.line = LeftKHStance_DP;
            data_ens.LeftKHSwing_DP.line = LeftKHSwing_DP;
            data_ens.LeftAKStance_DP.line =LeftAKStance_DP;
            data_ens.LeftAKSwing_DP.line = LeftAKSwing_DP;
            
            % compute events at each phase of gait cycle for each MARP, DP curve -------------------
            ch = fieldnames(data_ens);            
            for c = 1:length(ch)
                r = data_ens.(ch{c}).line;
                events = struct;

                if strfind(ch{c}, 'Stance')
                    events.IC  = [1,  mean(r(1:4)),    0];
                    events.LR  = [5,  mean(r(5:20)),   0];
                    events.MS  = [21, mean(r(21:50)),  0];
                    events.TS  = [51, mean(r(51:81)),  0];
                    events.PSw = [82, mean(r(82:101)), 0];
                elseif strfind(ch{c}, 'Swing')
                    events.ISw = [1,  mean(r(1:34)),   0];
                    events.MSw = [35, mean(r(35:66)),  0];
                    events.TSw = [67, mean(r(67:101)), 0];
                end
                    
                data_ens.(ch{c}).event = events;
            end
            
            % add velocity as event to last channel (arbitrary)
            data_ens.RightKHStance_MARP.event.velocity = [1, vel_mean, 0];
            
            data_ens.zoosystem = setZoosystem(fl_ens);
            zsave(fl_ens, data_ens);
            
        end
    end
end


%% EXTRACT TRIAL BY TRIAL EVENTS TO SPREADSHEET ====================================================

subjects = {'OA03','OA06','OA08','OA10','OA11','OA12','OA14','OA15','OA17','OA18','OA19','OA20',...
            'OA21','OA22','OA23','OA25','OA26','YA01','YA02','YA03','YA04','YA05','YA06','YA07',...
            'YA08','YA09','YA10','YA11','YA12','YA13','YA16','YA17','YA18','YA19','YA20'};
cons = {'Old\Flat', 'Old\Uneven', 'Young\Flat', 'Young\Uneven'};
lcl_evts = {'IC', 'LR', 'MS', 'TS', 'PSw', 'ISw', 'MSw', 'TSw', 'velocity'};
chns = {'RightKHStance_MARP','RightKHSwing_MARP', 'RightAKStance_MARP','RightAKSwing_MARP', ...
        'RightKHStance_DP', 'RightKHSwing_DP', 'RightAKStance_DP', 'RightAKSwing_DP'};   

eventval('fld', fld_data_proc, 'dim1', cons, 'dim2', subjects, 'ch', chns, ...
         'localevents', lcl_evts, 'globalevents', 'none');




