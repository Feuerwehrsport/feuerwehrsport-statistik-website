SchemaValidations.setup do |config|

    # Whether to automatically create validations based on database constraints.
    # (Can be set false globally to disable the gem by default, and set true per-model to enable.)
    config.auto_create = true

    # Restricts the set of field names to include in automatic validation.
    # Value is a single name, an array of names, or nil.
    config.only = nil

    # Restricts the set of validation types to include in automatic validation.
    # Value is a single type, an array of types, or nil.
    # A type is specified as, e.g., `:validates_presence_of` or simply `:presence`.
    config.only_type = nil

    # A list of field names to exclude from automatic validation.
    # Value is a single name, an array of names, or nil.
    # (Providing a value per-model will completely replace a globally-configured list)
    config.except = nil

    # A list of validation types to exclude from automatic validation.
    # Value is a single type, an array of types, or nil.
    # (Providing a value per-model will completely replace a globally-configured list)
    config.except_type = nil

    # The base set of field names to always exclude from automatic validation.
    # Value is a single name, an array of names, or nil.
    # (This whitelist applies after all other considerations, global or per-model)
    config.whitelist = [:created_at, :updated_at, :created_on, :updated_on]

    # The base set of validation types to always exclude from automatic validation.
    # Value is a single type, an array of types, or nil.
    # (This whitelist applies after all other considerations, global or per-model)
    config.whitelist_type = nil
end