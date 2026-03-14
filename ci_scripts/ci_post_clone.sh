#!/bin/sh

# Install dependencies you manage with Arkana.
bundle install

# Install swiftlint
brew install swiftlint || true
