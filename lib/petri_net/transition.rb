# frozen_string_literal: true

module PetriNet
  # Transition
  class Transition < PetriNet::Base
    # Unique ID
    attr_accessor :id
    # Huan readable name
    attr_accessor :name
    # Description
    attr_accessor :description
    # Probability of firing (this moment)
    attr_accessor :probability
    # List of input-arcs
    attr_reader   :inputs
    # List of output-arcs
    attr_reader   :outputs
    # The net this transition belongs to
    attr_writer   :net

    # Create a new transition.
    def initialize(options = {}, &block)
      @id = next_object_id
      @name = (options[:name] || "Transition#{@id}")
      @description = (options[:description] || "Transition #{@id}")
      @inputs = []
      @outputs = []
      @probability = options[:probability]

      yield self unless block.nil?
    end

    # Add an input arc
    def add_input(arc)
      @inputs << arc.id unless arc.nil? || !validate_input(arc)
    end

    # Add an output arc
    def add_output(arc)
      @outputs << arc.id unless arc.nil? || !validate_output(arc)
    end

    # GraphViz ID
    def gv_id
      "T#{@id}"
    end

    # Validate this transition.
    def validate
      return false if @id < 1
      return false if @name.nil? || @name.empty?

      true
    end

    # Stringify this transition.
    def to_s
      "#{@id}: #{@name}"
    end

    # GraphViz definition
    def to_gv
      "\t#{gv_id} [ label = \"#{@name}#{@probability ? ' ' + @probability.to_s : ''}\" ];\n"
    end

    def ==(object)
      name == object.name && description = object.description
    end

    def preplaces
      raise 'Not part of a net' if @net.nil?

      places = []
      places << @inputs.map { |i| @net.objects[i].source }
    end

    def postplaces
      raise 'Not part of a net' if @net.nil?

      @outputs.map { |o| @net.objects[o].source }
    end

    def activated?
      raise 'Not part of a net' if @net.nil?

      @inputs.each do |i|
        return false if @net.get_object(i).source.markings.size < @net.get_object(i).weight
      end

      @outputs.each do |o|
        return false if @net.get_object(o).destination.markings.size + @net.get_object(o).weight > @net.get_object(o).destination.capacity
      end
    end
    alias firable? activated?

    def activate!
      @inputs.each do |i|
        source = @net.get_object(i).source
        source.add_marking(@net.get_object(i).weight - source.markings.size)
      end

      # what to do with outputs, if they have a capacity
    end

    def fire
      raise 'Not part of a net' if @net.nil?
      return false unless activated?

      @inputs.each do |i|
        @net.get_object(i).source.remove_marking @net.get_object(i).weight
      end

      @outputs.each do |o|
        @net.get_object(o).destination.add_marking @net.get_object(o).weight
      end
      true
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
end
