require 'dry/monads'

class OpenWithResult
  extend Dry::Monads[:result]

  ValveStateMachine = -> input, new_state do
    input[:machine_state] = new_state

    Success input
  end

  ShowedStateMachine = -> input, new_state do
    input[:showed_state] = new_state

    Success input
  end

  DesiredStateMachine = -> input, new_state do
    input[:desired_state] = new_state

    Success input
  end

  IncreaseCounter = -> input, counter do
    input[counter] += 1

    Success input
  end

  ResetCounter = -> input, counter do
    input[counter] = 0

    Success input
  end

  SetCounter = -> input, counter, number do
    input[counter] = number

    Success input
  end

  GenerateDownlink = -> input do
    input[:downlink][:sequence] += 1

    Success input
  end

  def call(input)
    last_valve_state = input[:last_uplink][:valve_state]

    if last_valve_state.eql?(:closed)
      #input[:machine_state] = :closed
      #input[:showed_state] = :closed

      valve_position_response = ValveStateMachine.(input, :closed)

      response = if valve_position_response.success?
        ShowedStateMachine.(input, :closed)
      else
        valve_position_response
      end
      return response
    end

    if last_valve_state.eql?(:not_detected) && input[:pos_nd] < 3
      #input[:machine_state] = :not_detected
      #input[:showed_state] = :not_detected
      #input[:pos_nd] += 1

      valve_position_response = ValveStateMachine.(input, :not_detected)

      response = if valve_position_response.success?
        showed_state_response = ShowedStateMachine.(input, :not_detected)

        if showed_state_response.success?
          IncreaseCounter.(input, :pos_nd)
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

      valve_position_response = ValveStateMachine.(input, :not_detected)

      response = if valve_position_response.success?
        showed_state_response = ShowedStateMachine.(input, :not_detected)

        if showed_state_response.success?
          update_couters_reponse = ResetCounter.(input, :pos_nd)

          if update_couters_reponse.success?
            DesiredStateMachine.(input, :do_nothing)
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

      valve_position_response = ValveStateMachine.(input, :waiting_closed_downlink)

      response = if valve_position_response.success?
        update_couters_reponse = SetCounter.(input, :timeout, 7)

        if update_couters_reponse.success?
          GenerateDownlink.(input)
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

      return ShowedStateMachine.(input, :open)
    end

  end
end
