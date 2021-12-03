# frozen_string_literal: true

# Create compiled oligrapher assets in public/oligrapher
# for example:
#     public/oligrapher/oligrapher-24dadc5401c717cbf63fab3489ad7a9a748d0b38.js
#
# example: OligrapherAssetsService.run(<commit-hash>)
#
class OligrapherAssetsService
  attr_accessor :commit

  REPO = 'https://github.com/public-accountability/oligrapher'
  REPO_DIR = Rails.root.join('tmp', Rails.env.production? ? 'oligrapher' : 'oligrapher-test').to_s
  ASSET_DIR = Rails.root.join('public/oligrapher').to_s
  BRANCH = '3.0'

  def self.setup_repo
    FileUtils.mkdir_p REPO_DIR
    FileUtils.mkdir_p ASSET_DIR
    system("git clone #{REPO} #{REPO_DIR}") unless File.exist?("#{REPO_DIR}/.git")
  end

  def self.fetch_all
    `git -C #{REPO_DIR} fetch --all --quiet`
  end

  def self.current_commit
    `git -C #{REPO_DIR} rev-parse HEAD`.strip
  end

  def self.latest_commit
    fetch_all
    `git -C #{REPO_DIR} rev-parse origin/#{BRANCH}`.strip
  end

  def self.run(commit = nil)
    fetch_all
    new(commit || Rails.application.config.littlesis.oligrapher_commit).run
  end

  def initialize(commit, skip_fetch: false, development: false, force: false)
    self.class.setup_repo
    @commit = commit
    @development = development
    @force = force
    # validate commit
    error '@commit is blank' if @commit.blank?
    git "rev-parse --quiet --verify #{@commit} > /dev/null"
  end

  def run
    # return self if !@force && build_file_exists?

    # Build oligrapher
    Dir.chdir REPO_DIR do
      git "checkout --force -q #{@commit}"
      system('yarn install --silent') || error("Yarn install failed for commit #{@commit}")
      build_cmd = "yarn run build-prod --env output_path=#{ASSET_DIR} && yarn run build-prod-one --env output_path=#{ASSET_DIR} "
      system(build_cmd) || error("Failed to build for commit #{@commit}")
    end

    # Compress
    Dir.glob(Pathname.new(OligrapherAssetsService::ASSET_DIR).join("oligrapher-#{@commit}*.{js,css,map}")).each do |f|
      system("gzip --keep #{f}") unless File.exist?(f + ".gz")
      system("brotli --keep #{f}") unless File.exist?(f + ".br")
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
