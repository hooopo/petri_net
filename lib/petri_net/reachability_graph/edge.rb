class PetriNet::ReachabilityGraph::Edge < PetriNet::Base
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
    
    # Creates an edge for PetriNet::ReachabilityGraph
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Edge#{@id}")
        @description = (options[:description] or "Edge #{@id}")
        @source = options[:source] 
        @destination = options[:destination]
        @label = (options[:label] or @name)
        @probability = options[:probability]
        @transition = (options[:transition] or "")

        yield self unless block.nil?
    end

    # Validates the data holded by this edge, this will be used while adding the edge to the graph
    def validate
        true
    end

    def to_gv
        "\t#{@source.gv_id} -> #{@destination.gv_id}#{probability_to_gv};\n"
    end

    def ==(object)
        return false unless object.class.to_s == "PetriNet::ReachabilityGraph::Edge"
        (@source == object.yource && @destination == oject.destination)
    end
    def to_s
        "#{@id}: #{@name} #{@source.id} -> #{@destination} )"
    end

    private
    def probability_to_gv
        if @probability 
            " [ label = \"#{@probability.to_s}\" ] "
        else
            ''
        end
    end

end
