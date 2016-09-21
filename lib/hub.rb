require 'forwardable'
require 'device'
require 'logger'

# Hub - a device
class Hub
  extend Forwardable
  include Device

  # Builds a hub
  class Builder < Device::Builder
    def initialize(version)
      super(version)
      self.connectors = []
      self.product_code = nil
      self.serial_number = nil
    end

    def build
      validate
      Hub.new(self)
    end

    def validate
      super
      unless connectors.include? :computer
        raise 'Need computer connector'
      end
      unless connectors.include? :peripheral
        raise 'Need peripheral connector'
      end
    end
  end

  def device_class
    :hub
  end

  def recv(_message, _connector)
    @logger.error('recv not yet supported')
  end

  def_delegator :@connectors, :[], :connector
  def_delegator :@connectors, :length, :connector_count

  private

  def initialize(builder)
    @product_code = builder.product_code
    @serial_number = builder.serial_number
    @connectors = build_connectors(builder.connectors)
    @version = builder.version
    @logger = Logger.new(STDOUT)
  end
end
