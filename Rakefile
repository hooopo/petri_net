require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/tasklib'
require 'rdoc/rdoc'
require 'rdoc/task'

require 'net/sftp'
require 'fileutils'

desc 'Default task'
task :default => [:test, :rdoc, :clean]

task(:test) { puts "==> Running main test suite" }
Rake::TestTask.new(:test) do |t|
	t.test_files = FileList['test/ts_all']
	t.ruby_opts = ['-rubygems'] if defined? Gem
end

Rake::RDocTask.new(:rdoc) do |rdoc|
        rdoc.main = "README"
	rdoc.rdoc_files.include('LICENSE', 'CHANGELOG','lib/')
	rdoc.title = "PetriNet Documentation"
#	rdoc.options << '--webcvs=http://svn.wildcoder.com/svn/petri/trunk/'
	rdoc.rdoc_dir = 'doc' # rdoc output folder
end

desc 'Clean up unused files.'
task :clean => :clobber_rdoc do
end

desc 'Run tests.'
task :test do
end

