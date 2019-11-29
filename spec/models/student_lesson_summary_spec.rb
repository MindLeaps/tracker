# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentLessonSummary, type: :model do
  describe 'scopes' do
    describe '#table_order_lesson_students' do
      before :each do
        @group = create :group
        @abimz = create :student, last_name: 'Abimz', first_name: 'Zima', group: @group
        @zimba = create :student, last_name: 'Zimba', first_name: 'Azim', group: @group
        create :lesson, group: @group
      end

      it 'orders summaries by student last name' do
        summaries = StudentLessonSummary.table_order_lesson_students(key: :last_name, order: :asc).all
        expect(summaries.map(&:last_name)).to eq [@abimz.last_name, @zimba.last_name]

        summaries = StudentLessonSummary.table_order_lesson_students(key: :last_name, order: :desc).all
        expect(summaries.map(&:last_name)).to eq [@zimba.last_name, @abimz.last_name]
      end
    end
  end
end
