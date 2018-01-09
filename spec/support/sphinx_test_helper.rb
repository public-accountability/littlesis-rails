require 'rake'

module SphinxTestHelper
  def setup_sphinx(*indexes)
    Lilsis::Application.load_tasks
    Rake::Task['ts:configure'].invoke
    ThinkingSphinx::Test.init
    indexes.each { |idx| ThinkingSphinx::Test.index idx }
    ThinkingSphinx::Test.start index: false
  end

  def teardown_sphinx
    ThinkingSphinx::Test.stop
    ThinkingSphinx::Test.clear
  end
end
