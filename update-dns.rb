require 'json'
require 'net/https'
require 'securerandom'
require_relative 'config.rb'

# Define some basic methods to keep the script marginally cleaner.
def uuid
  SecureRandom.uuid
end

def get_current_ip
  uri  = URI.parse("http://jsonip.com")
  body = Net::HTTP.get(uri)
  json = JSON.parse(body)
  json["ip"]
end

def dreamhost_api(command, params="")
  uri  = URI.parse("https://api.dreamhost.com/?key=#{KEY}&cmd=#{command}&unique_id=#{uuid}&format=json#{params unless params.empty?}")
  dest = Net::HTTP::Get.new(uri)
  connection = Net::HTTP.new(uri.host, uri.port)
  connection.use_ssl = true
  connection.ssl_version = "SSLv3"
  connection.start do |https|
    response = https.request(dest)
    JSON.parse(response.body)
  end
end

# Use awesome jsonip.com service to get public IP address.
current_ip = get_current_ip
puts "The current IP address is: " + current_ip

# Query Dreamhost for the current value of the DNS record.
dns_list   = dreamhost_api("dns-list_records")
dns_record = dns_list["data"].select{ |entry| entry["record"] == HOST }.first
stored_ip  = dns_record["value"]
puts "The stored IP address is: " + stored_ip

# If the current IP address differs from the DNS record, update DNS.
if current_ip == stored_ip
  puts "The current IP address matches the DNS record. No changes are necessary."
else
  dreamhost_api("dns-remove_record", "&record=#{HOST}&type=A&value=#{stored_ip}")
  dreamhost_api("dns-add_record", "&record=#{HOST}&type=A&value=#{current_ip}")
  puts "The DNS record has been updated."
end
