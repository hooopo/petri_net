class PetriNet::ReachabilityGraph::Node < PetriNet::Base
    include Comparable

    # human readable name
    attr_reader :name
    # unique ID
    attr_reader :id 
    # Makking this node represents
    attr_reader :markings
    # The graph this node belongs to
    attr_accessor :graph
    # Omega-marked node (unlimited Petrinet -> coverabilitygraph)
    attr_reader :omega_marked
    # Incoming edges
    attr_reader :inputs
    # Outgoing edges
    attr_reader :outputs
    # Label of the node
    attr_reader :label
    # True if this is the start-marking
    attr_reader :start

    def initialize(options = {}, &block)
        @id = next_object_id
        @name = (options[:name] or "Node#{@id}")
        @description = (options[:description] or "Node #{@id}")
        @inputs = Array.new
        @outputs = Array.new
        @label = (options[:label] or @name)
        @markings = options[:markings] 
        @start = (options[:start] or false)
        if @markings.nil?
            raise ArgumentError.new "Every Node needs markings"
        end
        if @markings.include? Float::INFINITY
            @omega_marked = true 
        else 
            @omega_marked = false
        end

        yield self unless block.nil?
    end

    # Add an omega-marking to a specified place
    def add_omega object 
        if object.class.to_s == "PetriNet::ReachabilityGraph::Node"
            if self < object
                counter = 0
                object.markings.each do |marking|
                    if @markings[counter] < marking 
                        @markings[counter] = Float::INFINITY 
                    end
                    counter += 1
                end
            else
                return false
            end
        elsif object.class.to_s == "Array"
            object.each do |place|
                markings[place] = Float::INFINITY
            end
        elsif object.class.to_s == "Fixnum"
            markings[object] = Float::INFINITY
        end
        @omega_marked = true
    end

    def validate
        true
    end

    def gv_id
        "N#{@id}"
    end

    def to_gv
        "\t#{self.gv_id} [ label = \"#{@markings}\" ];\n"
    end

    # Compare-operator, other Operators are available through comparable-mixin
    def <=>(object)
        return nil unless object.class.to_s == "PetriNet::ReachabilityGraph::Node"
        if @markings == object.markings
            return 0
        end

        counter = 0
        less = true
        self.markings.each do |marking|
            if marking <= object.markings[counter] && less
                less = true
            else 
                less = false
                break
            end
            counter += 1
        end
        if less
            return -1 
        end
        counter = 0
        more = true
        self.markings.each do |marking|
            if marking >= object.markings[counter] && more
                more = true
            else
                more = false
                break
            end
            counter += 1
        end
        if more
            return 1
        end
        return nil
    end

    def to_s
        "#{@id}: #{@name} (#{@markings})"
    end

end
