class IotClient
  class DeviceError < StandardError
  end

  def initialize(url)
    @url = url
  end

  def generate_downlink(id, payload)
    ids = (-5..-1).to_a

    if ids.include?(id)
      raise DeviceError.new "device can't be reached"
    else
      { id: id, name: "device#{id}" }
    end
  end
end

class TriggerDownlink
  BASE_COUNTER = 44343

  def initialize(iot_client)
    @iot_client = iot_client
  end

  def call(input)
    payload = "000000" + input[:sequence].to_s + "2" + (input[:sequence] * BASE_COUNTER).to_s
    @iot_client.generate_downlink(input[:id], payload)
  end
end

class EmailClient
  def self.notify_error(message)
    :ok
  end
end
