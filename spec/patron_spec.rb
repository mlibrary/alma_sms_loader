describe Patron do
  before(:each) do
    @orig_alma_patron = JSON.parse(File.read("./spec/fixtures/user.json"))
  end
  subject do
    stub_alma_get_request(url: 'users/etude', output: @orig_alma_patron.to_json)
    Patron.for(uniqname: 'etude')
  end
  it "returns a patron with proper uniqname" do
    expect(subject.uniqname).to eq('etude')
  end
  context "#update_sms(sms_number)" do
    it "calls AlmaClient with patron with updated phone number" do
      response_double = double("HTTParty::Response", code: 200)
      updated_alma_patron = @orig_alma_patron.clone
      updated_alma_patron["contact_info"]["phone"][1]["phone_number"] = '734-555-6666'
      updated_alma_patron["contact_info"]["phone"][1]["segment_type"] = 'Internal'

      client_double = instance_double(AlmaClient, put: response_double)

      expect(client_double).to receive(:put).with("/users/etude", updated_alma_patron)
      subject.update_sms(sms_number: '734-555-6666', client: client_double)
    end
    it "calls AlmaClient with patron with added phone number" do
      response_double = double("HTTParty::Response", code: 200)
      @orig_alma_patron["contact_info"]["phone"][1]["preferred_sms"] = false
      updated_alma_patron = JSON.parse(@orig_alma_patron.to_json)

      updated_alma_patron["contact_info"]["phone"].push({
        "phone_number"=> '734-555-6666',
        "preferred"=> false,
        "preferred_sms"=> true,
        "segment_type"=> "Internal",
        "phone_type"=> [{
          "value"=> "mobile",
          "desc"=> "Mobile"
        }]
      })

      client_double = instance_double(AlmaClient, put: response_double)

      expect(client_double).to receive(:put).with("/users/etude", updated_alma_patron)
      subject.update_sms(sms_number: '734-555-6666', client: client_double)
    end
  end
end
