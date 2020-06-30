# frozen_string_literal: true

require 'csv'
require 'tempfile'

# Various helper functions used by scripts and rake tasks.

module Utility
  def self.save_hash_array_to_csv(file_path, data, mode: 'wb')
    CSV.open(file_path, mode) do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end

  def self.execute_sql_file(path)
    db = Rails.configuration.database_configuration.fetch(Rails.env)
    cmd = "mysql -u #{db['username']} -p#{db['password']} -h #{db['host']} #{db['database']} < #{path}"
    output = `#{cmd}`
    if $?.exitstatus != 0
      ColorPrinter.print_red output
      raise SQLFileError, output
    end
  end

  def self.file_is_empty_or_nonexistent(path)
    !File.exist?(path) || File.stat(path).size.zero?
  end

  def self.sh(cmd, fail_message: nil)
    if system(cmd)
      true
    else
      raise SubshellCommandError, (fail_message || cmd)
    end
  end

  # This will copy the contents of the file to a
  # temporary file and convert the text to UTF-8,
  # replacing any invalid characters with empty strings.
  # Then it overwrites the original file with the new, UTF-8 data.
  #
  # All file operations are done streaming, and is therefore
  # safe to use on large files.
  def self.convert_file_to_utf8(path)
    # populate temp file with converted data
    tmp_file = Tempfile.new
    File.foreach(path) do |line|
      utf8_line = line
                    .encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '')
                    .force_encoding('UTF-8')

      tmp_file.write utf8_line
    end

    # replace CSV_FILE_PATH with new utf-8 data
    tmp_file.rewind
    IO.copy_stream(tmp_file, path)
    tmp_file.unlink

    return true
  end

  def self.today_str
    Time.zone.now.strftime('%F')
  end

  # Saves url to local path with streams
  def self.stream_file(url:, path:)
    File.open(path, 'wb') do |file|
      HTTParty.get(url, stream_body: true) do
        file.write(fragment)
      end
    end
  end

  def self.stream_file_if_not_exists(url:, path:)
    unless file_is_empty_or_nonexistent(path)
      stream_file_if_not_exists(url: url, path: path)
    end
  end

  def self.yes_no_converter(x)
    return nil if x.nil?

    if x.strip.casecmp('Y').zero?
      true
    elsif x.strip.casecmp('N').zero?
      false
    else
      nil
    end
  end

  def self.one_zero_converter(x)
    return nil if x.nil?

    if x.strip == '1'
      true
    elsif x.strip == '0'
      false
    else
      nil
    end
  end

  class SubshellCommandError < StandardError; end
  class SQLFileError < StandardError; end
end
