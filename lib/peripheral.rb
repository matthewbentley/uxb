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
      @logger.info { str_msg(message) }
    end

    def recv_bin(message, _connector)
      @logger.info { bin_msg(message) }
    end
  end

  # A sister printer
  class SisterPrinter < APrinter
    def name
      'Sister'
    end

    def str_msg(message)
      "Sister printer has printed the string: #{message.value} #{serial_number}"
    end

    def bin_msg(message)
      "Sister printer has printed the bin message: #{message.value}
        #{product_code}"
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

    def str_msg(message)
      "Cannon printer has printed the string: #{message.value} #{version}"
    end

    def bin_msg(message)
      product = serial_number.nil? ? '' : message.value * serial_number
      "Cannon printer has printed the bin message: #{message.value} #{product}"
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

    def recv_bin(_message, _connector)
      m = BinaryMessage.new(293)
      connectors.each { |c| c.peer.recv(m) unless c.peer.nil? }
    end
  end
end
