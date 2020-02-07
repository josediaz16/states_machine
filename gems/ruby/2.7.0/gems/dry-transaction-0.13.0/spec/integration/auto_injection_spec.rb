# require "dry-monads"
# require "dry-auto_inject"

# RSpec.describe "Using dry-auto_inject" do
#   let(:transaction) {
#     Class.new do
#       include Dry::Transaction(container: Test::Container)
#       include Test::Inject[:extract_email]

#       step :symbolize

#       def call(input)
#         super(input).bind(extract_email)
#       end
#     end.new
#   }

#   before do
#     module Test
#       Container = {
#         symbolize: -> input { Dry::Monads::Right(name: input["name"], email: input["email"]) },
#         extract_email: -> input { Dry::Monads::Right(email: input[:email]) },
#       }

#       Inject = Dry::AutoInject(container: Container)
#     end
#   end

#   it "support auto-injection of dependencies alongside step operations" do
#     expect(transaction.("name" => "Jane", "email" => "jane@example.com").value).to eq(email: "jane@example.com")
#   end
# end
