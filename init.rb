require 'bundler'
ROOT_DIR = File.dirname(__FILE__)

Bundler.require
require_all File.join(ROOT_DIR, 'lib')