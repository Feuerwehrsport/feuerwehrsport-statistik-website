# frozen_string_literal: true

%w[
  mise.toml
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }
