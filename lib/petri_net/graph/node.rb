# frozen_string_literal: true

class PetriNet::Graph::Node < PetriNet::Base
  include Comparable

  # human readable name
  attr_reader :name
  # unique ID
  attr_reader :id
  # Makking this node represents
  attr_reader :markings
  # The graph this node belongs to
  attr_accessor :graph
  # Omega-marked node (unlimited Petrinet -> coverabilitygraph)
  attr_reader :omega_marked
  # Incoming edges
  attr_reader :inputs
  # Outgoing edges
  attr_reader :outputs
  # Label of the node
  attr_reader :label
  # True if this is the start-marking
  attr_reader :start

  def initialize(graph, options = {}, &block)
    @graph = graph
    @id = next_object_id
    @name = (options[:name] || "Node#{@id}")
    @description = (options[:description] || "Node #{@id}")
    @inputs = []
    @outputs = []
    @label = (options[:label] || @name)
    @markings = options[:markings]
    @start = (options[:start] || false)
    raise ArgumentError, 'Every Node needs markings' if @markings.nil?

    @omega_marked = if @markings.include? Float::INFINITY
                      true
                    else
                      false
                    end

    yield self unless block.nil?
  end

  def infinite?
    @omega_marked
  end

  # Add an omega-marking to a specified place
  def add_omega(object)
    ret = []
    if object.class.to_s == 'PetriNet::CoverabilityGraph::Node'
      if self < object
        counter = 0
        object.markings.each do |marking|
          if @markings[counter] < marking
            @markings[counter] = Float::INFINITY
            ret << counter
            end
          counter += 1
        end
      else
        return false
      end
    elsif object.class.to_s == 'Array'
      object.each do |place|
        markings[place] = Float::INFINITY
        ret = object
      end
    elsif object.class.to_s == 'Fixnum'
      markings[object] = Float::INFINITY
      ret = [object]
    elsif object.class.to_s == 'PetriNet::ReachabilityGraph::Node'
      raise PetriNet::Graph::InfinityError('ReachabilityGraphs do not support omega-markings')
    end
    @omega_marked = true
    ret
  end

  def include_place(place)
    places = @graph.net.get_place_list
    included_places = []
    i = 0
    @markings.each do |m|
      included_places << places[i] if m > 0
      i += 1
    end
    included_places.include? place
  end

  def validate
    true
  end

  def gv_id
    "N#{@id}"
  end

  def to_gv
    "\t#{gv_id} [ label = \"#{@markings}\" ];\n"
  end

  # Compare-operator, other Operators are available through comparable-mixin
  def <=>(object)
    return nil unless object.class.to_s == 'PetriNet::ReachabilityGraph::Node'
    return 0 if @markings == object.markings

    counter = 0
    less = true
    markings.each do |marking|
      if marking <= object.markings[counter] && less
        less = true
      else
        less = false
        break
      end
      counter += 1
    end
    return -1 if less

    counter = 0
    more = true
    markings.each do |marking|
      if marking >= object.markings[counter] && more
        more = true
      else
        more = false
        break
      end
      counter += 1
    end
    return 1 if more

    nil
  end

  def to_s
    "#{@id}: #{@name} (#{@markings})"
  end
end
