module ApplicationHelper
  def class_if_path(c, path)
    c if current_page?(path)
  end
end
