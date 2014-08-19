classdef data_source < handle
    %DATA_SOURCE - Container for data and views shown in a data_view
    %
    % SYNTAX:
    %   myObject = data_source( data , 'name')
    %
    % Description:
    %
    % PROPERTIES:
    %   data - the data from workspace
    %   name - name of data from workspace
    %   views - cell array of views that can be applied to the data
    %
    % METHODS:
    %   add_view - 
    %
    % EXAMPLES:
    %
    % SEE ALSO: data_view
    %
    % Author:       nick roth
    % email:        nick.roth@nou-systems.com
    % Matlab ver.:  8.3.0.532 (R2014a)
    % Date:         07-Aug-2014
    % Update:
    
    %% Properties
    properties
        data                % Required property of data_source
        name
        views = {}
    end
    
    %% Methods
    methods
        % DATA_SOURCE Constructor
        function obj = data_source(data, name, varargin)
            % Setup input parsing
            p = inputParser;
            p.FunctionName = 'data_source';
            p.addRequired('data');
            p.addRequired('name');
            p.parse(data, name, varargin{:});
            
            % Add inputs to object properties
            obj.data = p.Results.data;
            obj.name = p.Results.name;
        end

    end

end
