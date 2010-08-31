HoptoadNotifier.configure do |config|
  config.api_key = '61b68f7dd9d00f0789dba1dc298a39f8'
  config.params_filters << "number" << "cvv" << "password" << "password_confirmation" << "token"
end
