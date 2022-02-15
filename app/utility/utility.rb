# frozen_string_literal: true

require 'csv'
require 'tempfile'
require 'open3'

module Utility
  def self.current_git_commit
    @current_git_commit ||= Dir.chdir(Rails.root.to_s) do
      `git rev-parse --short HEAD`.chomp
    end
  end

  def self.save_hash_array_to_csv(file_path, data, mode: 'w')
    CSV.open(file_path, mode) do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end

  def self.execute_sql_file(path)
    db = Rails.configuration.database_configuration.fetch(Rails.env)

    psql_connection_string = "postgresql://#{db['username']}:#{db['password']}@#{db['host']}/#{db['database']}"

    output = `psql -b -v ON_ERROR_STOP=1 #{psql_connection_string} < #{path}`

    if $?.exitstatus != 0
      ColorPrinter.print_red output
      raise SQLFileError, output
    end
  end

  def self.file_is_empty_or_nonexistent(path)
    !File.exist?(path) || File.stat(path).size.zero?
  end

  def self.create_tmp_file(content)
    Tempfile.new.tap do |t|
      t.write content
      t.rewind
    end
  end

  def self.with_tmp_file(content)
    tmp_file = create_tmp_file(content)
    yield tmp_file
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def self.sh(cmd, fail_message: nil)
    if system(cmd)
      true
    else
      raise SubshellCommandError, (fail_message || cmd)
    end
  end

  # This will convert the contents of a text file UTF-8, replacing any
  # invalid characters with empty strings.
  # All file operations are done streaming, and is safe to use on large files.
  def self.convert_file_to_utf8(path)
    # populate temp file with converted data
    tmp_file = Tempfile.new
    File.foreach(path) do |line|
      tmp_file.write line
                       .encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '')
                       .force_encoding('UTF-8')
    end

    tmp_file.rewind
    IO.copy_stream(tmp_file, path) # overwrite original file
    tmp_file.unlink

    true
  end

  def self.today_str
    Time.zone.now.strftime('%F')
  end

  def self.head_request(url, redirects: 0)
    uri = URI(url)
    http = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https')
    response = http.head(uri.path.presence || '/')
    http.finish

    if %w[301 302].include?(response.code) && response['location'] && redirects < 5
      head_request(response['location'], redirects: redirects + 1)
    else
      response
    end
  end

  # GET HTTP request, saving the response body to a local file (streaming)
  def self.stream_file(url:, path:, redirects: 0)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(Net::HTTP::Get.new(uri)) do |response|
        if response.is_a?(Net::HTTPRedirection)
          if redirects > 5
            response.error!
          else
            return stream_file(url: response['location'], path: path, redirects: redirects + 1)
          end
        end

        response.value # this raises an error if the response is not successful

        File.open(path, 'wb') do |file|
          response.read_body do |fragment|
            file.write(fragment)
          end
        end
      end
    end
  end

  def self.stream_file_if_not_exists(url:, path:)
    stream_file(url: url, path: path) if file_is_empty_or_nonexistent(path)
  end

  # GET HTTP request, saving the response body to a local file
  def self.download_file(url:, path:)
    File.write(path, Net::HTTP.get(URI.parse(url)))
  end

  def self.zip_entry_each_line(zip:, file:, &block)
    require 'zip'
    Zip::File.open(zip) do |zip_file|
      zip_file.get_entry(file).get_input_stream.each(&block)
    end
  end

  # converts all values that resopnd .blank?
  # to nil, except for false
  def self.nilify_blank_vals(h)
    h.transform_values do |val|
      if val.blank? && val != false
        nil
      else
        val
      end
    end
  end

  class SubshellCommandError < Exceptions::LittleSisError; end
  class SQLFileError < Exceptions::LittleSisError; end
end
