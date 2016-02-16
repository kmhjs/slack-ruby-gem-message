require_relative '../lib/slack-ruby-gem-message.rb'
require 'json'

MODEL_DEFINITIONS = open('../config/types.json') { |io| JSON.load(io) }

RSpec.describe 'ResponseType' do
    it 'returns whole defined values' do
        expect(ResponseType.types).to eq MODEL_DEFINITIONS.keys
    end

    it 'returns whole fields' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, fields)|
            flag &&= (fields.sort == ResponseType.fields_for(type))
            flag
        }
        expect(result).to eq true
    end

    it 'validate type' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, _)|
            flag &&= ResponseType.defined?(type)
            flag
        }
        expect(result).to eq true
    end
end

RSpec.describe 'ResponseMapper' do
    it 'returns type' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, fields)|
            sample_hash = fields.inject({}) { |h, k| h[k] = ''; h }
            flag &&= (type == ResponseMapper.to_type(sample_hash))
            flag
        }
        result &&= (ResponseMapper.to_type({}) == 'Unknown')
        expect(result).to eq true
    end

    it 'maps to instance' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, fields)|
            sample_hash = fields.inject({}) { |h, k| h[k] = ''; h }
            instance = ResponseMapper.to_struct(sample_hash)

            flag &&= fields.inject(true) { |f, field|
                f &&= (instance[field] == sample_hash[field])
                f
            }
            flag &&= (instance[:struct_type] == type)
            flag
        }
        expect(result).to eq true
    end
end

RSpec.describe 'ResponseModelGenerator' do
    it 'create model' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (_, fields)|
            model = ResponseModelGenerator.create(fields)

            expected_fields = fields.map { |v| v.to_sym }
            expected_fields << :struct_type

            flag &&= (model.members.sort == expected_fields.sort)
            flag
        }
        expect(result).to eq true
    end
end

RSpec.describe 'Hash extension' do
    it 'identifies type' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, fields)|
            sample_hash = fields.inject({}) { |h, k| h[k] = ''; h }
            flag &&= sample_hash.is_type_of(type)
            flag
        }
        expect(result).to eq true
    end

    it 'returns type' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, fields)|
            sample_hash = fields.inject({}) { |h, k| h[k] = ''; h }
            flag &&= (type == sample_hash.type)
            flag
        }
        result &&= ({}.type == 'Unknown')
        expect(result).to eq true
    end

    it 'mapped to instance' do
        result = MODEL_DEFINITIONS.inject(true) { |flag, (type, fields)|
            sample_hash = fields.inject({}) { |h, k| h[k] = ''; h }
            instance = sample_hash.to_struct

            flag &&= fields.inject(true) { |f, field|
                f &&= (instance[field] == sample_hash[field])
                f
            }
            flag &&= (instance[:struct_type] == type)
            flag
        }
        expect(result).to eq true
    end
end
