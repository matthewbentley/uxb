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

    def recv(_message)
    end
  end
end
