require 'forwardable'

module UXB
  # Generic message
  module Message
    extend Forwardable
    attr_reader :value

    def initialize(value)
      @value = value.nil? ? @default_value : value
      freeze
    end

    def_delegators :@value, :==
  end

  # Message with an integer value
  class BinaryMessage
    include Message
    @default_value = 0
  end

  # Message with a string value
  class StringMessage
    extend Forwardable
    include Message
    @default_value = ''

    def_delegators :@value, :[], :length, :include?, :start_with?, :end_with?
  end
end
