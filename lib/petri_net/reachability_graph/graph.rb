# frozen_string_literal: true

require 'graphviz'

class PetriNet::ReachabilityGraph < PetriNet::Graph
  def initialize(net, options = {})
    options[:type] = 'Reachability'
    super(net, options)
    self
  end

  def add_node(node)
    @nodes.each_value do |n|
      raise PetriNet::InfiniteReachabilityGraphError if @objects[n] < node
    rescue ArgumentError
      # Just an InfiniteNode
    end
    super node
  end

  def add_node!(node)
    super node
  end
end
