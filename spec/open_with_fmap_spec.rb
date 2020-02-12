require './open_with_fmap'
require_relative 'shared_test'

RSpec.describe OpenWithFmap do
  it_behaves_like "Monad state machine"
end
