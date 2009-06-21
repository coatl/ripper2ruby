require File.dirname(__FILE__) + '/test_helper'
# require File.dirname(__FILE__) + '/vendor/diff'
require 'diff/lcs'
require 'diff/lcs/hunk'

SRC = <<-eoc
require 'ruby/node/source'

module Ruby
  class Node
  end
end
eoc

LIBS = {
  :self => {
    :path => File.dirname(__FILE__) + '/../'
  },
  :rails => {
    :path => '~/Development/shared/rails/rails',
    :exclude => [
      'tmail/obsolete.rb',                         # nested array access, queue opener tokens before pushing them?
      'action_controller/verification.rb',
      
      'tmail/parser.rb',
      
      'environment.rb',                            # erb file
      '/templates/',
    ]
  },
  :ruby => {
    :path => '/usr/local/ruby19/lib/ruby/1.9.1',
    :exclude => [
      'tktable.rb'                # invalid array access syntax? sexp fails on: [idx [a, b]]
    ]
  },
  :adva_cms => {
    :path => '~/Development/projects/adva_cms/adva_cms',
    :exclude => []
  }
}


class SelfTest < Test::Unit::TestCase
  include TestHelper

  def filenames(root)
    Dir["#{root}/**/*.rb"].sort
  end

  def read_file(filename)
    src = File.read(filename)
    src = File.open(filename, 'r:iso-8859-1') { |f| f.read } unless src.valid_encoding?
    src
  end

  def xtest_library_build
    lib = LIBS[:rails]
    filenames(File.expand_path(lib[:path])).each do |filename|
      next if filename <= '/Users/sven/Development/shared/rails/rails/actionpack/lib/action_controller/mime_responds.rb'
      next if Array(lib[:exclude]).any? { |exclude| filename.index(exclude) }

      puts filename
      src = read_file(filename)
      result = build(src).to_ruby
      unless src == result
        puts diff(src, result)
        break
      end
      assert_equal src, result
    end
  end

  def test_tmp_file
    src = File.read(File.dirname(__FILE__) + '/fixtures/tmp.rb')
    pp sexp(src)
    result = build(src).to_ruby(true)
    assert_equal src, result
    # puts diff(src, result)
  end

  def xtest_src
    assert_equal SRC, build(SRC).to_ruby(true)
  end

  def xtest_this
    src = ':"#{self}"'
    assert_equal src, build(src).to_ruby(true)
  end
end