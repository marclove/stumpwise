s3 = YAML.load(ERB.new(File.read(RAILS_ROOT + '/config/amazon_s3.yml')).result)[RAILS_ENV].symbolize_keys

CarrierWave.configure do |config|
  config.s3_access_key_id = s3[:access_key_id]
  config.s3_secret_access_key = s3[:secret_access_key]
  config.s3_bucket = s3[:bucket_name]
end
