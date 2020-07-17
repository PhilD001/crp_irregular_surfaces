function clean_raw_data(fld_data_root)

fl = engine('fld', fld_data_root, 'extension', 'zoo');
for i = 1:length(fl)
    [pth, f, ext] = fileparts(fl{i});
    new_pth = strrep(pth, 'Straight/Ant/', '');
    if ~exist(new_pth, 'dir')
        mkdir(new_pth)
    end
    
    if ~exist([new_pth, filesep, f, ext], 'file')
        movefile([pth, filesep, f, ext], [new_pth, filesep, f, ext])
    end
    fl_sub = engine('fld', pth, 'extension', 'zoo');
    if isempty(fl_sub)
        rmdir(pth)
    end
    
    if ~isempty(strfind(fl{i}, 'tatic'))
       delfile(fl{i}) 
    end
end

[subs, ~] = subdir(fld_data_root);
for j = 1:length(subs)
    if ~isempty(strfind(subs{j}, 'Straight'))
        fl_sub = engine('fld', subs{j}, 'extension', 'zoo');
        if isempty(fl_sub)
            rmdir(subs{j})
        end
    end
    if ~isempty(strfind(subs{j}, 'tatic'))
        fl_sub = engine('fld', subs{j}, 'extension', 'zoo');
        if isempty(fl_sub)
            rmdir(subs{j})
        end
    end
    
end

ch_kp = {'SACR', 'RightHipAngle_x', 'RightKneeAngle_x', 'RightAnkleAngle_x',...
                 'LeftHipAngle_x', 'LeftKneeAngle_x', 'LeftAnkleAngle_x'};
             
fl = engine('fld', fld_data_root, 'ext', 'zoo');
for i = 1:length(fl)
    data = zload(fl{i});
    data.zoosystem.Processing = {'kinematics and partitonned'};
    zsave(fl{i},data)
end
             
bmech_removechannel(fld_data_root, ch_kp, 'keep');