require 'json'

class SlackMessage < Struct
    attr_accessor :message_type
    @message_type = nil
end

module UnknownSlackMessage
    def self.create(field_symbols)
        eval("Struct.new('Unknown', :" + field_symbols.join(', :') + ")")
    end

    def self.members
        []
    end
end

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

module ResponseMapper
end

class Hash
    def is_type_of(type)
        self.keys.sort == ResponseType.fields_for(type)
    end
end
