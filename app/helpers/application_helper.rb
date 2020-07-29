module ApplicationHelper
  def model_links(model, model_ids)
    return 'Not Processed Yet' if model_ids.blank?
    model_ids.map do |model_id|
      record = model.find(model_id)
      link_to( record.name, record)
    end.join(' | ')
  end

  def theme_links(theme_ids)
    model_links(Theme, theme_ids)
  end

  def category_links(category_ids)
    model_links(Category, category_ids)
  end
end
