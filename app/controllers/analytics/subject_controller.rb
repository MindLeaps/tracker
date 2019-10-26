require 'sql/queries'
include SQL

module Analytics
  class SubjectController < AnalyticsController
    def index
      @subject = params[:subject_select]

      @organizations = policy_scope Organization
      if not @selected_organization_id.nil? and not @selected_organization_id == '' and not @selected_organization_id == 'All'
        @chapters = policy_scope Chapter.where(organization_id: @selected_organization_id)
      else
        @chapters = policy_scope Chapter
      end

      if not @selected_group_id.nil? and not @selected_group_id == '' and not @selected_group_id == 'All'
        @groups = policy_scope Group.where(chapter_id: @selected_chapter_id)
      elsif not @selected_organization_id.nil? and not @selected_organization_id == '' and not @selected_organization_id == 'All'
        @groups = policy_scope Group.includes(:chapter).where(chapters: {organization_id: @selected_organization_id})
      else
        @groups = policy_scope Group
      end

      if not @selected_group_id.nil? and not @selected_group_id == '' and not @selected_group_id == 'All'
        @students = policy_scope Student.where(group_id: @selected_group_id).order(:last_name, :first_name)
      elsif not @selected_chapter_id.nil? and not @selected_chapter_id == '' and not @selected_chapter_id == 'All'
        @students = policy_scope Student.includes(:group).where(groups: {chapter_id: @selected_chapter_id}).order(:last_name, :first_name)
      elsif not @selected_organization_id.nil? and not @selected_organization_id == '' and not @selected_organization_id == 'All'
        @students = policy_scope Student.includes(group: :chapter).where(chapters: {organization_id: @selected_organization_id}).order(:last_name, :first_name)
      else
        @students = policy_scope Student.order(:last_name, :first_name)
      end

      if not @selected_organization_id.nil? and not @selected_organization_id == '' and not @selected_organization_id == 'All'
        @subjects = policy_scope Subject.where(organization: @selected_organization_id)
      else
        @subjects = policy_scope Subject
      end

      unless params[:organization_select]
        @selected_organization_id = @organizations.first.id
      end
      unless params[:subject_select]
        @subject = @subjects.first.id
      end

      # figure 3: Histograms (Trellis) for the seven skills that are evaluated
      # multiple series (1 per group) per histogram;
      # x-axis: nr. of lessons
      # y-axis: average score
      # series = [{skill : skill_name, series : [{name : group_name, data : [[x, y], ..]}]}]
      series3 = performance_per_skill
      @count = series3.count
      @series3 = series3.to_json
    end

    private

    def performance_per_skill
      series = []
      if @selected_student_id.present? && @selected_student_id != 'All'
        lessons = Lesson.includes(:grades).where(grades: {student_id: @selected_student_id})
      elsif @selected_group_id.present? && @selected_group_id != 'All'
        lessons = Lesson.where(group_id: @selected_group_id)
      elsif @selected_chapter_id.present? && @selected_chapter_id != 'All'
        lessons = Lesson.includes(:group).where(groups: {chapter_id: @selected_chapter_id})
      elsif @selected_organization_id.present? && @selected_organization_id != 'All'
        lessons = Lesson.includes(group: :chapter).where(chapters: {organization_id: @selected_organization_id})
      else
        lessons = Lesson.where(group: @groups)
      end

      return [] if lessons.empty?

      conn = ActiveRecord::Base.connection.raw_connection
      groups = {}
      query_result = conn.exec(performance_per_skill_in_lessons_query(lessons)).values
      result = query_result.reduce({}) do |acc, e|
        group_id = e[-1]
        group_name = groups[group_id] ||= Group.find(group_id).group_chapter_name
        skill_name = e[-2]
        acc.tap do |a|
          if a.has_key?(skill_name)
            if a[skill_name].has_key?(group_name)
              a[skill_name][group_name].push({x: e[0], y: e[1], lesson_url: Rails.application.routes.url_helpers.lesson_path(e[2]), date: e[3]})
            else
              a[skill_name][group_name] = [{x: e[0], y: e[1], lesson_url: Rails.application.routes.url_helpers.lesson_path(e[2]), date: e[3]}]
            end
          else
            a[skill_name] = { group_name => [{x: e[0], y: e[1], lesson_url: Rails.application.routes.url_helpers.lesson_path(e[2]), date: e[3]}] }
          end
        end
      end

      # Calculation is done, now convert the series_hash to something HighCharts understands
      result.each do |skill_name, hash|
        # regression = RegressionService.new.skill_regression skill_name, hash.values.map(&:length).max

        skill_series = []
        hash.each_with_index do |(group, array), index|
          skill_series << {name: "#{t(:group)} #{group}", data: array, color: get_color(index), regression: array.length > 1, regressionSettings: {
              type: 'polynomial',
              order: 4,
              color: get_color(index),
              name: "#{t(:group)} #{group} - Regression",
              lineWidth: 1
          }}
        end

        # skill_series << {name: t(:regression_curve), data: regression, color: '#FF0000', lineWidth: 1, marker: {enabled: false}}
        series << {skill: skill_name, series: skill_series}
      end
      series
    end
  end
end