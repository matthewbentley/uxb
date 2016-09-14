# Generic connector
class Connector
  attr_reader :type, :index, :device
  attr_accessor :peer

  def initialize(device, index, type)
    @device = device
    @type = type
    @index = index
    @peer = nil
  end
end

# Generic message
class Message
end

# Message with an integer value
class BinaryMessage < Message
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def ==(other)
    value == other.value
  end
end

# Abstract device
class Device
  extend Forwardable
  attr_reader :product_code, :serial_number, :version, :device_class,
              :connectors

  # Builds an abstract device
  class Builder
    def initialize(version)
      @version = version
    end

    def product_code=(code)
      @product_code = code
      self
    end

    def serial_number=(serial)
      @serial_number = serial
      self
    end

    def connectors=(conns)
      @connectors = conns
      self
    end

    def connectors
      @connectors.map(&:type)
    end

    def validate
      raise 'Version number is needed' if version.nil?
    end
  end

  def initialize(builder)
    @product_code = builder.product_code
    @serial_number = builder.serial_number
    @connectors = builder.connectors
    @version = builder.version
  end

  def_delegator :@connectors, :[], :connector
  def_delegator :@connectors, :length, :connector_count
end

# Hub - a device
class Hub < Device
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
      raise 'Need computer connector' unless connectors.include? :computer
      raise 'Need peripheral connector' unless connectors.include? :peripheral
    end
  end

  def device_class
    :hub
  end

  private

  def initialize(builder)
    super
  end
end
