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
    @skill_ids = {}
    @gds = {}
  end

  def seed_data(chapter, default_subject)
    @subject = default_subject
    read_csv_file.each { |r| seed_row r, chapter }
  end

  private

  def read_csv_file
    SmarterCSV.process @csv_file_path
  end

  def seed_row(row, chapter)
    group = create_group(row[:group], chapter)
    student = create_student(row[:id], group, row[:gender] == 1 ? 'male' : 'female', row[:age] || 13)
    lesson = create_lesson(group, row[:date])
    grade_student student, lesson, get_row_grades(row)
  end

  def create_group(group_id, chapter)
    @groups[group_id] ||= chapter.groups.create group_name: generate_group_name(group_id)
  end

  def generate_group_name(group_id)
    return group_id if group_id.respond_to? :to_str

    @group_names[group_id]
  end

  def create_student(id, group, gender, age)
    @students[id] ||= Student.create(
      mlid: id,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      gender: gender,
      dob: age.years.ago,
      estimated_dob: 'true',
      group: group
    )
  end

  def create_lesson(group, date)
    d = parse_date(date)
    # rubocop:disable Rails/Output
    @lessons[:"#{group.id}-#{date}"] ||=
      puts("Lesson: #{d} - Chapter: #{group.chapter.chapter_name} - Group: #{group.group_name}") || Lesson.create(group: group, date: d, subject: @subject)
    # rubocop:enable Rails/Output
  end

  def parse_date(date_string)
    return Date.strptime date_string, '%m/%d/%y' if date_string.split('/')[2].length == 2

    Date.strptime date_string, '%m/%d/%Y'
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
    new_grades = []
    grades.each do |skill_name, mark|
      return lesson.mark_student_as_absent(student) if mark.nil?

      skill_id = get_skill_id skill_name
      gd = get_gd skill_id, mark
      new_grades << Grade.new(lesson: lesson, student: student, grade_descriptor: gd)
    end
    Grade.transaction do
      new_grades.each(&:save!)
    end
  end

  def get_skill_id(skill_name)
    @skill_ids[:"#{skill_name}"] ||= Skill.where(skill_name: DEFAULT_SKILL_NAMES[skill_name]).first.id
  end

  def get_gd(skill_id, mark)
    @gds[:"#{skill_id}-#{mark}"] ||= GradeDescriptor.where(skill_id: skill_id, mark: mark).first
  end
end
