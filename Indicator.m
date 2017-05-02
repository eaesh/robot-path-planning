%{
	When you write a code to extract all the Northern neighbors
	of a box, you can be sure that this code is rather similar
	for extracting the Southern, Eastern, Western neighbors.
	We do not want to write 4 copies of this code!

	The following class is an aid for writing such code.
	It provides an "algebra" of indicators, which amounts
	to algebraic manipulation of sign vectors.

	But we also want to exploit enum types so that our
	human intuitions about compass directions can be used.

	Indicator for directions (N, S, E, W)
		and for children (NE, NW, SE, SW),
		and their algebra.

		NOTE: the indicators are pairs of signs,
			where a sign is an element of {+1, 0, -1}.

			However, in Matlab, we need to convert
			each pair into a integer value (int32),
			which is called the code.
	
		E.g.,  [0,+1] is a direction indicator with code 23
		E.g.,  [+1,-1] is a child indicator with code 31

	
	HOW TO USE:
		1.  You can use this to get "enum types"
	
			>> direction1 = Indicator.N
			>> direction2 = Indicator.W
			>> child1 = Indicator.NE
			>> child2 = Indicator.SE

		2.  Methods "code(ii)" and "indic(cc)" will
			convert between codes and indicators

		3.  Method "opp(dir)" returns the opposite direction
		4.  Method "siblingNbr(child1)" returns two neigbors
				who are siblings of child1
		5.  Method "cousinNbr(dir)" returns two neigbors
				who are cousin of current box
				in direction "dir".

		These Nbr methods can be used
			to get all the neigbors of a box
			in a given direction.
	
	Intro Robotics (Spring 2017)
	--Chee Yap (Apr 1, 2017)
%}

classdef Indicator < int32
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        enumeration
            NE	(33)		% = [+1,+1]
            NW	(13)		% = [-1,+1]
            SE	(31)		% = [+1,-1]
            SW	(11)		% = [-1,-1]
        end
        enumeration
            N	(23)		% = [0,+1]
            S	(21)		% = [0,-1]
            E	(32)		% = [+1,0]
            W	(12)		% = [-1,0]
	end
	
	methods (Static = true)
	
		% dirs()
		%	returns an array of the direction indicators
		%	This is useful for iterations over all directions. 
		function d = dirs()
			d (1) = Indicator.N;
			d (2) = Indicator.W;
			d (3) = Indicator.S;
			d (4) = Indicator.E;
		end
	
		% children()
		%	returns an array of the children indicators.
		%	This is useful for iterations over all children. 
		function d = children()
			d (1) = Indicator.NE;
			d (2) = Indicator.NW;
			d (3) = Indicator.SW;
			d (4) = Indicator.SE;
		end
	
		% indic(c)
		% 	-- converts a code c into an ind:
		%	e.g., indic(12) returns [-1,+1] (=NW)
		function ind = indic(c)
			cc = int32(c);
			ind(1) = idivide(cc, int32(10)) - 2;
			ind(2) = mod(cc, 10) - 2;
		    end
	
		% code(ind)
		% 	-- converts an indicator "ind" to a code c
		%	e.g., code([0,-1]) returns 21 (="south")
		function cc = code(ind)
			cc = int32((ind(1)+2)*10 + (ind(2) +2));
		    end
	
		% code2(indx, indy)
		% 	-- variation of code(ind) where we are given 2 ints
		%	e.g., code(0,-1) returns 21 (="south")
		function cc = code2(indx, indy)
			cc = int32((indx +2)*10 + (indy +2));
		    end
	
		% opp(dir)
		%	-- transforms direction "dir" to its opposite direction
		%	e.g., code(21) returns 23
		function cc = opp(c)
			ii = Indicator.indic(c);
			cc = Indicator.code(-ii);
		    end
	
		% siblingNbr(child)
		%	-- returns an array of the two children indicators 
		%		that are the sibling neigbhors of child.
		%	e.g., siblingNbr(NE) returns [NW, SE] = [13 31]
		function ccc = siblingNbr(child)
			ind = Indicator.indic(child);
			ccc(1) = Indicator.code2(-ind(1), ind(2));
			ccc(2) = Indicator.code2(ind(1), -ind(2));
		    end
	
		% cousinNbr(dir)
		%	-- returns an array of the two children indicators 
		%	   that are the cousin neigbors in direction "dir"
		%	e.g., cousinNbr(E) returns [NW, SW] = [13 11]
		function ccc = cousinNbr(dir)
			a = - Indicator.indic(dir);
			a ( a == 0)  = 1;
			b = - Indicator.indic(dir);
			b ( b == 0)  = -1;
			ccc(1) = Indicator.code(a);
			ccc(2) = Indicator.code(b);
		    end


		% test()
		%
		function ccc = test()
		% to be implemented
	    	end
        end
     end

