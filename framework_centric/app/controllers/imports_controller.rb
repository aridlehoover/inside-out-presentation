require_relative '../../../lib/base_controller'
require_relative '../../../lib/rss'
require_relative '../../../lib/alert'

class ImportsController < BaseController
  def create
    feed_items = case params[:url]
    when /xml/
      RSS.read(params[:url])
    else
      return render :new, notice: 'Unable to import alerts.'
    end

    if feed_items.empty?
      return render :new, notice: 'Unable to import alerts.'
    end

    feed_items.each do |item|
      case params[:url]
      when 'nws.xml'
        Alert.create(
          id: item.id,
          title: item.title,
          description: item.summary,
          published_at: item.published,
          updated_at: item.updated,
          effective_at: item.cap_effective,
          expires_at: item.cap_expires
        )
      when 'noaa.xml'
        Alert.create(
          id: item.id,
          title: item.title,
          description: item.description,
          published_at: item.pub_date,
          updated_at: item.last_update,
          effective_at: item.pub_date,
          expires_at: (Time.parse(item.pub_date) + 6 * 3600).to_s
        )
      end
    end

    redirect_to '/alerts', notice: 'Alerts imported.'
  end
end
