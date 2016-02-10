require_relative '../lib/slack-ruby-gem-message.rb'

RSpec.describe 'MessageType' do
    it 'data specified as unknown message' do
        data = {
            "reply_to" => 0,
            "type" => "",
            "channel" => "",
            "user" => "",
            "text" => "",
            "ts" => ""
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
        expect(ResponseType::RawValues.all.sort()).to eq ResponseType::REQUIRED_FIELDS.keys.sort()
    end
end
