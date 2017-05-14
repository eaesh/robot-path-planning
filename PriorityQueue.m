% Based off Java Linked List Structure
% Orders Queue by Lowest Value

classdef PriorityQueue < handle

    properties ( Access = private )
        headNode = [];
        numElements;
    end
    
    methods

        % Constructor
        function obj = PriorityQueue
            obj.headNode = [];
            obj.numElements = 0;
        end

        % Insert Node into Queue based on Lowest Value
        function add( obj, el, val )
            
            node = obj.headNode;
            prevNode = [];
            
            % Traverse through linked nodes until insert spot found
            while (~isempty(node) && node.value < val)
                prevNode = node;
                node = node.nextNode;
            end
            
            % Insert node in queue
            if isempty(prevNode)
                % Add Node to Head of Queue;
                obj.headNode = PriorityNode(el, val);
                obj.headNode.nextNode = node;
            elseif isempty(node)
                % Add Node to Tail of Queue
                pNode = PriorityNode(el, val);
                prevNode.nextNode = pNode;
            else
                % Insert Node between two nodes
                pNode = PriorityNode(el, val);
                prevNode.nextNode = pNode;
                pNode.nextNode = node;
            end
            
            % Update Size of Queue
            obj.numElements = obj.numElements + 1;
        end

        % Remove Highest Priority Node (Lowest Value) 
        function el = remove( obj )

            if obj.isEmpty()
                error( 'Queue is empty' );
            end

            % Pop Head
            el = obj.headNode.element;
            obj.headNode = obj.headNode.nextNode;
            
            % Update Size of Queue
            obj.numElements = obj.numElements - 1;
        end

        function tf = isEmpty( obj )
            
            tf = ( obj.numElements == 0 );
            
        end

        function n = getNumElements( obj )
            n = obj.numElements;
        end

    end
end