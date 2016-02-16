require 'json'

module Response
    module Type
        MODEL_DEFINITION = open('../config/types.json') { |io|
            JSON.load(io)
        }

        def self.types
            MODEL_DEFINITION.keys
        end

        def self.fields_for(type)
            MODEL_DEFINITION[type].to_a.sort
        end

        def self.defined?(type)
            self.types.include?(type)
        end
    end

    module ModelGenerator
        def self.create(fields)
            eval('Struct.new(:struct_type, "' + fields.join('", "') + '")')
        end
    end

    module Mapper
        def self.to_type(hash)
            fields = hash.keys.sort

            # Look up
            type = Type.types.select { |t|
                fields == Type.fields_for(t)
            }.first

            type.nil? ? "Unknown" : type
        end

        def self.to_struct(hash)
            type = self.to_type(hash)
            fields = Type.fields_for(type)

            model = ModelGenerator.create(fields)

            instance = fields.inject(model.new) { |m, f|
                m[f] = hash[f]
                m
            }
            instance.struct_type = type

            instance
        end
    end
end

class Hash
    def is_type_of(type)
        self.keys.sort == Response::Type.fields_for(type)
    end

    def type
        Response::Mapper.to_type(self)
    end

    def to_struct
        Response::Mapper.to_struct(self)
    end
end
