#!/usr/bin/env ruby
#
#

require 'rubygems'
require 'logger'
require 'test/unit'
require "#{`pwd`.strip}/../lib/petri_net" 

class CreateTest < Test::Unit::TestCase
    attr_accessor :net

    def setup
        @net = PetriNet::Net.new(:name => 'Water', :description => 'Creation of water from base elements.')	
        @net.logger = Logger.new(STDOUT)
    end

    def test_create_net
        net = PetriNet::Net.new(:name => 'Water', :description => 'Creation of water from base elements.')
        assert_not_nil net
        #needs more assertions
    end

    def test_create_place
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

    def test_create_transition
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

    def test_create_arc
        @net.add_object PetriNet::Transition.new(:name => 'Join', :description => 'great testing transition')
        @net.add_object PetriNet::Place.new(:name => 'Hydrogen')
        arc = PetriNet::Arc.new do |a|
            a.name = 'Hydrogen.Join'
            a.weight = 2
            a.add_source(@net.objects[@net.places['Hydrogen']])
            a.add_destination(@net.objects[@net.transitions['Join']])
        end

        assert_not_nil arc
        assert arc.validate @net

        #add the arc
        id = @net.add_arc arc
        assert @net.objects.length > 1
        assert_equal @net.arcs['Hydrogen.Join'], id
        assert_equal @net.objects[@net.arcs['Hydrogen.Join']], arc

    end

    def test_create_marking
        place = PetriNet::Place.new(:name => 'Hydrogen')
        marking = PetriNet::Marking.new
        place.add_marking
        assert place.markings.length > 0
    end

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

