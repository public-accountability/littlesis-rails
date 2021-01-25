# frozen_string_literal: true

# Just a simple wrapper to enable us to use FormMathCaptcha
class NewUserForm
  include ActiveModel::Model
  include FormMathCaptcha
end
