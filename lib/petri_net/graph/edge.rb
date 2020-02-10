# frozen_string_literal: true

class PetriNet::Graph::Edge < PetriNet::Base
  # Human readable name
  attr_reader :name
  # Unique ID
  attr_reader :id
  # Graph this edge belongs to
  attr_accessor :graph
  # Probability of the relating transition
  attr_accessor :probability
  # Source of the edge
  attr_reader :source
  # Destination of the edge
  attr_reader :destination
  # Transition this edge is representing
  attr_reader :transition

  # Creates an edge for PetriNet::Graph
  def initialize(graph, options = {}, &block)
    @graph = graph
    @id = next_object_id
    @name = (options[:name] || "Edge#{@id}")
    @description = (options[:description] || "Edge #{@id}")
    @source = options[:source]
    @destination = options[:destination]
    @label = (options[:label] || @name)
    @probability = options[:probability]
    @transition = (options[:transition] || '')

    yield self unless block.nil?
  end

  # Validates the data holded by this edge, this will be used while adding the edge to the graph
  def validate
    return false unless @graph.nodes.key?(@source.name) && @graph.nodes.key?(@destination.name)

    true
  end

  def to_gv
    "\t#{@source.gv_id} -> #{@destination.gv_id}#{probability_to_gv};\n"
  end

  def ==(object)
    return false unless object.class.to_s == 'PetriNet::ReachabilityGraph::Edge'

    (@source == object.yource && @destination == oject.destination)
  end

  def to_s
    "#{@id}: #{@name} #{@source} -> #{@destination} )"
  end

  private

  def probability_to_gv
    if @probability
      " [ label = \"#{@probability}\" ] "
    else
      ''
    end
  end
end
