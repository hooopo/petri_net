module PetriNet
	# Marking
	class Marking < PetriNet::Base
                # depricated
		attr_accessor :id            # Unique ID
                # depricated
		attr_accessor :name          # Human readable name	
                # depricated
		attr_accessor :description   # Description
                # depricated
		attr_accessor :timestep      # Marking timestep

		# Create a new marking.
                # depricated
		def initialize(options = {}, &block)
		  
			yield self unless block == nil
		end	

		# Validate this marking.
		def validate
		end

		# Stringify this marking.
		def to_s
		end
	end 
end
