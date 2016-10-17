%invertedImageIndex Search index that maps visual words to images.
%  imageIndex = invertedImageIndex(bag) returns an invertedImageIndex
%  object given a bagOfFeatures object, bag. Add images to the imageIndex
%  using the addImages method. Then use the retrieveImages function to
%  search for images within the imageIndex.
%
%  [...] = invertedImageIndex(...,'SaveFeatureLocations', value) optionally
%  specifies whether or not the feature location data should be saved
%  within the image index. By default, 'SaveFeatureLocations' is true.
% 
%   invertedImageIndex properties:
%     ImageLocation      - Cell array defining indexed image locations.
%     ImageWords         - A vector of visualWords objects for each indexed image.
%     WordFrequency      - A vector containing the percentage of images in which each visual word occurs.
%     BagOfFeatures      - bagOfFeatures object used by the index.
%     MatchThreshold     - Percentage of matching words required between a query and a potential match.                                                 
%     WordFrequencyRange - Upper and lower bounds on valid word frequencies.
%
%   invertedImageIndex methods:
%     addImages    - Add new images into the index.
%     removeImages - Remove images from the index.
%
% Example - Search for objects
% ----------------------------
% % Define a set of images to search
% imageFiles = ...
%     {'elephant.jpg', 'cameraman.tif', ...
%      'peppers.png',  'saturn.png',...
%      'pears.png',    'stapleRemover.jpg', ...
%      'football.jpg', 'mandi.tif',...
%      'kids.tif',     'liftingbody.png', ...
%      'office_5.jpg', 'gantrycrane.png',...
%      'moon.tif',     'circuit.tif', ...
%      'tape.png',     'coins.png'};
%                              
% imgSet = imageSet(imageFiles);
%
% % Learn the visual vocabulary
% bag = bagOfFeatures(imgSet, 'PointSelection', 'Detector', 'VocabularySize', 1000);
%
% % Create an image search index and add images
% imageIndex = invertedImageIndex(bag);
% 
% addImages(imageIndex, imgSet);
%
% % Specify a query image and an ROI to search for the elephant
% queryImage = imread('clutteredDesk.jpg');
% queryROI = [130 175 330 365]; 
%  
% figure
% imshow(queryImage)
% rectangle('Position',queryROI,'EdgeColor','yellow')
%  
% % You can also use IMRECT to interactively select a ROI
% %   queryROI = getPosition(imrect)
%  
% % Find images that contain the elephant 
% imageIDs = retrieveImages(queryImage,imageIndex,'ROI',queryROI)
%   
% bestMatch = imageIDs(1);
%   
% figure
% imshow(imageIndex.ImageLocation{bestMatch})
%
% See also indexImages, retrieveImages, evaluateImageRetrieval, 
%          bagOfFeatures, imageSet.

classdef invertedImageIndex_mine < vision.internal.EnforceScalarHandle   
    
    % ---------------------------------------------------------------------
    properties(GetAccess = public, SetAccess = protected)                
        % ImageLocation - Cell array defining indexed image locations
        ImageLocation
        
        % ImageWords - A vector of visualWords objects for each indexed image.
        ImageWords
        
        % Dimensions - A cell array of the dimension of the features for
        %              each image
        Dimensions
        
        % WordFrequency - A vector containing the percentage of images in
        %                 which each visual word occurs. This is analogous
        %                 to document frequency in text retrieval
        %                 applications.
        WordFrequency
        
        WordFrequency_test
        
        % BagOfFeatures - The bagOfFeatures object used in the index.
        BagOfFeatures               
    end
    
    % ---------------------------------------------------------------------
    properties        
        % MatchThreshold - Specifies the percentage of similar words
        %                  required between a query and a potential image
        %                  match. Lower this threshold to obtain more
        %                  search results at the cost of additional
        %                  computation.
        %
        %                  Default: 0.01
        MatchThreshold        
        
        % WordFrequencyRange   Specify the word frequency range,
        %                      [lower upper], as a percentage. Use the word
        %                      frequency range to ignore words that are
        %                      very common or very rare within the image
        %                      index. These words are often due to
        %                      repeated patterns or outliers and may reduce
        %                      search accuracy.
        %
        %                      Default: [0.01 0.9]
        WordFrequencyRange
    end
        
    properties(Access = public)  % Deafult: Access = protected, Dependent, Hidden
        NumImages   
    end
    
    % ---------------------------------------------------------------------
    properties(Access = public)        % Deafult: Hidden, Access = protected
        WordHistograms      % it is the database (memory) of the system !!!!!!!!!!!!  
        InverseDocumentFrequency
        NumImagesPerWord
        NumImagesPerWord_test
        WordsPerImage   
        SaveLocations
        NumImages_test
        NumImages_processed
    end            
    
    % =====================================================================
    methods
        
        % -----------------------------------------------------------------
        function this = invertedImageIndex_mine(bag, varargin)
            
            % Set parameter defaults.
            defaults = invertedImageIndex_mine.getParameterDefaults();
            
            this.MatchThreshold     = defaults.MatchThreshold;
            this.WordFrequencyRange = defaults.WordFrequencyRange;           
                        
            params = invertedImageIndex_mine.parseInputs(bag, varargin{:});
            
            this.BagOfFeatures = bag;
            this.SaveLocations = params.SaveFeatureLocations;
            
%             if exists(this.WordHistograms)
%                 this.NumImages_test = size(this.WordHistograms, 1);
%             else
%                 this.NumImages_test = 0;
%             end
            
            this.NumImages_test = size(this.WordHistograms, 1);
            
            this.NumImages_processed = 0;
            
        end                       
        
        % -----------------------------------------------------------------
        function [imageIDs, varargout] = search(this, query, varargin)                                    
            
            nargoutchk(1,3);
            
            params = invertedImageIndex_mine.parseSearchInputs(query, varargin{:});
            
            if this.SaveLocations
                % TO BE MODIFIED !!!!!!!!!!!!!!!!!!!!
                [queryHist, queryVisualWords] = this.BagOfFeatures.encode(query,'Normalization','none','SparseOutput',true);
            else
                % TO BE MODIFIED !!!!!!!!!!!!!!!!!!!!
                queryHist = this.BagOfFeatures.encode(query,'Normalization','none','SparseOutput',true);
                queryVisualWords = vision.internal.visualWords.empty();
            end
            
            if this.NumImages == 0
                warning(message('vision:invertedImageIndex:noImages'));                
                imageIDs = zeros(0,1);
                scores   = zeros(0,1);                              
            else
                                
                [words, queryVisualWords] = removeStopWords(this, queryHist, queryVisualWords, this.WordFrequencyRange);
                
                imageIDs = findImagesContainingWords(this, words);
                
                imageIDs = removeImagesWithLowWordMatches(this, imageIDs, words, this.MatchThreshold);
                
                scores   = computeMatchMetric(this,imageIDs,words,queryHist);
                
                [imageIDs, scores] = selectStrongest(this, imageIDs, scores, params.NumResults);
            end
            
            if nargout > 1
                varargout{1} = scores;
            end
            
            if nargout > 2
                varargout{2} = queryVisualWords;
            end           
        end    
        
        % -----------------------------------------------------------------
        function [imageIDs, varargout] = search_and_update(this, query, varargin)
            
            global ds
            
            nargoutchk(1,5);
            
            params = invertedImageIndex_mine.parseSearchInputs(query, varargin{:});
            
            if this.SaveLocations
                % TO BE MODIFIED !!!!!!!!!!!!!!!!!!!!
                [queryHist, queryVisualWords, dimensions, dist] = this.BagOfFeatures.encode(query,'Normalization','none','SparseOutput',true);
            else
                % TO BE MODIFIED !!!!!!!!!!!!!!!!!!!!
                queryHist = this.BagOfFeatures.encode(query,'Normalization','none','SparseOutput',true);
                queryVisualWords = vision.internal.visualWords.empty();
            end
            
            numImagesPerWord = sum(spones(queryHist), 1);
            wordsPerImage    = full(sum(queryHist,2));
            
            [words, queryVisualWords] = removeStopWords(this, queryHist, queryVisualWords, this.WordFrequencyRange);
            
            imageIDs = findImagesContainingWords(this, words);
            
            imageIDs = removeImagesWithLowWordMatches(this, imageIDs, words, this.MatchThreshold);
            
            scores   = computeMatchMetric(this,imageIDs,words,queryHist);
            
            [imageIDs, scores] = selectStrongest(this, imageIDs, scores, params.NumResults);
            
            if(ds.conf.static_mem)
                this.NumImagesPerWord = this.NumImagesPerWord + numImagesPerWord;
            else
                %             this.ImageLocation    = [this.ImageLocation; imgSet.ImageLocation(:)];
                this.WordHistograms   = vertcat(this.WordHistograms, queryHist);
                this.NumImagesPerWord = this.NumImagesPerWord + numImagesPerWord;
                this.WordsPerImage    = [this.WordsPerImage; wordsPerImage];
                this.ImageWords       = [this.ImageWords; queryVisualWords];
                this.Dimensions       = [this.Dimensions; {dimensions}];
            end
            
            if(ds.conf.update_statistics)
                this.NumImages_test = this.NumImages_test + 1;
                updateIndexStatistics(this);
            end
            
            if nargout > 1
                varargout{1} = scores;
            end
            
            if nargout > 2
                varargout{2} = queryVisualWords;
                varargout{3} = dimensions;
                varargout{4} = dist;
            end
        end
        
        % -----------------------------------------------------------------
        function addImages(this, imgSet, varargin)
            % addImages(imageIndex, imgSet) adds the images in imgSet into
            % the imageIndex. imgSet is an imageSet object that contains
            % new images to add to an existing index. Duplicate images are
            % not ignored.
            %
            % addImages(..., Name, Value) specifies additional name-value
            % pair arguments described below:
            %
            % 'Verbose'  Set true to display progress information.
            %
            %            Default: true
            
            params = invertedImageIndex_mine.parseAddImagesInputs(imgSet, varargin{:});
            
            if this.SaveLocations
                % TO BE MODIFIED !!!!!!!! with encodeSingleImage
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Index word histograms and word location information
                [wordHistograms, words] = this.BagOfFeatures.encode(imgSet, ...
                    'Normalization', 'None', ...
                    'SparseOutput',  true,...
                    'Verbose',       params.Verbose,...
                    'UseParallel',   params.UseParallel);
            else
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Just index the word histograms
                wordHistograms = this.BagOfFeatures.encode(imgSet, ...
                    'Normalization', 'None', ...
                    'SparseOutput',  true,...
                    'Verbose',       params.Verbose,...
                    'UseParallel',   params.UseParallel);
                
                words = [];
            end
            
            numImagesPerWord = sum(spones(wordHistograms), 1);
            wordsPerImage    = full(sum(wordHistograms,2));
            
            if isempty(this.ImageLocation)
                % Empty index - initialize everything
                this.ImageLocation    = reshape(imgSet.ImageLocation,imgSet.Count,1);
                this.WordHistograms   = wordHistograms;
                this.NumImagesPerWord = numImagesPerWord;
                this.WordsPerImage    = wordsPerImage;
                this.ImageWords       = words;
            else
                this.ImageLocation    = [this.ImageLocation; imgSet.ImageLocation(:)];
                this.WordHistograms   = vertcat(this.WordHistograms, wordHistograms);
                this.NumImagesPerWord = this.NumImagesPerWord + numImagesPerWord;
                this.WordsPerImage    = [this.WordsPerImage; wordsPerImage];
                this.ImageWords       = [this.ImageWords; words];
            end
            
            updateIndexStatistics(this);
        end
        
        % -----------------------------------------------------------------
        function removeImages(this, indices)
            % removeImages(imageIndex, indices) removes images from the
            % index. The indices correspond to the images within
            % imageIndex.ImageLocation.
            
            validateattributes(indices, {'numeric'}, ...
                {'vector','nonempty','integer','positive','real','nonsparse'}, ...
                mfilename, 'indices');
            
            if max(indices) > this.NumImages
                error(message('vision:invertedImageIndex:invalidIndices'));
            end
            
            % Decrement NumImagesPerWord by the counts for the images being removed
            removedNumImagesPerWord = sum(spones(this.WordHistograms(indices,:)));
            this.NumImagesPerWord   = this.NumImagesPerWord - removedNumImagesPerWord;
            
            this.ImageLocation(indices)    = [];
            this.WordHistograms(indices,:) = [];
            this.WordsPerImage(indices)    = [];
            
            if this.SaveLocations
                this.ImageWords(indices) = [];
            end
            
            updateIndexStatistics(this);
            
        end
        
        % -----------------------------------------------------------------
        function addImages_online(this, image, varargin)
            global ds
            % addImages(imageIndex, imgSet) adds the images in imgSet into
            % the imageIndex. imgSet is an imageSet object that contains
            % new images to add to an existing index. Duplicate images are
            % not ignored.
            %
            % addImages(..., Name, Value) specifies additional name-value
            % pair arguments described below:
            %
            % 'Verbose'  Set true to display progress information.
            %
            %            Default: true
            
            params = invertedImageIndex_mine.parseAddImages_online_Inputs(image, varargin{:});
            
            if this.SaveLocations
                % TO BE MODIFIED !!!!!!!! if we use encodeSingleImage the
                % first argument must be an image not an imgSet
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Index word histograms and word location information
                [wordHistograms, words, dimensions] = this.BagOfFeatures.encode(image, ...
                    'Normalization', 'None', ...
                    'SparseOutput',  true,...
                    'Verbose',       params.Verbose,...
                    'UseParallel',   params.UseParallel);
                
            else
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Just index the word histograms
                wordHistograms = this.BagOfFeatures.encode(image, ...
                    'Normalization', 'None', ...
                    'SparseOutput',  true,...
                    'Verbose',       params.Verbose,...
                    'UseParallel',   params.UseParallel);
                
                words = [];
            end
            
            numImagesPerWord = sum(spones(wordHistograms), 1);
            wordsPerImage    = full(sum(wordHistograms,2));
            
            if this.NumImages_processed == 0   % case in which no memory is loaded
                if this.NumImages ~= 0    % case in which the bag is already loaded
%                     this.ImageLocation    = reshape(imgSet.ImageLocation, imgSet.Count, 1);
                    this.WordHistograms   = wordHistograms;
                    this.NumImagesPerWord = this.NumImagesPerWord + numImagesPerWord;
                    this.WordsPerImage    = wordsPerImage;
                    this.ImageWords       = words;
                    this.Dimensions       = {dimensions};
                else
                    % Empty index - initialize everything
%                     this.ImageLocation    = reshape(imgSet.ImageLocation, imgSet.Count, 1);
                    this.WordHistograms   = wordHistograms;
                    this.NumImagesPerWord = numImagesPerWord;
                    this.WordsPerImage    = wordsPerImage;
                    this.ImageWords       = words;
                    this.Dimensions       = {dimensions};
                end
            else  % case in which we have already test images in memory
%                 this.ImageLocation    = [this.ImageLocation; imgSet.ImageLocation(:)];
                this.WordHistograms   = vertcat(this.WordHistograms, wordHistograms);
                this.NumImagesPerWord = this.NumImagesPerWord + numImagesPerWord;
                this.WordsPerImage    = [this.WordsPerImage; wordsPerImage];
                this.ImageWords       = [this.ImageWords; words];
                this.Dimensions       = [this.Dimensions; {dimensions}];
            end
            
            this.NumImages_processed = this.NumImages_processed + 1;
            
            if(ds.conf.update_statistics)
                this.NumImages_test = this.NumImages_test + 1;
                updateIndexStatistics(this);
            end

        end
        
    end
    
    
    
    % =====================================================================
    % Set/Get Methods
    % =====================================================================
    methods
        
        % -----------------------------------------------------------------
        function set.MatchThreshold(this,threshold)
            validateattributes(threshold, {'numeric'},...
                {'scalar','nonnegative', '<=',1,'real', 'nonsparse'},...
                mfilename,'MatchThreshold');
            
            % stored as double
            this.MatchThreshold = double(threshold);
        end
        
        % -----------------------------------------------------------------
        function set.WordFrequencyRange(this,range)
            validateattributes(range, {'numeric'},...
                {'numel',2,'nonnegative', '<=',1,'real','nonsparse','increasing'},...
                mfilename,'WordFrequencyRange');
            
            % stored as double row vector
            this.WordFrequencyRange(1,:) = double(range);
        end
        
        % -----------------------------------------------------------------
        function n = get.NumImages(this)
            n = numel(this.ImageLocation);
        end
        
        
        % -----------------------------------------------------------------
        function set_idf_on_bag(this, wordFreq, ImgLoc, numImPerWord, idf)
            %             validateattributes(....., {'numeric'},...
            %                 {'numel',2,'nonnegative', '<=',1,'real','nonsparse','increasing'},...
            %                 mfilename,'WordFrequencyRange');
            
            this.WordFrequency = wordFreq;
            this.ImageLocation = ImgLoc;
            this.NumImagesPerWord = numImPerWord;
            this.InverseDocumentFrequency = idf;
            
        end
        
        % -----------------------------------------------------------------
        function [wordFreq, ImgLoc, numImPerWord, idf] = get_idf_on_bag(this)
            %             validateattributes(....., {'numeric'},...
            %                 {'numel',2,'nonnegative', '<=',1,'real','nonsparse','increasing'},...
            %                 mfilename,'WordFrequencyRange');
            
            wordFreq = this.WordFrequency;
            ImgLoc = this.ImageLocation;
            numImPerWord = this.NumImagesPerWord;
            idf = this.InverseDocumentFrequency;
            
        end
        
    end
    
    % =====================================================================
    methods(Access = protected, Hidden)
        % -----------------------------------------------------------------
        function updateIndexStatistics(this)
            
            this.WordFrequency = this.NumImagesPerWord ./ (this.NumImages+this.NumImages_test);
            
            this.InverseDocumentFrequency = log( this.NumImages+this.NumImages_test ./ (full(this.NumImagesPerWord) + eps) );
        end
        
        % -----------------------------------------------------------------
        function imageIDs = findImagesContainingWords(this, words)
            % Find images that have at least 1 common word with the query
            % image. This reduces the set of image candidates due to the
            % sparse nature of the visual word histograms.
            
            [id,~]   = find(this.WordHistograms(:, words));
            imageIDs = unique(reshape(id,[],1));
        end
        
        % -----------------------------------------------------------------
        function imageIDs = removeImagesWithLowWordMatches(this, imageIDs, words, threshold)
            % Remove images that do not have enough matching words. This
            % helps reduce the number of computations required to find the
            % best matches.
            
            binaryHist   = spones(this.WordHistograms(imageIDs, words));
            numMatches   = sum(binaryHist, 2);
            imagesToKeep = numMatches./numel(words) >= threshold;
            imageIDs     = imageIDs(imagesToKeep);
        end
        
        % -----------------------------------------------------------------
        function [words, queryWords] = removeStopWords(this, queryHist, queryWords, freqRange)
            
            stopWordFilter = this.WordFrequency >= freqRange(1) ...
                & this.WordFrequency <= freqRange(2);
            
            % remove stop words from query
            words = find(queryHist & stopWordFilter);
            
            if this.SaveLocations
                l = zeros(0,2,'like',queryWords.Location);
                w = zeros(0,1,'like',queryWords.WordIndex);
                for i = 1:numel(words)
                    idx = queryWords.WordIndex == words(i);
                    l = [l; queryWords.Location(idx,:)]; %#ok<AGROW>
                    w = [w; queryWords.WordIndex(idx)];  %#ok<AGROW>
                end
                queryWords = vision.internal.visualWords(w,l,this.BagOfFeatures.VocabularySize);
            end
        end
        
        % -----------------------------------------------------------------
        function [strongest, scores] = selectStrongest(~, imageIDs, scores, K)
            
            K = min(numel(imageIDs), K);
            
            [sortedScores, idx] = sort(scores,'descend');
            
            strongest = imageIDs(idx(1:K));
            scores    = sortedScores(1:K);
        end
        
        % -----------------------------------------------------------------
        function scores = computeMatchMetric(this, imageIDs, words, queryFeatures)
            
            indexFeatures = this.WordHistograms(imageIDs, :);
            
            % Term frequency weighting
            indexFeatures = applyWeighting(this, indexFeatures);
            queryFeatures = applyWeighting(this, queryFeatures);
            
            indexFeatures = invertedImageIndex_mine.l2NormalizeFeatures(indexFeatures);
            queryFeatures = invertedImageIndex_mine.l2NormalizeFeatures(queryFeatures);
            
            % cosine similarity
            scores = full(indexFeatures(:,words) * queryFeatures(words)');
            
        end
        
        % -----------------------------------------------------------------
        % Apply Term Frequency-Inverse Document Frequency (TF-IDF)
        % weighting. TF and IDF weights are packed into diagonal matrices
        % for efficient computation.
        % -----------------------------------------------------------------
        function tfidf = applyWeighting(this, h)
            
            [M,N]  = size(h);
            
            % Pack weights into sparse diagonal matrices
            diagTermFreq   = spdiags(1./(sum(h,2)+eps), 0, M, M);
            diagInvDocFreq = spdiags(this.InverseDocumentFrequency(:), 0, N, N);
            
            % Apply weights
            tf    = diagTermFreq * h;
            tfidf = tf  * diagInvDocFreq;
        end
        
    end
    
    % =====================================================================
    methods(Static, Access = private)
        % -----------------------------------------------------------------
        function normalizedFeatures = l2NormalizeFeatures(features)
            M = size(features, 1);
            
            fNorm = sqrt(sum(features.^2,2));
            
            fNormInv = 1./(fNorm + eps(class(features)));
            
            fNormInv = spdiags(fNormInv(:), 0, M, M); % sparse diagonal
            
            normalizedFeatures = fNormInv * features; % normalize row vectors
        end
        
        % -----------------------------------------------------------------
        function defaults = getSearchParameterDefaults()
            defaults.NumResults = 20;
        end
        
        % -----------------------------------------------------------------
        function params = parseSearchInputs(I, varargin)
            
            vision.internal.inputValidation.validateImage(I, 'I');
            
            defaults = invertedImageIndex_mine.getSearchParameterDefaults();
            
            % input parsing
            p = inputParser;
            addParameter(p, 'NumResults', defaults.NumResults);
            
            parse(p, varargin{:});
            
            params.NumResults = double(p.Results.NumResults);
        end
        
        % -----------------------------------------------------------------
        function params = parseInputs(bag, varargin)
            
            validateattributes(bag, {'bagOfFeatures_mine'},...
                {'nonempty'},mfilename,'bag');
            
            p = inputParser();
            
            d = invertedImageIndex_mine.getParameterDefaults();
            
            p.addParameter('SaveFeatureLocations', d.SaveFeatureLocations, ...
                @(x)vision.internal.inputValidation.validateLogical(x,'SaveFeatureLocations'));
            
            parse(p, varargin{:});
            
            params.SaveFeatureLocations = logical(p.Results.SaveFeatureLocations);
        end
        
        % -----------------------------------------------------------------
        function params = parseAddImagesInputs(imgSet, varargin)
            
            validateattributes(imgSet, {'imageSet_mine'},...
                {'scalar','nonempty'},mfilename,'imgSet');
            
            if imgSet.Count == 0
                error(message('vision:invertedImageIndex:emptyImageSet'));
            end
            
            p = inputParser();
            
            d = invertedImageIndex_mine.getParameterDefaults();
            
            p.addParameter('Verbose', d.Verbose, ...
                @(x)vision.internal.inputValidation.validateLogical(x,'Verbose'));
            
            p.addParameter('UseParallel', d.UseParallel, ...
                @(x)vision.internal.inputValidation.validateLogical(x,'UseParallel'));
            
            parse(p, varargin{:});
            
            params.Verbose     = logical(p.Results.Verbose);
            params.UseParallel = logical(p.Results.UseParallel);
            
        end
        
        % -----------------------------------------------------------------
        function params = parseAddImages_online_Inputs(~, varargin)
            
            p = inputParser();
            
            d = invertedImageIndex_mine.getParameterDefaults();
            
            p.addParameter('Verbose', d.Verbose, ...
                @(x)vision.internal.inputValidation.validateLogical(x,'Verbose'));
            
            p.addParameter('UseParallel', d.UseParallel, ...
                @(x)vision.internal.inputValidation.validateLogical(x,'UseParallel'));
            
            parse(p, varargin{:});
            
            params.Verbose     = logical(p.Results.Verbose);
            params.UseParallel = logical(p.Results.UseParallel);
            
        end
        
        % -----------------------------------------------------------------
        function defaults = getParameterDefaults()
            defaults.MatchThreshold       = 0.01;
            defaults.WordFrequencyRange   = [0.01 0.9];
            defaults.Verbose              = true;
            defaults.UseParallel          = vision.internal.useParallelPreference();
            defaults.SaveFeatureLocations = true;
        end
    end
    
    % =====================================================================
    methods(Hidden)
        function s = saveobj(this)
            s.ImageWords               = this.ImageWords;
            s.BagOfFeatures            = saveobj(this.BagOfFeatures);
            s.ImageLocation            = this.ImageLocation;
            s.WordFrequency            = this.WordFrequency;
            s.MatchThreshold           = this.MatchThreshold;
            s.WordFrequencyRange       = this.WordFrequencyRange;
            s.WordHistograms           = this.WordHistograms;
            s.InverseDocumentFrequency = this.InverseDocumentFrequency;
            s.NumImagesPerWord         = this.NumImagesPerWord;
            s.WordsPerImage            = this.WordsPerImage;
            s.SaveLocations            = this.SaveLocations;
%             s.NumImages                = this.NumImages;
%             s.NumImages_test           = this.NumImages_test;
%             s.WordFrequency_test       = this.WordFrequency_test;
%             s.Dimensions               = this.Dimensions;
            
        end
    end
    
    % =====================================================================
    methods(Static,Hidden)
        function this = loadobj(s)
            global ds
            
            bag  = bagOfFeatures_mine.loadobj(s.BagOfFeatures);
            this = invertedImageIndex_mine(bag);
            
            this.ImageWords               = s.ImageWords;
            this.ImageLocation            = s.ImageLocation;
            this.WordFrequency            = s.WordFrequency;
            this.MatchThreshold           = s.MatchThreshold;
            this.WordFrequencyRange       = s.WordFrequencyRange;
            this.WordHistograms           = s.WordHistograms;
            this.InverseDocumentFrequency = s.InverseDocumentFrequency;
            this.NumImagesPerWord         = s.NumImagesPerWord;
            this.WordsPerImage            = s.WordsPerImage;
            this.SaveLocations            = s.SaveLocations;
%             this.NumImages                = s.NumImages;
%             this.NumImages_test           = s.NumImages_test;
            this.NumImages_test           = size(s.WordHistograms, 1);
%             this.NumImages_processed      = this.NumImages_processed;
%             if(ds.conf.update_statistics)
%                 this.NumImages_test           = size(s.WordHistograms, 1);
%             end
%             this.WordFrequency_test       = s.WordFrequency_test;
%             this.Dimensions               = s.Dimensions;
        end
    end
    
end