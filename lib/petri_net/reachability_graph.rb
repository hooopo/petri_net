class PetriNet::ReachabilityGraph < PetriNet::Base
    def initialize
        @objects = Array.new
        @nodes = Array.new
        @edges = Array.new
    end

    def add_node(node)
        if node.validate && !@nodes.include? node.name
            @objects[node.id] = node
            @nodes[node.name] = node.id
            node.graph = self
            return node.id
        end
        return false
    end

    def add_edge(edge)
        if edge.validate && !@edges.include? edge.name
            @objects[edge.id] = edge
            @nodes[edge.name] = edge.id
            edge.graph = self
            return edge.id
        end
        return false
    end

    # Add an object to the Petri Net.
    def <<(object)
        case object.class.to_s
        when "Array"
            object.each {|o| self << o}
        when "PetriNet::ReachabilityGraph::Edge"
            add_edge(object)
        when "PetriNet::ReachabilityGraph::Node"
            add_node(object)
        else
            raise "(PetriNet::ReachabilityGraph) Unknown object #{object.class}."
        end
        self
    end
    alias_method :add_object, :<<

end
