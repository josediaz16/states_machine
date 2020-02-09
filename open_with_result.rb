require_relative 'state_machines'

class OpenWithResult

  def call(input)
    last_valve_state = input[:last_uplink][:valve_state]

    if last_valve_state.eql?(:closed)
      #input[:machine_state] = :closed
      #input[:showed_state] = :closed

      valve_position_response = StateMachines::ValveStateMachine.(input, :closed)

      response = if valve_position_response.success?
        StateMachines::ShowedStateMachine.(input, :closed)
      else
        valve_position_response
      end
      return response
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3
      #input[:machine_state] = :not_detected
      #input[:showed_state] = :not_detected
      #input[:pos_nd] += 1

      valve_position_response = StateMachines::ValveStateMachine.(input, :not_detected)

      response = if valve_position_response.success?
        showed_state_response = StateMachines::ShowedStateMachine.(input, :not_detected)

        if showed_state_response.success?
          StateMachines::IncreaseCounter.(input, :pos_nd)
        else
          showed_state_response
        end
      else
        valve_position_response
      end

      return response
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] >= 3
      #input[:machine_state] = :not_detected
      #input[:desired_state] = :do_nothing
      #input[:showed_state] = :not_detected
      #input[:pos_nd] = 0

      valve_position_response = StateMachines::ValveStateMachine.(input, :not_detected)

      response = if valve_position_response.success?
        showed_state_response = StateMachines::ShowedStateMachine.(input, :not_detected)

        if showed_state_response.success?
          update_couters_reponse = StateMachines::ResetCounter.(input, :pos_nd)

          if update_couters_reponse.success?
            StateMachines::DesiredStateMachine.(input, :do_nothing)
          else
            update_couters_reponse
          end
        else
          showed_state_response
        end
      else
        valve_position_response
      end

      return response
    end

    if input[:desired_state].eql?(:closed)
      #input[:downlink][:sequence] += 1
      #input[:timeout] = 7
      #input[:machine_state] = :waiting_closed_downlink

      valve_position_response = StateMachines::ValveStateMachine.(input, :waiting_closed_downlink)

      response = if valve_position_response.success?
        update_couters_reponse = StateMachines::SetCounter.(input, :timeout, 7)

        if update_couters_reponse.success?
          StateMachines::GenerateDownlink.(input)
        else
          update_couters_reponse
        end
      else
        valve_position_response
      end

      return response
    end

    if input[:desired_state].eql?(:open) && last_valve_state.eql?(:open)
      #input[:showed_state] = :open

      return StateMachines::ShowedStateMachine.(input, :open)
    end

  end
end
