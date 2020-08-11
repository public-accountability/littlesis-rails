# frozen_string_literal: true

# Create compiled oligrapher assets in public/oligrapher,
# with the file name oligrapher-`git commit sha`.js
# for example:
#     public/oligrapher/oligrapher-24dadc5401c717cbf63fab3489ad7a9a748d0b38.js
#
# example: OligrapherAssetsService.new(<commit-hash>).run
#
class OligrapherAssetsService
  attr_accessor :commit

  REPO = 'https://github.com/public-accountability/oligrapher'
  REPO_DIR = Rails.root.join('tmp', Rails.env.production? ? 'oligrapher' : 'oligrapher-test').to_s
  ASSET_DIR = Rails.root.join('public/oligrapher').to_s

  def self.setup_repo
    FileUtils.mkdir_p REPO_DIR
    FileUtils.mkdir_p ASSET_DIR
    system "git clone #{REPO} #{REPO_DIR}" unless File.exist?("#{REPO_DIR}/.git")
  end

  def self.latest_commit
    setup_repo
    `git -C #{REPO_DIR} rev-parse HEAD`.strip
  end

  def initialize(commit = Oligrapher::VERSION, skip_fetch: false, development: false, force: false)
    self.class.setup_repo
    @commit = commit
    @development = development
    @force = force
    git 'fetch --all --quiet' unless skip_fetch

    # validate commit
    error '@commit is blank' if @commit.blank?
    git "rev-parse --quiet --verify #{@commit} > /dev/null"
  end

  def run
    return self if !@force && build_file_exists?

    Dir.chdir REPO_DIR do
      git "checkout --force -q #{@commit}"
      system('yarn install --silent') || error("Yarn install failed for commit #{@commit}")

      build_cmd = [
        'yarn run webpack',
        "--env.output_path=#{ASSET_DIR}",
        "--env.filename=#{oligrapher_filename}"
      ]

      if @development
        build_cmd << '--env.development'
        build_cmd << '--env.api_url=http://127.0.0.1:8081'
      else
        build_cmd << '--env.production'
      end

      system(build_cmd.join(' ')) || error("Failed to build for commit #{@commit}")
    end

    self
  end

  private

  def oligrapher_filename
    "oligrapher-#{@commit}.js"
  end

  def build_file
    File.join(ASSET_DIR, oligrapher_filename)
  end

  def build_file_exists?
    if File.exist?(build_file) && File.stat(build_file).size.positive?
      Rails.logger.info "#{build_file} already exists"
      return true
    else
      return false
    end
  end

  def git(cmd = 'status')
    git_command = "git -C #{REPO_DIR} #{cmd}"
    system(git_command) || error("git command failed: #{git_command}")
  end

  def error(msg)
    Rails.logger.fatal "[OligrapherAssetsService]  #{msg}"
    raise Exceptions::OligrapherAssetsError, msg
  end
end
