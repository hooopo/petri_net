require 'rubygems'
require 'logger'
require 'test/unit'
require "#{File.dirname(__FILE__)}/../../lib/petri_net" 

class TestReachabilityGraphNode < Test::Unit::TestCase
    def setup
        @net = PetriNet::Net.new(:name => 'Water', :description => 'Creation of water from base elements.')
        @node = PetriNet::ReachabilityGraph::Node.new(markings: [1,3,5,4,0])
    end

    def teardown
        @net.reset
    end

    def test_create_node
        node = PetriNet::ReachabilityGraph::Node.new(markings: [1,3,5,4,0])
        assert_not_nil node
        assert_equal "Node2", node.name
        assert_equal [], node.inputs
        assert_equal [], node.outputs
        assert_equal node.name, node.label
        assert_equal [1,3,5,4,0], node.markings
        assert !node.omega_marked, "should not be omega_marked as there is no omega-marking"
    end

    def test_omega_marking
        node = PetriNet::ReachabilityGraph::Node.new(markings: [1,3,5,Float::INFINITY,0])
        assert node.omega_marked, "should be omega_marked as there is an omega marking"
    end

    def test_adding_omega_marking
        assert !@node.omega_marked
        @node.add_omega 3
        assert_equal [1,3,5,Float::INFINITY,0], @node.markings
        assert @node.omega_marked
    end

    def test_compare
        node1 = PetriNet::ReachabilityGraph::Node.new(markings: [0,1,0,0,1])
        node2 = PetriNet::ReachabilityGraph::Node.new(markings: [0,1,0,0,1])
        node3 = PetriNet::ReachabilityGraph::Node.new(markings: [0,0,1,0,1])
        node4 = PetriNet::ReachabilityGraph::Node.new(markings: [0,2,0,0,1])
        node5 = PetriNet::ReachabilityGraph::Node.new(markings: [1,1,0,0,1])
        node6 = PetriNet::ReachabilityGraph::Node.new(markings: [1,1,0,0,0])

        assert node1 == node1
        assert node2 == node2
        assert node1 == node2
        assert !(node1 < node2)
        assert !(node1 > node2)
        assert !(node3 == node1)
        assert_raise ArgumentError do node3 > node1 end
        assert_raise ArgumentError do node3 < node1 end
        assert node4 > node1
        assert node1 < node4
        assert node5 > node1
        assert !(node4 == node5)
        assert_raise ArgumentError do node4 > node5 end
        assert_raise ArgumentError do node6 > node1 end

    end
end
