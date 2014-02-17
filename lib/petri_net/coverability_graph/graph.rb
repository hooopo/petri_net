require 'graphviz'

class PetriNet::CoverabilityGraph < PetriNet::Base
    def initialize(net, options = Hash.new)
        @objects = Array.new
        @nodes = Hash.new
        @edges = Hash.new
        @name = net.name
        if options['unlimited'].nil? 
            @unlimited = true 
        else 
            @unlimited = options['unlimited']
        end
    end

    def add_node(node)
        double = false
        inf = false
        @nodes.each_value do |n|
            begin
                if node > @objects[n]
                    if @unlimited
                        double = n
                        break
                        #return @objects[n].id *-1
                    else
                        raise PetriNet::Graph::InfiniteReachabilityGraphError
                    end
                end
                if -Float::INFINITY == (node <=> @objects[n])
                    inf = true
                end
            rescue ArgumentError
                #just two different markings, completly ok
            end
        end
        # if there was a smaller marking
        return (@objects[double].id * -1) if double
        node_index = @objects.index node
        # if there already is a node with this marking
        return @objects[node_index].id * -1 unless node_index.nil?

        return -Float::INFINITY if inf

        if (node.validate && (!@nodes.include? node.name))
            @objects[node.id] = node
            @nodes[node.name] = node.id
            node.graph = self
            return node.id
        end
        return false
    end

end
