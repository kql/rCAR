%--------------------------------------------------------------------------
% Usage: This MATLAB's script performs re-referencing using the robust Common
% Average Reference (rCAR) procedure put forward by Lepage, Kramer and Chu
% (2014) to EEG data in different formats.
%--------------------------------------------------------------------------
%
% Copyright (C) 2017-8    Version 2.0.0     Release date: 13 August 2018
%
% Authors: Dr Phil Duke, Dr Giorgio Fuggetta, and Dr Kyle Q. Lepage
%
% Dr Phil A. Duke, University of Leicester, Leicester, UK 
% Email: pad11@leicester.ac.uk 
%
% Dr Giorgio Fuggetta, Roehampton University, London, UK
% Email: giorgio.fuggetta@roehampton.ac.uk
%
% Dr Kyle Q. Lepage
% Email: kyle.lepage@gmail.com
%
%
%--------------------------------------------------------------------------
% CONDITIONAL USE
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
% It is required that any publication including data re-referencing by Apply
% rCAR will properly cite the use of this MATLAB script in the Methods section
% and references as: Duke, P.A., Fuggetta, G., and Lepage K. Q. (2017). Apply 
% robust Common Average Reference - Apply rCAR. Available at: 
% http://www.github.com/kql/rCAR 
% or in a similar standard format for references as stated in most journal
% guidelines. Additional acknowledgments regarding free access to Apply rCAR 
% would be appreciated. Please make sure that any other person who might 
% publish findings stemming from the use of Apply rCAR, is aware of these 
% conditions.
%
%
%--------------------------------------------------------------------------
% PRE-REQUISITES BEFORE RUNNING APPLY rCAR
%
% This script uses Matlab's Parallel Computing Toolbox, so make sure that
% this toolbox is installed. Otherwise you will recieve the follwong message:
% Unable to checkout a license for the Parallel Computing Toolbox". 
%
% Apply rCAR uses functions from the software EEGLAB, so make sure you have
% installed EEGLAB (https://sccn.ucsd.edu/eeglab/index.php) and that both
% the Apply_rCAR code folder and the EEGLAB folder are set in MATLAB's search
% path.
%
% To import Brain Vision Analyser (BVA), Neuroscan continuous, Neuroscan
% Curry 6, 7 and 8 data files, and BioSemi files it is necessary to add data
% import extensions in EEGLAB. Thus from EEGLAB:
% 
% 1) go to File > Manage EEGLAB extensions > Data import extensions,
% 2) add the bva-io (Import Brain Vision Analyser data file) plugin, 
% 3) add the loadcurry (Import Neuroscan Curry 6, 7, 8 data files) plugin,
% 4) add the Biosig (BioSemi data files) plugin.
%
%
%--------------------------------------------------------------------------
% SUPPORTED INPUT FILES
%
% The script loads five possible EEG recording formats:
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
% 4) European Data Format : EDF and EDF+ (*.edf)
%
%
% 5) BioSemi format (*.bdf)
% 
% 
% 6) EEGLAB format (*.set)
%
%
%--------------------------------------------------------------------------
% SUPPORTED OUTPUT FILES
%
% The output files are currently in Brain Vision Analyser (BVA) exchange
% format (*.dat), Curry (*.cdt), Biosemi (*,bdf) or European Data Format (*.edf)
% without markers/annotations. Thus the script will load and save as follows:
%
% Load BVA and save as BVA
% Load Neuroscan .CNT and save as BVA
% Load Neuroscan Curry .CDT and save as Curry .CDT
% Load EDF or EDF+ and save as EDF (not EDF+).
% Load BioSemi .BDF and save as BioSemi.BDF
% Load EEGLAB .SET and save as EEGLAB .SET
%
% It does not convert between formats.
%
%
% -------------------------------------------------------------------------
% INSTRUCTIONS ON HOW TO USE APPLY rCAR
%
% After you have opened MATLAB which includes parallel processing toolbox
% and added to "set path" both EEGLAB and Apply rCAR folrers, run the 
% script "Apply_rCAR.m".
%
% First select a file to proceess. The application will display the channel
% labels present in the file.
%
% Select any channels to exclude and a derived re-reference channel (if
% necessary) from the channel list.
%
% You can save and load a default list of excluded chanels and re-refrence
% channel.
%
% The derived re-reference channel is the estimate of the reference channel
% used during the on-line EEG recording (i.e. usually Cz).
% It might be the case that no re-reference channel needs to be derived.
% In that case, select 'No re-reference channel'.
%
% Make sure that the excluded and re-reference channels are present in the 
% input file channel list. Note that labels can differ in case between file 
% types (e.g. 'CZ' vs. 'Cz') so be careful e.g. if using defaults. 
%
% You can select multiple files of the same type to process in a batch, but 
% only do this if you are sure that their channel labels are identical.
%--------------------------------------------------------------------------