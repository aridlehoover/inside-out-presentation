require_relative '../../../lib/base_controller'
require_relative '../../../lib/rss'
require_relative '../../../lib/alert'

class ImportsController < BaseController
  def create
    unless params[:url] == 'nws.xml'
      return render :new, notice: 'Unable to import alerts.'
    end

    feed_items = RSS.read(params[:url])

    if feed_items.empty?
      return render :new, notice: 'Unable to import alerts.'
    end

    feed_items.each do |feed_item|
      Alert.create(
        id: feed_item.id,
        title: feed_item.title,
        description: feed_item.summary,
        published_at: feed_item.published,
        updated_at: feed_item.updated,
        effective_at: feed_item.cap_effective,
        expires_at: feed_item.cap_expires
      )
    end

    redirect_to '/alerts', notice: 'Alerts imported.'
  end
end
