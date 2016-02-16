require 'json'

#
# A module for define type, generate struct, and mapping.
#
module Response
    #
    # A module for type definition and validation.
    # Definitions are defined in JSON file.
    #
    module Type
        # Definition JSON file
        DEFINITION_FILE = File.expand_path('../../config/types.json', __FILE__)

        # Definition of models
        MODEL_DEFINITION = open(DEFINITION_FILE) { |io| JSON.load(io) }

        # Returns defined types list.
        def self.types
            MODEL_DEFINITION.keys
        end

        # Returns sorted fields for type.
        # If not defined type was given, empty list will be returned.
        def self.fields_for(type)
            MODEL_DEFINITION[type].to_a.sort
        end

        # Validates the type is defined or not.
        def self.defined?(type)
            self.types.include?(type)
        end
    end

    #
    # A module for generating Struct class for given fields.
    # Members of Struct class are given fields and :struct_type.
    # :struct_type will contain the type name of Struct.
    #
    module StructGenerator
        # Returns Struct class which have members defined in fields and
        # :struct_type.
        def self.generate(fields)
            eval('Struct.new(:struct_type, "' + fields.join('", "') + '")')
        end
    end

    #
    # A module for mapping to type and struct from hash.
    #
    module Mapper
        # Returns type of given hash.
        # If type of hash is not defined, 'Unknown' will be returned.
        def self.to_type(hash)
            fields = hash.keys.sort

            # Look up
            type = Type.types.select { |t|
                fields == Type.fields_for(t)
            }.first

            type.nil? ? "Unknown" : type
        end

        # Convert hash into Struct class instance.
        def self.to_struct(hash)
            type = self.to_type(hash)
            fields = Type.fields_for(type)

            model = StructGenerator.generate(fields)

            instance = fields.inject(model.new) { |m, f|
                m[f] = hash[f]
                m
            }
            instance.struct_type = type

            instance
        end
    end
end

#
# A class extension of Hash class for Slack response object.
#
class Hash
    # Validates the hash is defined type or not.
    def is_type_of(type)
        self.keys.sort == Response::Type.fields_for(type)
    end

    # Returns type for hash structure.
    def type
        Response::Mapper.to_type(self)
    end

    # Converts into struct mapped object.
    def to_struct
        Response::Mapper.to_struct(self)
    end
end
