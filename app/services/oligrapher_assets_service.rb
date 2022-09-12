# frozen_string_literal: true

# Helper module to compile oligrapher
# by default it comiples the commit set in Rails.application.config.littlesis.oligrapher_commit
# but it can also compile any oligrapher commit OligrapherAssetsService.run("ac2ff73d4bad03cf08138baa608df0a346190768")
# Oligrapher assets are stored with the commit hash in the filesname, for instance
class OligrapherAssetsService
  REPO = 'https://github.com/public-accountability/oligrapher'
  REPO_DIR = Rails.root.join('tmp', Rails.env.production? ? 'oligrapher' : 'oligrapher-test').to_s.freeze
  ASSET_DIR = Rails.public_path.join('oligrapher').to_s.freeze
  BRANCH = 'main'

  def self.setup_repo
    FileUtils.mkdir_p REPO_DIR
    FileUtils.mkdir_p ASSET_DIR
    system("git clone #{REPO} #{REPO_DIR}") unless File.exist?("#{REPO_DIR}/.git")
  end

  def self.current_commit
    `git -C #{REPO_DIR} rev-parse HEAD`.strip
  end

  def self.latest_commit
    git "fetch --all --quiet"
    `git -C #{REPO_DIR} rev-parse origin/#{BRANCH}`.strip
  end

  def self.run(commit = nil)
    commit = Rails.application.config.littlesis.oligrapher_commit if commit.nil?
    setup_repo
    git "fetch --all --quiet"
    git "rev-parse --quiet --verify #{commit}"
    git "checkout --force -q #{commit}"

    Dir.chdir REPO_DIR do
      system 'npm ci --include=dev --silent', exception: true
      system 'npm run build', exception: true
      system "rsync -v -a #{REPO_DIR}/dist/ #{ASSET_DIR}/", exception: true
    end
  end

  private

  def self.git(cmd = 'status')
    git_command = "git -C #{REPO_DIR} #{cmd}"
    system git_command, exception: true
  end
end
