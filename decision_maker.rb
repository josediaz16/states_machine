require 'dry/monads'
require_relative 'state_machines'

class OptionsPerState < Struct.new(:next_states, :set_counter, :reset_counter, :increase_counter, :generate_downlink)
  def initialize(next_states:, set_counter: false, reset_counter: false, increase_counter: false, generate_downlink: false)
    super(next_states, set_counter, reset_counter, increase_counter, generate_downlink)
  end
end

module DecisionMaker
  # This module exist only to encapsulate logic to decide
  # whether to execute an action or not based on input
  # value

  extend Dry::Monads[:result, :maybe, :try]

  IncreaseCounter = -> input do
    if input[:options][:increase_counter]
      StateMachines::IncreaseCounter.(input, :pos_nd)
    else
      Success input
    end
  end

  ResetCounter = -> input do
    if input[:options][:reset_counter]
      StateMachines::ResetCounter.(input, :pos_nd)
    else
      Success input
    end
  end

  SetCounter = -> input do
    if input[:options][:set_counter]
      StateMachines::SetCounter.(input, :timeout, 7)
    else
      Success input
    end
  end

  GenerateDownlink = -> input do
    if input[:options][:generate_downlink]
      StateMachines::GenerateDownlink.(input)
    else
      input
    end
  end

  UpdateStates = -> input do
    StateMachines::UpdateStates.(id: input[:id], **input[:options][:next_states])
      .fmap { input }
  end

  GetNextStates = -> input do
    input.merge(options: FeaturesPerState[input])
  end

  FeaturesPerState = -> input do
    case input
    in {last_uplink: {valve_state: :closed}}
      OptionsPerState.new(next_states: {machine_state: "closed", showed_state: "closed"})

    in {last_uplink: {valve_state: :not_detected}, pos_nd:} if pos_nd < 3
      OptionsPerState.new(
        next_states: {machine_state: "not_detected", showed_state: "not_detected"},
        increase_counter: true
      )

    in {last_uplink: {valve_state: :not_detected}, pos_nd:} if pos_nd >= 3
      OptionsPerState.new(
        next_states: {machine_state: "not_detected", showed_state: "not_detected", desired_state: "do_nothing"},
        reset_counter: true
      )

    in {desired_state: :closed}
      OptionsPerState.new(
        next_states: {machine_state: "waiting_closed_downlink", desired_state: "closed"},
        set_counter: true,
        generate_downlink: true
      )

    in {last_uplink: {valve_state: :open}, desired_state: :open}
      OptionsPerState.new(next_states: {showed_state: "open"})
    end
  end
end
