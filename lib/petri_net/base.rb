# frozen_string_literal: true

module PetriNet
  # Common structure
  class Base
    # Accepts a logger conforming to the interface of Log4r or the default Ruby 1.8+ Logger class.
    attr_accessor :logger

    # Global object count.
    @@object_count = 0

    # Initialize the base class.
    def initialize(_options = {})
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    # Get the next object ID (object count).
    def next_object_id
      @@object_count += 1
    end

    # Resets the object-count
    # This should not be used without extreme care
    # It's made for testing-purposes only
    def reset
      @@object_count = 0
    end
  end
end
