%==========================================================================
% Usage: List_channels.m script loads an EEG file in four possible formats 
% (Brain Vision Analyzer *.eeg; Neuroscan *.cnt; Neuroscan Curry *.cdt; 
% *.EDF/EDF+) and lists the channel numbers and names. This infomration 
% is necessary to set the excluded channel(s) numbers and derived 
% re-reference channel number (if necessary) in the Apply_rCAR.m script
% to performs re-referencing using the robust Common Average Reference 
% (rCAR) procedure put forward by Lepage, Kramer and Chu (2014) to EEG data.
%==========================================================================
%
% Copyright (C) 2017    Version 0.2     Release date: 06 July 2017
%
% Authors: Dr Phil Duke and Dr Giorgio Fuggetta
%
% Dr Phil Duke, University of Leicester, Leicester, UK
% Email: pad11@leicester.ac.uk
%
% Dr Giorgio Fuggetta, Roehampton University, London, UK
% Email: giorgio.fuggetta@roehampton.ac.uk
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
%--------------------------------------------------------------------------
% PRE-REQUISITES BEFORE RUNNING LIST CHANNELS
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
%--------------------------------------------------------------------------

clearvars

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% get the path of this script.
currentFile = mfilename( 'fullpath' );
[pathstr,~,~] = fileparts( currentFile );


[fn pn]=uigetfile({[pathstr '\*.vhdr;*.cnt;*.cdt;*.edf']}, 'Select Input EEG recording File to list the channel numbers', 'MultiSelect', 'off' );

    
    % input file
    input_filename = char(fn);
    input_path_and_filename = [pn input_filename];
    [~,filename_only,input_file_extension] = fileparts( input_path_and_filename );
    
    % load input file according to its extension
    switch input_file_extension
        case '.vhdr'
            EEG = pop_loadbv(pn, input_filename, 1);
            
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
            
            
        case '.cnt'
            EEG = pop_loadcnt([pn  input_filename]);
            
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
    disp (fn)
    disp ('Channel numbers and names:')
    for c=1:1:size(chs,1)
        disp(sprintf('%d: %s',c,  chs(c,:)  ));
    end
   