# frozen_string_literal: true

class PetriNet::ReachabilityGraph::Node < PetriNet::Graph::Node
  def initialize(graph, options = {}, &block)
    super(graph, options)
    yield self unless block.nil?
  end
end

class PetriNet::ReachabilityGraph::InfinityNode < PetriNet::ReachabilityGraph::Node
  def initialize(graph)
    super(graph, markings: [Float::INFINITY])
  end
end
