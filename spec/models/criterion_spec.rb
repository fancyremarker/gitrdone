require_relative '../../models/criterion'

describe Criterion do
  let(:json) do
    <<-JSON
    {
      "none": { "min_age": 7, "max_age": 365 },
      "ready": { "max_count": 90 },
      "on deck": { "max_count": 60 },
      "in progress": { "max_count": 18 }
    }
    JSON
  end
  let(:labels) { ['ready', 'on deck', 'in progress'] }

  describe '.from_json' do
    it 'should correctly evaluate JSON' do
      criteria = described_class.from_json(json, labels)
      expect(criteria.count).to eq 5

      expect(criteria[0].label).to be_nil
      expect(criteria[1].label).to be_nil
      expect(criteria[2].label).to eq 'ready'
      expect(criteria[3].label).to eq 'on deck'
      expect(criteria[4].label).to eq 'in progress'

      expect(criteria[0].nonlabels).to eq labels
      expect(criteria[1].nonlabels).to eq labels
      expect(criteria[2].nonlabels).to be_nil
      expect(criteria[3].nonlabels).to be_nil
      expect(criteria[4].nonlabels).to be_nil

      expect(criteria[0].constraint_type).to eq :min_age
      expect(criteria[1].constraint_type).to eq :max_age
      expect(criteria[2].constraint_type).to eq :max_count
      expect(criteria[3].constraint_type).to eq :max_count
      expect(criteria[4].constraint_type).to eq :max_count

      expect(criteria[0].constraint_value).to eq 7
      expect(criteria[1].constraint_value).to eq 365
      expect(criteria[2].constraint_value).to eq 90
      expect(criteria[3].constraint_value).to eq 60
      expect(criteria[4].constraint_value).to eq 18
    end
  end
end
