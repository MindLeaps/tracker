class AddGrades < ActiveRecord::Migration[5.0]
  def change
    create_table :student_sessions do |t|
      t.timestamps null: false
    end

    create_table :sessions do |t|
      t.timestamps null: false
    end

    create_table :grades do |t|
      t.timestamps null: false
    end

    add_reference :student_sessions, :student, index: true
    add_reference :student_sessions, :session, index: true
    add_reference :grades, :session, index: true
  end
end
