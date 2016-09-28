require 'device'
require 'logger'

module UXB
  # An abstract peripheral
  class Peripheral
    include Device
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

  # A printer
  class APrinter < Peripheral
    def device_class
      :PRINTER
    end

    # A Printer builder
    class Builder < Peripheral::Builder
      def build
        validate
        make
      end

      private

      def make
      end
    end

    def recv_str(message, _connector)
      @logger.info do
        name + ' printer has printed the string: ' + message.value + ' ' +
          String(serial_number.to_i)
      end
    end

    def recv_bin(message, _connector)
      @logger.info do
        name + ' printer has printed the binary message: ' +
          String(message.value + product_code.to_i)
      end
    end
  end

  # A sister printer
  class SisterPrinter < APrinter
    def name
      'Sister'
    end

    # A Sister builder
    class Builder < APrinter::Builder
      private

      def make
        SisterPrinter.new(self)
      end
    end
  end

  # Cannon printer
  class CannonPrinter < APrinter
    def name
      'Cannon'
    end

    # Cannon builder
    class Builder < APrinter::Builder
      private

      def make
        CannonPrinter.new(self)
      end
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
      @logger.error do
        'GoAmateur does not understand string messages: ' + message.value +
          ' ' + String(idx)
      end
    end

    def recv_bin(message, _connector)
      @logger.warn { 'GoAmateur is not yet active: ' + String(message.value) }
    end
  end
end
