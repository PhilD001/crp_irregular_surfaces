function STSPN = TimeNorm(data, method)
%This functions normalizes data to 101 points. See interp1 for interpoation methods

newlen = 101;
[nframes, ~] = size(data);
index=1:nframes;
inc=(nframes-1)/(newlen-1);
cycle=1:inc:nframes;
STSPN = interp1(index, data, cycle, method)';

end

