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
        @name = (options[:name] or "Node#{@id}")
        @description = (options[:description] or "Node #{@id}")
        @inputs = Array.new
        @outputs = Array.new
        @label = (options[:label] or @name)
        @markings = options[:markings] 
        @start = (options[:start] or false)
        if @markings.nil?
            raise ArgumentError.new "Every Node needs markings"
        end
        if @markings.include? Float::INFINITY
            @omega_marked = true 
        else 
            @omega_marked = false
        end

        yield self unless block.nil?
    end

    # Add an omega-marking to a specified place
    def add_omega object 
        ret = Array.new
        if object.class.to_s == "PetriNet::CoverabilityGraph::Node"
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
        elsif object.class.to_s == "Array"
            object.each do |place|
                markings[place] = Float::INFINITY
                ret = object
            end
        elsif object.class.to_s == "Fixnum"
            markings[object] = Float::INFINITY
            ret = [object]
        elsif object.class.to_s == "PetriNet::ReachabilityGraph::Node"
            raise PetriNet::Graph::InfinityError("ReachabilityGraphs do not support omega-markings")
        end
        @omega_marked = true
        ret
    end

    def include_place(place)
        places = @graph.net.get_place_list
        included_places = Array.new
        i = 0
        @markings.each do |m|
            if m > 0
                included_places << places[i]
            end
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
        "\t#{self.gv_id} [ label = \"#{@markings}\" ];\n"
    end

    # Compare-operator, other Operators are available through comparable-mixin
    def <=>(object)
        return nil unless object.class.to_s == "PetriNet::ReachabilityGraph::Node"
        if @markings == object.markings
            return 0
        end

        counter = 0
        less = true
        self.markings.each do |marking|
            if marking <= object.markings[counter] && less
                less = true
            else 
                less = false
                break
            end
            counter += 1
        end
        if less
            return -1 
        end
        counter = 0
        more = true
        self.markings.each do |marking|
            if marking >= object.markings[counter] && more
                more = true
            else
                more = false
                break
            end
            counter += 1
        end
        if more
            return 1
        end
        return nil
    end

    def to_s
        "#{@id}: #{@name} (#{@markings})"
    end

end
