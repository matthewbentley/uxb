# Abstract device
class Device
  attr_reader :product_code, :serial_number, :version, :device_class,
              :connectors

  # Builds an abstract device
  class Builder
    attr_reader :version, :product_code, :serial_number, :connectors

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
      @connectors = conns.clone
      self
    end

    def validate
      raise 'Version number is needed' if version.nil?
    end
  end

  def recv(message, connector)
    raise 'connector must be in the device' unless connectors.include? connector
    if message.value.is_a? String
      recv_str(message, connector)
    elsif message.value.is_a? Numeric
      recv_bin(message, connector)
    else
      raise 'Unknown message type'
    end
  end
end
