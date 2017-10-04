function [varargout]=About_Apply_rCAR(varargin)

% HELPFIG   graphical display of help texts
%
%   helpfig opens a GUI for displaying text. The main purpose at creation
%   was to show a help text without the need to open MATLAB's browser
%   window, but its capabilities are not limited to this. 
%
%   helpfig(message) displays text stored in variable message, which has to
%   be a char array or a cellstring. If message consists of a single word
%   (string) and no further input arguments are provided, it will be
%   interpreted as file name and the help text for that file is shown
%   instead. Also figure title and size are adjusted accordingly.
%
%   helpfig(message,title) specify title of help window.
%
%   helpfig(message,title,chars,lines) specify number of characters per
%   line and number of lines (default: 75/25)
%
%   helpfig(message,title,'adjust') let helpfig calculate appriopriate
%   values for chars and lines, such that message fits well into the figure
%
%   handle=helpfig(...) returns the handle of the help figure.
%
%   Helpfig allow users to copy text to clipboard (either by pressing c, by
%   selecting a region with mouse or by selecting a complete word by
%   clickling on it - complete lines ares selected when the region before
%   that line is clicked). A simple feedback on what's going on at
%   selecting text is done via frame coloring. Helpfig also supports
%   scrolling via mouse, navigation via arrow, ... keys and can be closed
%   via esc.
%
%   See also dialog.
%

%   (c) Matthias Schwaiger, 2011
%       http://www.matzix.de

% $Revision: 29 $
% $Date: 2011-11-14 22:11:51 +0100 (Mo, 14. Nov 2011) $
% $Author: Matthias $

%% settings and input arguments processing
% default settings
title=mfilename;
maxlength=75; % chars per line
data.maxlines=25; % lines
data.charheight=16;
data.charwidth=8;

autoadjust=0;
aboutfig=0;

if nargin == 0 || (~iscellstr(varargin{1}) && ~ischar(varargin{1}))
    info=regexp('$Id: 1.0 03-10-2017 $','^.* (?<revision>[0.1-9.0]+) (?<date>[0-9\-]+) .*','names');
    helptxt={upper(mfilename),'',['Version: ' info.revision],'',['Release Date: ' info.date],'',[char(169) ' 2017 Dr Phil A. Duke, Dr Giorgio Fuggetta, Dr Kyle Q. Lepage ' ], '','http://www.github.com/kql/rCAR'};
    title='About Apply rCAR';
    autoadjust=1;
    aboutfig=1;
elseif nargin == 1 && ischar(varargin{1}) && ...
        any(size(varargin{1})==1) && ...
        ~isempty(regexp(varargin{1},'^[a-zA-z0-9_]+$','once')) && ...
        exist([varargin{1} '.m'],'file')
    helptxt=help(varargin{1});
    title=['Help on ' upper(varargin{1})];
    autoadjust=1;
    if strcmp(varargin{1},mfilename), aboutfig=1; end
else
    helptxt=varargin{1};
end
if ischar(helptxt) && any(size(helptxt)==1)
    helptxt=regexp(helptxt,'[\n\r]','split');
end
if ~iscellstr(helptxt)
    helptxt=cellstr(helptxt);
end
helptxt=regexprep(helptxt,'[\f\t\v]','');
helptxt=regexprep(helptxt,'[\n\r]+','');
helptxt=helptxt(:);

for k=2:nargin
    switch k
        case 2, if ischar(varargin{k}), title=varargin{k}; end
        case 3, if isnumeric(varargin{k}), maxlength=round(max(1,varargin{k}(1))); elseif ischar(varargin{k}) && strcmpi(varargin{k},'adjust'), autoadjust=1; end
        case 4, if isnumeric(varargin{k}), data.maxlines=round(max(1,varargin{k}(1))); end
    end
end

if autoadjust
    maxlength=max(cellfun(@length,helptxt));
    data.maxlines=length(helptxt);
end

scr=get(0,'ScreenSize');
maxlength=max(1,min(floor((scr(3)-70)/data.charwidth),maxlength));
data.maxlines=max(1,min(floor((scr(4)-100)/data.charheight),data.maxlines));
usescrollbar=1;
if sum(cellfun(@(x) ceil(length(x)/maxlength),helptxt)) <= data.maxlines
    usescrollbar=0;
end
width=38+maxlength*data.charwidth+usescrollbar*22;
height=30+data.maxlines*data.charheight;
data.curline=1;
data.mousepos=[0 0];

%% set up base figure
% close existing help figures
% hiddenstate=get(0,'ShowHiddenHandles');
% set(0,'ShowHiddenHandles','on');
% if ~isempty(findobj('tag','helpfig'))
%     close(findobj('tag','helpfig'))
% end
% set(0,'ShowHiddenHandles',hiddenstate);

fig=figure;
set(fig,'tag','helpfig','name',title,'NumberTitle','off', ...
    'menubar','none','resize','off', ...
    'position',round([(scr(3)-width)/2 (scr(4)-height)/2 width height]));
try set(fig,'DockControl','off'); catch; end %#ok<CTCH>
drawnow;

data.frame=uicontrol('style','frame', 'units','pixels', ...
    'position',[8 8 width-16 height-16], ...
    'enable','inactive');
data.ui(1)=uicontrol('style','text', 'units','pixels', ...
    'position',[16 16 width-32-usescrollbar*22 height-32], ...
    'backgroundcolor',get(data.frame,'backgroundcolor'), ...
    'horizontalalignment','left', ...
    'fontsize',10,'FontName', 'FixedWidth', ...
    'enable','inactive');
if usescrollbar
    data.ui(2)=uicontrol('style','slider', 'units','pixels', ...
        'position',[width-29 9 20 height-18]);
end

%% contents and callback setup
% reformat helptxt if necessary
k=1;
while k<=length(helptxt)
    if length(helptxt{k})>maxlength
        idx=strfind(helptxt{k}(1:maxlength),' ');
        if ~isempty(idx)
            idx=idx(end);
        else
            idx=maxlength;
        end
        helptxt=[helptxt(1:k-1); {helptxt{k}(1:idx)}; {helptxt{k}(idx+1:end)}; helptxt(k+1:end)];
    end
    k=k+1;
end
data.txt=helptxt;
data.maxline=max(1,length(helptxt)-data.maxlines+1);
% cellfun(@disp,helptxt);

% set up GUI contents and callback functions
set(data.ui(1),'string',helptxt(data.curline:min(data.curline+data.maxlines-1,length(helptxt))));
set(gcf,'keypressfcn',@helpfigtxtscroll);
set(data.frame,'keypressfcn',@helpfigtxtscroll);
set(data.ui(1),'keypressfcn',@helpfigtxtscroll);
if usescrollbar
    if length(helptxt) <= data.maxlines
        set(data.ui(2),'min',1,'max',2,'value',1,'enable','off');
    else
        set(data.ui(2),'min',1,'max',data.maxline, ...
            'sliderstep', min(1,[1 data.maxlines]/(data.maxline-1)), ...
            'value',data.maxline-data.curline+1, ...
            'callback',@helpfigtxtscroll);
    end
    set(data.ui(2),'keypressfcn',@helpfigtxtscroll);
end

try
    set(fig,'WindowButtonDownFcn',{@helpfigtxtscroll,'down'});
    set(fig,'WindowButtonUpFcn',{@helpfigtxtscroll,'up'});
    set(fig,'WindowScrollWheelFcn',@helpfigtxtscroll);
catch %#ok
end

if aboutfig && nargin == 0
    set(gcf,'tag','about_helpfig');
elseif aboutfig
    set(gcf,'tag','help_helpfig');
end
set(fig,'userdata',data,'HandleVisibility','off');


%% finish
if nargout ~=0
    varargout{1}=fig;
end

%%
function helpfigtxtscroll(src,evnt,varargin)

data=get(gcbf,'userdata');
if nargin == 3
    pos=get(data.ui(1),'position');
    pos=[pos(1) pos(2)+pos(4)];
    pos=ceil((get(gcbf,'CurrentPoint') - pos)./[data.charwidth -data.charheight]);
    pos(1)=max(0,min(max(cellfun(@length,data.txt)),pos(1)));
    pos(2)=max(1,min(min(data.maxlines,pos(2))+data.curline-1,data.maxline+data.maxlines-1));
    % get zero position
    if strcmp(varargin{1},'down')
        data.mousepos=pos;
        if pos(1)~=0
            set(data.frame,'backgroundcolor',[0.7 0.7 1]);
        else
            set(data.frame,'backgroundcolor',[0.3 0.3 1]);
        end
    elseif strcmp(varargin{1},'up')
        if all([pos(1) data.mousepos(1)]==0) % select complete lines
            pos(1)=max(cellfun(@length,data.txt));
        end
        if all(pos==data.mousepos)
            txt=[' ' data.txt{pos(2)} ' '];
            idx=strfind(txt,' ');
            txt=txt(max(idx(idx<=pos(1)+1))+1:min(idx(idx>=pos(1)+1))-1);
            if ~isempty(txt)
                set(data.frame,'backgroundcolor',[0.3 1 0.3]);
                drawnow
                pause(0.2);
            end
        else
            txt=char(data.txt);
            txt=txt(min(pos(2),data.mousepos(2)):max(pos(2),data.mousepos(2)),max(1,min(pos(1),data.mousepos(1))):max(pos(1),data.mousepos(1)));
            txt2='';
            for k=1:size(txt,1)
                txt2=[txt2 deblank(txt(k,:)) 10]; %#ok<AGROW>
            end
            txt=txt2(1:end-1);
        end
        try
        if ~isempty(txt)
            clipboard('copy',txt);
        else
            clipboard('copy',' ');
        end
        catch %#ok
            disp('clipboard is not available!');
        end
        data.mousepos=[0 0];
        set(data.frame,'backgroundcolor',get(data.ui(1),'backgroundcolor'));
        % disp(clipboard('paste'));
    end
    set(gcbf,'userdata',data);
    drawnow;
    return
elseif length(data.ui) >= 2 && src==data.ui(2)
    data.curline=round(data.maxline-get(data.ui(2),'value')+1);
elseif isfield(evnt,'Key')
    % disp(lower(evnt.Key)); % development
        switch lower(evnt.Key)
            case 'escape'
                delete(gcbf);
                return
            case 'a'
                if ~any(strcmp(get(gcbf,'tag'),{'about_helpfig','help_helpfig'}))
                    helpfig;
                end
            case 'f1'
                if ~strcmp(get(gcbf,'tag'),'help_helpfig')
                    helpfig('helpfig');
                end
            case 'c'
                if any(strcmp(evnt.Modifier,'control'))
                    txt='';
                    for k=1:length(data.txt)
                        txt=[txt deblank(data.txt{k}) 10]; %#ok<AGROW>
                    end
                    try
                        clipboard('copy',txt(1:end-1));
                    catch %#ok
                        disp('clipboard is not available!');
                    end
                end
            case 'home'
                data.curline=1;
            case 'end'
                data.curline=data.maxline;
            case {'leftarrow','pageup'}
                data.curline=max(1,data.curline-data.maxlines);
            case {'rightarrow','pagedown'}
                data.curline=min(data.maxline,data.curline+data.maxlines);
            case 'uparrow'
                data.curline=max(1,data.curline-1);
            case 'downarrow'
                data.curline=min(data.maxline,data.curline+1);
        end
elseif isfield(evnt,'VerticalScrollCount')
    data.curline=round(max(1,min(data.maxline,data.curline+evnt.VerticalScrollAmount*evnt.VerticalScrollCount)));
end
if length(data.ui) >= 2
    set(data.ui(2),'value',data.maxline-data.curline+1);
end
set(gcbf,'userdata',data);
set(data.ui(1),'string',data.txt(data.curline:min(data.curline+data.maxlines-1,length(data.txt))));
drawnow
