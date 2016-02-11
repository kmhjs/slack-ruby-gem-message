require 'ostruct'

class SlackMessage < Struct
    attr_accessor :message_type
    @message_type = nil
end

module ResponseType
    # Message types are defined in https://api.slack.com/events/message
    module RawValues
        UNKNOWN  = :unknown
        NORMAL   = :normal
        EDIT     = :edit
        SUBTYPE  = :subtype
        HIDDEN   = :hidden
        DELETED  = :deleted
        REACTION = :reaction
        BOT      = :bot

        def self.all
            self.constants.map { |name| self.const_get(name) }
        end
    end

    MODELS = {
        # DELETED is an element of SUBTYPE
        RawValues::UNKNOWN  => SlackMessage.new('Unknown'),
        RawValues::NORMAL   => SlackMessage.new('Normal',   :type, :channel, :user, :text, :ts, :team),
        RawValues::EDIT     => SlackMessage.new('Edit',     :type, :channel, :user, :text, :ts, :edited),
        RawValues::SUBTYPE  => SlackMessage.new('Subtype',  :type, :subtype, :text, :ts, :user),
        RawValues::HIDDEN   => SlackMessage.new('Hidden',   :type, :subtype, :hidden, :channel, :ts, :deleted_ts, :event_ts),
        RawValues::DELETED  => SlackMessage.new('Deleted',  :type, :deleted_ts, :subtype, :hidden, :channel, :previous_message, :event_ts, :ts),
        RawValues::REACTION => SlackMessage.new('Reaction', :type, :channel, :user, :text, :ts, :is_starred, :pinned_to, :reactions),
        RawValues::BOT      => SlackMessage.new('Bot',      :text, :username, :icons, :type, :subtype, :channel, :ts)
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
        #message = SlackMessage.new(self)
        #message.message_type = self.message_type

        #message

        model = ResponseType::MODELS[message_type].new()
        model.members.each { |member|
            model[member] = self[member.to_s]
        }
        model
    end
end
