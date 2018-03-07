# frozen_string_literal: true

# Simple typechecker
# ::examples::
#    TypeCheck.check 'hello', String
#    TypeCheck.check 123, [Array, Integer]
#
# if included in a class, it provides the method type_check()
module TypeCheck
  delegate :check, to: 'TypeCheck', prefix: :type

  def self.check(val, valid_types, allow_subclass: true)
    check_method = allow_subclass ? :is_a? : :instance_of?

    Array.wrap(valid_types).each do |valid_type|
      return true if val.send(check_method, valid_type)
    end

    raise TypeError, "wrong argument type #{val.class} (expected #{Array.wrap(valid_types).join(',')})"
  end
end
