require 'byebug'

class Open
  def call(input)
    last_valve_state = input[:last_uplink][:valve_state]
    result = false

    if device_exists?(input[:id])
      puts "i kill u"

      if last_valve_state.eql?(:closed)
        result = update_device(input[:id], machine_state: "closed", showed_state: "closed")
      end

      if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3
        if update_device(input[:id], machine_state: "not_detected", showed_state: "not_detected")
          input[:pos_nd] += 1 #replace with something fancy
          result = true
        end
      end

      if last_valve_state.eql?(:not_detected) && input[:pos_nd] >= 3
        if update_device(input[:id], machine_state: "not_detected", showed_state: "not_detected", desired_state: "do_nothing")
          input[:pos_nd] = 0
          result = true
        end
      end

      if input[:desired_state].eql?(:closed)
        if update_device(input[:id], machine_state: "waiting_closed_downlink")
          input[:downlink][:sequence] += 1
          input[:timeout] = 7
          result = true
        end
      end

      if input[:desired_state].eql?(:open) && last_valve_state.eql?(:open)
        update_device(input[:id], showed_state: "open")
        result = true
      end
      input
    else
      raise :device_not_found
    end
  end

  def device_exists?(id)
    !DeviceRepository[id].nil?
  end

  def update_device(id, input)
    begin
      valid_fields = input.slice(:machine_state, :showed_state, :desired_state)
      DeviceRepository.update(id, **valid_fields) != nil
    rescue ROM::SQL::Error => error
      false
    end
  end
end
