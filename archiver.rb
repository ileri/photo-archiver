#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'listen'
require 'logger'
require 'fileutils'
require 'mini_magick'

# Archiver Class
class Archiver
  attr_reader :src_dir, :dst_dis, :resize, :resize_x, :resize_y, :keep_ratio

  PHOTO_EXTENSIONS = %w[.jpg .jpeg .png .gif].freeze

  def initialize(file_path)
    @log = Logger.new($stdout)
    @config_file_path = file_path
    read_configs
    apply_auto_delete if @configs['auto_delete']
    run_init_process if @configs['run_on_init']
  end

  def listen
    info "Photo archiver initialized. Listening #{@src_dir} directory."
    listener = Listen.to(@src_dir) do |_modified, added, _removed|
      added.each { |f| apply_archiving f }
    end
    listener.start
    sleep
  end

  private

  def read_configs
    if File.exist? @config_file_path
      @configs = YAML.safe_load(File.read(@config_file_path))['archiver']
      configure_dirs(@configs)
    else
      error 'Config file cannot found!'
      raise StandardError
    end
  end

  def configure_dirs(yaml)
    @src_dir = yaml['src_dir']
    @dst_dir = yaml['dst_dir'] || 'archived'

    if @src_dir.nil? || (!File.exist? @src_dir)
      error 'Source directory is not set or not exists'
      raise StandardError
    elsif !File.exist? @dst_dir
      FileUtils.mkdir_p @dst_dir
    end
  end

  def info(text)
    @log.info text if @configs['logging']
  end

  def error(text)
    @log.error text
  end

  def photo?(file_path)
    is_photo = false
    PHOTO_EXTENSIONS.each { |ext| is_photo ||= file_path.downcase.end_with? ext }
    is_photo
  end

  def resize_photo(file_path)
    image = MiniMagick::Image.open(file_path)
    image.resize "#{@configs['resize_x']}x#{@configs['resize_y']}#{'>' if @configs['keep_ratio']}"
    image.write File.join(@dst_dir, File.basename(file_path))
    image
  end

  def archive_original_file(archive_path, file_path)
    base = File.basename(file_path, '.*')
    ext = File.extname(file_path)
    archived_file_name = "#{@configs['original_prefix']}#{base}#{@configs['original_postfix']}#{ext}"
    FileUtils.mv file_path, File.join(archive_path, archived_file_name)
  end

  def archive_resized_image(archive_path, file_path, resized_image)
    archived_file_name = File.join archive_path, File.basename(file_path)
    resized_image.write archived_file_name
  end

  def archive_file(file_path, resized_image)
    today = Time.new
    archive_path = File.join(@dst_dir, today.year.to_s, today.month.to_s, today.day.to_s)
    FileUtils.mkdir_p archive_path
    @configs['archive_original'] ? archive_original_file(archive_path, file_path) : FileUtils.rm_f(file_path)
    archive_resized_image(archive_path, file_path, resized_image) if @configs['archive_resized']
  end

  def apply_auto_delete
    deletable_files = Dir.glob("#{@dst_dir}/*").select { |e| File.file? e }
    deletable_files.each do |f|
      FileUtils.rm_f(f) if File.ctime(f).to_datetime < (DateTime.now - @configs['delete_days'])
    end
  end

  def apply_archiving(file_path)
    will_resize = @configs['resize'] && photo?(file_path)
    info "File #{'resizing and' if will_resize} archiving: #{file_path}"
    resized_image = will_resize ? resize_photo(file_path) : nil
    archive_file(file_path, resized_image)
  rescue StandardError => e
    error "File archiving is failed. Error: #{e}"
  end

  def run_init_process
    info 'Executing "run on init" process'
    files = Dir.glob("#{@src_dir}/*").select { |e| File.file? e }
    files.each { |f| apply_archiving f }
  end
end

def main
  Signal.trap('INT') { exit }
  archiver = Archiver.new('archiver_config.yml')
  archiver.listen
end

main if $PROGRAM_NAME == __FILE__
