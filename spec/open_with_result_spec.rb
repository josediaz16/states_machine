require './open_with_result'
require_relative 'shared_test'

RSpec.describe OpenWithResult do
  it_behaves_like "Monad state machine"
end
