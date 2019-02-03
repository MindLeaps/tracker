# frozen_string_literal: true

class AddReferencesToLessonUuid < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def change
    add_column :grades, :lesson_uid, :uuid
    add_foreign_key :grades, :lessons, column: :lesson_uid, primary_key: :uid, name: 'grades_lesson_uid_fk'

    add_column :absences, :lesson_uid, :uuid
    add_foreign_key :absences, :lessons, column: :lesson_uid, primary_key: :uid, name: 'absences_lesson_uid_fk'

    Grade.includes(:lesson).all.each do |g|
      g.lesson_uid = g.lesson.uid
      g.save!
    end

    Absence.includes(:lesson).all.each do |a|
      a.lesson_uid = a.lesson.uid
      a.save!
    end

    change_column_null :grades, :lesson_uid, false
    change_column_null :absences, :lesson_uid, false
  end
  # rubocop:enable Metrics/MethodLength
end
