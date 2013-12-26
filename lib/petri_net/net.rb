class PetriNet::Net < PetriNet::Base
    # Human readable name
    attr_accessor :name
    # Storage filename
    attr_accessor :filename
    # Description
    attr_accessor :description
    # List of places
    attr_reader   :places
    # List of arcs
    attr_reader   :arcs
    # List of transitions
    attr_reader   :transitions
    # List of markings
    # !depricated!
    attr_reader   :markings

# should not be public available    attr_reader   :objects       # Array of all objects in net
#    attr_reader   :up_to_date    # is true if, and only if, the cached elements are calculated AND the net hasn't changed


    # Create new Petri Net definition.
    #
    # options may be 
    # * name    used as a human usable identifier (defaults to 'petri_net')
    # * filename (defaults to the name)
    # * description (defaults to 'Petri Net')
    #
    # Accepts a block and yields itself
    def initialize(options = {}, &block)
        @name = (options[:name] or 'petri_net')
        @filename = (options[:filename] or @name)
        @description = (options[:description] or 'Petri Net')
        @places = Hash.new
        @arcs = Hash.new
        @transitions = Hash.new
        @markings = Hash.new
        @objects = Array.new
        @up_to_date = false
        @w_up_to_date = false

        yield self unless block == nil
    end	

    # Adds an object to the Petri Net.
    # You can add
    # * PetriNet::Place
    # * PetriNet::Arc
    # * PetriNet::Transition
    # * Array of these
    #
    # The Objects are added by PetriNet::Net#add_place, PetriNet::Net#add_arc and PetriNet::Net#add_transition, refer to these to get more information on how they are added
    # raises an RuntimeError if a wring Type is given
    #
    # returns itself
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

    # Adds a place to the list of places.
    # Adds the place only if the place is valid and unique in the objects-list of the net
    #
    # This Method changes the structure of the PetriNet, you will have to recalculate all cached functions
    def add_place(place)
        if place.validate && !@places.include?(place.name) 
            @places[place.name] = place.id
            @objects[place.id] = place
            place.net = self
            return place.id
        end
        changed_structure
        return false
    end

    # Add an arc to the list of arcs.
    #
    # see PetriNet::Net#add_place
    def add_arc(arc)
        if (arc.validate self) && !@arcs.include?(arc.name)
            if arc.need_update? self
                arc.update self
            end
            @arcs[arc.name] = arc.id
            @objects[arc.id] = arc
            arc.net = self
            return arc.id
        end
        changed_structure
        return false
    end

    # Add a transition to the list of transitions.
    #
    # see PetriNet::Net#add_place
    def add_transition(transition)
        if transition.validate && !@transitions.include?(transition.name)
            @transitions[transition.name] = transition.id
            @objects[transition.id] = transition
            transition.net = self
            return transition.id
        end
        changed_structure
        return false
    end

    # Returns the place refered by the given name
    # or false if there is no place with this name
    def get_place(name)
        place = @objects[@places[name]]
        place.nil? ? false : place
    end

    # Returns the transition refered by the given name
    # or false if there is no transition with this name
    def get_transition(name)
        trans = @objects[@transitions[name]]
        trans.nil? ? false : trans
    end

    # returns the arc refered by the given name
    # or false if there is no arc with this name
    def get_arc(name)
        arc = @objects[@arcs[name]]
        arc.nil? ? false : arc
    end

    # Is this Petri Net pure?
    # A Petri Net is said to be pure if it has no self-loops.  
    def pure?
        raise "Not implemented yet"
    end

    # Is this Petri Net ordinary?
    # A Petri Net is said to be ordinary if all of its arc weights are 1's.
    def ordinary?
        raise "Not implemented yet"
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

    # Generate GraphViz dot string.
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

    # Merges two PetriNets
    # Places, transitions and arcs are equal if they have the same name and description, arcs need to have the same source and destination too). With this definition of equality the resultung net will have unique ojects.
    # ATTENTION conflicting capabilities and weights will be lost and the properies of the net you merge to will be used in future
    # #TODO add a parameter to affect this!
    def merge(net)
        return self if self.equal? net
        return false if net.class.to_s != "PetriNet::Net"
        self << net.get_objects
        self
    end

    def generate_reachability_graph(unlimited = true)
        raise "Not implemented yet" unless unlimited
        startmarkings = get_markings
        @graph = PetriNet::ReachabilityGraph.new(self)
        @graph.add_node current_node = PetriNet::ReachabilityGraph::Node.new(markings: get_markings)

        reachability_helper startmarkings, current_node

        set_markings startmarkings
        @graph 
    end
    def generate_weight_function
        @weight = Hash.new
        @arcs.each_value do |id|
            arc = @objects[id]
            @weight[[arc.source.id,arc.destination.id]] = arc.weight
        end
        @w_up_to_date = true
        @weight
    end

    def w0(x,y)
        generate_weight_function unless @w_up_to_date
        return @weight[[x,y]].nil? ? 0 : @weight[[x,y]]
    end

    def update
        generate_weight_function
        @up_to_date = true
    end
    
    # is true if, and only if, the cached elements are calculated AND the net hasn't changed
    def update?
        if @w_up_to_date && true #all up_to_date-caches!!!
            @up_to_date = true
            return @up_to_date
        end
        false
    end
    alias_method :up_to_date, :update?

    def get_markings
        @places.map{|key,pid| @objects[pid].markings.size}
    end

    def set_markings(markings)
        i = 0
        @places.each_value do |pid| 
            @objects[pid].set_marking markings[i]
            i = i+1
        end
        changed_state
    end

    def objects_size
        @objects.count{|o| !o.nil?}
    end

    def objects_include?(object)
        @objects.include?(object)
    end

    def get_object(id)
        @objects[id]
    end

    def get_objects
        @objects.clone
    end

    def objects_find_index(object)
        @objects.find_index object
    end

    private

    def changed_structure
        @w_up_to_date = false
        @up_to_date = false
    end

    def changed_state
        @up_to_date = false
    end

    def reachability_helper(markings, source)
        @transitions.each_value do |tid|
            if @objects[tid].fire
                current_node = PetriNet::ReachabilityGraph::Node.new(markings: get_markings)
                current_node_id = @graph.add_node current_node 
                @graph.add_edge PetriNet::ReachabilityGraph::Edge.new(source: source, destination: current_node) unless current_node_id < 0
                reachability_helper get_markings, current_node unless (current_node_id < 0)
            end
            set_markings markings
        end
    end
end
