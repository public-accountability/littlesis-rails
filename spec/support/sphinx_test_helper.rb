module SphinxTestHelper
  def setup_sphinx
    ThinkingSphinx::Configuration.instance.settings['real_time_callbacks'] = true
    ThinkingSphinx::Test.init
    ThinkingSphinx::Test.start :index => false
  end

  def teardown_sphinx
    ThinkingSphinx::Test.stop
    ThinkingSphinx::Test.clear
    ThinkingSphinx::Configuration.instance.settings['real_time_callbacks'] = false
  end
end
