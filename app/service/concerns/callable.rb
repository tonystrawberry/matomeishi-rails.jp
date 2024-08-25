# frozen_string_literal: true

# Module to make a class callable with .call method
# Usage:
#   class MyService
#     include Callable
#     def initialize(args)
#       @args = args
#     end
#     def call
#       # do something
#     end
#   end
#
#   MyService.call(args)
module Callable
  extend ActiveSupport::Concern

  class_methods do
    def call(**args)
      new(**args).call
    end
  end
end
