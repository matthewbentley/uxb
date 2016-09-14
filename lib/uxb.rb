# Generic connector
class Connector
  def initialize(device, index, type)
    @device = device
    @type = type
    @index = index
    @peer = nil
  end

  attr_reader :type, :index, :peer, :device
end

# Generic message
class Message
end

# Message with an integer value
class BinaryMessage < Message
  def initialize(value)
    @value = value
  end

  attr_reader :value

  def ==(other)
    value == other.value
  end
end

# Generic device
class Device
  attr_reader :product_code, :serial_number, :version, :device_class,
              :connectors

  def connector(index)
    connectors[index]
  end

  def connector_count
    connectors.length
  end
end

# Abstract device
class AbstractDevice < Device
  # Builds an abstract device
  class Builder
    attr_reader :product_code, :version, :serial_number

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
end

# Hub - a device
class Hub < AbstractDevice
  # Builds a hub
  class Builder < AbstractDevice::Builder
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
    # TODO: handle exception??
  end
end
