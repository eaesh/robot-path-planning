classdef Subdiv3 < Subdiv2
    
    %%%%%%%%%%%%%%%%%%%%%
    properties
        sourceSet = [];         % Source Set of Boxes
        vorUnion;               % Union of Boxes connected by voronoi diagram
    end
    %%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor with Voronoi Features
        function obj = Subdiv3(fname)
            obj = obj@Subdiv2(fname);
            obj.updateVorFeatures(obj.rootBox, obj.rootBox.features);
            obj.vorUnion = UnionFind();
        end
        
        % Split Box 
        function split(obj, box)
            split@Subdiv2(obj, box);
            for i_dash = Idx.children()
                i = Idx.quad(i_dash);
                obj.updateVorFeatures(box.child(i));
            end
            %disp('------------------------------')
        end
                    
        % Update Voronoi Features for given box 
        function updateVorFeatures(obj, box, features)
            % Features not given use parent box's vorFeats
            if nargin < 3
                features = box.parent.vorFeats;
            end
            
            % Using Voronoi Feature Algorithm
            midpoint = mapshape(box.x, box.y);
            closFeat = obj.findClosestFeature(box, features);
            clearance = Geom2d.sep(midpoint, closFeat);
            rad = clearance + (2 * box.w);
            %disp(['Voronoi Radius: ', num2str(rad)]);
            %disp(['Voronoi Clearance: ', num2str(clearance)]);
            %disp(['Box Width: ', num2str(rad)]);
            
            %disp('Closest Feature');
            %disp(closFeat);
            
            for i = 1:length(features)
                if Geom2d.sep(midpoint, features{i}) <= rad
                    % Add as Voronoi Feature of Box
                    box.vorFeats{length(box.vorFeats)+1} = features{i};
                end            
            end    
        end
        
        % Add to Source Set
        function idx = addToSourceSet(obj, box)
            
            % Add to end of array
            obj.sourceSet = [obj.sourceSet box];
            idx = length(obj.sourceSet);
            box.sourceIdx = idx;
            box.vorIdx = obj.vorUnion.ADD(box);
            obj.vorUnion.union(box.vorIdx, obj.sourceSet(1).vorIdx);
        end
        
        % Find Path from Start to Goal
        function path = findPath(obj, goal)
            % Check if Source Set has box containing goal configuration
            path = false;
            for i = 1:length(obj.sourceSet)
                if obj.sourceSet(i).isIn(goal(1), goal(2))
                    path = true;
                end
            end
            
            % Return Path
            if path
                
            end
        end
    end
    
end