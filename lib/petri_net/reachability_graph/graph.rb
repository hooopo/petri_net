require 'graphviz'

class PetriNet::ReachabilityGraph < PetriNet::Graph
    def initialize(net, options = Hash.new)
        options[:type] = "Reachability"
        super(net, options)
        self
    end

    def add_node(node)
        @nodes.each_value do |n|
            begin
                if @objects[n] < node
                    raise PetriNet::InfiniteReachabilityGraphError
                end
            rescue ArgumentError
                #Just an InfiniteNode
            end

        end
        super node
    end

    def add_node!(node)
        super node
    end

end
