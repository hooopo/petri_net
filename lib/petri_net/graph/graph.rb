# frozen_string_literal: true

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

  def initialize(net, options = {})
    @net = net
    @objects = []
    @nodes = {}
    @edges = {}
    @name = net.name
    @type = 'Reachability'
    @unlimited = if options['unlimited'].nil?
                   true
                 else
                   options['unlimited']
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
    false
  end
  alias add_node! add_node

  def add_edge(edge)
    if edge.validate && (!@edges.include? edge.name)
      @objects[edge.id] = edge
      @edges[edge.name] = edge.id
      edge.graph = self
      edge.source.outputs << edge.id
      edge.destination.inputs << edge.id
      return edge.id
    end
    false
  end

  def get_edge(source, dest)
    res = nil
    @edges.each_value do |edge|
      if @objects[edge].source == source && @objects[edge].destination == dest
        res = @objects[edge]
      end
    end
    res
  end

  # Add an object to the Graph.
  def <<(object)
    case object.class.to_s
    when 'Array'
      object.each { |o| self << o }
    when 'PetriNet::ReachabilityGraph::Edge'
      add_edge(object)
    when 'PetriNet::ReachabilityGraph::Node'
      add_node(object)
    else
      raise "(PetriNet::ReachabilityGraph) Unknown object #{object.class}."
    end
    self
  end
  alias add_object <<

  def get_node(node)
    return @objects[node] if node.class.to_s == 'Fixnum'
    if node.class.to_s == 'Array'
      return @objects.select { |o| o.class.to_s == 'PetriNet::ReachabilityGraph::Node' && o.markings == node }.first
    end
  end

  def get_object(id)
    @objects[id]
  end

  def get_nodes
    res = []
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
    filename = "#{@name}_graph.png" if filename.empty?
    g.output(png: filename) if output == 'png'
    g.output
  end

  def generate_gv(named = true)
    g = GraphViz.new(:G, type: :digraph)

    @nodes.each_value do |node|
      label = if named
                (@net.get_place_from_marking @objects[node].markings).to_s
              else
                @objects[node].markings.to_s
              end
      gv_node = g.add_nodes(label)
      gv_node.set do |n|
        n.label = '*' + label + '*' if @objects[node].start
      end
    end
    @edges.each_value do |edge|
      label1 = if named
                 (@net.get_place_from_marking @objects[edge].source.markings).to_s
               else
                 @objects[edge].source.markings.to_s
               end

      label2 = if named
                 (@net.get_place_from_marking @objects[edge].destination.markings).to_s
               else
                 @objects[edge].destination.markings.to_s
               end
      gv_edge = g.add_edges(label1, label2)
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
    @nodes.each_value { |p| str += @objects[p].to_s + "\n" }
    str += "\n"

    str += "Edges\n"
    str += "----------------------------\n"
    @edges.each_value { |t| str += @objects[t].to_s + "\n" }
    str += "\n"

    str
  end

  def get_rgl
    generate_rgl if @rgl.nil?
    @rgl
  end

  def cycles
    get_rgl.cycles
  end

  def shortest_path(start, destination)
    g = get_rgl
    weights = ->(_edge) { 1 }
    g.dijkstra_shortest_path(weights, start.to_s, destination.to_s)
  end

  def path_probability(path)
    sanitize_probabilities
    prob = 1
    counter = 0
    path.each do |node|
      edge = get_edge(path[counter + 1], node)
      prob *= edge.probability unless edge.nil? # last node has no pre-edge
      counter = counter += 1
    end
    prob
  end

  def node_probability(start, node)
    paths = get_paths_without_loops(start, node)
    prob = 0
    paths.each do |path|
      prob += (path_probability path)
    end
    prob
  end

  def best_path(start, node)
    paths = get_paths_without_loops(start, node)
    prob = 0
    res_path = nil
    paths.each do |path|
      if (path_probability path) >= prob
        prob = (path_probability path)
        res_path = path
      end
    end
    [res_path, prob]
  end

  def worst_path(start, node)
    paths = get_paths_without_loops(start, node)
    prob = 1
    res_path = nil
    paths.each do |path|
      if (path_probability path) <= prob
        prob = (path_probability path)
        res_path = path
      end
    end
    [res_path, prob]
  end

  def get_most_relative_influence_on_path(start, node, factor = 0.5)
    prob_counter = 0
    prob_diff = []
    paths = get_paths_without_loops(start, node)
    paths.each do |path|
      counter = 0
      path.each do |curr_node|
        prob_before = node_probability start, node
        next if node == path[-1]

        edge = get_edge(path[counter + 1], curr_node)
        save = edge.probability unless edge.nil?
        edge.probability += (1 - edge.probability) * factor unless edge.nil?
        prob_after = node_probability start, node unless edge.nil?
        edge.probability = save unless edge.nil?
        prob_diff[prob_counter] = [prob_after - prob_before, [curr_node, path[counter + 1]]] unless edge.nil?
        prob_counter += 1 unless edge.nil?
        counter += 1
      end
    end
    prob_diff.max { |x, y| x[0] <=> y[0] }
  end

  def get_most_absolute_influence_on_path(start, node, sum = 0.01)
    prob_counter = 0
    prob_diff = []
    paths = get_paths_without_loops(start, node)
    paths.each do |path|
      counter = 0
      path.each do |curr_node|
        prob_before = node_probability start, node
        next if node == path[-1]

        edge = get_edge(path[counter + 1], curr_node)
        save = edge.probability unless edge.nil?
        edge.probability = edge.probability + sum unless edge.nil?
        edge.probability = 1 if !edge.nil? && edge.probability > 1
        prob_after = node_probability start, node unless edge.nil?
        edge.probability = save unless edge.nil?
        prob_diff[prob_counter] = [prob_after - prob_before, [curr_node, path[counter + 1]]] unless edge.nil?
        prob_counter += 1 unless edge.nil?
        counter += 1
      end
    end
    prob_diff.max { |x, y| x[0] <=> y[0] }
  end

  def get_paths_without_loops(start, goal)
    get_paths_without_loops_helper(get_node(start), get_node(goal))
  end

  def sanitize_probabilities
    @nodes.each_value do |node|
      prob = 1.0
      @objects[node].outputs.each do |edge|
        prob += @objects[edge].probability unless @objects[edge].probability.nil?
      end
      @objects[node].outputs.each do |edge|
        @objects[edge].probability = prob / @objects[node].outputs.size if @objects[edge].probability.nil?
      end
    end
  end

  private

  def get_paths_without_loops_helper(start, goal, reverse_paths = [], reverse_path = [])
    if goal == start
      reverse_path << goal
      reverse_paths << reverse_path
      return nil
    end
    return nil if reverse_path.include? goal

    path = []
    goal.inputs.each do |input|
      get_paths_without_loops_helper(start, @objects[input].source, reverse_paths, reverse_path.clone << goal)
    end
    reverse_paths
  end
end
