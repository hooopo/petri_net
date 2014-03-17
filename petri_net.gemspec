# -*- encoding: utf-8 -*-
require File.expand_path('../lib/petri_net/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["cclausen"]
  gem.email         = ["\"cclausen@tzi.de\""]
  gem.description   = %q{A Petri net modeling gem}
  gem.summary       = %q{You can create Petri Nets and do some calculations with them like generating the Reachability Graph}
  gem.homepage      = "https://github.com/cclausen/petri_net"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "petri_net"
  gem.require_paths = ["lib"]
  gem.version       = PetriNet::VERSION
  
  gem.license       = 'MIT'
  gem.add_dependency "ruby-graphviz"
  gem.add_development_dependency "net-sftp"
end
