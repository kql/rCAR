%==========================================================================
%
% Apply rCAR is a user friendly MATLAB script/software that performs 
% re-referencing using the robust Common Average Reference (rCAR) procedure 
% put forward by Lepage, Kramer and Chu (2014) to EEG data in different 
% formats (i.e. Brainvision Analyzer, Neuroscan Curry, European Data Format 
% - EDF).
% 
% The Apply rCAR software is free but copyrighted software, distributed 
% under the terms of the GNU General Public Licence as published by the 
% Free Software Foundation (either version 3, or at your option any later 
% version). 
%
% We hope that our contribution is helpful to other researchers who wish to 
% apply rCAR to their data files. We would like to keep a record of rCAR 
% users. It would be nice if you could send us an email and mention in your 
% paper(s) if you have used rCAR re-reference procedure and software to 
% process your EEG data, thanks.
%
%==========================================================================
%
% Copyright (C) 2017    Version 0.6     Release date: 06 July 2017
%
% Authors: Dr Phil Duke, Dr Giorgio Fuggetta, and Dr Kyle Q. Lepage
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

