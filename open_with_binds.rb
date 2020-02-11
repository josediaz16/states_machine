require_relative 'state_machines'

class OpenWithBinds
  include Dry::Monads[:result]

  def call(**input)
    last_valve_state = input[:last_uplink][:valve_state]

    if last_valve_state.eql?(:closed)

      return StateMachines::FetchDevice.(input)
        .bind do |fetch_device_response|
          StateMachines::UpdateStates.(id: input[:id], machine_state: "closed", showed_state: "closed")
        end
        .bind { Success input }
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3

      return StateMachines::FetchDevice.(input)
        .bind do |fetch_device_response|
          StateMachines::UpdateStates.(id: input[:id], machine_state: "not_detected", showed_state: "not_detected")
        end
        .bind do |showed_state_response|
          StateMachines::IncreaseCounter.(input, :pos_nd)
        end
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] >= 3

      return StateMachines::FetchDevice.(input)
        .bind do |fetch_device_response|
          StateMachines::UpdateStates.(id: input[:id], machine_state: "not_detected", showed_state: "not_detected", desired_state: "do_nothing")
        end
        .bind do |showed_state_response|
          StateMachines::ResetCounter.(input, :pos_nd)
        end
    end

    if input[:desired_state].eql?(:closed)

      return StateMachines::FetchDevice.(input)
        .bind do |fetch_device_response|
          StateMachines::UpdateStates.(id: input[:id], machine_state: "waiting_closed_downlink", desired_state: "closed")
        end
        .bind do |showed_state_response|
          StateMachines::SetCounter.(input, :timeout, 7)
        end
        .bind do |update_counters_response|
          StateMachines::GenerateDownlink.(input)
        end
    end

    if input[:desired_state].eql?(:open) && last_valve_state.eql?(:open)

      return StateMachines::FetchDevice.(input)
        .bind do |fetch_device_response|
          StateMachines::UpdateStates.(id: input[:id], showed_state: "open")
        end
        .bind do |showed_state_response|
          Success input
        end
    end
  end
end
