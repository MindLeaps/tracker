# frozen_string_literal: true

class StudentImagesController < HtmlController
  def create
    @student = Student.find params.require(:student_id)
    authorize @student, :update?
    images = student_images @student
    return notice_and_redirect t(:images_uploaded), student_student_images_path if save_images(images)

    handle_save_error images
  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound
    skip_authorization
    image_missing
  end

  def destroy
    @student = Student.find params.require(:student_id)
    authorize @student, :update?
  end

  private

  def student_images(student)
    images = params.require(:student_image).permit(image: [])[:image]
    images.map { |i| StudentImage.new image: i, student: student }
  end

  def save_images(student_images)
    StudentImage.transaction do
      student_images.each(&:save!)
    end
    true
  rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
    false
  end

  def image_missing
    @new_image = StudentImage.new
    flash.alert = t :no_image_submitted
    render :index, status: :bad_request
  end

  def handle_save_error(images)
    @new_image = StudentImage.new
    flash.alert = images_validation_errors(images)
    render :index, status: flash.alert.empty? ? :internal_server_error : :bad_request
  end

  def images_validation_errors(images)
    errors = []
    images.each do |image|
      errors += image.errors.messages[:image]
    end
    errors
  end
end
