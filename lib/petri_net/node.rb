class PetriNet::ReachabilityGraph::Node < PetriNet::Base
    attr_reader :name, :id
    attr_accessor :graph
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Node#{@id}")
        @description = (options[:description] or "Node #{@id}")
        @inputs = Array.new
        @outputs = Array.new
        @label = (options[:label] or @name)
        @markings = options[:markings] 

        yield self unless block.nil?
    end

    def validate
        true
    end

end
