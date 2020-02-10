# frozen_string_literal: true

class PetriNet::Place < PetriNet::Base
  # Unique ID
  attr_reader :id
  # Needed to sanitize a Petrinet after merging
  attr_writer :id
  # Human readable name
  attr_accessor :name
  # description
  attr_accessor :description
  # Token capacity
  attr_accessor :capacity
  # List of input-arcs
  attr_reader   :inputs
  # List of output-arcs
  attr_reader   :outputs
  # Current token
  attr_reader :markings
  # The net this place belongs to
  attr_writer :net

  # Initialize a new place.  Supports block configuration.
  def initialize(options = {}, &block)
    @id = next_object_id
    @name = (options[:name] || "Place#{@id}")
    @description = (options[:description] || "Place #{@id}")
    @capacity = options[:capacity].nil? ? Float::INFINITY : options[:capacity]
    @inputs = []
    @outputs = []
    @markings = []

    yield self unless block.nil?
  end

  # Add an input arc
  def add_input(arc)
    @inputs << arc.id unless arc.nil? || !validate_input(arc)
  end

  # Add an output arc
  def add_output(arc)
    @outputs << arc.id unless arc.nil? || !validate_input(arc)
  end

  def add_marking(count = 1)
    if count <= @capacity
      count.times do
        @markings << PetriNet::Marking.new
      end
      true
    else
      raise 'Tried to add more markings than possible'
    end
  end

  def set_marking(count)
    @markings = []
    add_marking count
  end

  alias + add_marking

  def remove_marking(count = 1)
    if @markings.size >= count
      ret = @markings.pop(count)
      return ret unless ret.nil?
    else
      raise 'Tried to remove more markings that possible'
    end
  end
  alias - remove_marking

  # GraphViz ID
  def gv_id
    "P#{@id}"
  end

  # Validate the setup of this place.
  def validate
    return false if @id.nil? || (@id < 0)
    return false if @name.nil? || (@name.strip.length <= 0)
    return false if @description.nil? || (@description.strip.length <= 0)
    return false if @capacity.nil? || (@capacity < -1)

    true
  end

  def pretransitions
    raise 'Not part of a net' if @net.nil?

    transitions = []
    places << inputs.map { |i| @net.objects[i].source }
  end

  def posttransitions
    raise 'Not part of a net' if @net.nil?

    outputs.map { |o| @net.objects[o].source }
  end

  # Stringify this place.
  def to_s
    "#{@id}: #{@name} (#{@capacity.nil? ? -1 : 0}) #{'*' * @markings.length}"
  end

  # GraphViz definition
  def to_gv
    "\t#{gv_id} [ label = \"#{@name} #{@markings.size}  \" ];\n"
  end

  def ==(object)
    return true if name == object.name && description = object.description
  end

  private

  def validate_input(arc)
    inputs.each do |a|
      return false if (@net.get_objects[a] <=> arc) == 0
    end
    true
  end

  def validate_output(arc)
    outputs.each do |a|
      return false if (@net.get_objects[a] <=> arc) == 0
    end
    true
  end
end
