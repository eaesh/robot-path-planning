%{
 file: Box1.m
	
 	The Box1 class is designed to be called by the Subdivision class.

	Each box is a square defined by three independent parameters:
		x, y, w
	where (x,y) is the box center, and w the half-width.

	We have dependent properties like
		NEcorner, SEcorner, SWcorner, NWcorner
	for the four corners of the box.

	In Subdivision class, the boxes must be treated as objects
		because it has state information.
		So that our boxes are "handle objects".
	
	What is NOT implemented in Box1.m are information related to
	the subdivision tree, such as the neighbor properties.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Robotics Class, Spring 2017
	Chee Yap (with help of TA's Rohit Muthyla and Naman Kumar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef Box1 < handle
    properties
    % child is either empty or an array of size 4.
    %	child(i) is the index to the i-th child.
    %	CONVENTION:
    %	   The i-th child is in the i-th quadrant relative to the box center.
	x; y; w;
	isLeaf = true;
    parent;
	child = []; % We assume the four children are indexed so that
	            % the i-th child is in the i-th quadrant (i=1,2,3,4) 
    end

    properties (Dependent)
    	NEcorner; SEcorner; SWcorner; NWcorner;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = Box1(xx, yy, ww,pp)
            if(nargin == 3)
                obj.x = xx;
                obj.y = yy;
                obj.w = ww;
            elseif (nargin == 4)
                obj.x = xx;
                obj.y = yy;
                obj.w = ww;
                obj.parent = pp;
            else
                 error('Wrong number of input args');
            end
            
	end

        %{
    function obj = Box1(xx, yy, ww, pp)
	% Constructor
	    obj.x = xx;
	    obj.y = yy;
	    obj.w = ww;
	    obj.parent = pp;
	end
%}
	function corner = get.NEcorner(obj)
	% compute dependent value of NE corner
	    corner = [ obj.x + obj.w, obj.y + obj.w];
	end

	function corner = get.SWcorner(obj)
	% compute dependent value of NE corner
	    corner = [ obj.x - obj.w, obj.y - obj.w];
	end

	function children = split(obj)
	% SPLIT() returns an array CHILD where
	%   CHILD(i) is in quadrant i (i=1,2,3,4)
	    obj.child = [
	        Box1(obj.x+obj.w/2,obj.y+obj.w/2,obj.w/2, obj)
	        Box1(obj.x-obj.w/2,obj.y+obj.w/2,obj.w/2, obj)
	        Box1(obj.x-obj.w/2,obj.y-obj.w/2,obj.w/2, obj)
	        Box1(obj.x+obj.w/2,obj.y-obj.w/2,obj.w/2, obj)];
	    obj.isLeaf = false;
	    children = obj.child;
	end
	
	function inside = isIn(obj, x, y)
	% ISIN(x,y) returns true if (x,y) is inside the box.
		ww = obj.w;
		inside = false;
		if (x >= obj.x - ww && x <= obj.x + ww && ...
		    	y >= obj.y - ww && y <= obj.y + ww)
		    		inside = true;
	        end
	end

	function quad = findQuad(obj, x, y)
	% FINDQUAD(x,y) returns index i if (x,y) is in quadrant i
	%   for some i = 1,2,3,4.
	%   ASSERT: (x,y) lies within the box.
	%   We ought to return 0 if (x,y) is not in the box.
		if (x>obj.x)
		    if (y>obj.y)
			quad = 1;
		    else
			quad = 4;
		    end
		else 
		    if (y>obj.y)
			quad = 2;
		    else
			quad = 3;
		    end
		end
	end

	function showBox(obj)	
	% SHOWBOX is displays some information about the box.
	 if (obj.isLeaf == 1)
	    disp(['leaf box(', num2str(obj.x), ', ', ...
	   	num2str(obj.y), ', ', num2str(obj.w), ')']);
	 else
	    disp(['internal box(', num2str(obj.x), ', '  ...
	   	,num2str(obj.y), ', ', num2str(obj.w), ')']);
	%% alternatively: if child
	%	    disp(['Box1(', num2str(obj.x), ', '  ...
	%	   	,num2str(obj.y), ', ', num2str(obj.w), ...
	%		') with child indices ', num2str(child(1)), ', ', ...
	%		num2str(child(2)), ', ', num2str(child(3)), ', ', ...
	%		num2str(child(4)) ]);
	    end;
	end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static = true)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function test()
	% Testing some basic functions of box class.
	    b = Box1(0,0,1);
            b.showBox();
            disp(['-->> Is root a leaf? ',num2str(b.isLeaf)]);
            children = b.split();
            disp('-->> child 1 = '); children(1).showBox();
            disp('-->> child 2 = '); children(2).showBox();
            disp('-->> child 3 = '); children(3).showBox();
            disp(['-->> Is root a leaf? ',num2str(b.isLeaf)]);
            disp(['-->> Is child(1) a leaf? ',num2str(children(1).isLeaf)]);
	    disp(['-->> Which child contains (-0.2, 0.6)  ? ', ...
	    	num2str(b.findQuad(-.2,.6))]);
	    disp(['-->> Is (0.5, -2) inside Box1(0,0,1)? ', ...
	    	num2str(b.isIn(0.5,-2))]);
        end
    end
end
