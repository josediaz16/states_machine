require 'dry/monads'
require_relative 'db'

module StateMachines
  extend Dry::Monads[:result]

  FetchDevice = -> input do
    device = DeviceRepository[input[:id]]
    if device.empty?
      Failure(:device_not_found)
    else
      Success(input)
    end
  end

  UpdateStates = -> input do
    valid_fields = input.slice(:desired_state, :machine_state, :showed_state)
    DeviceRepository.update(input[:id], **valid_fields)
  end

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

end
