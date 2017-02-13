#!/bin/bash

spec() {
    RAILS_ENV=test bundle exec spring rspec "$@"
}

export -f spec
