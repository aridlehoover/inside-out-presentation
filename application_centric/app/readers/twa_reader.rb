require_relative '../../../lib/twitter'

class TWAReader < Reader
  ONE_HOUR = 3600

  def read
    Twitter.get_tweets(url).map { |item| parse(item) }
  end

  private

  def parse(item)
    title, desc = item.body.match(/^([^.]*)\.(.*)/).captures
    {
      id: item.id,
      title: title,
      description: desc,
      published_at: item.date_time,
      updated_at: item.date_time,
      effective_at: item.date_time,
      expires_at: (Time.parse(item.date_time) + ONE_HOUR).to_s
    }
  end
end
