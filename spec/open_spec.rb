require './db'
require './open'
require 'active_support/time'

RSpec.describe Open do
  let(:response) { subject.(input) }
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
    context "The device does not exist" do
      it "Should raise an exception" do
        expect { response }.to raise_error(StandardError)
      end
    end

    context "The device exists" do
       let(:input)  { super().merge(id: device.id) }
       let(:device) { DeviceRepository.create(showed_state: "open", desired_state: "open", machine_state: "open") }

       context "The last position valve reported by uplink is closed" do
         it "should update the valve and showed state to closed" do
           input[:last_uplink] = {
             time: (Time.now - 1.day).to_i,
             valve_state: :closed
           }

           expect(response).to eq(input)
           persisted_device = DeviceRepository[device.id]

           expect(persisted_device.machine_state).to eq("closed")
           expect(persisted_device.showed_state).to eq("closed")
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
             })
 
             expect(response).to match(expected_response)
             persisted_device = DeviceRepository[device.id]
            
             expect(persisted_device.machine_state).to eq("not_detected")
             expect(persisted_device.showed_state).to eq("not_detected")
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
 
             expect(response).to match(expected_response)
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
 
           expect(response).to match(expected_response)
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
 
           expect(response).to match(expected_response)
         end
       end
    end
  end
end
