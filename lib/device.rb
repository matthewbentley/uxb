require 'connector'

module UXB
  # Abstract device
  module Device
    attr_reader :product_code, :serial_number, :version, :device_class,
                :connectors

    # Builds an abstract device
    class Builder
      attr_reader :version, :product_code, :serial_number

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

      def connectors
        @connectors.clone
      end

      def validate
        raise 'Version number is needed' if version.nil?
      end
    end

    def recv(message, connector)
      raise 'connector must be in device' unless connectors.include? connector
      if message.value.is_a? String
        recv_str(message, connector)
      elsif message.value.is_a? Numeric
        recv_bin(message, connector)
      else
        raise 'Unknown message type'
      end
    end

    def build_connectors(conn_types)
      real_conns = []
      conn_types.each.with_index do |type, i|
        real_conns.push(Connector.new(self, i, type))
      end
      real_conns
    end

    def initialize(builder)
      @version = builder.version
      @product_code = builder.product_code
      @serial_number = builder.serial_number
      @connectors = build_connectors(builder.connectors)
      @logger = Logger.new(STDOUT)
    end
  end
end
