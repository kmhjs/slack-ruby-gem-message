require_relative '../lib/slack-ruby-gem-message.rb'

RSpec.describe 'Message' do
    it 'data specified as unknown message' do
        data = {"reply_to"=>0, "type"=>"", "channel"=>"", "user"=>"", "text"=>"", "ts"=>""}
        expect(true).to eq false
    end

    it 'data specified as normal message' do
        data = {"type"=>"", "channel"=>"", "user"=>"", "text"=>"", "ts"=>"", "team"=>""}
        expect(true).to eq false
    end

    it 'data specified as reaction message' do
        data = {"type"=>"", "deleted_ts"=>"", "subtype"=>"", "hidden"=>true, "channel"=>"", "previous_message"=>{"type"=>"", "user"=>"", "text"=>"", "ts"=>""}, "event_ts"=>"", "ts"=>""}
        expect(true).to eq false
    end

    it 'data specified as bot message' do
        data = {"text"=>"", "username"=>"", "icons"=>{"emoji"=>""}, "type"=>"", "subtype"=>"", "channel"=>"", "ts"=>""}
        expect(true).to eq false
    end
end
