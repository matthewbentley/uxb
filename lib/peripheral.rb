require 'device'
require 'logger'

module UXB
  # An abstract peripheral
  class Peripheral
    include Device
    def initialize(builder)
      @version = builder.version
      @product_code = builder.product_code
      @serial_number = builder.serial_number
      @connectors = build_connectors(builder.connectors)
      @logger = Logger.new(STDOUT)
    end
  
    # Builder for the abstract peripheral
    class Builder < Device::Builder
      def initialize(version)
        super(version)
      end
  
      def validate
        super
        if connectors.any? { |c| c != :peripheral }
          raise 'Connectors must be peripherals'
        end
      end
    end
  end
  
  # A sister printer
  class SisterPrinter < Peripheral
    def device_class
      :PRINTER
    end
  
    # Builder for the sister printer
    class Builder < Peripheral::Builder
      def build
        validate
        SisterPrinter.new(self)
      end
    end
  
    def recv_str(message, _connector)
      @logger.info('Sister printer has printed the string: ' + message.value +
                   ' ' + String(serial_number.to_i))
    end
  
    def recv_bin(message, _connector)
      @logger.info('Sister printer has printed the binary message: ' +
                   String(message.value + product_code.to_i))
    end
  end
  
  # A cannon printer
  class CannonPrinter < Peripheral
    def device_class
      :PRINTER
    end
  
    # Builder for the cannon printer
    class Builder < Peripheral::Builder
      def build
        validate
        CannonPrinter.new(self)
      end
    end
  
    def recv_str(message, _connector)
      @logger.info('Cannon printer has printed the string: ' + message.value +
                   ' ' + String(version))
    end
  
    def recv_bin(message, _connector)
      @logger.info('Cannon printer has printed the binary message: ' +
                   String(message.value * serial_number.to_i))
    end
  end
  
  # A Go Amateur device
  class GoAmateur < Peripheral
    def device_class
      :VIDEO_DEVICE
    end
  
    # Builder for the Go Amateur device
    class Builder < Peripheral::Builder
      def build
        validate
        GoAmateur.new(self)
      end
    end
  
    def recv_str(message, connector)
      idx = connectors.index connector
      @logger.error('GoAmateur does not understand string messages: ' +
                   message.value + ' ' + String(idx))
    end
  
    def recv_bin(message, _connector)
      @logger.warn('GoAmateur is not yet active: ' + String(message.value))
    end
  end
end
