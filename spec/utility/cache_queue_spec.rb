require "rails_helper"

describe CacheQueue do
  describe 'initialize' do
    let(:cache_queue) do
      CacheQueue.new(name: 'test_cache', options: { expires_in: 5.minutes })
    end

    specify do
      expect(cache_queue.instance_variable_get(:@cache_key)).to eq 'queue/test_cache'
    end

    specify do
      expect(cache_queue.instance_variable_get(:@options)).to have_key(:expires_in)
    end

    specify do
      expect(cache_queue.fetch).to eq []
    end
  end

  describe 'set' do
    let(:cache_queue) { CacheQueue.new(name: 'set_test') }

    it 'raises error if called on any value but an array' do
      expect { cache_queue.set(foo: 'bar') }.to raise_error(TypeError)
    end

    it 'stores passed array in queue' do
      expect(Rails.cache.fetch('queue/set_test')).to eql []
      cache_queue.set([:x, :y, :z])
      expect(Rails.cache.fetch('queue/set_test')).to eql [:x, :y, :z]
    end

    it 'returns self' do
      expect(cache_queue.set([])).to be cache_queue
    end
  end

  describe 'get' do
    let(:cache_queue) { CacheQueue.new(name: 'get_test') }

    before { cache_queue.set(%w[one two three]) }

    it 'returns first item in queue but does not change order' do
      expect(cache_queue.get).to eq 'one'
      expect(Rails.cache.fetch('queue/get_test')).to eq %w[one two three]
    end
  end

  describe 'get!' do
    let(:cache_queue) { CacheQueue.new(name: 'get!_test') }

    before { cache_queue.set(%w[one two three]) }

    it 'returns and removes first item from queue' do
      expect(cache_queue.get!).to eq 'one'
      expect(Rails.cache.fetch('queue/get!_test')).to eq %w[two three]
    end
  end

  describe 'random_get' do
    let(:cache_queue) { CacheQueue.new(name: 'random_get_test') }

    before { cache_queue.set(%w[one two three]) }

    it 'returns a random item from the queue' do
      3.times do
        expect(%w[one two three]).to include cache_queue.random_get
      end
    end
  end

  describe 'random_get!' do
    let(:cache_queue) { CacheQueue.new(name: 'random_get!_test') }

    before { cache_queue.set(%w[one two three]) }

    it 'returns a random item from the queue and removes it ' do
      expect(Rails.cache.fetch('queue/random_get!_test')).to eq %w[one two three]
      3.times do
        expect(%w[one two three]).to include cache_queue.random_get!
      end
      expect(Rails.cache.fetch('queue/random_get!_test')).to eq []
    end

    it 'returns nil if queue is empty' do
      q = CacheQueue.new(name: 'empty_random_get_test')
      q.set([])
      expect(q.random_get!).to be nil
    end
  end

  describe 'add' do
    let(:cache_queue) { CacheQueue.new(name: 'add_test') }

    before { cache_queue.set(%w[one two three]) }

    it 'adds items to queue' do
      expect { cache_queue.add('four') }
        .to change(cache_queue, :fetch)
              .from(%w[one two three]).to(%w[one two three four])
    end

    it 'can prevent duplicates from being added' do
      expect { cache_queue.add('three', uniq: true) }
        .not_to change(cache_queue, :fetch)
    end
  end

  describe 'remove' do
    let(:cache_queue) do
      CacheQueue.new(name: 'remove_test').set([1, 2, 3, 4, 3])
    end

    specify do
      expect(cache_queue.remove(3).fetch).to eq [1, 2, 4]
    end

    specify do
      expect(cache_queue.remove(2).fetch).to eq [1, 3, 4, 3]
    end

    specify do
      expect(cache_queue.remove(5).fetch).to eq [1, 2, 3, 4, 3]
    end
  end

  describe 'clear' do
    let(:cache_queue) { CacheQueue.new(name: 'clear_test').set([1, 2, 3]) }

    it 'removes all items' do
      cache_queue.clear
      expect(cache_queue.fetch).to eq []
    end
  end

  describe 'empty?' do
    specify { expect(CacheQueue.new(name: 'is_empty').set([]).empty?).to be true }
    specify { expect(CacheQueue.new(name: 'is_not_empty').set(['x']).empty?).to be false }
  end

  describe 'size' do
    specify { expect(CacheQueue.new(name: 'size_test').set([1, 2, 3]).size).to be 3 }
  end

  describe 'reset' do
    let(:reset_lambda) do
      -> { %w[foo bar] }
    end

    let(:cache_queue) do
      CacheQueue.new(name: 'reset_test', reset: reset_lambda).set([1, 2, 3])
    end

    it 'uses return value of block to reset' do
      expect(cache_queue.fetch).to eq [1, 2, 3]
      cache_queue.reset
      expect(cache_queue.fetch).to eq %w[foo bar]
    end
  end
end
