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

    def peer_devices(exclude: nil)
      connectors.map { |conn| conn.peer&.device }
                .compact
                .reject { |i| i == exclude }
    end

    def reachable_devices(exclude: nil)
      # re-write to work even with cycles?
      peer_devices(exclude: exclude).reduce([]) do |all, one|
        all + [one] + one.reachable_devices(exclude: self)
      end
    end

    def reachable?(other, exclude: nil)
      return true if connectors.map { |conn| conn.peer&.device }.include? other
      peer_devices(exclude: exclude).each do |i|
        return true if i.reachable?(other, exclude: self)
      end
      false
    end
  end
end
