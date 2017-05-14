%{
	SSS class:
		this is the main class encoding the
		"Soft Subdivision Search" technique.

	The Main Method:
		Setup Environment
			(read from file and initialize data structures)
%}

classdef SSS < handle

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		fname;		% filename
		sdiv;		% subdivision
		path=[];	% path 
		startBox=[];	% box containing the start config
		goalBox=[];	% box containing the goal config
        hasPath=false;
        count;      % Box Split Counter
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Constructor
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function sss = SSS(fname)
	    	if (nargin < 1)
                fname = 'env0.txt';
            end
            sss.fname = fname;
            sss.setup(fname);
	    end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % run (arg)
	    %		if no arg, run default example
	    %		if with arg, do
	    %			interactive loop (ignores arg)
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function run(obj, arg)
	    	if nargin<1
                obj.mainLoop();
                obj.showPath();
                return;
            end

            disp(['Welcome to SSS!']);
            while true
                option = input(...
                    ['Choose an options:\n',...
                    '0 = quit\n1 = mainLoop\n2 = showEnv\n'...
                    '3 = showPath\n4 = new setup\n']);
                  switch option
                case 0
                return;
                case 1
                flag = obj.mainLoop();
                if flag
                    obj.showPath();
                end
                case 2
                obj.showEnv();
                case 3
                obj.showPath();
                case 4
                obj.fname=input('input environment file');
                obj.setup(obj.fname);
                obj.showEnv(obj);
                otherwise
                disp('invalid option');
                  end % switch
            end % while
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % mainLoop
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flag = mainLoop(obj, handles)
            flag = false;
            
            % Find Start Box
            obj.startBox = obj.makeFree(obj.sdiv.env.start);
            if size(obj.startBox, 2) == 0
                textLabel = sprintf('NO PATH: Start is not free');
                set(handles.subDivFeedback, 'String', textLabel);
                return;
            end
            textLabel = sprintf('... start is FREE!...');
            set(handles.subDivFeedback, 'String', textLabel);
            
            % Find Goal Box
            textLabel = sprintf('... finding goal box...');
            set(handles.subDivFeedback, 'String', textLabel);
            obj.goalBox = obj.makeFree(obj.sdiv.env.goal);
            if size(obj.goalBox, 2) == 0
                textLabel = sprintf('NO PATH: Goal is not free');
                set(handles.subDivFeedback, 'String', textLabel);
                return;
            end
            
            textLabel = sprintf('... goal is FREE!...');
            set(handles.subDivFeedback, 'String', textLabel);
            
            % Find Path Between Start and Goal
            if ~obj.makeConnected(obj.startBox, obj.goalBox, handles)
                textLabel = sprintf('NO PATH: Start and goal do not connect');
                set(handles.subDivFeedback, 'String', textLabel);
                return;
            end
            
            textLabel = sprintf('PATH FOUND! Animate the path below.');
            set(handles.subDivFeedback, 'String', textLabel);
            
            flag = true;
        end
        
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Setup
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function setup(obj, fname)
            obj.sdiv = Subdiv2(fname); % Create Subdivision with FileName
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % makeFree(config)
	    %		keeps splitting until we find
	    %		a FREE box containing the config.
	    %		If we fail, we return [] (empty array)
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function box = makeFree(obj,config)
            
            % config is array holding coordinates of box to find [x,y]
            % Keep splitting until box is FREE or STUCK(fail)
            box = obj.sdiv.rootBox;
            if ~box.isIn(config(1), config(2))
                box = [];
            else
                % Get Leaf Box containing configuration
                box = obj.getLeaf(box, config);
                
                % Split box until FREE box is found containing config
                while (box.type == BoxType.MIXED)
                    obj.sdiv.split(box);
                    obj.sdiv.plotLeaf(box);
                    box = obj.getLeaf(box, config);
                    drawnow
                end
            end
            % BoxType is not free, it is STUCK or SMALL
            if box.type ~= BoxType.FREE
                box = [];
            end
        end

        function leaf = getLeaf(~, box, config)
            leaf = box;
            % Iterate through until leaf is found.
            while ~leaf.isLeaf
                for c = 1:length(leaf.child)
                    child = leaf.child(c);
                    if child.isIn(config(1), config(2)) 
                        leaf = child;
                        break;
                    end
                end
            end
        end
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % makeConnected(startBox, goalBox)
	    %		keeps splitting until we find
	    %		a FREE path from startBox to goalBox.
	    %		Returns true if path found, else false.
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = makeConnected(obj, startBox, goalBox, handles)
            
            % Loop that keeps iterating until path is found or path can't
            % be found (no more splits can be made(no mixed boxes
            % remaining))
            
            % Should through all boxes to decide which to split
            % Only mixed boxes should be split
            
            % Stop when no more mixed boxes inside q (instructor said stop
            % when small)
            
            obj.sdiv.plotLeaf();
            drawnow
            
            % Create Queue of Mixed Leaf Boxes
            q = Queue();
            leaves = obj.getLeaves(obj.sdiv.rootBox, BoxType.MIXED);
            for l = leaves
                q.add(l);
            end
            disp('QUEUE COMPLETED')
            disp(['Number of Elements: ', num2str(q.NumElements)])

            obj.count = 0;
%           pause = false;
            while obj.sdiv.unionF.find(startBox.idx) ~= obj.sdiv.unionF.find(goalBox.idx)
                textLabel = sprintf(num2str(toc));
                set(handles.subDivFeedback, 'String', textLabel);
                drawnow
                
%                 if (strcmp(get(handles.pauseBttn,'String'), 'P A U S E'))
%                     disp('about to unpause');
%                     uiresume
%                 if (strcmp(get(handles.pauseBttn,'String'), 'U N P A U S E'))
%                     disp('about to pause');
%                     uiwait
%                 end
                
                % If Queue is empty, no path can be found
                if q.isEmpty()
                    flag = false;
                    break;
                end
                
                % Count iterations
                obj.count = obj.count + 1;   
                if mod(obj.count,50) == 0
                    fprintf('.')
                    %obj.sdiv.plotLeaf();
                    %drawnow
                end
                %}
                
                % Pop queue and split.
                % Add child to the Q if it hasn't been classified
                % and is bigger than epsilon.
                box = q.remove();
                obj.sdiv.split(box);
                children = box.child;
                hold on;
                for c = 1:length(children)
                    child = children(c);
                    obj.sdiv.plotLeaf(child);
                    drawnow
                    if child.type == BoxType.MIXED
                        q.add(child); 
                    end
                end
                hold off;
            end
            
            disp(['COUNT: ', num2str(obj.count)])
            %obj.sdiv.plotLeaf();
            %drawnow
            
            disp('STARTBOX PARENT')
            disp(obj.sdiv.unionF.find(startBox.idx))
            disp('GOALBOX PARENT')
            disp(obj.sdiv.unionF.find(goalBox.idx))
            
            if obj.sdiv.unionF.find(startBox.idx) == obj.sdiv.unionF.find(goalBox.idx)
                flag = true;
            else
                flag = false;
            end
        end

        % Recursively gets all leaves of box of type 
        function leaves = getLeaves(obj, box, type)
            if box.isLeaf
                if box.type == type
                    leaves = box;
                else
                    leaves = [];
                end
            else
                leaves = [];
                children = box.child;
                for i = 1:length(children)
                    leaves = [leaves obj.getLeaves(children(i), type)];
                end
            end
            
        end
        
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showPath(path)
	    %		Animation of the path
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showPath(obj, handles)
            
            disp('SHOWPATH() BEGINS')
            obj.sdiv.BFS(obj.startBox, obj.goalBox);
            disp('SHOWPATH PART 1')
            
            % Backtrack from Goal
            fpath = [];
            b = obj.goalBox;
            while (b ~= obj.startBox)
                fpath = [b fpath];
                b = b.prev;
            end
            disp(['Length of Path', num2str(length(fpath))])
            
            % Animate
            obj.sdiv.env.showPath(fpath, handles);
	    end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showEnv()
	    %		Display the environment
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showEnv(obj)
            obj.sdiv.env.showEnv();
	    end

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % test()
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = test(val, filename, handles, pathS)
            if nargin < 4
                pathS = 0;
            end
            s = SSS(filename);
            if (val == 1)
                s.showEnv();
            elseif (val == 2)
                flag = s.mainLoop(handles);
                pathS = s;
                if flag
                    s.hasPath = true;
                end
            elseif (val == 3)
                pathS.showPath(handles);
            end
%             s.showEnv(handles);
%             s.run(1);
            flag = pathS;
        end
           
        % Voronoi
        function flag = test2() 
            obj = SSS("env3.txt");
            obj.showEnv();
            obj.sdiv = Subdiv3(obj.fname);
            flag = false;
            
            hold on;
            % Find Start Box
            obj.startBox = obj.makeFree(obj.sdiv.env.start);
            if size(obj.startBox, 2) == 0
                disp('NO PATH: Start is not free');
                return;
            end
            obj.sdiv.plotLeaf(obj.startBox);
            % Add Type Free StartBox to Source Set
            obj.sdiv.sourceSet = [obj.sdiv.sourceSet obj.startBox];
            disp('... start is FREE!...');
            
            
            % Find Goal Box
            obj.goalBox = obj.makeFree(obj.sdiv.env.goal);
            if size(obj.goalBox, 2) == 0
                disp('NO PATH: Goal is not free');
                return;
            end
            obj.sdiv.plotLeaf(obj.goalBox);
            disp('... goal is FREE!...');
            hold off;
            
            
            % Find Path with Voronoi
            %{
            while obj.sdiv.unionF.find(startBox.idx) ~= obj.sdiv.unionF.find(goalBox.idx)
                
                % If Fring is empty, no path can be found 
                if obj.sdiv.fringe.isEmpty()
                    disp('Fringe is Empty');
                    flag = false;
                    break;
                end
                
                % Count iterations
                obj.count = obj.count + 1;   
                if mod(obj.count,50) == 0
                    fprintf('.')
                end
                
                
                % Pop queue and split.
                % Add child to the Q if it hasn't been classified
                % and is bigger than epsilon.
                box = q.remove();
                obj.sdiv.split(box);
                children = box.child;
                hold on;
                for c = 1:length(children)
                    child = children(c);
                    obj.sdiv.plotLeaf(child);
                    drawnow
                    if child.type == BoxType.MIXED
                        q.add(child); 
                    end
                end
                hold off;
            end
            %}
                
                
                
                
                
                
            hold on;
            %feats = obj.startBox.voroFeats;
            feats = obj.sdiv.rootBox.voroFeats;
            %obj.sdiv.split(obj.sdiv.rootBox);
            for i = 1:length(feats)
                %disp(feats{i});
                plot(feats{i}.X,feats{i}.Y,'--r');
            end
            hold off;
            %{
            if ~obj.makeConnected(obj.startBox, obj.goalBox, handles)
                textLabel = sprintf('NO PATH: Start and goal do not connect');
                set(handles.subDivFeedback, 'String', textLabel);
                return;
            end
            
            textLabel = sprintf('PATH FOUND! Animate the path below.');
            set(handles.subDivFeedback, 'String', textLabel);
            flag = true;
            %}
            
            
        end
    end
end % SSS class

