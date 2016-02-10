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

        TYPES = [UNKNOWN, NORMAL, EDIT, SUBTYPE, HIDDEN, DELETED, REACTION, BOT]
    end

    REQUIRED_KEYS = {
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
        return REQUIRED_KEYS[type] if ResponseType::RawValues::TYPES.include?(type)
        REQUIRED_KEYS[RawValues::UNKNOWN]
    end

    def self.message_type_of?(message_hash, type)
        required_fields = ResponseType::required_fields_for(type)
        (required_fields.map { |e| e.to_s }).sort == message_hash.keys.sort
    end
end

class Hash
    @message_type_cache = nil

    def message_type()
        ResponseType::RawValues::TYPES.each { |type|
            if ResponseType::message_type_of?(self, type)
                return type
            end
        }
        ResponseType::RawValues::UNKNOWN
    end

    def message_type_of?(type)
        ResponseType::message_type_of?(self, type)
    end

    def to_model()
        # If not cached
        if @message_type_cache.nil?
            @message_type_cache = self.message_type
            if @message_type_cache.nil?
                p "No type found"
                return nil
            end
        end

        message = SlackMessage.new(self)
        message.message_type = @message_type_cache

        message
    end
end

class SlackMessage < OpenStruct
    attr_accessor :message_type
    @message_type = nil
end
