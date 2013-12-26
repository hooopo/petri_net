class PetriNet::ReachabilityGraph::Edge < PetriNet::Base
    # Human readable name
    attr_reader :name
    # Unique ID
    attr_reader :id
    # Graph this edge belongs to
    attr_accessor :graph
    
    # Creates an edge for PetriNet::ReachabilityGraph
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Edge#{@id}")
        @description = (options[:description] or "Edge #{@id}")
        @source = options[:source] 
        @destination = options[:destination]
        @label = (options[:label] or @name)

        yield self unless block.nil?
    end

    # Validates the data holded by this edge, this will be used while adding the edge to the graph
    def validate
        true
    end

    def to_gv
        "\t#{@source.gv_id} -> #{@destination.gv_id};\n"
    end

    def ==(object)
        return false unless object.class.to_s == "PetriNet::ReachabilityGraph::Edge"
        (@source == object.yource && @destination == oject.destination)
    end
    def to_s
        "#{@id}: #{@name} #{@source.id} -> #{@destination} )"
    end

end
