% Helper Class to Priority Queue

classdef PriorityNode < handle
   
    properties
        element;
        value;
        nextNode = [];
    end
    
    methods
        
        % Constructor
        function obj = PriorityNode(el, val)
            obj.element = el;
            obj.value = val;
            nextNode = [];
        end
        
        
        
    end
    
end