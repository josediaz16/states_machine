require_relative 'state_machines'
require 'byebug'

class OpenWithResult

  def call(input)
    last_valve_state = input[:last_uplink][:valve_state]

    if last_valve_state.eql?(:closed)
      fetch_device_response = StateMachines::FetchDevice.(input)

      response = if fetch_device_response.success?
        update_states_response = StateMachines::UpdateStates.(id: input[:id], machine_state: "closed", showed_state: "closed")
        if update_states_response.success?
          Dry::Monads::Success.new(input)
        else
          update_states_response
        end
      else
        fetch_device_response
      end

      return response
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3
      fetch_device_response = StateMachines::FetchDevice.(input)

      response = if fetch_device_response.success?

        update_states_response = StateMachines::UpdateStates.(id: input[:id], machine_state: "not_detected", showed_state: "not_detected")

        if update_states_response.success?
          StateMachines::IncreaseCounter.(input, :pos_nd)
        else
          update_states_response
        end

      else
        fetch_device_response
      end

      return response
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] >= 3
      fetch_device_response = StateMachines::FetchDevice.(input)

      response = if fetch_device_response.success?

        update_states_response = StateMachines::UpdateStates.(id: input[:id], machine_state: "not_detected", showed_state: "not_detected", desired_state: "do_nothing")

        if update_states_response.success?
          StateMachines::ResetCounter.(input, :pos_nd)
        else
          update_states_response
        end
      else
        fetch_device_response
      end

      return response
    end

    if input[:desired_state].eql?(:closed)
      fetch_device_response = StateMachines::FetchDevice.(input)

      response = if fetch_device_response.success?

        update_states_response = StateMachines::UpdateStates.(id: input[:id], machine_state: "waiting_closed_downlink", desired_state: "closed")

        if update_states_response.success?
          update_couters_reponse = StateMachines::SetCounter.(input, :timeout, 7)

          if update_couters_reponse.success?
            StateMachines::GenerateDownlink.(input)
          else
            update_couters_reponse
          end
        else
          update_states_response
        end
      else
        fetch_device_response
      end

      return response
    end

    if input[:desired_state].eql?(:open) && last_valve_state.eql?(:open)
      fetch_device_response = StateMachines::FetchDevice.(input)

      response = if fetch_device_response.success?
        update_states_response = StateMachines::UpdateStates.(id: input[:id], showed_state: "open")
        if update_states_response.success?
          Dry::Monads::Success.new(input)
        else
          update_states_response
        end
      else
        fetch_device_response
      end

      return response
    end

  end
end
