config = YAML.load_file(Rails.root.join('config', 'mongo.yml'))
MongoMapper.setup(config, Rails.env, { :logger => Rails.logger })