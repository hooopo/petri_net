class PetriNet::ReachabilityGraph::Edge < PetriNet::Base
    attr_reader :name, :id
    attr_accessor :graph
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Edge#{@id}")
        @description = (options[:description] or "Edge #{@id}")
        @source = options[:source] 
        @destination = options[:destination]
        @label = (options[:label] or @name)

        yield self unless block.nil?
    end

    def validate
        true
    end

    def to_gv
        "\t#{@source.gv_id} -> #{@destination.gv_id};\n"
    end
end
