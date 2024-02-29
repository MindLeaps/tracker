class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :assignments do |t|
      t.belongs_to :skill, index: true, null: false
      t.belongs_to :subject, index: true, null: false
    end
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
