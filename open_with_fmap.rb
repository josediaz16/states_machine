require 'dry/monads'
require_relative 'state_machines'
require_relative 'decision_maker'
require_relative 'trigger_downlink'

class OpenWithFmap

  include Dry::Monads[:try, :result]

  def call(**input)
    result = StateMachines::FetchDevice.(input)
      .fmap(DecisionMaker::GetNextStates)
      .bind(DecisionMaker::UpdateStates)
      .bind(DecisionMaker::IncreaseCounter)
      .bind(DecisionMaker::ResetCounter)
      .bind(DecisionMaker::SetCounter)
      .bind do |acc|
        Try(IotClient::DeviceError) { DecisionMaker::GenerateDownlink.(acc) }
          .to_result
          .fmap { acc }
      end
    process_result(result)
  end

  def process_result(result)
    case result
    in Failure(:device_not_found)
    in Failure(IotClient::DeviceError)
    in Some(Float | String)
    in Success(_)
      Success(:ok)
    end
  end

end
