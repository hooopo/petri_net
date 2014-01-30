require 'rubygems'
require 'logger'
require 'test/unit'

class TestPetriNetReachabilityGraph < Test::Unit::TestCase
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

    def teardown
        @net.reset
    end

    def test_trivial_generate_reachability_graph
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

def test_generate_reachability_graph
    fill_net
assert_equal "Reachability Graph [Water]
----------------------------
Description: 
Filename: 

Nodes
----------------------------
4: Node4 ([0])

Edges
----------------------------

", @net.generate_reachability_graph().to_s, "Reachability Graph of sample net"
    end


end
