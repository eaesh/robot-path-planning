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
% 	    function flag = mainLoop(obj)
% 
% 	        flag = false;
%             disp('MainLoop Begins')
%             
%             alpha(0.1);
%             % Find Start Box
%             startConfig = obj.sdiv.env.start;
% 	    	obj.startBox = obj.makeFree(startConfig);
%             if isempty(obj.startBox)
%                 disp('NOPATH: start is not free');
%                 return;
%             else 
%                 hold on;
%                 disp('StartBox is Found!')
%                 obj.sdiv.plotLeaf(obj.startBox, BoxType.FREE);
%                 hold off;
%             end
%             
%             % Plot Start Box
%             obj.sdiv.plotLeaf();
%             drawnow
%             %}
%             
%             
%             % Find Goal Box
% 	    	goalConfig = obj.sdiv.env.goal;
%             obj.goalBox = obj.makeFree(goalConfig);
%             if isempty(obj.goalBox)
%                 disp('NOPATH: goal is not free');
%                 return;
%             else
%                 hold on;
%                 disp('GoalBox is Found!')
%                 obj.sdiv.plotLeaf(obj.goalBox, BoxType.FREE)
%                 hold off;
%             end
%             
%             % Plot Goal Box
%             obj.sdiv.plotLeaf();
%             drawnow
%             %}
%             
%             
%             if (~obj.makeConnected(obj.startBox, obj.goalBox))
%                 display('NOPATH: start and goal not connected');
%                 return;
%             else
%                 % Box Split and Path Found
%                 flag = true;
%             end
%             %}
%         end


        function flag = mainLoop(obj, handles)
            flag = false;
            
            obj.startBox = obj.makeFree(obj.sdiv.env.start);
            if size(obj.startBox, 2) == 0
                textLabel = sprintf('NO PATH: Start is not free');
                set(handles.subDivFeedback, 'String', textLabel);
                return;
            end
            textLabel = sprintf('... start is FREE!');
            set(handles.subDivFeedback, 'String', textLabel);
            
            textLabel = sprintf('... finding goal box');
            set(handles.subDivFeedback, 'String', textLabel);
            obj.goalBox = obj.makeFree(obj.sdiv.env.goal);
            if size(obj.goalBox, 2) == 0
                textLabel = sprintf('NO PATH: Goal is not free');
                set(handles.subDivFeedback, 'String', textLabel);
                return;
            end
            
            textLabel = sprintf('... goal is FREE!');
            set(handles.subDivFeedback, 'String', textLabel);
            
            if ~obj.makeConnected(obj.startBox, obj.goalBox)
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
                    box = obj.getLeaf(box, config);
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
	    function flag = makeConnected(obj, startBox, goalBox)
            
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

            count = 0;
            while obj.sdiv.unionF.find(startBox.idx) ~= obj.sdiv.unionF.find(goalBox.idx)
                
                % If Queue is empty, no path can be found
                if q.isEmpty()
                    flag = false;
                    break;
                end
                
                % Count iterations
                count = count + 1;                
                if mod(count,50) == 0
                    fprintf('.')
                    obj.sdiv.plotLeaf();
                    drawnow
                end
                                
                % Pop queue and split.
                % Add child to the Q if it hasn't been classified
                % and is bigger than epsilon.
                box = q.remove();
                obj.sdiv.split(box);
                children = box.child;
                for c = 1:length(children)
                    child = children(c);
                    if child.type == BoxType.MIXED
                        q.add(child); 
                    end
                end
            end
            
            disp(['COUNT: ', num2str(count)])
            obj.sdiv.plotLeaf();
            drawnow
            
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
                pathS = false;
            end
            s = SSS(filename);
            if (val == 1)
                s.showEnv();
            elseif (val == 2)
                s.mainLoop(handles);
                pathS = s;
%                 if flag
%                     s.showPath();
%                 end
            elseif (val == 3)
                pathS.showPath(handles);
            end
%             s.showEnv(handles);
%             s.run(1);
            flag = pathS;
        end
                
        function test2() 
            fudge = [2, 4, 6, 8, 10];
            fudge2 = fudge([1:2, 4:end]);
            
            disp(length(fudge))
            disp(length(fudge2))
            
            disp(fudge)
            disp(fudge2)
        end
    end
end % SSS class

