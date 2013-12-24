module PetriNet
    # Transition
    class Transition < PetriNet::Base
        attr_accessor :id            # Unique ID
        attr_accessor :name          # Human readable name	
        attr_accessor :description   # Description
        attr_reader   :inputs        # Input arcs
        attr_reader   :outputs       # Output arcs
        attr_writer   :net           # The net this transition belongs to

        # Create a new transition.
        def initialize(options = {}, &block)
            @id = next_object_id
            @name = (options[:name] or "Transition#{@id}")
            @description = (options[:description] or "Transition #{@id}")
            @inputs = Array.new
            @outputs = Array.new

            yield self unless block == nil
        end	

        # Add an input arc
        def add_input(arc)
            @inputs << arc.id unless arc.nil?
        end

        # Add an output arc
        def add_output(arc)
            @outputs << arc.id unless arc.nil?
        end

        # GraphViz ID
        def gv_id
            "T#{@id}"
        end

        # Validate this transition.
        def validate
            return false if @id < 1
            return false if @name.nil? or @name.length < 1
            return true
        end

        # Stringify this transition.
        def to_s
            "#{@id}: #{@name}"
        end

        # GraphViz definition
        def to_gv
            "\t#{self.gv_id} [ label = \"#{@name}\" ];\n"
        end

        def ==(object)
            name == object.name && description = object.description
        end

        def preplaces
            raise "Not part of a net" if @net.nil?
            places = Array.new
            places << @inputs.map{|i| @net.objects[i].source}
        end

        def postplaces
            raise "Not part of a net" if @net.nil?
            @outputs.map{|o| @net.objects[o].source}
        end

        def activated?
            raise "Not part of a net" if @net.nil?
            @inputs.each do |i|
                return false if @net.get_object(i).source.markings.size < @net.get_object(i).weight
            end

            @outputs.each do |o|
                return false if @net.get_object(o).destination.markings.size + @net.get_object(o).weight > @net.get_object(o).destination.capacity
            end
        end
        alias_method :firable?, :activated?

        def activate!
            @inputs.each do |i|
                source = @net.get_object(i).source
                source.add_marking(@net.get_object(i).weight - source.markings.size)
            end

            #what to do with outputs, if they have a capacity
        end

        def fire
            raise "Not part of a net" if @net.nil?
            return false unless activated?
            @inputs.each do |i|
                @net.get_object(i).source.remove_marking @net.get_object(i).weight
            end

            @outputs.each do |o|
                @net.get_object(o).destination.add_marking @net.get_object(o).weight
            end
            true
        end
    end 
end
