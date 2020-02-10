require "rom-sql"
require "rom-repository"

module Relations
  # This relation is for the `devices` table.
  class Devices < ROM::Relation[:sql]
    # Define a canonical schema for this relation. This will be used when we
    # use commands to make changes to our data. It ensures that only
    # appropriate attributes are written through to the database table.
    schema(:devices) do
      attribute :id, Types::Serial
      attribute :machine_state, Types::String
      attribute :desired_state, Types::String
      attribute :showed_state, Types::String
    end

    # Define some composable, reusable query methods to return filtered
    # results from our database table. We'll use them in a moment.
    def by_id(id)
      where(id: id)
    end

  end
end

# ### Repositories
#
# Now, let's define a **Repository**. Repositories are the primary persistence
# interfaces in our app. Responsitories contribute a couple of important things
# to a well-designed app:
#
# 1. They hide low-level persistence details, ensuring the rest of our app
#    doesn't have any accidental or unnecessary coupling to the implementation
#    details for our data source.
# 2. They return objects that are appropriate for our app's domain. The data
#    for these objects may come from one or more relations, may be transformed
#    into a different shape, and may be returned as objects that are designed
#    to be passed around the other components in our app.
module Repositories
  # This simple repository uses devices as its main relation.
  class Devices < ROM::Repository[:devices]
    # Define a command to create new devices.
    commands :create, update: :by_pk

    # Define methods to return the device objects we want to use within our
    # app. Each of these can access the relation via `devices` and use its
    # query methods.
    #
    # Unlike the query methods inside the relations, these ones should not be
    # chainable. Their purpose is to return a set of devices for each
    # distinct use case within our app. This means that our repository API
    # (and therefore our persistence API in general) is a perfect reflection
    # of our app's persistence requirements.
    def [](id)
      devices.by_id(id).one!
    end

  end
end

# ## Initialize rom-rb
#
# rom-rb is built to be non-intrusive. When we initialize it here, all our
# relations and commands are bundled into a single container that we can
# inject into our app.
#
# In any kind of framework, this setup will be taken care of for us, but
# because rom-rb is flexible, explicit setup for our playground is still nice
# and easy.

# Configure rom-rb to use an in-memory SQLite database via its SQL adapter,
# register our articls relation, then build and finalize the persistence
# container.
config = ROM::Configuration.new(:sql, "sqlite::memory")
config.register_relation Relations::Devices
container = ROM.container(config)

# ## Prepare our database
#
# Since this is a standalone playground, run a migration to give us a database
# table to work with.
container.gateways[:default].tap do |gateway|
  migration = gateway.migration do
    change do
      create_table :devices do
        primary_key :id
        string :machine_state, null: false
        string :desired_state, null: false
        string :showed_state, null: false
      end
    end
  end
  migration.apply gateway.connection, :up
end

DeviceRepository = Repositories::Devices.new(container)
