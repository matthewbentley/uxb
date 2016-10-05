require 'forwardable'
require 'device'
require 'logger'

module UXB
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
        raise 'Need computer connector' unless connectors.include? :computer
        raise 'Need peripheral connector' unless connectors.include? :peripheral
      end
    end

    def device_class
      :hub
    end

    def recv(message, connector)
      connectors.reject { |c| c == connector || c.peer.nil? }
                .each   { |c| c.peer.recv(message) }
    end

    def_delegator :@connectors, :[], :connector
    def_delegator :@connectors, :length, :connector_count
  end
end
