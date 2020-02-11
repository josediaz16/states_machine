require 'dry/monads'
require_relative 'db'
require 'byebug'

module StateMachines
  extend Dry::Monads[:result, :maybe]

  FetchDevice = -> input do
    device = DeviceRepository[input[:id]]
    Maybe(device)
      .fmap { input }
      .to_result(:device_not_found)
  end

  UpdateStates = -> input do
    valid_fields = input.slice(:desired_state, :machine_state, :showed_state)
    updated = DeviceRepository.update(input[:id], **valid_fields)

    Maybe(updated)
      .fmap { input }
      .to_result(:update_failed)
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
