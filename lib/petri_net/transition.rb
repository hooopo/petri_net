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
            return true if name == object.name && description = object.description
        end

        def preplaces
            raise "Not part of a net" if @net.nil?
            places = Array.new
            places << inputs.map{|i| @net.objects[i].source}
        end

        def postplaces
            raise "Not part of a net" if @net.nil?
            outputs.map{|o| @net.objects[o].source}
        end
    end 
end
