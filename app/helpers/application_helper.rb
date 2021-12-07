# frozen_string_literal: true

module ApplicationHelper
  def page_title
    title = content_for(:page_title) || 'LittleSis'

    if title.include?('LittleSis')
      title
    else
      "#{title} - LittleSis"
    end
  end

  def excerpt(text, length=30)
    if text
      break_point = text.index(/[\s.,:;!?-]/, length - 5) || length + 1

      text[0..(break_point - 1)] + (text.length > break_point - 1 ? "..." : "")
    end
  end

  def yes_or_no(value)
    value ? "yes" : "no"
  end

  def notice_if_notice
    raw "<div class='alert alert-success'>#{notice}</div>" if notice
  end

  def notice_or_alert
    return unless flash[:alert] || flash[:notice]

    msg = flash[:alert] || flash[:notice]
    style = flash[:alert].present? ? 'danger' : 'success'

    tag.div(msg, class: "alert alert-#{style}")
  end

  def dismissable_alert(id, class_name = 'alert-info', &block) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    session[:dismissed_alerts] = [] unless session[:dismissed_alerts].is_a?(Array)

    unless session[:dismissed_alerts].include? id
      tag.div(
        id: id,
        class: "alert #{class_name} alert-dismissable",
        data: { controller: 'alert', alert_target: 'alert' }
      ) do
        tag.button(
          raw('&times;'),
          class: 'ml-2 close',
          data: {
            dismiss_id: id,
            dismiss_url: dismiss_helper_path,
            action: 'alert#dismiss',
            alert_target: 'dismisser'
          }
        ) + capture(&block)
      end
    end
  end

  def flash_class(key)
    {
      'notice' => 'alert-success',
      'alert' => 'alert-warning',
      'errors' => 'alert-danger'
    }[key]
  end

  def dashboard_panel(heading: '', color: 'rgba(0, 0, 0, 0.03)', &block)
    content_tag('div', class: 'card') do
      content_tag('div', heading, class: 'card-header', style: "background-color: #{color}") +
        content_tag('div', class: 'card-body') { capture(&block) }
    end
  end

  def contact_path
    "/contact"
  end

  def current_username
    current_user&.username
  end

  def has_ability?(permission)
    current_user && current_user.has_ability?(permission)
  end

  def og_tags(title:, image:, url:, type: 'website')
    tag.meta(proeprty: 'og:type', content: type) +
      tag.meta(property: 'og:title', content: title) +
      tag.meta(property: 'og:url', content: url) +
      tag.meta(property: 'og:image', content: image)
  end

  def paginate_preview(ary, num, path)
    raw("1-#{num} of #{ary.count} :: " + link_to("see all", path))
  end

  def entity_link(entity, name = nil, html_class: nil, html_id: nil, target: nil)
    name ||= entity.name
    link_to name, concretize_entity_path(entity), class: html_class, id: html_id, target: target
  end

  # Input: [References], Integer | nil
  def references_select(references, selected_id = nil)
    return nil if references.nil?
    options_array = references.collect { |r| [r.document.name, r.id] }
    select_tag(
      'reference_existing',
      options_for_select(options_array, selected_id),
      { include_blank: true, class: 'selectpicker', name: 'reference[reference_id]' }
    )
  end

  def user_admin?
    user_signed_in? && current_user.admin?
  end

  def show_donation_banner?
    if Rails.application.config.littlesis[:donation_banner_display] == 'everywhere'
      return true
    end

    if Rails.application.config.littlesis[:donation_banner_display] == 'homepage' &&
       controller_name == 'home' &&
       controller.action_name == 'index'
      return true
    end

    false
  end

  def show_stars?
    user_admin? && current_user.settings.show_stars
  end
end
