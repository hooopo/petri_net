class PetriNet::ReachabilityGraph::Edge < PetriNet::Base
    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Edge#{@id}")
        @description = (options[:description] or "Edge #{@id}")
        @source = Array.new
        @destination = Array.new
        @label = (options[:label] or @name

        yield self unless block.nil?
    end

end
