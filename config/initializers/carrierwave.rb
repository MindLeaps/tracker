# frozen_string_literal: true

unless File.basename($PROGRAM_NAME) == 'rake' # we don't want to setup this stuff for every rake task
  CarrierWave.configure do |config|
    # For testing, upload files to local `tmp` folder.
    if Rails.env.test? || (Rails.env.development? && Rails.application.secrets.aws_access_key_id.nil?)
      config.storage = :file
      config.enable_processing = false
      config.root = Rails.root.join 'tmp'
    else
      config.fog_provider = 'fog/aws'
      config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: Rails.application.secrets.aws_access_key_id,
        aws_secret_access_key: Rails.application.secrets.aws_secret_access_key,
        region: Rails.application.secrets.aws_region
      }
      config.fog_directory = Rails.application.secrets.aws_bucket_name
      config.fog_public = true
      config.fog_use_ssl_for_aws = true
      config.storage = :fog
    end
  end
end
