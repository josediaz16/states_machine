require_relative 'state_machines'

class OpenWithBinds
  def call(**input)
    last_valve_state = input[:last_uplink][:valve_state]

    if last_valve_state.eql?(:closed)

      return StateMachines::ValveStateMachine.(input, :closed)
        .bind do |valve_position_response|
          StateMachines::ShowedStateMachine.(valve_position_response, :closed)
        end

    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3

      state_machine_input = [input, :not_detected]

      return StateMachines::ValveStateMachine.(input, :not_detected)
        .bind do |valve_position_response|
          StateMachines::ShowedStateMachine.(*state_machine_input)
        end
        .bind do |showed_state_response|
          StateMachines::IncreaseCounter.(input, :pos_nd)
        end
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] >= 3

      state_machine_input = [input, :not_detected]

      return StateMachines::ValveStateMachine.(*state_machine_input)
        .bind do |valve_position_response|
          StateMachines::ShowedStateMachine.(*state_machine_input)
        end
        .bind do |showed_state_response|
          StateMachines::ResetCounter.(input, :pos_nd)
        end
        .bind do |update_counters_response|
          StateMachines::DesiredStateMachine.(input, :do_nothing)
        end
    end

    if input[:desired_state].eql?(:closed)

      state_machine_input = [input, :waiting_closed_downlink]

      return StateMachines::ValveStateMachine.(*state_machine_input)
        .bind do |showed_state_response|
          StateMachines::SetCounter.(input, :timeout, 7)
        end
        .bind do |update_counters_response|
          StateMachines::GenerateDownlink.(input)
        end
    end

    if input[:desired_state].eql?(:open) && last_valve_state.eql?(:open)

      state_machine_input = [input, :open]
      return StateMachines::ShowedStateMachine.(*state_machine_input)
    end
  end
end
