require_relative '../lib/slack-ruby-gem-message.rb'

RSpec.describe 'MessageType' do
    it 'data specified as unknown message' do
        data = {
            "field1" => 0,
            "field2" => "",
            "field3" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::UNKNOWN
    end

    it 'data specified as normal message' do
        data = {
            "type" => "",
            "channel" => "",
            "user" => "",
            "text" => "",
            "ts" => "",
            "team" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::NORMAL
    end

    it 'data specified as last_log message' do
        data = {
            "reply_to" => "",
            "type" => "",
            "channel" => "",
            "user" => "",
            "text" => "",
            "ts" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::LAST_LOG
    end

    it 'data specified as deleted message' do
        data = {
            "type" => "",
            "deleted_ts" => "",
            "subtype" => "",
            "hidden"=>true,
            "channel" => "",
            "previous_message" => {
                "type" => "",
                "user" => "",
                "text" => "",
                "ts" => ""
            },
            "event_ts" => "",
            "ts" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::DELETED
    end

    it 'data specified as bot message' do
        data = {
            "text" => "",
            "username" => "",
            "icons"=> {
                "emoji" => ""
            },
            "type" => "",
            "subtype" => "",
            "channel" => "",
            "ts" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::BOT
    end

    it 'data specified as normal message with no team info' do
        data = {
            "type" => "",
            "user" => "",
            "text" => "",
            "channel" => "",
            "ts" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::NORMAL_NO_TEAM
    end

    it 'data specidied as link info' do
        data = {
            "type" => "",
            "message" => "",
            "subtype" => "",
            "hidden" => "",
            "channel" => "",
            "previous_message" => "",
            "event_ts" => "",
            "ts" => ""
        }
        expect(data.message_type).to eq ResponseType::RawValues::LINK_INFO
    end
end

RSpec.describe 'MessageMapping' do
    it 'data specified as unknown message' do
        data = {
            "reply_to" => 0,
            "type" => "",
            "channel" => "",
            "user" => "",
            "text" => "",
            "ts" => ""
        }
        model = data.to_model

        comp = data.inject(true) { |res, (k, v)| res &&= (v == model["#{k}"]) }
        expect(comp).to eq true
    end

    it 'data specified as normal message' do
        data = { 
            "type" => "",
            "channel" => "",
            "user" => "",
            "text" => "",
            "ts" => "",
            "team" => ""
        }
        model = data.to_model

        comp = data.inject(true) { |res, (k, v)| res &&= (v == model["#{k}"]) }
        expect(comp).to eq true
    end

    it 'data specified as reaction message' do
        data = {
            "type" => "",
            "deleted_ts" => "",
            "subtype" => "",
            "hidden"=>true,
            "channel" => "",
            "previous_message"=>{
                "type" => "",
                "user" => "",
                "text" => "",
                "ts" => ""

            },
            "event_ts" => "",
            "ts" => ""
        }
        model = data.to_model

        comp = data.inject(true) { |res, (k, v)| res &&= (v == model["#{k}"]) }
        expect(comp).to eq true
    end

    it 'data specified as bot message' do
        data = { 
            "text" => "",
            "username" => "",
            "icons"=>{ 
                "emoji" => ""
            },
            "type" => "",
            "subtype" => "",
            "channel" => "",
            "ts" => ""
        }
        model = data.to_model

        comp = data.inject(true) { |res, (k, v)| res &&= (v == model["#{k}"]) }
        expect(comp).to eq true
    end
end


RSpec.describe 'Type definition' do
    it 'raw values mapped to required keys' do
        expect(ResponseType::RawValues.all.sort()).to eq ResponseType::MODELS.keys.sort()
    end
end
