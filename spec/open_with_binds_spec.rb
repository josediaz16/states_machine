require './open_with_binds'
require_relative 'shared_test'

RSpec.describe OpenWithBinds do
  it_behaves_like "Monad state machine"
end
