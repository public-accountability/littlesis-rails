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

  # see shared/notice
  def alert_div(message:, type:)
    flash_class =  { 'notice' => 'alert-success',
                     'alert' => 'alert-warning',
                     'errors' => 'alert-danger' }[type.to_s]

    tag.div(class: ['alert', 'alert-dismissible', 'fade', 'show', flash_class], role: 'alert') do
      tag.span(message) + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>'.html_safe
    end
  end

  def dashboard_panel(heading: '', color: 'rgba(0, 0, 0, 0.03)', &block)
    content_tag('div', class: 'card') do
      content_tag('div', heading, class: 'card-header', style: "background-color: #{color}") +
        content_tag('div', class: 'card-body') { capture(&block) }
    end
  end

  def current_username
    current_user&.username
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
    case Rails.application.config.littlesis[:donation_banner_display]
    when 'everywhere'
      true
    when 'homepage'
      controller_name == 'home' && controller.action_name == 'index'
    else
      false
    end
  end

  def show_stars?
    user_signed_in? &&
      current_user.role.include?(:star_relationship) &&
      current_user.settings.show_stars
  end

  def bs_row_column(row_class: 'row', column_class: 'col', &block)
    tag.div(tag.div(class: column_class, &block), class: row_class)
  end
end
