require 'graphviz'

class PetriNet::InfiniteReachabilityGraphError < RuntimeError
end

class PetriNet::Graph < PetriNet::Base
    def initialize(net, options = Hash.new)
        @objects = Array.new
        @nodes = Hash.new
        @edges = Hash.new
        @name = net.name
        @type = "Reachability"
        if options['unlimited'].nil? 
            @unlimited = true 
        else 
            @unlimited = options['unlimited']
        end
    end

    def add_node(node)
        if node.validate
            @objects[node.id] = node
            @nodes[node.name] = node.id
            node.graph = self
            return node.id
        end
        return false
    end
    alias_method :add_node!, :add_node

    def add_edge(edge)
        if (edge.validate && (!@edges.include? edge.name))
            @objects[edge.id] = edge
            @edges[edge.name] = edge.id
            edge.graph = self
            return edge.id
        end
        return false
    end

    # Add an object to the Petri Net.
    def <<(object)
        case object.class.to_s
        when "Array"
            object.each {|o| self << o}
        when "PetriNet::ReachabilityGraph::Edge"
            add_edge(object)
        when "PetriNet::ReachabilityGraph::Node"
            add_node(object)
        else
            raise "(PetriNet::ReachabilityGraph) Unknown object #{object.class}."
        end
        self
    end
    alias_method :add_object, :<<

    def get_node(id)
        return @objects[id]
    end

    def to_gv(output = 'png', filename = '')
        g = generate_gv
        if filename.empty?
            filename = "#{@name}_graph.png"
        end
        g.output( :png => filename ) if output == 'png'
        g.output
    end

    def generate_gv
        g = GraphViz.new( :G, :type => :digraph )

        @nodes.each_value do |node|
            gv_node = g.add_nodes( @objects[node].markings.to_s )
            gv_node.set do |n|
                n.label = '*' + @objects[node].markings.to_s + '*' if @objects[node].start 
            end
        end
        @edges.each_value do |edge|
            gv_edge = g.add_edges( @objects[edge].source.markings.to_s, @objects[edge].destination.markings.to_s )
            gv_edge.set do |e|
                e.label = @objects[edge].transition
            end
        end
        g
    end

    def to_s
        str = "#{@type} Graph [#{@name}]\n"
        str += "----------------------------\n"
        str += "Description: #{@description}\n"
        str += "Filename: #{@filename}\n"
        str += "\n"

        str += "Nodes\n"
        str += "----------------------------\n"
        @nodes.each_value {|p| str += @objects[p].to_s + "\n" }
        str += "\n"

        str += "Edges\n"
        str += "----------------------------\n"
        @edges.each_value {|t| str += @objects[t].to_s + "\n" }
        str += "\n"

        return str
    end

end
