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
            obj.showEnv();
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % voronoiMain(obj)
        %   ->  Finds FREE startBox and goalBox
        %   ->  Uses GBF (Greedy Best First) variation of Dijkstra's 
        %       Algorithm customized for Voronoi Diagrams
        %       CONDITIONS:
        %       ->  Source Set made up of FREE Boxes with >=2 Voronoi 
        %           Features Connected by free space to startBox
        %       ->  Fringe made up of FREE & MIXED Boxes adjacent to Source
        %           Set and has >=2 Voronoi Features
        %   ->  Highest Priority Box (GBF) from Fringe selected
        %       ->  FREE box is added to Source Set
        %       ->  MIXED box is split, adjacent boxes to Source Set are 
        %           add back to Fringe
        %   ->  Keeps looping until a FREE path from startBox to goalBox is
        %       found
        %   ->  Returns true if path found, else false
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function voronoiMain(obj)
            
        end
        
        % Check Fringe for Box
        function check = fringeAdjCheck(obj, box)
            % Check if adjacent to Source Set
            check = false;                      
            nbrs = obj.sdiv.getNeighbours(box);
            for n = 1:length(nbrs)
                nbr = nbrs(n);
                if nbr.sourceIdx > 0
                    check = obj.fringeCheck(box);
                end
            end
        end
        
        % Check Fringe for Box Adjacent to Source
        function check = fringeCheck(obj, box)
            % FREE/MIXED
            check = false;
            if (box.type == BoxType.FREE) || (box.type == BoxType.MIXED)
                % >=2 Voronoi Features
                if size(box.vorFeats, 2) >= 2
                    % Add to Fringe
                    check = true;
                end
            end
        end
        
        % Add Box to Fringe using (Box2) box and ([x y]) dest
        function fringeAdd (obj, fringe, box, dest)
            if nargin < 4
                dest = obj.sdiv.env.goal;
            end
            
            midBox = mapshape(box.x, box.y);
            midDest = mapshape(dest(1), dest(2));
            fringe.add(box, Geom2d.sep(midBox, midDest));
        end
        
        function plotSourceBox(obj, box)
            hold on;
            alpha(0.3);
            fill(box.shape().X, box.shape().Y, 'b');
            plot(box.shape().X, box.shape().Y, 'r--');
            hold off;
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showPathVor(path)
	    %		Animation of the path for Voronoi boxes
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showPathVor(obj, handles)
            obj.sdiv.env.showPath(obj.sdiv.sourceSet, handles);
	    end

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
        % Voronoi
        function flag = test2(obj,filename, handles) 
            flag = false;
            
%             obj = SSS('env3.txt');              % Select Enviroment File
            obj.showEnv();                      % Display Environment in Figure
            obj.sdiv = Subdiv3(obj.fname);      % Set to Subdiv3 for Voronoi Support
            fringe = PriorityQueue();           % Fringe for Voronoi Algorithms

            % Find Start Box
            obj.startBox = obj.makeFree(obj.sdiv.env.start);
            if size(obj.startBox, 2) == 0
                textLabel = sprintf('NO PATH: start is not free!');
                set(handles.vorFeedback, 'String', textLabel);
                flag = false;
                return;
            end
            
            obj.sdiv.plotLeaf(obj.startBox);
            obj.sdiv.addToSourceSet(obj.startBox);                      % Add Type Free StartBox to Source Set
            obj.plotSourceBox(obj.startBox);
            %{
            hold on;
            alpha(0.3);
            fill(obj.startBox.shape().X, obj.startBox.shape().Y, 'b');
            plot(obj.startBox.shape().X, obj.startBox.shape().Y, 'r--');
            hold off;
            %}
            %plot(obj.startBox.shape().X, obj.startBox.shape().Y,'--r'); % Plot StartBox as part of Source Set
            
            textLabel = sprintf('... start is free ...');
            set(handles.vorFeedback, 'String', textLabel);
            %}
            
            % Find Goal Box
            obj.goalBox = obj.makeFree(obj.sdiv.env.goal);
            if size(obj.goalBox, 2) == 0
                textLabel = sprintf('NO PATH: GOAL IS NOT FREE');
                set(handles.vorFeedback, 'String', textLabel);
                flag = false;
                return;
            end
            obj.sdiv.plotLeaf(obj.goalBox);
            textLabel = sprintf('... goal is free ...');
            set(handles.vorFeedback, 'String', textLabel);
            %}
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create check if startBox is not on Voronoi Diagram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %{
                ->  Find Neighbors of StartBox
                ->  Only Include FREE/MIXED
                ->  Find Closest Feature to StartBox
                ->  Add Neighbor farthest from ClosFeat to Fringe
            %}
            
            
            % INIT Fringe using CONDITIONS Stated Above
            for i = 1:length(obj.sdiv.sourceSet)
                % Get Neighbors of Source Set to Add to Fringe
                nbrs = obj.sdiv.getNeighbours(obj.sdiv.sourceSet(i));
                for j = 1:length(nbrs)
                    nbr = nbrs(j);
                    if obj.fringeCheck(nbr)
                        obj.fringeAdd(fringe, nbr);
                    end
                    
                    %{
                    % FREE/MIXED
                    if nbr.type == BoxType.FREE || nbr.type == BoxType.MIXED
                        % >=2 Voronoi Features
                        if size(nbr.vorFeats, 2) >= 2
                            
                            % Add to Fringe
                            midNbr = mapshape(nbr.x, nbr.y);
                            midGoal = mapshape(obj.sdiv.env.goal(1), obj.sdiv.env.goal(2));
                            fringe.add(nbr, Geom2d.sep(midNbr, midGoal));
                        end
                    end
                    %}
                end
            end
            %}
                        
            % Find Path with Voronoi
            
            obj.count = 0;
            % TO BE USED: When goalBox is also attached to vorUnion from the beginning
            %while obj.sdiv.vorUnion.find(obj.startBox.vorIdx) ~= obj.sdiv.vorUnion.find(obj.goalBox.vorIdx)
            while obj.goalBox.vorIdx == 0                                       % Hasn't been added to the Union
                % If Fringe is empty, no path can be found 
                if fringe.isEmpty()
                    disp('Fringe is Empty');
                    flag = false;
                    break;
                end
                
                % Count iterations
                obj.count = obj.count + 1;   
                if mod(obj.count,50) == 0
                    fprintf('.')
                end
                
                % Pop Fringe
                % if FREE --> add box to Source Set 
                % else MIXED --> split box, add adjacents to Fringe
                box = fringe.remove();
                if box.type == BoxType.FREE
                    obj.sdiv.addToSourceSet(box);                       % Add to Source Set
                    obj.plotSourceBox(box);
                    %hold on;
                    %plot(box.shape().X, box.shape().Y,'--r');           % Plot Source Set Box
                    %hold off;
                    %drawnow
                    disp('--------------------------------------------------');
                    disp(box);
                    disp('--------------------------------------------------');
                    nbrs = obj.sdiv.getNeighbours(box);                 % Add Neighbors to Fringe 
                    %for i = 1:length
                    disp(nbrs);
                    disp('--------------------------------------------------');
                    for n = 1:length(nbrs)
                        nbr = nbrs(n);
                        
                        % Check for null Boxes
                        if ~isempty(nbr.type)
                            if obj.fringeCheck(nbr)
                                obj.fringeAdd(fringe, nbr);
                            end
                        end
                    end
                elseif box.type == BoxType.MIXED
                    obj.sdiv.split(box);
                    children = box.child;
                    
                    % Check if any children go back on fringe
                    for c = 1:length(children)
                        child = children(c);
                        
                        if obj.fringeAdjCheck(child)
                            obj.fringeAdd(fringe, child);   % Add to Fringe
                        end
                    end
                end
                disp(['Fringe Size: ', num2str(fringe.getNumElements)]);
            end
            disp(['Count: ', num2str(obj.count)]);
            disp(['Source Size: ', num2str(length(obj.sdiv.sourceSet))]);
            flag = true;
        end
        
        function test3() 
            
            
            % Test Priority Queue
            pq = PriorityQueue();
            testBox = Box2(0.5, 0.5, 0.5);
            disp(testBox);
            
            pq.add(testBox, 1);
            testBox.sourceIdx = 5;
            
            disp(pq.remove());
            
            
            
            
        end
        
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
                if (strcmp(get(handles.showPath,'String'), 'S H O W   P A T H  :  H W 4   S S S'))
                    pathS.showPath(handles);
                elseif (strcmp(get(handles.showPath,'String'), 'S H O W   P A T H  :  V O R O N O I'))
                    pathS.showPathVor(handles);
                end
            elseif (val == 4)
                flag = SSS.test2(s,filename, handles)
                pathS = s;
                if flag
                    s.hasPath = true;
                end
            end
%             s.showEnv(handles);
%             s.run(1);
            flag = pathS;
        end
        
    end
end % SSS class