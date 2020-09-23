# rubocop:disable RSpec/MessageSpies:

describe OligrapherScreenshotService do
  let(:svg) do
    '<svg height="1000" width="1200" preserveAspectRatio="xMidYMid" viewBox="-600 -500 1200 1000" xmlns="http://www.w3.org/2000/svg" id="oligrapher-svg" style="background-color: white"><defs><filter id="blur" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="5"></feGaussianBlur></filter><marker id="marker1" viewBox="0 -5 10 10" refX="8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L10,0L0,5" fill="#999"></path></marker><marker id="marker2" viewBox="-10 -5 10 10" refX="-8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L-10,0L0,5" fill="#999"></path></marker><marker id="highlightedmarker1" viewBox="0 -5 10 10" refX="8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L10,0L0,5" fill="#000"></path></marker><marker id="highlightedmarker2" viewBox="-10 -5 10 10" refX="-8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L-10,0L0,5" fill="#000"></path></marker><marker id="fadedmarker1" viewBox="0 -5 10 10" refX="8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L10,0L0,5" fill="#ddd"></path></marker><marker id="fadedmarker2" viewBox="0 -5 10 10" refX="8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L-10,0L0,5" fill="#ddd"></path></marker><marker id="selectedmarker1" viewBox="0 -5 10 10" refX="8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L10,0L0,5" fill="#444"></path></marker><marker id="selectedmarker2" viewBox="-10 -5 10 10" refX="-8" refY="0" markerWidth="3.5" markerHeight="3.5" orient="auto"><path d="M0,-5L-10,0L0,5" fill="#444"></path></marker></defs><g id="oligrapher-svg-export"><g class="edges"></g><g class="nodes"><g id="node-7_enhJ35f" class="oligrapher-node react-draggable" style="" transform="translate(0,0)"><g><rect class="nodeLabelRect" fill="#fff" opacity="1" rx="5" ry="5" x="-48" width="96" height="20" y="29" filter="url(#blur)"></rect><g class="node-label"><text x="0" y="45" dy="0" text-anchor="middle" font-family="Helvetica Neue Medium, Helvetica, Arial, sans-serif" font-size="16px" fill="#000">Example Node</text></g></g><circle class="node-halo" cx="0" cy="0" r="31" fill="none"></circle><circle class="node-circle draggable-node-handle" cx="0" cy="0" r="25" fill="#ccc" opacity="1"></circle></g></g><g class="captions"></g></g></svg>'
  end

  context 'with private map' do
    let(:map) { build(:network_map_version3, is_private: true) }

    it 'skips screenshots' do
      expect(Firefox).not_to receive(:visit)
      OligrapherScreenshotService.run(map)
    end
  end

  context 'with public map' do
    let(:map) { create(:network_map_version3, user_id: 1) }
    let(:driver) { instance_double('Selenium::WebDriver::Firefox::Marionette::Driver') }
    let(:map_url) { Lilsis::Application.routes.url_helpers.oligrapher_url(map) }

    it 'saves screenshot to database' do
      expect(driver).to receive(:execute_script).with('window.oli.hideAnnotations()')
      expect(driver).to receive(:execute_script).with('return window.oli.toSvg()').and_return(svg)
      expect(Firefox).to receive(:visit).with(map_url).and_yield(driver)
      expect { OligrapherScreenshotService.run(map) }.to change(map, :screenshot)
      expect(map.screenshot).to be_a(String)
    end

    it 'transforms the height and width of the SVG' do
      expect(driver).to receive(:execute_script).with('window.oli.hideAnnotations()')
      expect(driver).to receive(:execute_script).with('return window.oli.toSvg()').and_return(svg)
      expect(Firefox).to receive(:visit).and_yield(driver)
      OligrapherScreenshotService.run(map)
      expect(map.screenshot).to include "height=\"#{OligrapherScreenshotService::HEIGHT}\""
      expect(map.screenshot).to include "width=\"#{OligrapherScreenshotService::WIDTH}\""
    end

    it 'validates svg and skips saving' do
      expect(driver).to receive(:execute_script).with('window.oli.hideAnnotations()')
      expect(driver).to receive(:execute_script).with('return window.oli.toSvg()').and_return("invalid svg")
      expect(Firefox).to receive(:visit).and_yield(driver)
      expect { OligrapherScreenshotService.run(map) }.not_to change(map, :screenshot)
    end
  end
end

# rubocop:enable RSpec/MessageSpies:
