A quick and dirty script for using Dreamhost for dynamic DNS.

Note: This script assumes it resides along side a config.rb file that contains KEY and HOST constants. The KEY is your Dreamhost API key, and the HOST is the DNS record you wish to keep updated.

    config.rb
    KEY  = "6SHU5P2HLDAYECUM"
    HOST = "homeserver.example.com"
