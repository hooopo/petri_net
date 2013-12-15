class PetriNet::Net < PetriNet::Base
  attr_accessor :name          # Human readable name	
  attr_accessor :filename      # Storage filename
  attr_accessor :description   # Description
  attr_reader   :places        # List of places
  attr_reader   :arcs          # List of arcs
  attr_reader   :transitions   # List of transitions
  attr_reader   :markings      # List of markings
  attr_reader   :objects       # Array of all objects in net

  # Create new Petri Net definition.	
  def initialize(options = {}, &block)
    @name = (options[:name] or 'petri_net')
    @filename = options[:filename]
    @description = (options[:description] or 'Petri Net')
    @places = Hash.new
    @arcs = Hash.new
    @transitions = Hash.new
    @markings = Hash.new
    @objects = Array.new
    
    yield self unless block == nil
  end	

  # Add an object to the Petri Net.
  def <<(object)
    return if object.nil?  #TODO WORKAROUND There should never be a nil here, even while merging.
    case object.class.to_s
    when "Array"
        object.each {|o| self << o}
    when "PetriNet::Place" 
        add_place(object)
    when "PetriNet::Arc" 
        add_arc(object)
    when "PetriNet::Transition" 
        add_transition(object)
    else 
        raise "(PetriNet) Unknown object #{object.class}."
    end
    self
  end
  alias_method :add_object, :<<

  # Add a place to the list of places.
  def add_place(place)
    if place.validate && !@places.include?(place.name) 
      @places[place.name] = place.id
      @objects[place.id] = place
      return place.id
    end
    return false
  end

  # Add an arc to the list of arcs.
  def add_arc(arc)
    if (arc.validate self) && !@arcs.include?(arc.name)
      if arc.need_update? self
        arc.update self
      end
      @arcs[arc.name] = arc.id
      @objects[arc.id] = arc
      return arc.id
    end
    return false
  end

  # Add a transition to the list of transitions.
  def add_transition(transition)
    if transition.validate && !@transitions.include?(transition.name)
      @transitions[transition.name] = transition.id
      @objects[transition.id] = transition
      return transition.id
    end
    return false
  end

  # A Petri Net is said to be pure if it has no self-loops.  
  # Is this Petri Net pure?
  def pure?
  end

  # A Petri Net is said to be ordinary if all of its arc weights are 1's.
  # Is this Petri Net ordinary?
  def ordinary?
  end

  # Stringify this Petri Net.
  def to_s
    str = "Petri Net [#{@name}]\n"
    str += "----------------------------\n"
    str += "Description: #{@description}\n"
    str += "Filename: #{@filename}\n"
    str += "\n"

    str += "Places\n"
    str += "----------------------------\n"
    @places.each_value {|p| str += @objects[p].to_s + "\n" }
    str += "\n"

    str += "Transitions\n"
    str += "----------------------------\n"
    @transitions.each_value {|t| str += @objects[t].to_s + "\n" }
    str += "\n"

    str += "Arcs\n"
    str += "----------------------------\n"
    @arcs.each_value {|a| str += @objects[a].to_s + "\n"}
    str += "\n"

    return str
  end

  # Generate GraphViz dot file.
  def to_gv
    # General graph options
    str = "digraph #{@name} {\n"
    str += "\t// General graph options\n"
    str += "\trankdir = LR;\n"
    str += "\tsize = \"10.5,7.5\";\n"
    str += "\tnode [ style = filled, fillcolor = white, fontsize = 8.0 ]\n"
    str += "\tedge [ arrowhead = vee, arrowsize = 0.5, fontsize = 8.0 ]\n"
    str += "\n"

    str += "\t// Places\n"
    str += "\tnode [ shape = circle ];\n"
    @places.each_value {|id| str += @objects[id].to_gv }
    str += "\n"

    str += "\t// Transitions\n"
    str += "\tnode [ shape = box, fillcolor = grey90 ];\n"
    @transitions.each_value {|id| str += @objects[id].to_gv }
    str += "\n"

    str += "\t// Arcs\n"
    @arcs.each_value {|id| str += @objects[id].to_gv }
    str += "}\n"    # Graph closure

    return str
  end

  def merge(net)
      return self if self.equal? net
      return false if net.class.to_s != "PetriNet::Net"
      self << net.objects
      self
  end
end
