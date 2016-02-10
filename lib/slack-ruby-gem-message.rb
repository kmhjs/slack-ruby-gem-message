require 'ostruct'

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
            self.constants.map{|name| self.const_get(name) }
        end
    end

    REQUIRED_FIELDS = {
        # DELETED is an element of SUBTYPE
        RawValues::UNKNOWN  => [],
        RawValues::NORMAL   => [:type, :channel, :user, :text, :ts, :team],
        RawValues::EDIT     => [:type, :channel, :user, :text, :ts, :edited],
        RawValues::SUBTYPE  => [:type, :subtype, :text, :ts, :user],
        RawValues::HIDDEN   => [:type, :subtype, :hidden, :channel, :ts, :deleted_ts, :event_ts],
        RawValues::DELETED  => [:type, :deleted_ts, :subtype, :hidden, :channel, :previous_message, :event_ts, :ts],
        RawValues::REACTION => [:type, :channel, :user, :text, :ts, :is_starred, :pinned_to, :reactions],
        RawValues::BOT      => [:text, :username, :icons, :type, :subtype, :channel, :ts]
    }

    def self.required_fields_for(type)
        return REQUIRED_FIELDS[type] if ResponseType::RawValues.all.include?(type)
        REQUIRED_FIELDS[RawValues::UNKNOWN]
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
        message = SlackMessage.new(self)
        message.message_type = self.message_type

        message
    end
end

class SlackMessage < OpenStruct
    attr_accessor :message_type
    @message_type = nil
end
