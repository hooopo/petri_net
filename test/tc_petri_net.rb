require 'rubygems'
require 'logger'
require 'test/unit'
require "#{File.dirname(__FILE__)}/../lib/petri_net" 


class TestPetriNet < Test::Unit::TestCase
    def setup
        @net = PetriNet::Net.new(:name => 'Water', :description => 'Creation of water from base elements.')	
        @net.logger = Logger.new(STDOUT)
    end

    def fill_net
        @net << PetriNet::Place.new(:name => "testplace")
        @net << PetriNet::Transition.new(:name => "testtrans")
        arc = PetriNet::Arc.new do |a|
            a.name = 'testarc'
            a.weight = 2
            a.add_source(@net.get_place 'testplace')
            a.add_destination(@net.get_transition 'testtrans')
        end
        @net << arc 
    end

    def complex_net
        @net << PetriNet::Place.new(:name => "P1")
        @net << PetriNet::Place.new(:name => "P2")
        @net << PetriNet::Place.new(:name => "C1")
        @net << PetriNet::Place.new(:name => "C2")
        @net << PetriNet::Place.new(:name => "buffer")
        @net << PetriNet::Transition.new(:name => "produce")
        @net << PetriNet::Transition.new(:name => "consume")
        @net << PetriNet::Transition.new(:name => "put")
        @net << PetriNet::Transition.new(:name => "take")
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_place 'P1')
            a.add_destination(@net.get_transition 'produce')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_transition 'produce')
            a.add_destination(@net.get_place 'P2')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_place 'P2')
            a.add_destination(@net.get_transition 'put')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_transition 'put')
            a.add_destination(@net.get_place 'P1')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_transition 'put')
            a.add_destination(@net.get_place 'buffer')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_place 'buffer')
            a.add_destination(@net.get_transition 'take')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_transition 'take')
            a.add_destination(@net.get_place 'C1')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_place 'C1')
            a.add_destination(@net.get_transition 'consume')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_transition 'consume')
            a.add_destination(@net.get_place 'C2')
        end
        @net <<  PetriNet::Arc.new do |a|
            a.add_source(@net.get_place 'C2')
            a.add_destination(@net.get_transition 'take')
        end

        @net.get_place('P1').add_marking
        @net.get_place('buffer').add_marking
        @net.get_place('C2').add_marking
    end

    def teardown
        @net.reset
    end

    def test_create_net
        net = PetriNet::Net.new(:name => 'Water', :description => 'Creation of water from base elements.')
        assert_not_nil net
        assert_equal "Water", net.name, "Name was not properly set"
        assert_equal "Creation of water from base elements.", net.description,  "Description was not properly set"
        assert_equal 0, net.objects_size, "There should not be any Objects in this fresh and empty net"
        assert_empty net.arcs, "There should not be any Objects in this fresh and empty net"
        assert_empty net.transitions, "There should not be any Objects in this fresh and empty net"
        assert_empty net.places, "There should not be any Objects in this fresh and empty net"
        assert !net.up_to_date, "There are no cached functions calculated"
        net.update
        assert net.up_to_date, "Now we calculated all cached functions without changing anything afterwards, so this schould be up to date"
        assert_empty net.get_markings, "No Places should mean no markings..."
    end

    def test_complex_net
        complex_net
        assert_equal "Petri Net [Water]\n----------------------------\nDescription: Creation of water from base elements.\nFilename: Water\n\nPlaces\n----------------------------\n1: P1 (0) *\n2: P2 (0) \n3: C1 (0) \n4: C2 (0) *\n5: buffer (0) *\n\nTransitions\n----------------------------\n6: produce\n7: consume\n8: put\n9: take\n\nArcs\n----------------------------\n10: Arc10 (1) 1 -> 6\n11: Arc11 (1) 6 -> 2\n12: Arc12 (1) 2 -> 8\n13: Arc13 (1) 8 -> 1\n14: Arc14 (1) 8 -> 5\n15: Arc15 (1) 5 -> 9\n16: Arc16 (1) 9 -> 3\n17: Arc17 (1) 3 -> 7\n18: Arc18 (1) 7 -> 4\n19: Arc19 (1) 4 -> 9\n\n", @net.to_s
        assert_equal "digraph Water {\n\t// General graph options\n\trankdir = LR;\n\tsize = \"10.5,7.5\";\n\tnode [ style = filled, fillcolor = white, fontsize = 8.0 ]\n\tedge [ arrowhead = vee, arrowsize = 0.5, fontsize = 8.0 ]\n\n\t// Places\n\tnode [ shape = circle ];\n\tP1 [ label = \"P1 1  \" ];\n\tP2 [ label = \"P2 0  \" ];\n\tP3 [ label = \"C1 0  \" ];\n\tP4 [ label = \"C2 1  \" ];\n\tP5 [ label = \"buffer 1  \" ];\n\n\t// Transitions\n\tnode [ shape = box, fillcolor = grey90 ];\n\tT6 [ label = \"produce\" ];\n\tT7 [ label = \"consume\" ];\n\tT8 [ label = \"put\" ];\n\tT9 [ label = \"take\" ];\n\n\t// Arcs\n\tP1 -> T6 [ label = \"Arc10\", headlabel = \"1\" ];\n\tT6 -> P2 [ label = \"Arc11\", headlabel = \"1\" ];\n\tP2 -> T8 [ label = \"Arc12\", headlabel = \"1\" ];\n\tT8 -> P1 [ label = \"Arc13\", headlabel = \"1\" ];\n\tT8 -> P5 [ label = \"Arc14\", headlabel = \"1\" ];\n\tP5 -> T9 [ label = \"Arc15\", headlabel = \"1\" ];\n\tT9 -> P3 [ label = \"Arc16\", headlabel = \"1\" ];\n\tP3 -> T7 [ label = \"Arc17\", headlabel = \"1\" ];\n\tT7 -> P4 [ label = \"Arc18\", headlabel = \"1\" ];\n\tP4 -> T9 [ label = \"Arc19\", headlabel = \"1\" ];\n}\n", @net.to_gv 
        @net.to_gv_new
        #assert_equal "digraph Water {\n\t// General graph options\n\trankdir = LR;\n\tsize = \"10.5,7.5\";\n\tnode [ style = filled, fillcolor = white, fontsize = 8.0 ]\n\tedge [ arrowhead = vee, arrowsize = 0.5, fontsize = 8.0 ]\n\n\t// Nodes\n\tnode [ shape = circle ];\n\tN20 [ label = \"[1, 0, 0, 1, Infinity]\" ];\n\tN21 [ label = \"[0, 1, 0, 1, 1]\" ];\n\tN24 [ label = \"[0, 1, 1, 0, 0]\" ];\n\tN26 [ label = \"[0, 1, 0, 1, Infinity]\" ];\n\tN28 [ label = \"[1, 0, 0, 1, 1]\" ];\n\tN31 [ label = \"[1, 0, 1, 0, Infinity]\" ];\n\tN34 [ label = \"[1, 0, 0, 1, Infinity]\" ];\n\tN36 [ label = \"[0, 1, 0, 1, 0]\" ];\n\tN40 [ label = \"[1, 0, 1, 0, 0]\" ];\n\tN43 [ label = \"[1, 0, 0, 1, 0]\" ];\n\n\t// Edges\n\tN20 -> N21;\n\tN21 -> N24;\n\tN24 -> N26;\n\tN26 -> N28;\n\tN28 -> N31;\n\tN31 -> N34;\n\tN34 -> N36;\n\tN20 -> N40;\n\tN40 -> N43;\n}\n", @net.generate_reachability_graph.to_gv

        #@net.reachability_graph.to_gv_new
    end

    def test_add_place
        # Create the place
        place = PetriNet::Place.new(:name => 'Hydrogen')
        assert_not_nil place
        assert place.validate

        # Add the place
        id = @net.add_place(place)
        assert_equal 1, @net.objects_size
        assert_equal id, @net.places["Hydrogen"]
        assert_equal place, @net.get_place("Hydrogen")

        place.add_marking
        assert_equal 1, place.markings.size
        place.add_marking
        assert_equal 2, place.markings.size
        place.remove_marking
        assert_equal 1, place.markings.size
        assert_raise( RuntimeError ){ place.remove_marking(4) }


    end

    def test_add_transition
        # create the transition
        transition = PetriNet::Transition.new(:name => 'Join', :description => 'great testing transition')
        assert_not_nil transition
        assert transition.validate

        #Add the transition
        id = @net.add_transition(transition)
        assert_equal 1, @net.objects_size
        assert_equal @net.transitions['Join'], id
        assert_equal @net.get_transition('Join'), transition 
    end

    def test_add_object()
        assert_equal @net, @net << PetriNet::Place.new(:name => "testplace")
        assert_equal 1, @net.places.size, "Added only one place, this means there should only be one place"
        assert_equal 1, @net.objects_size, "Added only one place, this means there should only be one object"
        @net << PetriNet::Transition.new(:name => "testtrans")
        assert_equal 1, @net.transitions.size, "Added only one transition, this means there should only be one transition"
        assert_equal 2, @net.objects_size, "Added one transition to the place, this means there should be exactly two objects"
        arc = PetriNet::Arc.new do |a|
            a.name = 'testarc'
            a.weight = 2
            a.add_source(@net.get_place 'testplace')
            a.add_destination(@net.get_transition 'testtrans')
        end
        @net << arc 
        assert_equal 1, @net.arcs.size, "Addes only one arc, this means there should only be one arc"
        assert_equal 3, @net.objects_size, "Added an arc, so there should be exactly three objects now"
        assert_raise(RuntimeError, "You can't add a Hash, so this should raise an Error"){@net << Hash.new}#
        array = [PetriNet::Place.new, PetriNet::Transition.new, PetriNet::Transition.new]
        assert_equal @net, @net << array, "Adding an array should result in the same as adding is one by one"
        assert_equal 2, @net.places.size, "Adding an array should result in the same as adding is one by one"
        assert_equal 3, @net.transitions.size, "Adding an array should result in the same as adding is one by one"
        assert_equal 6, @net.objects_size, "Adding an array should result in the same as adding is one by one"
    end

    def test_get_place
        @net << place = PetriNet::Place.new(:name => 'Test')
        assert_equal place, @net.get_place('Test'), "should be the same as the given place"
    end

    def test_get_transition
        @net << transition = PetriNet::Transition.new(:name => 'Test')
        assert_equal transition, @net.get_transition('Test'), "should be the same transition als the given one"
    end

    def test_add_arc
        @net.add_object PetriNet::Transition.new(:name => 'Join', :description => 'great testing transition')
        @net.add_object PetriNet::Place.new(:name => 'Hydrogen')
        arc = PetriNet::Arc.new do |a|
            a.name = 'Hydrogen.Join'
            a.weight = 2
            a.add_source(@net.get_place 'Hydrogen')
            a.add_destination(@net.get_transition 'Join')
        end
        assert_not_nil arc
        assert arc.validate(@net), "the created arc is not valid"

        #add the arc
        id = @net.add_arc arc
        assert @net.objects_size > 1
        assert_equal @net.arcs['Hydrogen.Join'], id
        assert_equal @net.get_arc('Hydrogen.Join'), arc

        #should not be here :-(
        transition = @net.get_transition 'Join'
        assert !transition.activated?, "Transition should not be activated as there are no markings" 

        @net.add_object PetriNet::Place.new(:name => 'Oxygen')
        arc = PetriNet::Arc.new do |a|
            a.name = 'Join.Oxygen'
            a.weight = 1
            a.add_source(@net.get_transition 'Join')
            a.add_destination(@net.get_place 'Oxygen')
        end
        @net << arc
        @net.get_place('Hydrogen').add_marking(2)
        assert transition.activated?, "Transition should be activated now"

#puts        @net.generate_reachability_graph.to_gv


#puts 
#        puts @net.get_markings
#     puts    
#        transition.fire
#        assert_equal @net.objects[@net.places['Hydrogen']].markings.size, 0, "After firing the transituon, there should be no marking left in this place"
#
#        assert_equal 0, @net.w0(4,3), "There is no arc with this IDs, so there should be 0"
#        assert_equal 2, @net.w0(@net.places['Hydrogen'], @net.transitions['Join']), "There should be an arc with weight 2"
#        assert_equal 0, @net.w0(@net.transitions['Join'], @net.places['Hydrogen']), "Wrong direction"
#
#        puts @net.get_markings
#puts
    end


    def test_merge
        fill_net
        net2 = PetriNet::Net.new(:name => 'Water2', :description => '    Creation of water from base elements version2.')
        net2 << PetriNet::Place.new(:name => "testplace2")
        net2 << PetriNet::Transition.new(:name => "testtrans")
        arc = PetriNet::Arc.new do |a|
            a.name = 'testarc'
            a.weight = 2
            a.add_source(net2.get_place 'testplace2')
            a.add_destination(net2.get_transition 'testtrans')
        end
        net2 << arc
        assert_equal "Petri Net [Water]\n----------------------------\nDescription: Creation of water from base elements.\nFilename: Water\n\nPlaces\n----------------------------\n1: testplace (0) \n4: testplace2 (0) \n\nTransitions\n----------------------------\n2: testtrans\n\nArcs\n----------------------------\n3: testarc (2) 1 -> 2\n\n", @net.merge(net2).to_s, "Merge failed, this is only a basic test"
    end

    def test_generate_reachability_graph
assert_equal "Reachability Graph [Water]
----------------------------
Description: 
Filename: 

Nodes
----------------------------
1: Node1 ([])

Edges
----------------------------

", @net.generate_reachability_graph().to_s, "Simple Reachability Graph with only one reachable state"
    end

    def test_w0
        fill_net
        assert_equal 2, @net.w0(1,2), "The weight of the arc between 1 aud 2 is 2"
        assert_equal 0, @net.w0(2,1), "The other direction should be 0 because arcs are directed"
        assert_equal 0, @net.w0(3,6), "If there is no arc, there should not be a weight, so 0"
    end

    def test_update
        fill_net
        assert !@net.up_to_date, "At first the net should be not up to date"
        @net.update
        assert @net.up_to_date, "Afterwards the net should be up to date and all cached functions should be calculated"
    end

    def test_generate_weight_function
        fill_net
        weight = {[1,2] => 2}
        assert_equal weight, @net.generate_weight_function
    end

    def test_get_markings
        fill_net
        @net << PetriNet::Place.new(name: 'place2')
        @net.get_place('testplace').add_marking 2
        @net.get_place('place2').add_marking 3

        assert_equal [2,3], @net.get_markings
    end

    def test_set_markings
        fill_net
        @net << PetriNet::Place.new(name: 'place2')
        @net.set_markings [2,3]
        assert_equal [2,3], @net.get_markings
    end

    def test_objects_size
        fill_net
        assert_equal 3, @net.objects_size
    end

    def test_save_and_load
        fill_net
        @net.save("/tmp/petrinet")
        net = YAML.load(File.read("/tmp/petrinet"))
        assert_not_nil net
    end

 #   def test_create_marking
 #       place = PetriNet::Place.new(:name => 'Hydrogen')
 #       marking = PetriNet::Marking.new
 #       place.add_marking
 #       assert place.markings.length > 0
 #   end

end
COMMENTED_OUT = <<-EOC
puts "((Create Place 1 [Hydrogen]))"
place = PetriNet::Place.new(:name => 'Hydrogen')

puts "((Add Place 1 [Hydrogen] to PetriNet))"
net.add_place(place)

puts "((Add Place 2 [Oxygen] to PetriNet))"
net.add_place(PetriNet::Place.new(:name => 'Oxygen'))

puts "((Add Place 3 [Water] to PetriNet))"
net << PetriNet::Place.new do |p|
        p.name = 'Water'
end

puts "((Add Transition 1 [Join] to PetriNet))"
net.add_transition(PetriNet::Transition.new(:name => 'Join'))

puts "((Add Arc 1 [Hydrogen.Join] to PetriNet))"
net << PetriNet::Arc.new do |a|
        a.name = 'Hydrogen.Join'
        a.weight = 2
        a.add_source(net.objects[net.places['Hydrogen']])
        a.add_destination(net.objects[net.transitions['Join']])
end

puts "((Add Arc 2 [Oxygen.Join] to PetriNet))"
arc = PetriNet::Arc.new do |a| 
        a.name = 'Oxygen.Join'
        a.add_source(net.objects[net.places['Oxygen']])
        a.add_destination(net.objects[net.transitions['Join']])
end
net.add_arc(arc)

puts "((Add Arc 3 [Join.Water] to PetriNet))"
net.add_arc(PetriNet::Arc.new(
                :name => 'Join.Water',
                :description => "Join to Water",
                :source => net.objects[net.transitions["Join"]],
                :destination => net.objects[net.places["Water"]],
                :weight => 1
        )
)

puts
puts
puts net.inspect
puts
puts
puts net.to_s
puts
puts
EOC

