require "csv"
require_relative './alma_client'


class Patron
  def initialize(patron)
    @patron = patron
  end
  def uniqname
    @patron["primary_id"]
  end
  def valid?
    true
  end
  def update_sms(sms_number:, client: AlmaClient.new)
    url = "/users/#{uniqname}"
    response = client.put(url, patron_with_internal_sms(sms_number)) 
    if response.code == 200
      puts "#{uniqname}: SUCCESS"
    else
      puts "#{uniqname}: #{response}"
    end
  end
  def self.for(uniqname:, client: AlmaClient.new)
    url = "/users/#{uniqname}"
    response = client.get(url)
    if response.code == 200
      Patron.new(response.parsed_response)
    else
      PatronError.new(response)
    end
  end
  private
  def patron_with_internal_sms(sms_number)
    updated_patron = JSON.parse(@patron.to_json)
    phones = updated_patron["contact_info"]["phone"]
    mobile = phones.find { |x| x["preferred_sms"] == true }
    if mobile 
      mobile["segment_type"] = "Internal"
      mobile["phone_number"] = sms_number
    else
      phones.push({
        "phone_number"=> sms_number,
        "preferred"=> false,
        "preferred_sms"=> true,
        "segment_type"=> "Internal",
        "phone_type"=> [{
          "value"=> "mobile",
          "desc"=> "Mobile"
        }]
      })
    end
    updated_patron
  end

end
class PatronError
  attr_reader :error
  def initialize(error)
    @error= error
  end
  def valid?
    false
  end
end

#Alma API doesn't check for valid phone_numbers
parsed_file = CSV.read("./sms.tsv", col_sep: "\t")
parsed_file.each do |row|
  uniqname = row[0]
  sms_number = row[1]
  patron = Patron.for(uniqname: uniqname)
  if patron.valid?
    patron.update_sms(sms_number: sms_number)
  else
    puts "#{uniqname}: #{patron.error}"
  end
end
