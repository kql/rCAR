%==========================================================================
% Usage: Apply_rCAR.m script performs re-referencing using the robust Common
% Average Reference (rCAR) procedure put forward by Lepage, Kramer and Chu
% (2014) to EEG data in different formats.
%==========================================================================
%
% Copyright (C) 2017    Version 0.6     Release date: 06 July 2017
%
% Authors: Dr Phil Duke, Dr Giorgio Fuggetta, and Dr. Kyle Q. Lepage
%
% Dr Phil Duke, University of Leicester, Leicester, UK
% Email: pad11@leicester.ac.uk
%
% Dr Giorgio Fuggetta, Roehampton University, London, UK
% Email: giorgio.fuggetta@roehampton.ac.uk
%
% Dr Kyle Q. Lepage
% Email: kyle.lepage@gmail.com
%
% This script/program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as published
% by the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version. For further infomration go to:
% https://www.gnu.org/licenses/quick-guide-gplv3.html
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You can find here http://math.bu.edu/people/lepage/code.html a Zip file that
% provides the original MATLAB scripts to re-reference data using the robust
% procedure described in: K. Q. Lepage, M. A. Kramer, C. J. Chu (2014)
% A Statistically Robust EEG Re-referencing Procedure to Mitigate Reference
% Effect, Journal of Neuroscience Methods, 235 101-116.
%
%
%--------------------------------------------------------------------------
% PRE-REQUISITES BEFORE RUNNING APPLY rCAR
%
% This script uses functions from the software EEGLAB, so make sure you have
% installed EEGLAB (https://sccn.ucsd.edu/eeglab/index.php) and that both
% the re-referencing code folder and the EEGLAB folder are set in MATLAB's
% search path.
%
% To import Brain Vision Analyser (BVA), Neuroscan continuous and Neuroscan
% Curry 6, 7 and 8 data files, it is necessary to add two data import
% extensions in EEGLAB. Thus from EEGLAB:
% 1) go to File > Manage EEGLAB extensions > Data import extensions,
% 2) add the bva-io (Import Brain Vision Analyser data file) plugin, and
% 3) add the loadcurry (Import Neuroscan Curry 6, 7, 8 data files) plugin.
%
%
%--------------------------------------------------------------------------
% SUPPORTED INPUT FILES
%
% The script loads four possible EEG recording formats:
%
% 1) Brain vision Analyser (BVA) continuous format. The EEG recording consists of
% three dedicated files: the EEG data file (*.eeg), the header file (*.vhdr).
% and the marker file (*.vmrk). The script will firstly access *.vhdr files.
% Supported BVA formats:
% Multiplexed 16 bit signed integer
% Vectorized 16 bit signed integer
% BVA Multiplexed IEEE 32 Bit Floating Point Format
% BVA Vectorized IEEE 32 Bit Floating Point Format
%
% NOTE: if the EEG data from BVA is segmented, then it is necessary to
% convert it into continous format before exporting it in one of the supported
% BVA formats. You could use the provided "Marker Remove new segment.vabs"
% solution for this purpose. This file needs to be copied in Analyser's
% solutions folder to be used (e.g. C:\Vision\Analyzer2\Solutions\Markers).
%
%
% 2) Neuroscan continuous signal file (*.cnt).
%
%
% 3) Neuroscan CURRY 6, 7, 8 continuous format. The EEG recording consists of
% three dedicated files: the EEG data file (*.cdt), the Curry parameters file
% (*.dpa) and the events file (*.cef).
%
% NOTE: The file can be opened correctly in both EEGLAB and CURRY. From CURRY
% you might need to use the Functional Data Import Wizard and under Data Order:
% you just need to change the Data Order to "Blocked (Channels)". This step can
% be skipped by opening the *.dpa file in a text editor and setting the
% DataSampOrder to "CHAN".
%
%
% 4) European Data Format (*.EDF or *.EDF+).
%
%
%--------------------------------------------------------------------------
% SUPPORTED OUTPUT FILES
%
% The output files are currently in Brain Vision Analyser (BVA) exchange
% format (*.dat), Curry (*.cdt) or European Data Format (*.EDF) without
% markers/annotations. Thus the script will load and save as follows:
%
% Load BVA .eeg and save as BVA .dat
% Load Neuroscan .CNT and save as BVA .dat
% Load Neuroscan Curry .CDT and save as Curry .CDT
% Load EDF or EDF+ and save as EDF (not EDF+).
%
% It does not convert between formats.
%
%
% -------------------------------------------------------------------------
% INSTRUCTIONS ON HOW TO USE APPLY rCAR
%
% First. Establish which channel numbers to exclude, and which should be the
% derived re-reference (if necessary). Run 'List_channels.m' to list the
% channel numbers and names (i.e. labels) in a selected EEG file format.
%
% Second. Set the excluded channels numbers and derived re-reference channel 
% number (if necessary) in the Apply_rCAR.m script. The derrived re-reference 
% channel is the estimate of reference channel used during the on-line EEG
% recording (e.g. Cz for Sample data.cnt file). It might be the case that no 
% re-reference channel needs to be derrived. In that case put as 
% "re_reference_reference_channel_no" below a "0" (zero).
%
% You can select multiple files to process in a batch. For the above reason,
% be sure the channels selected for exclusion and re-reference channel are
% appropriate if processing different file types at once.
%
%--------------------------------------------------------------------------

clearvars
t0=clock;

%--------------------------------------------------------------------------
% CHANNEL EXCLUSION AND REFERENCE PARAMETERS
%
% NOTE: these numbers can be different for different input file types so
% be sure to use the convention used in the file type being processed.
%
% Pick the channel numbers to exclude. These channel(s) will not be part of
% rCAR procedure. Exclude the following channels:

exclude   = [32 ]; % VEOG channel for Sample data *.vhdr *.cdt *.edf

% exclude   = [17 20 21 31 32 ] % Cz, A1, A2, HEOG & VEOG for Sample data.cnt

% Channel number for the re-referenced and derivated on-line reference. If
% there is no need to compute a reference estimate, put a number 0 (zero).
% Derived re-reference channel:

re_reference_reference_channel_no = 0; % e.g. Sample data *.vhdr *.cdt *.edf

% re_reference_reference_channel_no = 17; % e.g. Cz for Sample data *.cnt

%--------------------------------------------------------------------------
% PARALLEL PROCESSING VARIABLES
%
% Pick the number of threads to use. This represents the number of cores
% of your processor. If you have a quad-core processor, then you can change
% the number below from 2 to 4. So you can run 4 parallel processes
% (i.e. 4 workers).
%
n_threads                      = 2;     % # of threads

%--------------------------------------------------------------------------
% PLOT OPTIONS
plotData = 0; 
%--------------------------------------------------------------------------


%==========================================================================
%--------------------------------------------------------------------------
% get the path of this script.
currentFile = mfilename( 'fullpath' );
[pathstr,~,~] = fileparts( currentFile );

[fn pn]=uigetfile({[pathstr '\*.vhdr;*.cnt;*.cdt;*.edf']}, 'Select Input Files', 'MultiSelect', 'on' );
output_folder = uigetdir(pathstr, 'Select a folder to save output');

if ~iscell(fn)
    totalFiles = 1;
    fn = {fn};
else
    totalFiles = size(fn,2);
end


% start a parallel pool
pool                                        = gcp( 'nocreate' );
pool                                        = parpool( n_threads );
    

% process each data file
for file_no=1:totalFiles
    
    % input file
    input_filename = char(fn(file_no));
    input_path_and_filename = [pn input_filename];
    [~,filename_only,input_file_extension] = fileparts( input_path_and_filename );
    
    % output file
    output_filename = [filename_only '_rCAR'];
    output_path_and_filename = [output_folder '\' output_filename];
    
    disp(sprintf('Processing file %d of %d. %s',file_no,totalFiles,input_filename));
    
    
    % load input file according to its extension
    switch input_file_extension

        case '.vhdr'
            EEG = pop_loadbv(pn, input_filename, 1);
            
            % get EEG data
            % IMPORTANT - need to make sure data are double precision.
            data = double(EEG.data);
            
            % get number of channels
            n_ch = EEG.nbchan;
            
            % get channel names
            for c=1:1:n_ch
                chs0{c} = char(EEG.chanlocs(c).labels);
            end
            chs = char(chs0);
            
        case '.cnt'
            EEG = pop_loadcnt([pn  input_filename]);
            
            % get EEG data
            % IMPORTANT - need to make sure data are double precision.
            data = double(EEG.data);
            
            % get number of channels
            n_ch = EEG.nbchan;
            
            % get channel names
            for c=1:1:n_ch
                chs0{c} = char(EEG.chanlocs(c).labels);
            end
            chs = char(chs0);
            
         case '.cdt'
            EEG = pop_loadcurry([pn input_filename]);
            
            % get EEG data
            % IMPORTANT - need to make sure data are double precision.
            data = double(EEG.data);
            
            origdata = EEG.data;
            % get number of channels
            n_ch = EEG.nbchan;
            
            % get channel names
            for c=1:1:n_ch
                chs0{c} = char(EEG.chanlocs(c).labels);
            end
            chs = char(chs0);
            
         case '.edf'
            [data,header] = lab_read_edf_no_events(input_path_and_filename);
            origdata = data;
            n_ch = header.numchannels;
            
            % get channel names
            for c=1:1:n_ch
                chs0{c} = char(header.channels(c,:));
            end
            chs = char(chs0);
    end
    
    
    % display channel numbers & names
    disp ('Channel numbers and names:')
    for c=1:1:size(chs,1)
        disp(sprintf('%d: %s',c,  chs(c,:)  ));
    end
    
    disp('Exclude the following channels:');
    exc=chs(exclude,:);
    for c=1:1:size(exclude,2)
        disp(sprintf('%d: %s',exclude(c),  exc(c,:)  ));
    end
    
    if ~(re_reference_reference_channel_no==0)
        disp('Derived re-reference channel:');
        disp(sprintf('%d: %s',re_reference_reference_channel_no,  chs(re_reference_reference_channel_no,:)  ));
    end
    
    % get number or samples per channel
    n = size(data,2);
    
    % select channel numbers (indices i_use) to enter into the analysis
    i_use     = setdiff( 1:n_ch, exclude );
    use_chs   = chs( setdiff( 1:n_ch, exclude ), :);
    n_use_chs = size( use_chs, 1 );
    
    data_mean                      = mean(data(i_use,:),2);
    [ n_channels n_samples ]       = size( data(i_use,:) );
    
    n_min_contributing_channels    = 8;
    dt                             = 1e-3;  % seconds
    
    [ d_rcar  ref_est_rcar nn_ref_est_rcar  ]   = rCAR( data(i_use,:), dt, n_min_contributing_channels, n_threads, pool );% select data with indices i_use to enter into the analysis

    %  d_rcar                                      = d_rcar + (ones(n,1)*data_mean' ); % original array format
    d_rcar                                      = d_rcar + ( data_mean*ones(1,n));
    
    
    % Plotting.
    if plotData    
        t=0:size(ref_est_rcar,2)-1;
        plotdata = data;
        t = t * dt + dt/2;
        figure;clf;
        plot( t, ref_est_rcar );
        title( 'Reference Estimate' );
        xlabel( 'Time (s)' );
        %       print( nm, '-dpsc2', '-append' ); close( 1 );
        
        shift         = 5*std( ref_est_rcar );
        for k0 = 1 : n_use_chs
            figure;clf;
            plot( t, data(k0,:) + shift, t, d_rcar(k0,:) - shift );
            title( [ {sprintf( 'Channel %s', use_chs(k0,:))}, {sprintf( 'original + %.1f (b), rcar re-referenced - %.1f (r)', shift, shift )} ] );
            xlabel( 'Time (s)' );
            %        print( nm, '-dpsc2', '-append' ); close( 1 );
        end
    end
    
    
    % create output data array with the same size as the input data
    output_data = zeros(size(data));
    
    % put data for rereferenced channels into the output array
    output_data(i_use,:) = d_rcar;
    
    % put data for excluded channels into the output array
    output_data(exclude,:) = data(exclude,:);
    
    % put data for the re-referenced online reference into the output array
    if ~(re_reference_reference_channel_no==0)
        output_data(re_reference_reference_channel_no, :) = ref_est_rcar;
    end
    
    
    % save output data
    disp(sprintf('Saving rereferenced data: %s',output_path_and_filename));
    
    switch input_file_extension
        
        case {'.vhdr','.cnt'}
            % replace original data with re-referenced data
            EEG.data = output_data;
            pop_writebva(EEG, output_path_and_filename);
            
        case {'.cdt'}
            % replace original data with re-referenced data
            EEG.data = output_data;
            
            % write EEG data array
            fid = fopen( [ output_path_and_filename '.cdt'  ], 'wb', 'ieee-le');
            fwrite(fid, EEG.data, 'float' );
            fclose(fid);
            
            % copy header files
            copyfile([pn input_filename '.cef'], [output_path_and_filename '.cdt.cef']);
            copyfile([pn input_filename '.dpa'], [output_path_and_filename '.cdt.dpa']);
                        
        case '.edf'
            % create header for output file
            header.channels = cellstr(header.channels);
            c = clock;
            header.year         = c(1);
            header.month        = c(2);
            header.day          = c(3);
            header.hour         = c(4);
            header.minute       = c(5);
            header.second       = c(6);
            
            %      EDF ANNOTATIONS: These fields are passed in a substruct of Header & will
            %      result in an EDF+ file, if given. This is also code from the original
            %      version and might not work properly.
            %       - events.POS: kx1 vector; Sample ids of event starts.
            %       - events.DUR: kx1 vector; Event durations in samples.
            %       - events.TYP: kx1 cellstr; Event names.
            
            if isfield(header,'events')% this is to avoid writing problematic markers in the output file
                header = rmfield(header,'events'); % which can create a distorsion of data as part of EDF file.
            end
            lab_write_edf(output_path_and_filename, output_data, header);
    end
end

% Shut down the parallel pool
delete( pool );
 
t1=clock;

Round_time_in_seconds = round(etime(t1,t0));
Processing_time_in_HH_MM_SS = datestr((Round_time_in_seconds/86400), 'HH:MM:SS')
