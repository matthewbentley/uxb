require 'connector'
require 'message'

module UXB
  # Abstract device
  module Device
    RECV_METHOD = {
      StringMessage => :recv_str,
      BinaryMessage => :recv_bin
    }.freeze

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

      send RECV_METHOD.fetch(message.class), message, connector
    end

    def build_connectors(conn_types)
      conn_types.map.with_index do |type, i|
        Connector.new(self, i, type)
      end
    end

    def initialize(builder)
      @version = builder.version
      @product_code = builder.product_code
      @serial_number = builder.serial_number
      @connectors = build_connectors(builder.connectors)
      @logger = Logger.new(STDOUT)
    end

    def peer_devices
      connectors.map { |conn| conn.peer&.device }.compact
    end

    def reachable_devices
      # re-write to work even with cycles?
      device_enumerator
    end

    def reachable?(other)
      device_enumerator { |d| return true if d == other }
      false
    end

    private

    def device_enumerator
      devs = peer_devices
      index = 0
      loop do
        return devs.reject { |d| d == self } if index == devs.length
        yield devs[index] if block_given?
        devs += devs[index].peer_devices.reject { |d| devs.include? d }
        index += 1
      end
    end
  end
end
