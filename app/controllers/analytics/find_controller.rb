module Analytics
  class FindController < AnalyticsController
    def update_chapters
      if params[:organization_id] and not params[:organization_id] == '' and not params[:organization_id] == 'All'
        chapters = policy_scope Chapter.where(organization_id: params[:organization_id])
      else
        chapters = policy_scope Chapter.all
      end
      respond_to do |format|
        format.json { render json: chapters, fields: [:id, :chapter_name], include: [] }
      end
    end

    def update_groups
      if params[:chapter_id] and not params[:chapter_id] == '' and not params[:chapter_id] == 'All'
        groups = policy_scope Group.where(chapter_id: params[:chapter_id])
      elsif params[:organization_id] and not params[:organization_id] == '' and not params[:organization_id] == 'All'
        groups = policy_scope Group.includes(:chapter).where(chapters: {organization_id: params[:organization_id]})
      else
        groups = policy_scope Group.all
      end
      respond_to do |format|
        format.json { render json: groups, fields: [:id, :group_name], include: [] }
      end
    end

    def update_students
      if params[:group_id] and not params[:group_id] == '' and not params[:group_id] == 'All'
        students = policy_scope Student.where(group_id: params[:group_id]).order(:last_name, :first_name)
      elsif params[:chapter_id] and not params[:chapter_id] == '' and not params[:chapter_id] == 'All'
        students = policy_scope Student.includes(:group).where(groups: {chapter_id: params[:chapter_id]}).order(:last_name, :first_name)
      elsif params[:organization_id] and not params[:organization_id] == '' and not params[:organization_id] == 'All'
        students = policy_scope Student.includes(group: {chapter: :organization}).where(chapters: {organization_id: params[:organization_id]}).order(:last_name, :first_name)
      else
        students = policy_scope Student.all.order(:last_name, :first_name)
      end
      respond_to do |format|
        format.json { render json: students, fields: [:id, :first_name, :last_name], include: [] }
      end
    end

    def update_subjects
      if params[:organization_id] and not params[:organization_id] == '' and not params[:organization_id] == 'All'
        subjects = policy_scope Subject.where(organization_id: params[:organization_id])
      else
        subjects = policy_scope Subject.all
      end
      respond_to do |format|
        format.json { render json: subjects, fields: [:id, :subject_name], include: [] }
      end
    end
  end
end
