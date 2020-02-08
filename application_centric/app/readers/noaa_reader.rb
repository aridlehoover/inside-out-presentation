require_relative '../../../lib/rss'

class NOAAReader < Reader
  SIX_HOURS = 6 * 3600

  def read
    RSS.read(url).map { |item| parse(item) }
  end

  private

  def parse(item)
    {
      id: item.id,
      title: item.title,
      description: item.description,
      published_at: item.pub_date,
      updated_at: item.last_update,
      effective_at: item.pub_date,
      expires_at: (Time.parse(item.pub_date) + SIX_HOURS).to_s
    }
  end
end
