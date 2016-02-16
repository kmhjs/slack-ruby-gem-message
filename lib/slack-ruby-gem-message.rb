require 'json'

module ResponseType
    MODEL_DEFINITION = open('../config/types.json') { |io| JSON.load(io) }

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

module ResponseModelGenerator
    def self.create(fields)
        eval('Struct.new(:struct_type, "' + fields.join('", "') + '")')
    end
end

module ResponseMapper
    def self.to_type(hash)
        fields = hash.keys.sort

        # Look up
        type = ResponseType.types.select { |t|
            fields == ResponseType.fields_for(t)
        }.first

        type.nil? ? "Unknown" : type
    end

    def self.to_struct(hash)
        type = self.to_type(hash)
        fields = ResponseType.fields_for(type)

        model = ResponseModelGenerator.create(fields)

        instance = fields.inject(model.new) { |m, f|
            m[f] = hash[f]
            m
        }
        instance.struct_type = type

        instance
    end
end

class Hash
    def is_type_of(type)
        self.keys.sort == ResponseType.fields_for(type)
    end

    def type()
        ResponseMapper.to_type(self)
    end

    def to_struct()
        ResponseMapper.to_struct(self)
    end
end
