class Open
  def call(input)
    last_valve_state = input[:last_uplink][:valve_state]

    if last_valve_state.eql?(:closed)
      input[:machine_state] = :closed
      input[:showed_state] = :closed
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3
      input[:machine_state] = :not_detected
      input[:showed_state] = :not_detected
      input[:pos_nd] += 1
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] >= 3
      input[:machine_state] = :not_detected
      input[:desired_state] = :do_nothing
      input[:showed_state] = :not_detected
      input[:pos_nd] = 0
    end

    if input[:desired_state].eql?(:closed)
      input[:downlink][:sequence] += 1
      input[:timeout] = 7
      input[:machine_state] = :waiting_closed_downlink
    end

    if input[:desired_state].eql?(:open) && last_valve_state.eql?(:open)
      input[:showed_state] = :open
    end

    input
  end
end
