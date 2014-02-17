class PetriNet::ReachabilityGraph::Node < PetriNet::Graph::Node
    def initialize(options = {}, &block)
        super(options)
        yield self unless block.nil?
    end

end

class PetriNet::ReachabilityGraph::InfinityNode < PetriNet::ReachabilityGraph::Node
    def initialize()
        super(markings: [Float::INFINITY])
    end
end
