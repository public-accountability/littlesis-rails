# frozen_string_literal: true


describe CssColorValidator do

  class CssColorValidatorTester
    include ActiveModel::Validations
    attr_accessor :color
    validates :color, css_color: true
  end

  def self.test_css_color(color, valid)
    context "with color: #{color}" do
      let(:css_color) { color }
      let(:color_tester) do
        CssColorValidatorTester.new.tap { |x| x.color = css_color }
      end

      specify { expect(color_tester.valid?).to be valid }
    end
  end

  test_css_color nil, true
  test_css_color '#ccebc5', true
  test_css_color 'rgb(120,22,33)', true
  test_css_color 'rgb(0, 255, 0)', true
  test_css_color 'rgba(1,2,3,0.4)', true
  test_css_color 'rgba(1,2,3,0.08)', true
  test_css_color 'rgba(0,255,100, 1.0)', true

  test_css_color 'rgba(0,0,0,6.5)', false
  test_css_color 'I AM NOT A COLOR', false
  test_css_color '#xxxxxx', false
end
