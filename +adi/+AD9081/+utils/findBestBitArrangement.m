function [mode,quantizedTaps,tapError] = findBestBitArrangement(taps,N)

reps = N/(192/4);

tapGroups = {};
for k=1:4:N
    tapGroups = [tapGroups(:)',{taps(k:k+3)}];
end

% Arrange
Taps16bit = [16,16,16];

N = N/4;
Taps16bitAll = repmat(Taps16bit,1,reps);
L = length(Taps16bitAll);
PossibleCasts = [];
loops = N-L;
for leading12s = 0:L
    for offset16 = 0:loops-L
        PossibleCast = zeros(1,N);
        % Place 16 bit markers
        start = 1+leading12s+offset16; last = L+leading12s+offset16;
        PossibleCast(start:last) = 16;
        % Place 12 bit markers
        PossibleCast(start-leading12s:start-1) = 12;
        PossibleCast(last+1:last+L-leading12s) = 12;
        % Place 6 bit markers
        PossibleCast(PossibleCast==0) = 6;
        PossibleCasts = [PossibleCasts; PossibleCast]; %#ok<*AGROW>
    end
end

error = zeros(size(PossibleCasts,1),1);
for leading12s = 1:size(PossibleCasts,1)
    for group = 1:length(tapGroups)
        config = PossibleCasts(leading12s,group);
        tg = tapGroups{group};
        diff = abs( double(fi(tg,1,config,0)) - double(tg));
        error(leading12s) = error(leading12s) + sum(diff);
    end
end

[tapError,bestCast] = min(error);
% plot(sort(error));

mode = PossibleCasts(bestCast,:);

%% Apply new types to taps
quantizedTaps = length(taps);
for group = 1:length(tapGroups)
    config = PossibleCasts(bestCast,group);
    tg = tapGroups{group};
    quantizedTaps( (group-1)*4+1 : group*4) = int16((fi(tg,1,config,0)));
end

end