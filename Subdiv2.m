classdef Subdiv2 < Subdiv1
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        env;        % environment
        unionF;     % union find data structure
        %q = [];          % array of mixed boxes
    end
    
    properties (Access = private)
        %white = [1 1 1]
        %gray = [0.5 0.5 0.5]
        %red = [1 0 0]
        %yellow = [1 1 0]
        %green =[0 1 0]
        colo = [[1 1 1];[0.5 0.5 0.5];[1 0 0]; [1 1 0]; [0 1 0]];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Constructor for Subdiv2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Subdiv2(fname)
            if (nargin < 1)
                fname = 'env0.txt';
            end
            env = Environment(fname);
            
            % Assuming the convention that our bounding box starts from SW
            % corner and the remaining points are the other three corners in
            % clock-wise order
            BoundingBox = env.BoundingBox;
            x = (BoundingBox.X(1)+ BoundingBox.X(2)+ BoundingBox.X(3)+ BoundingBox.X(4))/4;
            y = (BoundingBox.Y(1)+ BoundingBox.Y(2)+ BoundingBox.Y(3)+ BoundingBox.Y(4))/4;
            w = abs(x - BoundingBox.X(1));
            
            % Constructor for SubDiv
            obj = obj@Subdiv1(x,y,w);
            obj.rootBox.pNbr = [Box2.null Box2.null Box2.null Box2.null];
            obj.rootBox.type = BoxType.MIXED;
            obj.env = env;
            obj.updateFeatures(obj.rootBox);
            obj.unionF = UnionFind();
        end
        
        %	THIS IS A KEY METHOD:
        %		It is best to call sub-methods.
        %
        %         function child = split(obj)
        %		1. call Box2.split
        %		2. For each child:
        %			2.1 compute its features
        %			2.2 classify the child
        %			2.3 if FREE, add child to UnionFind structure
        %		3. For each child:
        %			If it is FREE, do UNION with all its neighbors
        %			%	NOTE that this is NOT done as step 2.4! Why?
        %         end
        
        % Split(box)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function split(obj, box)
            box.split();
            %             for i_dash = Idx.children()
            %                     i = Idx.quad(i_dash);
            %                     obj.updateFeatures(box.child(i));
            %                     %obj.classify(box.child(i));
            %                     if (box.child(i).type == BoxType.FREE)
            %                         obj.unionF.add(box.child(i));
            %                     end %if
            %             end %for
            %
                        
            for i_dash = Idx.children()
                i = Idx.quad(i_dash);
                obj.updateFeatures(box.child(i));   % Update feature set of each child box
                obj.classify(box.child(i));         % Classify child as MIXED/FREE/STUCK
                if box.child(i).type == BoxType.FREE   % Add child to UnionFind if FREE
                    box.child(i).idx = obj.unionF.ADD(box.child(i));
                end
                    
                box.child(i).pNbr = [Box2.null Box2.null Box2.null Box2.null];  % Initializing neighbors of children
                for j_dash = Idx.dirs()
                    k = Idx.quad(Idx.nbr(i_dash,j_dash));   % Each neighbor of child
                    j = Idx.dir(j_dash);
                    if(Idx.isSibling(i_dash,j_dash))    % Check if neighbor is sibling of child
                        box.child(i).pNbr(j) = box.child(k);    
                    else        % Neighbor is parents neighbor as well
                        if(box.pNbr(j).isLeaf)      % Parent Neighbor doesn't have children
                            box.child(i).pNbr(j) = box.pNbr(j);
                        else    % Neighbor of child is set to Parent's Neighbor's child
                            box.child(i).pNbr(j) = box.pNbr(j).child(k);
                            boxNbrSet = obj.getNbrDir(box.child(i),j_dash);
                            for b = 1:length(boxNbrSet)
                                boxes = boxNbrSet(b);
                                boxes.pNbr(Idx.dir(Idx.opp(j_dash))) = box.child(i);
                            end
                        end
                    end
                end %for j_dash
            end %for i_dash
            
            % Children are updated, classified, and their neighbors are
            % initialized
            % Now Do UNION to create CONNECTED COMPONENTS of FREE space
            for i_dash = Idx.children()
                i = Idx.quad(i_dash);
                if box.child(i).type == BoxType.FREE
                    neighbors = obj.getNeighbours(box.child(i));
                    for j = 1:length(neighbors)
                        if neighbors(j).type == BoxType.FREE
                            obj.unionF.union(box.child(i).idx, neighbors(j).idx);
                        end
                    end %for each neighbors
                end %if child == free
            end %for union
            
        end %function split
        
        % All Neighbors of Box
        function neighbour = getNeighbours(obj,box)
            dir = Idx.dirs();
            neighbour = [obj.getNbrDir(box,dir(1))...
                obj.getNbrDir(box,dir(2))...
                obj.getNbrDir(box,dir(3))...
                obj.getNbrDir(box,dir(4))];
        end
        
        % Finds specific neighbor in direction
        function nbrs = getNbrDir(obj,box,dir_dash)
            pN = box.pNbr(Idx.dir(dir_dash));
            if(pN.isLeaf)
                nbrs = [pN];
            else
                nbrs = obj.getLeavesDir(pN,dir_dash);
            end
        end
        
        % Finds Neighbors of children until leaf neighbor is found
        function lvs = getLeavesDir(obj,box,dir_dash)
            if(box.isLeaf)
                lvs = [box];
            else
                dd = Idx.adj(dir_dash);
                lvs = [obj.getLeavesDir(box.child(Idx.quad(dd(1))),dir_dash)...
                    obj.getLeavesDir(box.child(Idx.quad(dd(2))),dir_dash)];
            end
        end
        
        function updateFeatures(obj, box)
            % Process through each obstacle from the environment 
            % to see if any features belong in the set
            obstacles = obj.env.polygons;
            rad = box.w + obj.env.radius;   % Radius used to select features
            
            for i = 1:length(obstacles)
            
                midpoint = mapshape(box.x, box.y);   % Midpoint of Box
                
                % Load Obstacle's Features
                % Check Distance between Midpoint of Box and Feature of Obstacles
                % Check if Geom2d.sep() method <= radius(width) of box
                
                % Go through all Points
                for j = 1:length(obstacles{i}.X)
                    % Load Point
                    point = mapshape([obstacles{i}.X(j)], [obstacles{i}.Y(j)]);
                    
                    % Compare Distance to Midpoint
                    if Geom2d.sep(midpoint, point) < rad
                        % Add to feature set
                        box.features{length(box.features)+1} = point;
                    end
                end
                
                % Go through all Edges
                for j = 1:length(obstacles{i}.X)
                    % Load Edge
                    if j ~= length(obstacles{i}.X)
                        edge = mapshape([(obstacles{i}.X(j)) (obstacles{i}.X(j+1))],...
                                        [(obstacles{i}.Y(j)) (obstacles{i}.Y(j+1))]);
                    else    % Circle around to first point
                        edge = mapshape([(obstacles{i}.X(j)) (obstacles{i}.X(1))],...
                                        [(obstacles{i}.Y(j)) (obstacles{i}.Y(1))]);
                    end
                    
                    % Compare Distance to Midpoint
                    if Geom2d.sep(midpoint, edge) <= rad
                        % Add to feature set
                        box.features{length(box.features)+1} = edge;
                    end
                end % for each feature
            end % for each obstacle
        end %function updateFeatures
        
        function classify(obj,box)
            % Check Parent
            if box.parent.type ~= BoxType.MIXED % Just in case 
                box.type = box.parent.type;
            elseif box.w < obj.env.epsilon
                box.type = BoxType.SMALL;
            elseif ~isempty(box.features)   % Check MIXED
                box.type = BoxType.MIXED;
            else    % Check FREE or STUCK
                % Find closest feature
                closFeat = findClosestFeature(obj,box);
                midpoint = mapshape(box.x, box.y);   % Midpoint of Box
                                
                if length(closFeat.X) > 1         % First case (Edge)
                    %disp('FIRST CASE -------------------')
                    a = mapshape(closFeat.X(1), closFeat.Y(1));
                    b = mapshape(closFeat.X(2), closFeat.Y(2));
                    if ~Geom2d.leftOf(a, b, midpoint)       % FREE
                        box.type = BoxType.FREE;
                    else
                        box.type = BoxType.STUCK;
                    end
                else    % Second case (point)
                    %disp('SECOND CASE ------------------')
                    % Find edges incident to point
                    features = box.parent.features;
                    a = [];
                    b = [];
                    for i = 1:length(features)
                        if length(features{i}.X) > 1
                            if (closFeat.X(1) == features{i}.X(2)) && (closFeat.Y(1) == features{i}.Y(2))
                                a = mapshape(features{i}.X(1), features{i}.Y(1));
                            elseif (closFeat.X(1) == features{i}.X(1)) && (closFeat.Y(1) == features{i}.Y(1))
                                b = mapshape(features{i}.X(2), features{i}.Y(2));
                            end
                        end
                    end
                    
                    if ~Geom2d.leftOf(a, b, closFeat)    % FREE
                        box.type = BoxType.FREE;
                    else
                        box.type = BoxType.STUCK;
                    end
                end % if free/stuck
            end % if parent/small/mixed
        end % function classify

        function closFeat = findClosestFeature(obj,box, features) % 'helper method for classify()
            if nargin < 3
                features = box.parent.features;
            end
            dist = max(obj.env.BoundingBox.X) - min(obj.env.BoundingBox.X); % Max distance between Two Points within Bounding Box

            % Load Feature Set of Parent Box
            for i = 1:length(features)
                midpoint = mapshape(box.x, box.y);   % Midpoint of Box

                if Geom2d.sep(midpoint, features{i}) < dist
                    dist  = Geom2d.sep(midpoint, features{i});
                    closFeat = features{i};
                end
            end
        end
                
        % Plot all Leaf Children of given Box/rootBox
        function plotLeaf(obj, box, type)
            if nargin < 2
                box = obj.rootBox;
            end
            if nargin < 3
                type = BoxType.UNKNOWN;
            end
            %plot(box.shape().X,box.shape().Y,'b-');
            %hold on;
            alpha(0.2);
            obj.plotLeaves(box,type);
            %hold off;
        end
        
        % Recursive helper method for plotLeaf
        function plotLeaves(obj, box, type)
            if(box.isLeaf && (box.type == type || type == BoxType.UNKNOWN))
                hold on;
                alpha(0.3);
                fill(box.shape().X,box.shape().Y,obj.colo(box.type + 4,:));
                plot(box.shape().X,box.shape().Y,'b-');
                hold off;
            else
                for i = 1:length(box.child)
                    obj.plotLeaves(box.child(i),type);
                end
            end
            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
        end
        
        function plotNbrs(obj, box, nbrsList, dir)
            if nargin < 3
                box = obj.rootBox;
            end
            if nargin < 4
                dir = 0;
            end
            %hold on;
            alpha(0.2)
            fill(box.shape().X, box.shape().Y, [0 1 0]);
            plot(box.shape().X, box.shape().Y, 'b-');
            
            if dir == 0
                for i = 1:length(nbrsList)
                    if(nbrsList(i) ~= Box2.null && (dir == 0))
                        fill(nbrsList(i).shape().X,nbrsList(i).shape().Y,[1 1 0]);
                        plot(nbrsList(i).shape().X,nbrsList(i).shape().Y,'b-');
                    end
                end
            else
                i = Idx.dir(dir);
                if (nbrsList(i) ~= Box2.null)
                    fill(nbrsList(i).shape().X,nbrsList(i).shape().Y,[1 1 0]);
                    plot(nbrsList(i).shape().X,nbrsList(i).shape().Y,'b-');
                end
            end

            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
            
            %hold off;
        end
%{        
        function path = findPath(obj, start, goal)
            %{
            if nargin < 2
                % Find start and end boxes
                start = obj.findBox(obj.env.start(1), obj.env.start(2));
                goal = obj.findBox(obj.env.goal(1), obj.env.goal(2));
            end
            %}
            % Cancel if start or goal is not free
            if start.type ~= BoxType.FREE
                disp('FindPath(): START NOT FREE')
                path = [];
                return;
            elseif goal.type ~= BoxType.FREE
                disp('FindPath(): GOAL NOT FREE')
                path = [];
                return;
            elseif obj.unionF.find(start.idx) ~= obj.unionF.find(goal.idx)  % Check if path exists
                disp('FindPath(): PATH DOES NOT EXIST')
                path = [];
                return;
            else     % Find the Path
                path = [start.idx];
                parentUnion = obj.unionF.PARENT;
                itemUnion = obj.unionF.ITEM;
                itemUnion{start.idx}.visited = true;
                path = obj.DFS(start.idx, goal.idx, path, parentUnion, itemUnion);
        
            end % if start/goal not free

            % Unmark all boxes
            obj.unmarkAllBox();
        end
        
        function path = DFS(obj, v, goal, path, parents, items)
            path = [path v];
            items{v}.visited = true;
            if v ~= goal
                % Search possible neighbors
                for i = 1:length(parents)
                    % If no more possible neighbors return empty array
                    if ~items{i}.visited
                        % Item points to V OR % V points to Item
                        if (parents(i) == v) || (parents(v) == i)   
                            temp = obj.DFS(i, goal, path, parents, items);
                            if isempty(temp)
                                % This path failed and returned empty array
                            elseif temp(length(temp)) == goal   % Found GOAL!!!
                                path = temp;
                                return;
                            end %if
                        end %if 
                    end %if 
                end %for
                
                % If no change to path then failed 
                if path(length(path)) ~= goal
                    path = [];
                end %if
            else
                % Search Complete: Path Found
            end
        end
        
        function path = findPath2(obj, startBox, goalBox)
            
            path = [];
            
            if isempty(startBox) 
                path = [];
            elseif isempty(goalBox)
                path = [];
            elseif obj.unionF.find(startBox.idx) == obj.unionF.find(goalBox.idx)
                disp('PATH EXISTS!!!')
                
                
                
                path = obj.DFS2(path, startBox, goalBox);
            else
                path = [];
            end
        end
        
        function path = DFS2(obj, path, box, goal)
            path = [path box.idx];
            disp(path)
            if box.idx == goal.idx
                % GOAL FOUND - Path Complete
                return;
            else
                % Search through free neighbors
                neighbors = box.pNbr;
                
                for n = 1:length(neighbors)
                    nbr = neighbors(n);
                    % Check if neighbor is free and hasn't been visited yet
                    if nbr.type == BoxType.FREE
                        if ~ismember(nbr.idx, path)
                            temp = obj.DFS2(path, nbr, goal);
                            if ~isempty(temp)
                                if temp(length(temp)) == goal.idx
                                    path = temp;
                                    return;
                                end
                            end
                        end
                    end
                end
                
                % GOAL NOT FOUND
                path = [];                    
            end
        end
%}
        function BFS(obj, start, goal)
            start.visited = true;
            Q = [start];
            while ~ isempty(Q)
                B = Q(1);
                Q(1) = [];
                neighbors = obj.getNeighbours(B);
                for n = 1:length(neighbors)
                    b = neighbors(n);
                    if b == goal
                        goal.prev = B;
                        return;
                    elseif (b.type == BoxType.FREE)
                        if ~b.visited
                            Q = [Q b];
                            b.prev = B;
                            b.visited = true;
                        end
                    end
                end
            end
        end
        
        
        % Removed 'visited' mark after findPath is complete so it can be
        % used again
        function unmarkAllBox(obj)  % Unmark (unvisit) all boxes
            obj.unmark(obj.rootBox);
        end
            
        function unmark(obj, box)   % Recursive 'helper' function to unmarkAllBox()
            box.visited = false;
            if ~box.isLeaf
               for i = 1:length(box.child)
                   obj.unmark(box.child(i));
               end
            end
        end
    end
        
    
    methods (Static = true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test()
            fname = 'env0.txt';
            s = Subdiv2(fname);
            
            %%%%%%%%%%%%%%%%%%%%%% FIRST SPLIT:
            rootBox = s.rootBox;
            s.split(rootBox);
            rootBox.showBox();
            disp(rootBox.shape())
            
            %%%%%%%%%%%%%%%%%%%%%% SECOND SPLIT:
            box = s.findBox(9,1);
            s.split(box);
            
            %%%%%%%%%%%%%%%%%%%%%% THIRD SPLIT:
            box = s.findBox(9,1);
            s.split(box);
            
            box = s.findBox(8.125,0.625);
            s.split(box);
            
            %box = s.findBox(2.5,2.5);
            box = s.findBox(8.13,1.9);
            nbrs = s.getNeighbours(box);
            disp(nbrs(1))
            s.plotNbrs(box,nbrs); % Assuming 1-N, 2-W, 3-S, 4-E, dir needs to be impemented
            
            s.findPath();
            %s.showSubdiv();
            %s.displaySubDiv();
            %s.plotLeaf(rootBox, BoxType.MIXED);
            %}
            
            %{
            box = s.findBox(1,9);
            s.split(box);
            disp(box)
            
            box = s.findBox(1,9);
            s.split(box);
            disp(box)
            
            
            % Display Feature Set of Box
            disp(box)
            disp(length(box.features))
            for i = 1:length(box.features)
                disp(box.features{i})
            end
            disp(s.findClosestFeature(box));
            %}
        end
    end
end