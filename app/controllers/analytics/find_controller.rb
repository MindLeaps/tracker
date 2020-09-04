# frozen_string_literal: true

module Analytics
  class FindController < AnalyticsController
    def update_chapters
      chapters = if params[:organization_id] && (params[:organization_id] != '') && (params[:organization_id] != 'All')
                   policy_scope Chapter.where(organization_id: params[:organization_id])
                 else
                   policy_scope Chapter.all
                 end
      respond_to do |format|
        format.json { render json: chapters, fields: [:id, :chapter_name], include: [] }
      end
    end

    # rubocop:disable Metrics/AbcSize
    def update_groups
      groups = if params[:chapter_id] && (params[:chapter_id] != '') && (params[:chapter_id] != 'All')
                 policy_scope Group.where(chapter_id: params[:chapter_id])
               elsif params[:organization_id] && (params[:organization_id] != '') && (params[:organization_id] != 'All')
                 policy_scope Group.includes(:chapter).where(chapters: { organization_id: params[:organization_id] })
               else
                 policy_scope Group.all
               end
      respond_to do |format|
        format.json { render json: groups, fields: [:id, :group_name], include: [] }
      end
    end

    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def update_students
      students = if params[:group_id] && (params[:group_id] != '') && (params[:group_id] != 'All')
                   policy_scope Student.where(group_id: params[:group_id]).order(:last_name, :first_name)
                 elsif params[:chapter_id] && (params[:chapter_id] != '') && (params[:chapter_id] != 'All')
                   policy_scope Student.includes(:group).where(groups: { chapter_id: params[:chapter_id] }).order(:last_name, :first_name)
                 elsif params[:organization_id] && (params[:organization_id] != '') && (params[:organization_id] != 'All')
                   policy_scope Student.includes(group: { chapter: :organization }).where(chapters: { organization_id: params[:organization_id] }).order(:last_name, :first_name)
                 else
                   policy_scope Student.all.order(:last_name, :first_name)
                 end
      respond_to do |format|
        format.json { render json: students, fields: [:id, :first_name, :last_name], include: [] }
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    def update_subjects
      subjects = if params[:organization_id] && (params[:organization_id] != '') && (params[:organization_id] != 'All')
                   policy_scope Subject.where(organization_id: params[:organization_id])
                 else
                   policy_scope Subject.all
                 end
      respond_to do |format|
        format.json { render json: subjects, fields: [:id, :subject_name], include: [] }
      end
    end
  end
end
