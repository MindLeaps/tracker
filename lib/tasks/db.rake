# frozen_string_literal: true
namespace :db do
  desc 'Reset Postgres sequences of table primary keys to highest value'
  task correct_sequence_ids: :environment do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.reset_pk_sequence! table
    end
  end
end
