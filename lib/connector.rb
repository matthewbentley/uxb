require 'connection_error'
module UXB
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

    def recv(message)
      device.recv(message, self)
    end

    def peer=(other)
      raise 'Peer must not be nil' if other.nil?
      unless @peer.nil? && other.peer.nil?
        raise ConnectionError, :CONNECTOR_BUSY
      end
      raise ConnectionError, :CONNECTOR_MISMATCH if @type == other.type
      raise ConnectionError, :CONNECTION_CYCLE if reachable?(other.device)

      @peer = other
      other.simple_set_peer(self)
    end

    def reachable?(other)
      @device.reachable?(other)
    end

    protected

    def simple_set_peer(other)
      @peer = other
    end
  end
end
