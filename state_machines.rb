require 'dry/monads'
require_relative 'db'
require_relative 'trigger_downlink'

module StateMachines
  extend Dry::Monads[:result, :maybe, :try]

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
      TriggerDownlink
        .new(IotClient.new("https://amazon.iot/waico/devices"))
        .call(id: input[:id], sequence: 1)
  end

end
