%{
	Environment class
	
		The environment object defines an instance of the
		path planning problem for a disc robot.
		It needs these data (i.e., properties):
		 
				-- radius of robot
				-- epsilon
				-- bounding box for obstacles
				-- start and goal config of robot
				-- obstacle set (set of polygons)
	
		An environment file (e.g., env0.txt) is a line-based text file
		containing the above information, in THIS STRICT ORDER.
		Comment character (%) indicates that the rest of a line
		are ignored.
	
		Methods:
			env.readFile( fname )
			env.showEnv( fname )
			env.test( fname )
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	Intro to Robotics, Spring 2017
	%	Chee Yap (with help of TAs Naman and Rohit)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef Environment < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        radius;
        epsilon;
        BoundingBox = [];		% a mapshape (in CW order)
        start = [];		% point = array of size 2
        goal = [];		% point = array of size 2
        polygons = [];		% array of mapshapes (in CCW order)
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Environment(fname)
            if nargin<1
                fname = 'env0.txt';
            end
            % obj = obj@handle(); % call base class
            
            oo = Environment.readFile(fname);
            disp(num2str(oo.epsilon));
            % copy:
            obj.epsilon = oo.epsilon;
            obj.radius = oo.radius;
            obj.BoundingBox = oo.BoundingBox;
            obj.start = oo.start;
            obj.goal = oo.goal;
            obj.polygons = oo.polygons;
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Robot at conf(a,b) with color c
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showDisc(obj,a,b,c)
            t = linspace(0, 2*pi);
            x = obj.radius*cos(t);
            y = obj.radius*sin(t);
            patch(x+a, y+b, c);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SHOW PATH
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showPath(obj,path)
            disp('animating')
            for i = 1:length(path)
                obj.showDisc(path(i).x, path(i).y, [0.5 0.5 0.5]);
                drawnow
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Bounding Box
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showBoundingBox(obj)
            pX = min(obj.BoundingBox.X);
            pY = min(obj.BoundingBox.Y);
            width = max(obj.BoundingBox.X) - pX;
            height = max(obj.BoundingBox.Y) - pY;
            param = [pX pY width height];
            rectangle('Position', param, 'EdgeColor', 'b', 'LineWidth', 3);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Output Image to file
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function outputFile(obj, fname)
            if nargin<2
                fname = 'image.jpg';
            end
            axis square tight;
            alpha(0.3);	% DOES NOT WORK for screen? OK for image...
            F = getframe(gca);
            imwrite(F.cdata,fname);
            
            % EXPERIMENTAL:
            J = imresize(F.cdata, [256 256]);
            imwrite(J,'image_resized.jpg');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Environment:
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = showEnv(obj)
            figure(1);
            clf(1);  % clear fig 1 (or else it overlays previous display)
            axis square tight;
            alpha(0.3);	% Transparency (to show overlaps)
            % Show Bounding Box:
            obj.showBoundingBox();
            % show start and goal config:
            bluegreen=[0, 1, 1];
            redgreen=[1, 1, 0];
            obj.showDisc(obj.start(1), obj.start(2), bluegreen);
            obj.showDisc(obj.goal(1), obj.goal(2), redgreen);
            
            %Display the obstacles in brown:
            brown = [0.8, 0.5, 0];
            for C = obj.polygons
                patch(C{1}.X,C{1}.Y, brown);
            end
            
            %
            F = getframe(gca);
            imwrite(F.cdata,'fig1.jpg');
            
            
            % Output an image file:
            obj.outputFile('image.jpg');
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Static)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % readFile( fname )
        %	-- Reads an "env.txt" file with lines in this order:
        %	     radius, eps, BoundingBox, start, goal, polygon*
        %	-- although it returns an "obj", this is only a FAKE
        %		"Environment" object!
        %		The constructor has to copy each component
        %		of this FAKE object into the actual object
        %		begin constructed.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = readFile(filename)
            if nargin < 1
                filename = 'env0.txt';
            end
            fid=fopen(filename);
            nextCase = 1;
            obj.polygons = {};
            numOfPolygons = 0;
            
            numArray = Environment.getNumbers(fid);
            
            while ~ isempty(numArray)
                switch nextCase
                    case 1
                        obj.radius = numArray(1);
                    case 2
                        obj.epsilon = numArray(1);
                    case 3
                        BoundingBoxX = numArray(1:4);
                    case 4
                        BoundingBoxY = numArray(1:4);
                        obj.BoundingBox = mapshape(BoundingBoxX, BoundingBoxY);
                    case 5
                        obj.start = numArray(1:2);
                    case 6
                        obj.goal = numArray(1:2);
                    case 7
                        pBoxX = numArray;
                    case 8
                        pBoxY = numArray;
                        numOfPolygons = numOfPolygons+1;
                        obj.polygons{numOfPolygons} = mapshape(pBoxX,pBoxY);
                end % switch
                if nextCase == 8
                    nextCase = 7;
                else
                    nextCase = nextCase+1;
                end
                numArray = Environment.getNumbers(fid);
            end % while
            if nextCase<7
                disp(['Error reading input file: ', filename]);
                disp(['next Case = ', num2str(nextCase)]);
            end
            fclose(fid);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getNumbers( fileID )
        %	returns an array of numbers.
        %	It returns an empty array iff the fileID
        %		has reached EOF.
        % THIS IS A HELPER method for readFile().
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function result = getNumbers(fid)
            line = fgetl(fid); result = []; B = [];
            while ~feof(fid) % ~feof(fid) - for end of file or ischar(line)
                loc = strfind(line,'%');
                if(~isempty(loc))
                    line(loc(1):end) = [];
                end
                if(~isempty(line))
                    B = regexp(line,'(+|-)?\d+(\.\d+)?','match');
                end
                if(~isempty(B))
                    for i= 1:length(B)
                        result(i,1)=str2double(B{i});
                    end
                    break; % come out of while loop
                end
                line = fgetl(fid);
            end % getNumbers
            
        end % properties Static
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % test
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function a = test( filename )
            if nargin<1
                filename = 'env0.txt';
            end
            a = Environment(filename);
            showEnv(a); % uncomment this to show the entire environment
            
            % ADDITIONAL TEST: show obstacles using "mapshow" instead of
            %		patch.  How to do color?
            %{
	    figure(2);
	    clf(2);
	    axis tight square;
	    alpha(0.3);
	    a.showBoundingBox();
            shape = mapshape(a.X_bag, a.Y_bag);
            mapshow(shape.X,shape.Y,...
	    	'DisplayType','polygon',...
		'FaceColor', [0.8, 0.5, 0]...   % brown
		);
            %}
        end
    end
end