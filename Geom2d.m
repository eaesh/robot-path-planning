%{
	Geom2d.m

	This class knows about 

		points, edges, polygons

	Moreover, we assume these are all mapshape objects!!!

	This class has ONLY static methods such as

		sep(obj, obj)
		leftOf( p1, p2, p3)

	ALL geometric computation should be done in this class.

	Please add other methods as the need arise.
%}

classdef Geom2d 

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% returns the separation between obj1 and obj2
	%	You only need 2 cases:
	%	 (obj1,obj2) = (point, point)
	%	 (obj1,obj2) = (point, edge)
	function s = sep(obj1, obj2)
        % Check if obj2 is point or edge
        if length(obj2.X) == 1      % POINT
            % sqrt(((x2 - x1)^2) + ((y2 - y1)^2))
            s = sqrt(((obj2.X(1) - obj1.X(1))^2) + ((obj2.Y(1) - obj1.Y(1))^2));
        else    % EDGE
            % Check if closer to corner of edge than edge itself
            % t = ((q - a) dot (b - a))/((length(b - a)) ^ 2)
            q = [obj1.X(1) obj1.Y(1)];
            a = [obj2.X(1) obj2.Y(1)];
            b = [obj2.X(2) obj2.Y(2)];
            
            qa = q - a;
            ba = b - a;
            lenba2 = norm(ba) ^ 2;
            t = dot(qa, ba)/lenba2;
            
            if t <= 0       % s = ||q - a||
                s = norm(qa);
            elseif t >= 1   % s = ||q - b||
                s = norm(q - b);
            else            % s = ||q - p(t)||
                pt = ((1 - t) * a) + (t * b);
                s = norm(q - pt);
            end
        end
	end

	% returns true iff (p1,p2,p3) represents a "Left Turn"
	%
	function bool = leftOf(p1, p2, p3)
		% det(b - a, f - b) to determine if (a, b, f) is a "Left Turn"
        a = [p1.X(1) p1.Y(1)];
        b = [p2.X(1) p2.Y(1)];
        f = [p3.X(1) p3.Y(1)];
        
        bool = det([b - a; f - b]) > 0;
    end
    
    function test()  
        % On side of Point A on Edge
        point = mapshape([0], [0]);
        edge = mapshape([1 2],...
                        [1 2]);
        disp('Distance to Point A');
        disp(Geom2d.sep(point, edge));
        
        % On side of Point B on Edge
        point = mapshape([3], [3]);
        edge = mapshape([1 2],...
                        [1 2]);
        disp('Distance to Point B');
        disp(Geom2d.sep(point, edge));
        
        % Between Point A and B on Edge
        point = mapshape([1], [2]);
        edge = mapshape([1 2],...
                        [1 2]);
        disp('Distance to Point P(t)');
        disp(Geom2d.sep(point, edge));        
        
        % Right-Turn
        disp('Right-Turn');
        p1 = mapshape([0], [0]);
        p2 = mapshape([0], [1]);
        p3 = mapshape([1], [1]);
        disp(Geom2d.leftOf(p1, p2, p3));

        % Left-Turn
        disp('Left-Turn');
        p1 = mapshape([0], [1]);
        p2 = mapshape([0], [0]);
        p3 = mapshape([1], [0]);
        disp(Geom2d.leftOf(p1, p2, p3));
    end
    
    function test2()
        %'env0.txt' example test
        start = mapshape([9], [9]);
        line = mapshape([8 8],...
                        [3.5 10]);
        disp(Geom2d.sep(start, line))
                    
    end
    
    
    end
end




