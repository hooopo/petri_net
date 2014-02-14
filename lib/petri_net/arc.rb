module PetriNet
    # Arc
    class Arc < PetriNet::Base
        # Unique ID
        attr_reader   :id
        # human readable name
        attr_accessor :name
        # Description
        attr_accessor :description
        # Arc weight
        attr_accessor :weight
        # Source-object
        attr_reader   :source
        # Source-object
        attr_reader   :destination
        # The net this arc belongs to
        attr_writer   :net

        # Creates an arc. 
        # An arc is an directed edge between a place and a transition (or visa versa) and can have a weight which indicates how many token it comsumes or produces from/to the place
        def initialize(options = {}, &block)
            @id = next_object_id
            @name = (options[:name] or "Arc#{@id}")
            @description = (options[:description] or "Arc #{@id}")
            @weight = (options[:weight] or 1)
            self.add_source(options[:source]) unless options[:source].nil?
            self.add_destination(options[:destination]) unless options[:destination].nil?

            yield self unless block == nil
        end	

        # Add a source object to this arc.  Validation of the source object will be performed
        # before the object is added to the arc and an exception will be raised.
        def add_source(object)
            if object.class.to_s == "String"
                object = (@net.get_place object or @net.get_transition object)
            end
            if validate_source_destination(object)
                @source = object
                object.add_output(self)
            else
                raise "Invalid arc source object: #{object.class}"
            end
        end

        # Add a destination object
        def add_destination(object)
            if object.class.to_s == "String"
                object = (@net.get_place object or @net.get_transition object)
            end
            if validate_source_destination(object)
                @destination = object
                object.add_input(self)
            else
                raise "Invalid arc destination object: #{object.class}"
            end
        end

        # A Petri Net is said to be ordinary if all of its arc weights are 1's.
        # Is this arc ordinary?
        def ordinary?
            @weight == 1
        end

        # Validate this arc.
        def validate(net)
            return false if @id < 1
            return false if @name.nil? or @name.length <= 0
            return false if @weight < 1
            return false if @source.nil? or @destination.nil?
            return false if @source == @destination
            return false if @source.class == @destination.class

            if @source.class.to_s == "PetriNet::Place"
                return net.objects_include? @source 
            elsif @source.class.to_s == "PetriNet::Transition"
                return net.objects_include? @source
            else
                return false
            end
            if @destination.class.to_s == "PetriNet::Place"
                return net.objects.include? @destination
            elsif @destination.class.to_s == "PetriNet::Transition"
                return net.objects.include? @destination
            else
                return false
            end
            return true
        end

        # Stringify this arc.
        def to_s
            "#{@id}: #{@name} (#{@weight}) #{@source.id} -> #{@destination.id}"
        end

        # Gives the GraphViz-representation of this arc as string of a GV-Edge
        def to_gv
            "\t#{@source.gv_id} -> #{@destination.gv_id} [ label = \"#{@name}\", headlabel = \"#{@weight}\" ];\n"
        end

        # Checks if the information in this arc are still correct.
        # The information can get wrong if you merge two nets together.
        def need_update? net
            if net.get_object(@source.id).nil? || (@source.name != net.get_object(@source.id).name)
                return true
            end
            if  net.get_object(@destination.id).nil? || (@destination.name != net.get_object(@destination.id).name)
                return true
            end
        end

        # Updates the information in this arc
        # Should only be necessary if PetriNet::Arc#need_update? is true
        # affects source and destination
        def update net
            @source.id = net.objects_find_index @source
            @destination.id = net.objects_find_index @destination
        end

        private

        # Validate source or destination object
        def validate_source_destination(object)
            return false if object.nil?

            return object.class.to_s == "PetriNet::Place" || object.class.to_s == "PetriNet::Transition"

            #return if @source.nil? or @source.class.to_s == object.class.to_s
            #return if @destination.nil? or @destination.class.to_s == object.class.to_s
            return true
        end
    end 
end
