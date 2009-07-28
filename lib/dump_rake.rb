require 'rubygems'

require 'pathname'
require 'find'
require 'fileutils'
require 'zlib'

require 'rake'

def require_gem_or_unpacked_gem(name, version = nil)
  unpacked_gems_path = Pathname(__FILE__).dirname.parent + 'gems'

  begin
    gem name, version if version
    require name
  rescue Gem::LoadError, MissingSourceFile
    $: << Pathname.glob(unpacked_gems_path + "#{name.gsub('/', '-')}*").last + 'lib'
    require name
  end
end

require_gem_or_unpacked_gem 'archive/tar/minitar'
require_gem_or_unpacked_gem 'progress', '>= 0.0.6'

class DumpRake
  def self.versions(options = {})
    puts Dump.list(options)
  end

  def self.create(options = {})
    dump = Dump.new(options.merge(:dir => File.join(RAILS_ROOT, 'dump')))

    DumpWriter.create(dump.tmp_path)

    File.rename(dump.tmp_path, dump.tgz_path)
    puts File.basename(dump.tgz_path)
  end

  def self.restore(options = {})
    dump = Dump.list(options).last

    if dump
      DumpReader.restore(dump.path)
    else
      puts "Avaliable versions:"
      versions
    end
  end
end
