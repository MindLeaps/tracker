class AddRandomAlphaNumericGeneration < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      create or replace function random_alphanumeric_string(length integer) returns text
      language plpgsql
      as $$
      declare value text;
      begin
        select array_to_string(array(select substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',floor(random()*36)::int + 1, 1) from generate_series(1,length)),'') into value;
        return value;
      end;
      $$;
    SQL
  end

  def down
    execute <<~SQL
      drop function random_alphanumeric_string;
    SQL
  end
end
