require 'rake'

module SphinxTestHelper
  def setup_sphinx(*indexes)
    ThinkingSphinx::Deltas.suspend!
    yield if block_given?
    Lilsis::Application.load_tasks
    Rake::Task['ts:configure'].invoke
    ThinkingSphinx::Test.init
    ThinkingSphinx::Test.index
    # indexes.each { |idx| ThinkingSphinx::Test.index idx }
    ThinkingSphinx::Test.start index: false
  end

  def teardown_sphinx
    ThinkingSphinx::Test.stop
    ThinkingSphinx::Test.clear
    yield if block_given?
    ThinkingSphinx::Deltas.resume!
  end

  def delete_entity_tables
    Entity.delete_all
    Alias.delete_all
    Org.delete_all
    Person.delete_all
    Tagging.delete_all
  end
end
