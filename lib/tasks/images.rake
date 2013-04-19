namespace :images do
  desc "creates square versions of images"
  task create_square: :environment do
    options = {}
    %w(LIMIT LIST_ID SIZE CHECK_FIRST DEBUG).each do |option|
      value = ENV[option]
      options[option.downcase] = value unless value.nil?
    end

    task = CreateSquareImagesTask.new(options)
    task.execute
  end
end
