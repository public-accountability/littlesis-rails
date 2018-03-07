require 'rails_helper'

describe TypeCheck do
  it 'return true if is valid input' do
    expect { TypeCheck.check [1, 2, 3], Array }.not_to raise_error
    expect(TypeCheck.check([1, 2, 3], Array)).to be true
  end

  it 'raises type error if provided invalid class' do
    expect { TypeCheck.check [1, 2, 3], String }
      .to raise_error(TypeError)
  end

  it 'can check multiple types' do
    expect { TypeCheck.check [1, 2, 3], [String, Array] }
      .not_to raise_error
  end

  it 'checks subclasses by default (using is_a?)' do
    expect { TypeCheck.check Entity.new, ActiveRecord::Base }
      .not_to raise_error
  end

  it 'does strict checking if enabled (using instance_of?)' do
    expect { TypeCheck.check Entity.new, ActiveRecord::Base, allow_subclass: false }
      .to raise_error(TypeError)
  end

  context 'as a mixin' do
    class IAcceptOnlyIntegers
      include TypeCheck

      def initialize(this_better_be_an_int)
        type_check this_better_be_an_int, Integer
      end
    end

    it 'available as "type_check()" if included in a class' do
      expect { IAcceptOnlyIntegers.new('123') }
        .to raise_error(TypeError)

      expect { IAcceptOnlyIntegers.new(123) }
        .not_to raise_error
    end
  end
end

