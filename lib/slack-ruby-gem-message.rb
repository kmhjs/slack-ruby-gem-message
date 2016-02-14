module ResponseType
    # Message types are defined in https://api.slack.com/events/message
    module RawValues
        UNKNOWN  = :unknown
        NORMAL   = :normal
        EDIT     = :edit
        SUBTYPE  = :subtype
        LAST_LOG = :last_log
        HIDDEN   = :hidden
        DELETED  = :deleted
        REACTION = :reaction
        BOT      = :bot

        def self.all
            self.constants.map { |name| self.const_get(name) }
        end
    end

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

    MODELS = {
        # DELETED is an element of SUBTYPE
        RawValues::UNKNOWN  => UnknownSlackMessage,
        RawValues::NORMAL   => SlackMessage.new('Normal',   :type, :channel,           :user, :text, :ts, :team),
        RawValues::EDIT     => SlackMessage.new('Edit',     :type, :channel,           :user, :text, :ts, :edited),
        RawValues::LAST_LOG => SlackMessage.new('LastLog',  :type, :channel,           :user, :text, :ts, :reply_to),
        RawValues::SUBTYPE  => SlackMessage.new('Subtype',  :type,           :subtype, :user, :text, :ts),
        RawValues::BOT      => SlackMessage.new('Bot',      :type, :channel, :subtype,        :text, :ts, :username, :icons),
        RawValues::HIDDEN   => SlackMessage.new('Hidden',   :type, :channel, :subtype,               :ts, :hidden, :deleted_ts, :event_ts),
        RawValues::DELETED  => SlackMessage.new('Deleted',  :type, :channel, :subtype,               :ts, :hidden, :deleted_ts, :event_ts, :previous_message),
        RawValues::REACTION => SlackMessage.new('Reaction', :type, :channel,           :user, :text, :ts, :is_starred, :pinned_to, :reactions)
    }

    def self.required_fields_for(type)
        return MODELS[type].members if ResponseType::RawValues.all.include?(type)
        MODELS[RawValues::UNKNOWN].members
    end

    def self.message_type_of?(message_hash, type)
        required_fields = ResponseType::required_fields_for(type)
        (required_fields.map { |e| e.to_s }).sort == message_hash.keys.sort
    end
end

class Hash
    def message_type()
        ResponseType::RawValues.all.each { |type|
            return type if ResponseType::message_type_of?(self, type)
        }
        ResponseType::RawValues::UNKNOWN
    end

    def message_type_of?(type)
        ResponseType::message_type_of?(self, type)
    end

    def to_model()
        type = message_type

        if type == ResponseType::RawValues::UNKNOWN
            struct = ResponseType::MODELS[message_type].create(self.keys)
            model = struct.new()

        else
            model = ResponseType::MODELS[message_type].new()
        end

        model.members.each { |member|
            model[member] = self[member.to_s]
        }
        model
    end
end
