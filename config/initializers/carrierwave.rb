unless File.basename($PROGRAM_NAME) == 'rake' # we don't want to setup this stuff for every rake task
  CarrierWave.configure do |config|
    # For testing, upload files to local `tmp` folder.
    if Rails.env.test?
      config.storage = :file
      config.enable_processing = false
      config.root = Rails.root.join 'tmp'
    else
      config.fog_provider = 'fog/aws'
      config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
        region: ENV.fetch('AWS_REGION', nil)
      }
      config.fog_directory = ENV.fetch('AWS_BUCKET_NAME', nil)
      config.fog_public = true
      config.fog_use_ssl_for_aws = true
      config.storage = :fog
    end
  end
end
