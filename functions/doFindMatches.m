% Copyright 2013, Niko Sünderhauf
% niko@etit.tu-chemnitz.de
%
% This file is part of OpenSeqSLAM.
%
% OpenSeqSLAM is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% OpenSeqSLAM is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with OpenSeqSLAM.  If not, see <http://www.gnu.org/licenses/>.     
function matches = doFindMatches(results, params)       
     
%     filename = sprintf('%s/matches-%s-%s%s.mat', params.savePath, params.dataset(1).saveFile, params.dataset(2).saveFile, params.saveSuffix);  
     
%     if params.matching.load && exist(filename, 'file')
%         display(sprintf('Loading matchings from file %s ...', filename));
%         m = load(filename);
%         results.matches = m.matches;          
%     else
    
        matches = zeros(size(results,2),2);
        
        display('Searching for matching images ...');
        % h_waitbar = waitbar(0, 'Searching for matching images.');
        
        % make sure ds is dividable by two
        params.matching.ds = params.matching.ds + mod(params.matching.ds,2);
        
        DD = results;
        % default: N = 6:352
%         parfor N = params.matching.ds/2+1 : size(results.DD,2)-params.matching.ds/2
%         for N = params.matching.ds/2+1 : size(results,2)
        for N = params.matching.ds/2+1 : size(results,2)-params.matching.ds/2 %?? what about the second part
            matches(N,:) = findSingleMatch(DD, N, params);
            %   waitbar(N / size(results.DD,2), h_waitbar);
        end
               
        % save it
        if params.matching.save
            save(filename, 'matches');
        end
        
end