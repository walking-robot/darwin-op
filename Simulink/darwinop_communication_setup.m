function varargout = darwinop_communication_setup(varargin)

[varargout{1:nargout}] = feval(varargin{:});

end

function OpenFcn %#ok
% the block is double-clicked in simulink window

hBlk = gcbh;
% find existing figures, if any
f = FindFigure(hBlk);
if isempty(f)
    % figure does not exist yet, create a new one
    CreateFigure(hBlk);
else
    % this figure is already for this block, bring it to front,
    % eventually reflecting changes in block name
    SetFigureName(f);
    figure(f);
end

end

function DeleteFcn %#ok
% the block is deleted
hBlk = gcbh;
% find existing figures, if any
f = FindFigure(hBlk);
if ~isempty(f)
    close(f);
end

end

function NameChangeFcn %#ok
% the block name is changed

hBlk = gcbh;
% find existing figures, if any
f = FindFigure(hBlk);
if ~isempty(f)
    SetFigureName(f);
end

end

function StartFcn %#ok
% the simulation is started
end

function StopFcn %#ok
% the simulation is stopped
end

function CopyFcn %#ok
% the block is copied
% all data copies are automaticaly done
end

function ModelCloseFcn %#ok
% the model is closed

hBlk = gcbh;
% find existing figures, if any
f = FindFigure(hBlk);
if ~isempty(f)
    close(f);
end

end

function f = FindFigure(hBlk)

figures = findall(0,'Tag','darwinop_communication_setup');
for i = 1:length(figures)
    data = guidata(figures(i));
    if isfield(data,'simulink_block') && (data.simulink_block == hBlk)
        f = figures(i);
        return;
    end
end
f=[];

end

function CreateFigure(hBlk)

f = figure('MenuBar','none', ...
           'Toolbar','none', ...
           'Resize','off', ...
           'NumberTitle','off', ...
           'Units','pixels', ...
           'Position',[100,300,800,485], ...
           'Tag','darwinop_communication_setup');

data = guidata(f);

data.simulink_block = hBlk;

[data.mx28_fields,data.cm730_fields,data.ids] = get_constants;

data.read_text = uicontrol(f,'Style','text', ...
                             'String','Select items to read (ctrl+click for multiple):', ...
                             'HorizontalAlignment','left', ...
                             'Units','pixels', ...
                             'Position',[520,215,270,14]);
data.read_listbox = uicontrol(f,'Style','listbox', ...
                                ...'String',read_item_list, ...
                                ...'Max',length(read_item_list), ...
                                'BackgroundColor','white', ...
                                'Units','pixels', ...
                                'Position',[520,10,270,205]);

data.write_text = uicontrol(f,'Style','text', ...
                              'String','Select item to write (ctrl+click for multiple):', ...
                              'HorizontalAlignment','left', ...
                              'Units','pixels', ...
                              'Position',[520,435,270,14]);
data.write_listbox = uicontrol(f,'Style','listbox', ...
                                 ...'String',write_item_list, ...
                                 ...'Max',length(write_item_list), ...
                                 'BackgroundColor','white', ...
                                 'Units','pixels', ...
                                 'Position',[520,230,270,205]);

data.background_color = get(data.read_text,'BackgroundColor');
data.write_color = 'red';
data.read_color = 'green';
data.read_write_color = 'yellow';
data.selected_color = 'cyan';

set(f,'Color',data.background_color);

data.axes = axes('units','pixels', ...
                 'position',[10,10,483,424]);
data.image = imread('darwin.jpg');
imshow(data.image,'Parent',data.axes);

data.id_buttons = zeros(size(data.ids));
data.selected_read_fields = cell(size(data.ids));
data.selected_write_fields = cell(size(data.ids));

for i=1:length(data.ids)
    if data.ids{i}.address == 200
        data.selected_read_fields{i} = zeros(size(data.cm730_fields));
        data.selected_write_fields{i} = zeros(size(data.cm730_fields));
    else
        data.selected_read_fields{i} = zeros(size(data.mx28_fields));
        data.selected_write_fields{i} = zeros(size(data.mx28_fields));
    end
    data.id_buttons(i) = uicontrol(f,'Style','pushbutton', ...
                                     'String',data.ids{i}.address, ...
                                     'BackgroundColor',data.background_color, ...
                                     'Units','pixels', ...
                                     'Position',[data.ids{i}.posx+8,data.ids{i}.posy-10,20,20], ...
                                     'Callback',{@callback_button_id,i});
end

data.selected_button = uicontrol(f,'Style','pushbutton', ...
                                   'String','', ...
                                   'Enable','off', ...
                                   'BackgroundColor',data.selected_color, ...
                                   'Units','pixels', ...
                                   'Position',[20,60,20,20]);
data.selected_text = uicontrol(f,'Style','text', ...
                                 'String','selected joint', ...
                                 'HorizontalAlignment','left', ...
                                 'BackgroundColor','white', ...
                                 'Units','pixels', ...
                                 'Position',[50,63,80,14]);
data.read_write_button = uicontrol(f,'Style','pushbutton', ...
                                     'String','', ...
                                     'Enable','off', ...
                                     'BackgroundColor',data.read_write_color, ...
                                     'Units','pixels', ...
                                     'Position',[20,90,20,20]);
data.read_write_text = uicontrol(f,'Style','text', ...
                                   'String','read/write operation', ...
                                   'HorizontalAlignment','left', ...
                                   'BackgroundColor','white', ...
                                   'Units','pixels', ...
                                   'Position',[50,93,80,14]);
data.write_button = uicontrol(f,'Style','pushbutton', ...
                                'String','', ...
                                'Enable','off', ...
                                'BackgroundColor',data.write_color, ...
                                'Units','pixels', ...
                                'Position',[20,120,20,20]);
data.write_text = uicontrol(f,'Style','text', ...
                              'String','write operation', ...
                              'HorizontalAlignment','left', ...
                              'BackgroundColor','white', ...
                              'Units','pixels', ...
                              'Position',[50,123,80,14]);
data.read_button = uicontrol(f,'Style','pushbutton', ...
                               'String','', ...
                               'Enable','off', ...
                               'BackgroundColor',data.read_color, ...
                               'Units','pixels', ...
                               'Position',[20,150,20,20]);
data.read_text = uicontrol(f,'Style','text', ...
                             'String','read operation', ...
                             'HorizontalAlignment','left', ...
                             'BackgroundColor','white', ...
                             'Units','pixels', ...
                             'Position',[50,153,80,14]);
data.noop_button = uicontrol(f,'Style','pushbutton', ...
                               'String','', ...
                               'Enable','off', ...
                               'BackgroundColor',data.background_color, ...
                               'Units','pixels', ...
                               'Position',[20,180,20,20]);
data.noop_text = uicontrol(f,'Style','text', ...
                             'String','no operation', ...
                             'HorizontalAlignment','left', ...
                             'BackgroundColor','white', ...
                             'Units','pixels', ...
                             'Position',[50,183,80,14]);

data.ip_text = uicontrol(f,'Style','text', ...
                           'String','IP address:', ...
                           'HorizontalAlignment','left', ...
                           'Units','pixels', ...
                           'Position',[10,459,60,14]);
data.ip_edit = uicontrol(f,'Style','edit', ...
                           'BackgroundColor','white', ...
                           'HorizontalAlignment','left', ...
                           'Units','pixels', ...
                           'Position',[70,455,100,22]);

data.port_text = uicontrol(f,'Style','text', ...
                             'String','Port:', ...
                             'HorizontalAlignment','left', ...
                             'Units','pixels', ...
                             'Position',[190,459,30,14]);
data.port_edit = uicontrol(f,'Style','edit', ...
                             'BackgroundColor','white', ...
                             'HorizontalAlignment','left', ...
                             'Units','pixels', ...
                             'Position',[220,455,40,22]);

data.protocol_text = uicontrol(f,'Style','text', ...
                                 'String','Protocol:', ...
                                 'HorizontalAlignment','left', ...
                                 'Units','pixels', ...
                                 'Position',[280,459,50,14]);
data.protocol_popup = uicontrol(f,'Style','popupmenu', ...
                                  'String',{'tcp','udp'}, ...
                                  'BackgroundColor','white', ...
                                  'HorizontalAlignment','left', ...
                                  'Units','pixels', ...
                                  'Position',[330,463,50,14]);

data.timeout_text = uicontrol(f,'Style','text', ...
                                'String','Timeout (s):', ...
                                'HorizontalAlignment','left', ...
                                'Units','pixels', ...
                                'Position',[390,459,60,14]);
data.timeout_edit = uicontrol(f,'Style','edit', ...
                                'BackgroundColor','white', ...
                                'HorizontalAlignment','left', ...
                                'Units','pixels', ...
                                'Position',[450,455,40,22]);

data.advanced_checkbox = uicontrol(f,'Style','checkbox', ...
                                     'String','Advanced configuration', ...
                                     'Value',0, ...
                                     'Units','pixels', ...
                                     'Position',[520,459,160,14], ...
                                     'Callback',@callback_checkbox_advanced);

data.close_button = uicontrol(f,'Style','pushbutton', ...
                                'String','Save and close', ...
                                'Units','pixels', ...
                                'Position',[692,455,100,25], ...
                                'Callback',@callback_save_and_close);

guidata(f,data);

LoadFigure(f);

callback_button_id(data.id_buttons(1),[],1);

SetFigureName(f);

end

function LoadFigure(f)

data = guidata(f);
hBlk = data.simulink_block;

values = get_param(hBlk,'MaskValues');
% see mask properties
% values{1} = IP
% values{2} = Port
% values{3} = Protocol
% values{4} = Timeout
% values{5} = Frame
% values{6} = ReadIndex
% values{7} = WriteIndex

if isempty(values{1})
    values{1} = '192.168.123.1';
end
if isempty(values{2})
    values{2} = '1234';
end
if isempty(values{3})
    values{3} = 'tcp';
end
if isempty(values{4})
    values{4} = '0.5';
end

set(data.ip_edit,'String',values{1});
set(data.port_edit,'String',values{2});
if strcmp(values{3},'tcp')
    set(data.protocol_popup,'Value',1);
else
    set(data.protocol_popup,'Value',2);
end
set(data.timeout_edit,'String',values{4});

block_user_data = get_param(hBlk,'UserData');
if ~isempty(block_user_data)
    data.selected_read_fields = block_user_data.selected_read_fields;
    data.selected_write_fields = block_user_data.selected_write_fields;
end

for i = 1:length(data.id_buttons)
    read_value = find(data.selected_read_fields{i},1);
    write_value = find(data.selected_write_fields{i},1);
    if isempty(read_value)
        if isempty(write_value)
            set(data.id_buttons(i),'BackgroundColor',data.background_color);
        else
            set(data.id_buttons(i),'BackgroundColor',data.write_color);
        end
    else
        if isempty(write_value)
            set(data.id_buttons(i),'BackgroundColor',data.read_color);
        else
            set(data.id_buttons(i),'BackgroundColor',data.read_write_color);
        end
    end
end

guidata(f,data);

end

function SaveFigure(f)

callback_button_id(0,[],1);
callback_button_id(0,[],2);

data = guidata(f);
hBlk = data.simulink_block;
hModel = bdroot(hBlk);
if strcmp(get_param(hModel,'lock'),'on') == 0
    % flush current changes

    protocols = get(data.protocol_popup,'String');
    value_ip = get(data.ip_edit,'String');
    value_port = get(data.port_edit,'String');
    value_protocol = protocols{get(data.protocol_popup,'Value')};
    value_timeout = get(data.timeout_edit,'String');

    value_frame = '[ ';
    value_write_index = '[ ';
    value_read_index = '[ ';

    input_index = 1;
    output_index = 1;
    read_position = 1;
    write_position = 1;

    read_mask_display = {''};
    write_mask_display = {''};

    for i = 1:length(data.ids)
        if data.ids{i}.address == 200
            fields = data.cm730_fields;
        else
            fields = data.mx28_fields;
        end
        selected_read_fields = data.selected_read_fields{i};
        read_fields = zeros(size(selected_read_fields));
        for j = 1:length(selected_read_fields)
            field = fields{j};
            if selected_read_fields(j)
                read_fields(field.address+1:field.address+field.size) = ones(1,field.size);
                read_mask_display = [read_mask_display; ...
                                     'port_label(''output'',', ...
                                     num2str(output_index), ...
                                     ',''', ...
                                     data.ids{i}.name, ...
                                     '(', ...
                                     num2str(data.ids{i}.address), ...
                                     ')/', ...
                                     field.name, ...
                                     ''')' ...
                                    ]; %#ok
                output_index = output_index + 1;
            end
        end
        selected_write_fields = data.selected_write_fields{i};
        write_fields = zeros(size(selected_write_fields));
        for j = 1:length(selected_write_fields)
            field = fields{j};
            if selected_write_fields(j)
                write_fields(field.address+1:field.address+field.size) = ones(1,field.size);
                write_mask_display = [write_mask_display; ...
                                      'port_label(''input'',', ...
                                      num2str(input_index), ...
                                      ',''', ...
                                      data.ids{i}.name, ...
                                      '(', ...
                                      num2str(data.ids{i}.address), ...
                                      ')/', ...
                                      fields{j}.name, ...
                                      ''')' ...
                  ]; %#ok
                input_index = input_index + 1;
            end
        end
        
        read_ranges = get_ranges(read_fields) - 1;
        for j = 1:size(read_ranges,1)
            value_frame = [value_frame, ...
                           '2 ', ...
                           num2str(data.ids{i}.address),' ', ...
                           num2str(read_ranges(j,1)),' ', ...
                           num2str(read_ranges(j,2)-read_ranges(j,1)+1),' ' ...
                          ]; %#ok
            write_position = write_position + 4;
            for k = 1:length(selected_read_fields)
                field = fields{k};
                if (selected_read_fields(k) == 1) && (field.address >= read_ranges(j,1)) && ((field.address+field.size-1) <= read_ranges(j,2))
                    value_read_index = [value_read_index, ...
                                        num2str(read_position + field.address - read_ranges(j,1)),' ', ...
                                        num2str(field.size),';' ...
                                       ]; %#ok
                end
            end
            read_position = read_position + (read_ranges(j,2) - read_ranges(j,1) + 1);
        end
        
        write_ranges = get_ranges(write_fields) - 1;
        for j = 1:size(write_ranges,1)
            value_frame = [value_frame, ...
                           '3 ', ...
                           num2str(data.ids{i}.address),' ', ...
                           num2str(write_ranges(j,1)),' ', ...
                           num2str(write_ranges(j,2)-write_ranges(j,1)+1),' ' ...
                          ]; %#ok
            write_position = write_position + 4;
            for k = 1:length(selected_write_fields)
                field = fields{k};
                if (selected_write_fields(k) == 1) && (field.address >= write_ranges(j,1)) && ((field.address+field.size-1) <= write_ranges(j,2))
                    value_write_index = [value_write_index, ...
                                         num2str(write_position + field.address - write_ranges(j,1)),' ', ...
                                         num2str(field.size),';' ...
                                        ]; %#ok
                end
            end
            for k = write_ranges(j,1):write_ranges(j,2)
                value_frame = [value_frame,'0 ']; %#ok
            end
            write_position = write_position + (write_ranges(j,1) - write_ranges(j,2) + 1);
        end
    end
    value_frame(end) = ']';
    value_write_index(end) = ']';
    value_read_index(end) = ']';

    % see mask properties
    % values{1} = IP
    % values{2} = Port
    % values{3} = Protocol
    % values{4} = Timeout
    % values{5} = Frame
    % values{6} = ReadIndex
    % values{7} = WriteIndex
    values = {
        value_ip, ...
        value_port, ...
        value_protocol, ...
        value_timeout, ...
        value_frame, ...
        value_read_index, ...
        value_write_index ...
      };

    set_param(hBlk,'MaskValues',values);

    mask_display = [{'image(''darwin-blk.jpg'')'}; read_mask_display; write_mask_display];
    set_param(hBlk,'MaskDisplay',char(mask_display));

    block_user_data.selected_read_fields = data.selected_read_fields;
    block_user_data.selected_write_fields = data.selected_write_fields;
    set_param(hBlk,'UserData',block_user_data);
    set_param(hBlk,'UserDataPersistent', 'on');
end

end

function SetFigureName(f)

data = guidata(f);
set(f,'Name',sprintf('Darwin-OP communication setup (%s)', getfullname(data.simulink_block)));

end

function [mx28_fields,cm730_fields,ids] = get_constants
mx28_fields = {
    field(0,2,'Model Number','Model number','AR'), ...
    field(0,1,'Model Number (L)','Lowest byte of model number','AR'), ...
    field(1,1,'Model Number (H)','Highest byte of model number','AR'), ...
    field(2,1,'Version of Firmware','Information on the version of firmware','AR'), ...
    field(3,1,'ID','ID of Dynamixel','ARW'), ...
    field(4,1,'Baud Rate','Baud Rate of Dynamixel','ARW'), ...
    field(5,1,'Return Delay Time','Return Delay Time','ARW'), ...
    field(6,2,'CW Angle Limit','Clockwise Angle Limit','RW'), ...
    field(6,1,'CW Angle Limit (L)','Lowest byte of clockwise Angle Limit','ARW'), ...
    field(7,1,'CW Angle Limit (H)','Highest byte of clockwise Angle Limit','ARW'), ...
    field(8,2,'CCW Angle Limit','Counterclockwise Angle Limit','RW'), ...
    field(8,1,'CCW Angle Limit (L)','Lowest byte of counterclockwise Angle Limit','ARW'), ...
    field(9,1,'CCW Angle Limit (H)','Highest byte of counterclockwise Angle Limit','ARW'), ...
    field(11,1,'the Highest Limit Temperature','Internal Limit Temperature','ARW'), ...
    field(12,1,'the Lowest Limit Voltage','Lowest Limit Voltage','ARW'), ...
    field(13,1,'the Highest Limit Voltage','Highest Limit Voltage','ARW'), ...
    field(14,2,'Max Torque','Max. Torque','ARW'), ...
    field(14,1,'Max Torque (L)','Lowest byte of Max. Torque','ARW'), ...
    field(15,1,'Max Torque (H)','Highest byte of Max. Torque','ARW'), ...
    field(16,1,'Status Return Level','Status Return Level','ARW'), ...
    field(17,1,'Alarm LED','LED for Alarm','ARW'), ...
    field(18,1,'Alarm Shutdown','Shutdown for Alarm','ARW'), ...
    field(24,1,'Torque Enable','Torque On/Off','RW'), ...
    field(25,1,'LED','LED On/Off','RW'), ...
    field(26,1,'D Gain','Derivative Gain','RW'), ...
    field(27,1,'I Gain','Integral Gain','RW'), ...
    field(28,1,'P Gain','Proportional Gain','RW'), ...
    field(30,2,'Goal Position','Goal Position','RW'), ...
    field(30,1,'Goal Position (L)','Lowest byte of Goal Position','ARW'), ...
    field(31,1,'Goal Position (H)','Highest byte of Goal Position','ARW'), ...
    field(32,2,'Moving Speed','Moving Speed','RW'), ...
    field(32,1,'Moving Speed (L)','Lowest byte of Moving Speed','ARW'), ...
    field(33,1,'Moving Speed (H)','Highest byte of Moving Speed','ARW'), ...
    field(34,2,'Torque Limit','Torque Limit','RW'), ...
    field(34,1,'Torque Limit (L)','Lowest byte of Torque Limit','ARW'), ...
    field(35,1,'Torque Limit (H)','Highest byte of Torque Limit','ARW'), ...
    field(36,2,'Present Position','Current Position','R'), ...
    field(36,1,'Present Position (L)','Lowest byte of Current Position','AR'), ...
    field(37,1,'Present Position (H)','Highest byte of Current Position','AR'), ...
    field(38,2,'Present Speed','Current Speed','R'), ...
    field(38,1,'Present Speed (L)','Lowest byte of Current Speed','AR'), ...
    field(39,1,'Present Speed (H)','Highest byte of Current Speed','AR'), ...
    field(40,2,'Present Load','Current Load','R'), ...
    field(40,1,'Present Load (L)','Lowest byte of Current Load','AR'), ...
    field(41,1,'Present Load (H)','Highest byte of Current Load','AR'), ...
    field(42,1,'Present Voltage','Current Voltage','AR'), ...
    field(43,1,'Present Temperature','Current Temperature','AR'), ...
    field(44,1,'Registered','Means if Instruction is registered','AR'), ...
    field(46,1,'Moving','Means if there is any movement','AR'), ...
    field(47,1,'Lock','Locking EEPROM','ARW'), ...
    field(48,2,'Punch','Punch','ARW'), ...
    field(48,1,'Punch (L)','Lowest byte of Punch','ARW'), ...
    field(49,1,'Punch (H)','Highest byte of Punch','ARW')
  };

cm730_fields = {
    field(0,2,'Model Number','model number','AR'), ...
    field(0,1,'Model Number (L)','model number low byte','AR'), ...
    field(1,1,'Model Number (H)','model number high byte','AR'), ...
    field(2,1,'Version of Firmware','firmware version','AR'), ...
    field(3,1,'ID','Dynamixel ID','ARW'), ...
    field(4,1,'Baud Rate','Dynamixel baud rate','ARW'), ...
    field(5,1,'Return Delay Time','Return Delay Time','ARW'), ...
    field(16,1,'Status Return Level','Status Return Level','ARW'), ...
    field(24,1,'Dynamixel Power','Dynamixel On/Off','ARW'), ...
    field(25,1,'LED Pannel','LED Pannel On/Off','RW'), ...
    field(26,2,'LED Head','LED Head','RW'), ...
    field(26,1,'LED Head (L)','LED Head low byte','ARW'), ...
    field(27,1,'LED Head (H)','LED Head high byte','ARW'), ...
    field(28,2,'LED Eye','LED Eye','RW'), ...
    field(28,1,'LED Eye (L)','LED Eye low byte','ARW'), ...
    field(29,1,'LED Eye (H)','LED Eye high byte','ARW'), ...
    field(30,1,'Button','Button status','R'), ...
    field(38,2,'Gyro Z','Gyroscope Z-axis','R'), ...
    field(38,1,'Gyro Z (L)','Gyroscope Z-axis low byte','AR'), ...
    field(39,1,'Gyro Z (H)','Gyroscope Z-axis high byte','AR'), ...
    field(40,2,'Gyro Y','Gyroscope Y-axis','R'), ...
    field(40,1,'Gyro Y (L)','Gyroscope Y-axis low byte','AR'), ...
    field(41,1,'Gyro Y (H)','Gyroscope Y-axis high byte','AR'), ...
    field(42,2,'Gyro X','Gyroscope X-axis','R'), ...
    field(42,1,'Gyro X (L)','Gyroscope X-axis low byte','AR'), ...
    field(43,1,'Gyro X (H)','Gyroscope X-axis high byte','AR'), ...
    field(44,2,'ACC X','Accelerometer X-axis','R'), ...
    field(44,1,'ACC X (L)','Accelerometer X-axis low byte','AR'), ...
    field(45,1,'ACC X (H)','Accelerometer X-axis high byte','AR'), ...
    field(46,2,'ACC Y','Accelerometer Y-axis','R'), ...
    field(46,1,'ACC Y (L)','Accelerometer Y-axis low byte','AR'), ...
    field(47,1,'ACC Y (H)','Accelerometer Y-axis high byte','AR'), ...
    field(48,2,'ACC Z','Accelerometer Z-axis','R'), ...
    field(48,1,'ACC Z (L)','Accelerometer Z-axis low byte','AR'), ...
    field(49,1,'ACC Z (H)','Accelerometer Z-axis high byte','AR'), ...
    field(50,1,'Present Voltage','Current Voltage','AR'), ...
    field(51,2,'MIC Left','Mic Left low byte','R'), ...
    field(51,1,'MIC Left (L)','Mic Left low byte','AR'), ...
    field(52,1,'MIC Left (H)','Mic Left high byte','AR'), ...
    field(53,2,'ADC 2','ADC channel 2','AR'), ...
    field(53,1,'ADC 2 (L)','ADC channel 2 low byte','AR'), ...
    field(54,1,'ADC 2 (H)','ADC channel 2 high byte','AR'), ...
    field(55,2,'ADC 3','ADC channel 3','AR'), ...
    field(55,1,'ADC 3 (L)','ADC channel 3 low byte','AR'), ...
    field(56,1,'ADC 3 (H)','ADC channel 3 high byte','AR'), ...
    field(57,2,'ADC 4','ADC channel 4','AR'), ...
    field(57,1,'ADC 4 (L)','ADC channel 4 low byte','AR'), ...
    field(58,1,'ADC 4 (H)','ADC channel 4 high byte','AR'), ...
    field(59,2,'ADC 5','ADC channel 5','AR'), ...
    field(59,1,'ADC 5 (L)','ADC channel 5 low byte','AR'), ...
    field(60,1,'ADC 5 (H)','ADC channel 5 high byte','AR'), ...
    field(61,2,'ADC 6','ADC channel 6','AR'), ...
    field(61,1,'ADC 6 (L)','ADC channel 6 low byte','AR'), ...
    field(62,1,'ADC 6 (H)','ADC channel 6 high byte','AR'), ...
    field(63,2,'ADC 7','ADC channel 7','AR'), ...
    field(63,1,'ADC 7 (L)','ADC channel 7 low byte','AR'), ...
    field(64,1,'ADC 7 (H)','ADC channel 7 high byte','AR'), ...
    field(65,2,'ADC 8','ADC channel 8','AR'), ...
    field(65,1,'ADC 8 (L)','ADC channel 8 low byte','AR'), ...
    field(66,1,'ADC 8 (H)','ADC channel 8 high byte','AR'), ...
    field(67,2,'MIC Right','Mic Right','R'), ...
    field(67,1,'MIC Right (L)','Mic Right low byte','AR'), ...
    field(68,1,'MIC Right (H)','Mic Right high byte','AR'), ...
    field(69,2,'ADC 10','ADC channel 10','AR'), ...
    field(69,1,'ADC 10 (L)','ADC channel 10 low byte','AR'), ...
    field(70,1,'ADC 10 (H)','ADC channel 10 high byte','AR'), ...
    field(71,2,'ADC 11','ADC channel 11','AR'), ...
    field(71,1,'ADC 11 (L)','ADC channel 11 low byte','AR'), ...
    field(72,1,'ADC 11 (H)','ADC channel 11 high byte','AR'), ...
    field(73,2,'ADC 12','ADC channel 12','AR'), ...
    field(73,1,'ADC 12 (L)','ADC channel 12 low byte','AR'), ...
    field(74,1,'ADC 12 (H)','ADC channel 12 high byte','AR'), ...
    field(75,2,'ADC 13','ADC channel 13','AR'), ...
    field(75,1,'ADC 13 (L)','ADC channel 13 low byte','AR'), ...
    field(76,1,'ADC 13 (H)','ADC channel 13 high byte','AR'), ...
    field(77,2,'ADC 14','ADC channel 14','AR'), ...
    field(77,1,'ADC 14 (L)','ADC channel 14 low byte','AR'), ...
    field(78,1,'ADC 14 (H)','ADC channel 14 high byte','AR'), ...
    field(79,2,'ADC 15','ADC channel 15','AR'), ...
    field(79,1,'ADC 15 (L)','ADC channel 15 low byte','AR'), ...
    field(80,1,'ADC 15 (H)','ADC channel 15 high byte','AR')
  };

ids = {
    id('Right Shoulder Pitch',1,200,315), ...
    id('Left Shoulder Pitch',2,270,315), ...
    id('Right Shoulder Roll',3,140,295), ...
    id('Left Shoulder Roll',4,325,295), ...
    id('Right Elbow',5,108,297), ...
    id('Left Elbow',6,360,297), ...
    id('Right Hip Yaw',7,200,250), ...
    id('Left Hip Yaw',8,270,250), ...
    id('Right Hip Roll',9,145,185), ...
    id('Left Hip Roll',10,325,185), ...
    id('Right Hip Pitch',11,200,185), ...
    id('Left Hip Pitch',12,265,185), ...
    id('Right Knee',13,200,125), ...
    id('Left Knee',14,265,125), ...
    id('Right Ankle Pitch',15,200,60), ...
    id('Left Ankle Pitch',16,265,60), ...
    id('Right Ankle Roll',17,140,50), ...
    id('Left Ankle Roll',18,330,50), ...
    id('Head Pan',19,235,310), ...
    id('Head Tilt',20,235,355), ...
    id('Sub controller',200,235,265) ...
  };
end

function s = field(address, size, name, description, mode)
s = struct('address', address, ...
           'size', size, ...
           'name', name, ...
           'description', description, ...
           'mode', mode);
end

function i = id(name,address,posx,posy)
i = struct('address', address, ...
           'name', name, ...
           'posx', posx, ...
           'posy', posy);
end

function r = get_ranges(l)

last_id = 0;
j = 1;
r = [];
for i = 1:length(l)
    if l(i) == 1
        if last_id == 0
            last_id = i;
        end
    elseif last_id ~= 0
        r(j,:) = [last_id,i-1]; %#ok
        last_id = 0;
        j = j + 1;
    end
end

end

function [read_field_list,read_item_list,write_field_list,write_item_list] = filter_fields(fields,advanced)
    prec_address = -2;
    read_item_list = cell(0);
    read_field_list = cell(0);
    write_item_list = cell(0);
    write_field_list = cell(0);
    read_index = 1;
    write_index = 1;
    for field_index = 1:length(fields)
        field = fields{field_index};
        if (advanced) || isempty(find(field.mode == 'A',1))
            read = ~isempty(find(field.mode == 'R',1));
            write = ~isempty(find(field.mode == 'W',1));
            if (prec_address == field.address) || (prec_address == field.address - 1)
                description = ['  ' field.description];
            else
                description = field.description;
                if field.size == 2
                    prec_address = field.address;
                else
                    prec_address = -2;
                end
            end
            if read
                read_field_list{read_index} = field_index;
                read_item_list{read_index} = description;
                read_index = read_index + 1;
            end
            if write
                write_field_list{write_index} = field_index;
                write_item_list{write_index} = description;
                write_index = write_index + 1;
            end
        end
    end
end

function refresh_listbox
    data = guidata(gcf);
    if isfield(data,'old_index') && (data.old_index ~= data.current_index)
        read_value = get(data.read_listbox,'Value');
        selected_read_fields = zeros(size(data.selected_read_fields{data.old_index}));
        for i = read_value
            selected_read_fields(data.read_field_list{i}) = 1;
        end
        data.selected_read_fields{data.old_index} = selected_read_fields;

        write_value = get(data.write_listbox,'Value');
        selected_write_fields = zeros(size(data.selected_write_fields{data.old_index}));
        for i = write_value
            selected_write_fields(data.write_field_list{i}) = 1;
        end
        data.selected_write_fields{data.old_index} = selected_write_fields;

        if isempty(read_value)
            if isempty(write_value)
                set(data.id_buttons(data.old_index),'BackgroundColor',data.background_color);
            else
                set(data.id_buttons(data.old_index),'BackgroundColor',data.write_color);
            end
        else
            if isempty(write_value)
                set(data.id_buttons(data.old_index),'BackgroundColor',data.read_color);
            else
                set(data.id_buttons(data.old_index),'BackgroundColor',data.read_write_color);
            end
        end
    end
    
    if data.ids{data.current_index}.address == 200
        fields = data.cm730_fields;
    else
        fields = data.mx28_fields;
    end
    advanced = get(data.advanced_checkbox, 'Value');
    [data.read_field_list,read_item_list,data.write_field_list,write_item_list] = filter_fields(fields,advanced);

    read_value = zeros(size(data.read_field_list));
    selected_read_field = data.selected_read_fields{data.current_index};
    for i = 1:length(data.read_field_list)
        if selected_read_field(data.read_field_list{i}) == 1
            read_value(i) = 1;
        end
    end
    set(data.read_listbox,'String',read_item_list, ...
                          'Max',length(read_item_list), ...
                          'Value',find(read_value));
    write_value = zeros(size(data.write_field_list));
    selected_write_field = data.selected_write_fields{data.current_index};
    for i = 1:length(data.write_field_list)
        if selected_write_field(data.write_field_list{i}) == 1
            write_value(i) = 1;
        end
    end
    set(data.write_listbox,'String',write_item_list, ...
                           'Max',length(write_item_list), ...
                           'Value',find(write_value));
    set(data.id_buttons(data.current_index),'BackgroundColor',data.selected_color);
    data.old_index = data.current_index;
    
    guidata(gcf,data);
end

function callback_button_id(hObj, eventdata, index) %#ok

    data = guidata(gcf);
    data.current_index = index;
    guidata(gcf,data);
    refresh_listbox;

end

function callback_checkbox_advanced(hObj, eventdata) %#ok

    refresh_listbox;

end

function callback_save_and_close(hObj, eventdata) %#ok

    f = gcf;
    SaveFigure(f);
    close(f);

end