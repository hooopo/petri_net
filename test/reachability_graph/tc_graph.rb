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

    def test_to_gv
        fill_net
#        @net.generate_reachability_graph().to_gv_new
    end

    def test_simple_net_1
        @net = PetriNet::Net.new(:name => 'SimpleNet1', :description => 'PTP')
        @net << PetriNet::Place.new(name: 'A')
        @net << PetriNet::Place.new(name: 'B')
        @net << PetriNet::Transition.new(name:'T')
        @net << PetriNet::Arc.new(source:@net.get_place('A'), destination:@net.get_transition('T'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T'), destination:@net.get_place('B'))
        @net.get_place('A').add_marking
        rn = @net.generate_reachability_graph
        assert_equal "Reachability Graph [SimpleNet1]\n----------------------------\nDescription: \nFilename: \n\nNodes\n----------------------------\n6: Node6 ([1, 0])\n7: Node7 ([0, 1])\n\nEdges\n----------------------------\n8: Edge8 6 -> 7: Node7 ([0, 1]) )\n\n", rn.to_s

    end

    def test_simple_net_2
        @net = PetriNet::Net.new(:name => 'SimpleNet2', :description => 'PTTPP')
        @net << PetriNet::Place.new(name: 'A')
        @net << PetriNet::Place.new(name: 'B')
        @net << PetriNet::Place.new(name: 'C')
        @net << PetriNet::Transition.new(name:'T1')
        @net << PetriNet::Transition.new(name:'T2')
        @net << PetriNet::Arc.new(source:@net.get_place('A'), destination:@net.get_transition('T1'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T1'), destination:@net.get_place('B'))
        @net << PetriNet::Arc.new(source:@net.get_place('A'), destination:@net.get_transition('T2'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T2'), destination:@net.get_place('C'))
        @net.get_place('A').add_marking
        rn = @net.generate_reachability_graph
        assert_equal "Reachability Graph [SimpleNet2]\n----------------------------\nDescription: \nFilename: \n\nNodes\n----------------------------\n10: Node10 ([1, 0, 0])\n11: Node11 ([0, 1, 0])\n13: Node13 ([0, 0, 1])\n\nEdges\n----------------------------\n12: Edge12 10 -> 11: Node11 ([0, 1, 0]) )\n14: Edge14 10 -> 13: Node13 ([0, 0, 1]) )\n\n", rn.to_s

    end

    def test_simple_net_3
        @net = PetriNet::Net.new(:name => 'SimpleNet3', :description => 'PTPPinf')
        @net << PetriNet::Place.new(name: 'A')
        @net << PetriNet::Place.new(name: 'B')
        @net << PetriNet::Transition.new(name:'T')
        @net << PetriNet::Arc.new(source:@net.get_place('A'), destination:@net.get_transition('T'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T'), destination:@net.get_place('B'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T'), destination:@net.get_place('A'))
        @net.get_place('A').add_marking
        rn = @net.generate_reachability_graph
        assert_equal "Reachability Graph [SimpleNet3]\n----------------------------\nDescription: \nFilename: \n\nNodes\n----------------------------\n7: Node7 ([1, Infinity])\n\nEdges\n----------------------------\n9: Edge9 7 -> 7: Node7 ([1, Infinity]) )\n\n", rn.to_s

    end

    def test_simple_net_4
        @net = PetriNet::Net.new(:name => 'SimpleNet4', :description => 'PTPPinf')
        @net << PetriNet::Place.new(name: 'A')
        @net << PetriNet::Place.new(name: 'B')
        @net << PetriNet::Transition.new(name:'T1')
        @net << PetriNet::Transition.new(name:'T2')
        @net << PetriNet::Arc.new(source:@net.get_place('A'), destination:@net.get_transition('T1'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T1'), destination:@net.get_place('B'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T1'), destination:@net.get_place('A'))
        @net << PetriNet::Arc.new(source:@net.get_place('B'), destination:@net.get_transition('T2'))
        @net << PetriNet::Arc.new(source:@net.get_transition('T2'), destination:@net.get_place('A'))
        @net.get_place('A').add_marking
        rn = @net.generate_reachability_graph
        assert_equal "T2 is missing! Reachability Graph [SimpleNet4]\n----------------------------\nDescription: \nFilename: \n\nNodes\n----------------------------\n10: Node10 ([Infinity, Infinity])\n\nEdges\n----------------------------\n12: Edge12 10 -> 10: Node10 ([Infinity, Infinity]) )\n\n", rn.to_s
        rn.to_gv_new

    end
end
