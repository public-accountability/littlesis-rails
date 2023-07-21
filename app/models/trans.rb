# frozen_string_literal: true

# We have a model called "Transaction"
# that is one of the relationship categories.
# This is an unfortunately named model, because
# ` relationship.transaction ` is an ActiveRecord method
# that starts a database transaction

# In relationship.rb, the association is setup like such:
#    has_one :trans, class_name: "Transaction"
# which mostly solves the problem. However, because relationship
# association models are sometimes constantized from strings, it is
# helpful to be able to use `Trans` to refer to a Transaction

Trans = Transaction
