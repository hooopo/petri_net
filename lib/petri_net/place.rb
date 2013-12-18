class PetriNet::Place < PetriNet::Base
    attr_accessor :id            # Unique ID
    attr_accessor :name          # Human readable name	
    attr_accessor :description   # Description
    attr_accessor :capacity      # Token capacity
    attr_reader   :inputs        # Input arcs
    attr_reader   :outputs       # Output arcs
    attr_reader :markings      # Current Token/Markings
    attr_writer   :net           # The net this place belongs to

    # Initialize a new place.  Supports block configuration.
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Place#{@id}")
        @description = (options[:description] or "Place #{@id}")
        @capacity = options[:capacity].nil? ? Float::INFINITY : options[:capacity]
        @inputs = Array.new
        @outputs = Array.new
        @markings = Array.new

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

    def add_marking(count = 1)
        if count <= @capacity
            count.times do
                @markings << PetriNet::Marking.new
            end
            return true
        else
            raise "Tried to add more markings than possible"
        end
    end

    def set_marking(count)
        @markings = []
        add_marking count
    end

    alias_method :+, :add_marking

    def remove_marking(count = 1)
        if @markings.size >= count
            ret = @markings.pop(count)
            return ret unless ret.nil?
        else
            raise "Tried to remove more markings that possible" 
        end
    end
    alias_method :-, :remove_marking

    # GraphViz ID
    def gv_id
        "P#{@id}"
    end

    # Validate the setup of this place.
    def validate
        return false if @id.nil? or @id < 0
        return false if @name.nil? or @name.strip.length <= 0
        return false if @description.nil? or @description.strip.length <= 0
        return false if @capacity.nil? or @capacity < -1
        return true
    end

    def pretransitions
        raise "Not part of a net" if @net.nil?
        transitions = Array.new
        places << inputs.map{|i| @net.objects[i].source}
    end

    def posttransitions
        raise "Not part of a net" if @net.nil?
        outputs.map{|o| @net.objects[o].source}
    end

    # Stringify this place.
    def to_s
        "#{@id}: #{@name} (#{@capacity == nil ? -1 : 0})"
    end

    # GraphViz definition
    def to_gv
        "\t#{self.gv_id} [ label = \"#{@name} #{@markings.size}  \" ];\n"
    end
    def ==(object)
        return true if name == object.name && description = object.description
    end

end 
