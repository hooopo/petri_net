class PetriNet::ReachabilityGraph::Node < PetriNet::Base
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Node#{@id}")
        @description = (options[:description] or "Node #{@id}")
        @inputs = Array.new
        @outputs = Array.new
        @label = (options[:label] or @name
        @marking = Array.new

        yield self unless block.nil?
    end

end
