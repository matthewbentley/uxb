# UXB
module UXB
  def broadcast(devices, messages)
    devices.each do |device|
      messages.each do |message|
        message.reach(device, device.connectors[0])
      end
    end
  end
end
