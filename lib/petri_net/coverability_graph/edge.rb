class PetriNet::CoverabilityGraph::Edge < PetriNet::Base
    
    # Creates an edge for PetriNet::CoverabilityGraph
    def initialize(options = {}, &block)
        super(options)
        yield self unless block.nil?
    end

    # Validates the data holded by this edge, this will be used while adding the edge to the graph
    def validate
        super
    end
end
