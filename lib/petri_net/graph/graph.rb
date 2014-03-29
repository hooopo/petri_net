require 'graphviz'
require 'graphviz/theory'
require 'rgl/adjacency'
require 'rgl/dijkstra'
class PetriNet::InfiniteReachabilityGraphError < RuntimeError
end

class PetriNet::Graph < PetriNet::Base

    # The PetriNet this graph belongs to
    attr_reader :net
    # all nodes from this graph
    attr_reader :nodes
    # all edges of this graph
    attr_reader :edges

    def initialize(net, options = Hash.new)
        @net = net
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
        if node.validate && (!@objects.include? node)
            @objects[node.id] = node
            @nodes[node.name] = node.id
            node.graph = self
            return node.id
        end
        if @objects.include? node
            res = (@objects.index node) * -1
            return res 
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
        @objects[id]
    end

    def get_nodes
        res = Array.new
        @nodes.each_value do |n|
            res << @objects[n]
        end
        res
    end

    def infinite?
        @nodes.each_value do |node|
            return true if @objects[node].infinite?
        end
        false
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
        @gv = g
    end

    def generate_rgl
        g = RGL::DirectedAdjacencyGraph.new 
        @nodes.each_value do |node|
            g.add_vertex @objects[node].markings.to_s
        end
        @edges.each_value do |edge|
            g.add_edge @objects[edge].source.markings.to_s, @objects[edge].destination.markings.to_s
        end
        @rgl = g
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

    def get_rgl
        if @rgl.nil?
            generate_rgl
        end
        @rgl
    end

    def cycles
        get_rgl.cycles
    end

    def shortest_path(start, destination)
        g = get_rgl
        weights = lambda { |edge| 1 }
        g.dijkstra_shortest_path(weights, start.to_s, destination.to_s)
    end

    

end
