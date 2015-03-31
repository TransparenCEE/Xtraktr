module DatasetsHelper

  def format_dataset_public_status(is_public)
    if is_public == true
      return "<div class='publish-status public'>#{t('publish_status.public')}</div>".html_safe
    else
      return "<div class='publish-status not-public'>#{t('publish_status.private')}</div>".html_safe
    end
  end


  # if have start/end dates, show those, else use released date
  def format_dataset_dates(dataset)
    text = ''
    if dataset.start_gathered_at.present? && dataset.end_gathered_at
      text << I18n.l(dataset.start_gathered_at, format: :dataset)
      text << " - "
      text << I18n.l(dataset.end_gathered_at, format: :dataset)
    elsif dataset.released_at.present?
      text << I18n.l(dataset.released_at, format: :dataset)
    end
    return text
  end
end
