# frozen_string_literal: true

require 'smarter_csv'

class CSVDataSeeder
  DEFAULT_SKILL_NAMES = {
    memorization: 'Memorization',
    grit: 'Grit',
    teamwork: 'Teamwork',
    discipline: 'Discipline',
    self_esteem: 'Self-Esteem',
    creativity: 'Creativity & Self-Expression',
    language: 'Language'
  }.freeze

  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @groups = {}
    @students = {}
    @lessons = {}
    @group_names = { 1 => 'A', 2 => 'B', 3 => 'C' }
  end

  def seed_data(chapter, default_subject)
    @subject = default_subject
    read_csv_file.each { |r| seed_row r, chapter }
  end

  private

  def read_csv_file
    SmarterCSV.process(@csv_file_path, skip_lines: 2)
  end

  def seed_row(r, chapter)
    group = create_group(r[:group], chapter)
    student = create_student(r[:id], group, chapter, r[:gender] - 1, r[:age])
    lesson = create_lesson(group, r[:date])
    grade_student student, lesson, get_row_grades(r)
  end

  def create_group(group_id, chapter)
    @groups[group_id] ||= chapter.groups.create group_name: @group_names[group_id]
  end

  def create_student(id, group, chapter, gender, age)
    @students[id] ||= Student.create(
      mlid: id,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      gender: gender,
      dob: age.years.ago,
      estimated_dob: 'true',
      group: group,
      organization: chapter.organization
    )
  end

  def create_lesson(group, date)
    @lessons[:"#{group.id}-#{date}"] ||= Lesson.create group: group, date: (Date.strptime date, '%m/%d/%y'), subject: @subject
  end

  def get_row_grades(row)
    {
      memorization: row[:memorization],
      grit: row[:grit],
      teamwork: row[:teamwork],
      discipline: row[:discipline],
      self_esteem: row[:self_esteem],
      creativity: row[:creativity],
      language: row[:language]
    }
  end

  def grade_student(student, lesson, grades)
    grades.each do |skill_name, mark|
      return lesson.mark_student_as_absent(student) if mark.nil?
      skill = Skill.where(skill_name: DEFAULT_SKILL_NAMES[skill_name]).first
      gd = GradeDescriptor.where(skill: skill, mark: mark).first
      Grade.create lesson: lesson, student: student, grade_descriptor: gd
    end
  end
end
