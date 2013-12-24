#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'test/unit'
require "#{`pwd`.strip}/../lib/petri_net" 

require 'pry'

class TestPetriNet < Test::Unit::TestCase
    attr_accessor :net

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
            a.add_source(@net.objects[@net.places['testplace']])
            a.add_destination(@net.objects[@net.transitions['testtrans']])
        end
        @net << arc 
    end

    def teardown
        @net.reset
    end

    def test_create_net
        net = PetriNet::Net.new(:name => 'Water', :description => 'Creation of water from base elements.')
        assert_not_nil net
        assert_equal "Water", net.name, "Name was not properly set"
        assert_equal "Creation of water from base elements.", net.description,  "Description was not properly set"
        assert_empty net.objects, "There should not be any Objects in this fresh and empty net"
        assert_empty net.arcs, "There should not be any Objects in this fresh and empty net"
        assert_empty net.transitions, "There should not be any Objects in this fresh and empty net"
        assert_empty net.places, "There should not be any Objects in this fresh and empty net"
        assert !net.up_to_date, "There are no cached functions calculated"
        net.update
        assert net.up_to_date, "Now we calculated all cached functions without changing anything afterwards, so this schould be up to date"
        assert_empty net.get_markings, "No Places should mean no markings..."
    end

    def test_add_place
        # Create the place
        place = PetriNet::Place.new(:name => 'Hydrogen')
        assert_not_nil place
        assert place.validate

        # Add the place
        id = @net.add_place(place)
        assert @net.objects.length > 1
        assert_equal @net.places["Hydrogen"], id
        assert_equal @net.objects[@net.places["Hydrogen"]], place

        place.add_marking
        assert place.markings.size == 1
        place.add_marking
        assert place.markings.size == 2
        place.remove_marking
        assert place.markings.size == 1
        assert_raise( RuntimeError ){ place.remove_marking(4) }


    end

    def test_add_transition
        # create the transition
        transition = PetriNet::Transition.new(:name => 'Join', :description => 'great testing transition')
        assert_not_nil transition
        assert transition.validate

        #Add the transition
        id = @net.add_transition(transition)
        assert @net.objects.length > 1
        assert_equal @net.transitions['Join'], id
        assert_equal @net.objects[@net.transitions['Join']], transition 
    end

    def test_add_object()
        assert_equal @net, @net << PetriNet::Place.new(:name => "testplace")
        assert_equal 1, @net.places.size, "Added only one place, this means there should only be one place"
        assert_equal 1, @net.objects_size, "Added only one place, this means there should only be one object"
        net << PetriNet::Transition.new(:name => "testtrans")
        assert_equal 1, @net.transitions.size, "Added only one transition, this means there should only be one transition"
        assert_equal 2, @net.objects_size, "Added one transition to the place, this means there should be exactly two objects"
        arc = PetriNet::Arc.new do |a|
            a.name = 'testarc'
            a.weight = 2
            a.add_source(@net.objects[@net.places['testplace']])
            a.add_destination(@net.objects[@net.transitions['testtrans']])
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
            a.add_source(@net.objects[@net.places['Hydrogen']])
            a.add_destination(@net.objects[@net.transitions['Join']])
        end
        assert_not_nil arc
        assert arc.validate(@net), "the created arc is not valid"

        #add the arc
        id = @net.add_arc arc
        assert @net.objects.length > 1
        assert_equal @net.arcs['Hydrogen.Join'], id
        assert_equal @net.objects[@net.arcs['Hydrogen.Join']], arc

        #should not be here :-(
        transition = @net.objects[@net.transitions['Join']]
        assert !transition.activated?, "Transition should not be activated as there are no markings" 

        @net.add_object PetriNet::Place.new(:name => 'Oxygen')
        arc = PetriNet::Arc.new do |a|
            a.name = 'Join.Oxygen'
            a.weight = 1
            a.add_source(@net.objects[@net.transitions['Join']])
            a.add_destination(@net.objects[@net.places['Oxygen']])
        end
        @net << arc
        @net.objects[@net.places['Hydrogen']].add_marking(2)
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
            a.add_source(net2.objects[net2.places['testplace2']])
            a.add_destination(net2.objects[net2.transitions['testtrans']])
        end
        net2 << arc
        assert_equal "Petri Net [Water]
----------------------------
Description: Creation of water from base elements.
Filename: Water

Places
----------------------------
1: testplace (0)
4: testplace2 (0)

Transitions
----------------------------
2: testtrans

Arcs
----------------------------
3: testarc (2) 1 -> 2

", @net.merge(net2).to_s, "Merge failed, this is only a basic test"
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

", @net.generate_reachability_graph(net).to_s, "Simple Reachability Graph with only one reachable state"
        assert false, "needs more testing!"
    end

    def test_w0
        assert false, "not implemented yet" 
    end

    def test_update
        assert false, "not implemented yet" 
    end

    def test_generate_weight_function
        assert false, "not implemented yet" 
    end

    def test_get_markings
        assert false, "not implemented yet" 
    end

    def test_set_markings
        assert false, "not implemented yet" 
    end

    def test_objects_size
        assert false, "not implemented yet" 
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

