xml.instruct! :xml, :version => "1.0"
xml.rss(
  "version" => "2.0",
  "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
  "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  "xmlns:atom" => "http://www.w3.org/2005/Atom",
  "xmlns:sy" => "http://purl.org/rss/1.0/modules/syndication/",
  "xmlns:slash" => "http://purl.org/rss/1.0/modules/slash/"
) do
  xml.channel do
    xml.title @campaign.book_title
    xml.description @campaign.author_and_book_name
    xml.link campaign_url(@campaign)
    xml.language "ja-ja"
    xml.ttl "40"
    xml.pubDate(Time.current.rfc822)
    xml.atom :link, "href" => campaign_url(@campaign), "rel" => "self", "type" => "application/rss+xml"
    @feeds.each do |feed|
      xml.item do
        xml.title @campaign.book_title
        xml.description do
          xml.cdata! feed.content
        end
        xml.pubDate feed.send_at.rfc822
        xml.guid feed.id
        xml.link feed_url(feed)
      end
    end
  end
end