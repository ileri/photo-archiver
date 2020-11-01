#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'listen'
require 'fileutils'

# Archiver Class
class Archiver
  attr_reader :src_dir, :dst_dis, :resize, :resize_x, :resize_y, :keep_ratio

  def initialize(file_path)
    @config_file_path = file_path
    read_configs
  end

  def listen
    listener = Listen.to(@src_dir) do |_modified, added, _removed|
      apply_archiving added if added
    end
    listener.start
    sleep
  end

  private

  def read_configs
    if File.exist? @config_file_path
      yaml = YAML.safe_load(File.read(@config_file_path))['archiver']
      configure_dirs(yaml)
      configure_resize_options(yaml)
    else
      puts 'Config file cannot found!'
      raise StandardError
    end
  end

  def configure_dirs(yaml)
    @src_dir = yaml['src_dir']
    @dst_dir = yaml['dst_dir'] || 'archived'

    if @src_dir.nil? || (!File.exist? @src_dir)
      put 'Source directory is not set or not exists'
      raise StandardError
    elsif !File.exist? @dst_dir
      FileUtils.mkdir_p @dst_dir
    end
  end

  def configure_resize_options(yaml)
    @resize = yaml['resize']
    @resize_x = yaml['resize_x']
    @resize_y = yaml['resize_y']
    @keep_ratio = yaml['keep_ratio']
  end

  def apply_archiving(file_path)
    puts file_path
    # TODO : Implement resizing and archiving
  end
end

def main
  archiver = Archiver.new('archiver_config.yml')
  archiver.listen
end

main if $PROGRAM_NAME == __FILE__
