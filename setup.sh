#!/bin/bash

set -o pipefail

if which rvm >/dev/null; then
    rvm use system
fi

sudo gem install bundler -n /usr/local/bin --no-rdoc --no-ri 
bundle install --path=vendor/bundle --without=documentation

bundler exec pod install
