require 'active_support/time'

RSpec.shared_examples "Monad state machine" do
  let(:response) { subject.(**input) }
  let(:input) {
    {
      desired_state: :open,
      valve_state: :open,
      machine_state: :open,
      showed_state: :open,
      pos_nd: 0,
      timeout: 0,
      last_uplink: {
        time: (Time.now+ 1).to_i,
        valve_state: :open,
        d_sequence: 10
      },
      downlink: {
        time: (Time.now).to_i,
        sequence: 10
      }
    }
  }

  describe "#call" do
    context "The last position valve reported by uplink is closed" do
      it "should update the valve and showed state to closed" do
        input[:machine_state] = :open
        input[:last_uplink] = {
          time: (Time.now - 1.day).to_i,
          valve_state: :closed
        }

        expected_response = input.merge({
          machine_state: :closed,
          showed_state: :closed
        })

        expect(response).to be_success
        expect(response.success).to eq(expected_response)
      end
    end

    context "The last valve position reported by uplink is not_detected" do
      context "The Pos counter is lower than 3" do

        it "should update the valve and showed state to not_detected and sum 1 to the Pos counter" do
          input[:machine_state] = :open
          input[:pos_nd] = 1
          input[:last_uplink] = {
            time: (Time.now - 1.day).to_i,
            valve_state: :not_detected
          }

          expected_response = input.merge({
            last_uplink: {
              time: (Time.now - 1.day).to_i,
              valve_state: :not_detected
            },
            pos_nd: 2,
            machine_state: :not_detected,
            showed_state: :not_detected
          })

          expect(response).to be_success
          expect(response.success).to eq(expected_response)
        end
      end

      context "The Pos counter is higher or equal to 3" do
        it "should update the valve and showed state to not_detected and desired state to do_nothing" do
          input[:machine_state] = :open
          input[:pos_nd] = 4
          input[:last_uplink] = {
            time: (Time.now - 1.day).to_i,
            valve_state: :not_detected
          }

          expected_response = input.merge({
            last_uplink: {
              time: (Time.now - 1.day).to_i,
              valve_state: :not_detected
            },
            pos_nd: 0,
            machine_state: :not_detected,
            showed_state: :not_detected,
            desired_state: :do_nothing
          })

          expect(response).to be_success
          expect(response.success).to eq(expected_response)
        end
      end
    end

    context "The last user desired state is closed" do
      it "should build a Dowlink and update valve state to waiting_closed_downlink" do
        input[:desired_state] = :closed
        input[:machine_state] = :open

        expected_response = input.merge({
          desired_state: :closed,
          machine_state: :waiting_closed_downlink,
          timeout: 7,
        })

        expected_response[:downlink][:sequence] = 11

        expect(response).to be_success
        expect(response.success).to eq(expected_response)
      end
    end

    context "The last user desired state is open" do
      it "should update the valve and showed state to open" do
        input[:desired_state] = :open
        input[:machine_state] = :open

        expected_response = input.merge({
          desired_state: :open,
          machine_state: :open,
          showed_state: :open
        })

        expect(response).to be_success
        expect(response.success).to eq(expected_response)
      end
    end
  end
end
