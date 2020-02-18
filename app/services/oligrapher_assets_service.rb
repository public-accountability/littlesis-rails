# frozen_string_literal: true

# Create compiled oligrapher assets.
# places oligrapher assets into public/oligrapher
# with the file name oligrapher-`git commit sha`.js
# for example:
#     public/oligrapher-24dadc5401c717cbf63fab3489ad7a9a748d0b38.js
#
# example: OligrapherAssetsService.new(<commit-hash>).run
#
#
class OligrapherAssetsService
  attr_accessor :commit

  DEFAULT_BRANCH = '3.0'
  REPO = 'https://github.com/public-accountability/oligrapher'
  REPO_DIR = Rails.root.join('tmp', Rails.env.production? ? 'oligrapher' : 'oligrapher-test').to_s
  ASSET_DIR = Rails.root.join('public/oligrapher').to_s

  def initialize(commit = DEFAULT_BRANCH, skip_fetch: false)
    @commit = commit
    setup_repo
    git_fetch unless skip_fetch
    validate_commit
  end

  def run
    checkout
    yarn_install
    build
  end

  def setup_repo
    FileUtils.mkdir_p REPO_DIR
    system "git clone #{REPO} #{REPO_DIR}" unless File.exist?("#{REPO_DIR}/.git")
  end

  def validate_commit
    error '@commit is blank' if @commit.blank?
    git "rev-parse --quiet --verify #{@commit} > /dev/null"
  end

  def checkout
    git "checkout -q #{@commit}"
  end

  def yarn_install
    Dir.chdir REPO_DIR do
      system('yarn install') || error("Yarn install failed for commit #{@commit}")
    end
  end

  def git_fetch
    git 'fetch --all'
  end

  def build
    # Dir.chdir REPO_DIR do
    #   system('yarn build') || error("Failed to build oligrapher for commit #{@commit}")
    # end
    # system "bin/build PATH"
  end

  private

  def git(cmd = 'status')
    git_command = "git -C #{REPO_DIR} #{cmd}"
    system(git_command) || error("git command failed: #{git_command}")
  end

  def error(msg)
    Rails.logger.fatal "[OligrapherAssetsService]  #{msg}"
    raise Exceptions::OligrapherAssetsError, msg
  end
end
