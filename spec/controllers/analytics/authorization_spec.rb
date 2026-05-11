require 'rails_helper'

RSpec.shared_context 'analytics controller setup' do
  before :each do
    @allowed_org = create :organization
    @allowed_user = create :teacher_in, organization: @allowed_org
    @allowed_chapter = create :chapter, organization: @allowed_org
    @allowed_group = create :group, chapter: @allowed_chapter

    @foreign_org = create :organization
    @foreign_chapter = create :chapter, organization: @foreign_org
    @foreign_group = create :group, chapter: @foreign_chapter
    @foreign_student = create :enrolled_student, organization: @foreign_org, groups: [@foreign_group]
    @foreign_subject = create :subject, organization: @foreign_org
    @foreign_skill = create :skill_with_descriptors, subject: @foreign_subject, organization: @foreign_org, skill_name: 'Memorization'
    @foreign_lesson = create :lesson, group: @foreign_group, subject: @foreign_subject, date: 1.month.ago.to_date
    create :grade, student: @foreign_student, lesson: @foreign_lesson, grade_descriptor: @foreign_skill.grade_descriptors.find_by(mark: 5)

    sign_in @allowed_user
  end
end

RSpec.describe Analytics::GeneralController, type: :controller do
  include_context 'analytics controller setup'

  it 'loads analytics without a student filter when lesson data exists' do
    subject = create :subject, organization: @allowed_org
    skill = create :skill_with_descriptors, subject:, organization: @allowed_org
    student = create :enrolled_student, organization: @allowed_org, groups: [@allowed_group]
    lesson = create :lesson, group: @allowed_group, subject:, date: 1.week.ago.to_date
    create :grade, student:, lesson:, grade_descriptor: skill.grade_descriptors.find_by(mark: 5)

    get :index, params: {
      organization_id: @allowed_org.id,
      from_date: 2.years.ago.to_date.to_s,
      to_date: Date.current.to_s
    }

    expect(response).to be_successful
    expect(assigns(:selected_student_ids)).to be_empty
    expect(JSON.parse(assigns(:average_group_performance))).not_to be_empty
  end

  it 'does not use explicitly requested records outside scope' do
    get :index, params: {
      organization_id: @foreign_org.id,
      chapter_id: @foreign_chapter.id,
      group_ids: [@foreign_group.id],
      student_id: @foreign_student.id,
      from_date: 2.years.ago.to_date.to_s,
      to_date: Date.current.to_s
    }

    expect(assigns(:selected_students)).to be_empty
    expect(JSON.parse(assigns(:average_group_performance))).to be_empty
    expect(assigns(:number_of_data_points)).to eq 0
  end
end

RSpec.describe Analytics::GroupController, type: :controller do
  include_context 'analytics controller setup'

  it 'does not build group series for explicitly requested groups outside scope' do
    get :index, params: {
      organization_id: @allowed_org.id,
      group_ids: [@foreign_group.id],
      from_date: 2.years.ago.to_date.to_s,
      to_date: Date.current.to_s
    }

    expect(assigns(:group_series)).to be_empty
  end
end

RSpec.describe Analytics::SubjectController, type: :controller do
  include_context 'analytics controller setup'

  it 'does not build student skill series for an explicitly requested student outside scope' do
    get :index, params: {
      organization_id: @allowed_org.id,
      student_id: @foreign_student.id,
      from_date: 2.years.ago.to_date.to_s,
      to_date: Date.current.to_s
    }

    expect(assigns(:subject_series)).to be_empty
  end

  it 'does not build student skill series for a student outside the selected groups' do
    allowed_other_group = create :group, chapter: @allowed_chapter
    allowed_student = create :enrolled_student, organization: @allowed_org, groups: [allowed_other_group]
    subject = create :subject, organization: @allowed_org
    skill = create :skill_with_descriptors, subject:, organization: @allowed_org, skill_name: 'Discipline'
    lesson = create :lesson, group: allowed_other_group, subject:, date: 1.month.ago.to_date
    create :grade, student: allowed_student, lesson:, grade_descriptor: skill.grade_descriptors.find_by(mark: 5)

    get :index, params: {
      organization_id: @allowed_org.id,
      group_ids: [@allowed_group.id],
      student_ids: [allowed_student.id],
      from_date: 2.years.ago.to_date.to_s,
      to_date: Date.current.to_s
    }

    expect(assigns(:subject_series)).to be_empty
  end
end
