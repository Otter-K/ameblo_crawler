require 'open-uri'
require 'nokogiri'
require 'uri'

class AmebloEntryCrawler
  attr_reader :entry_url

  def initialize(entry_url)
    @entry_url = entry_url
  end

  def entry_crawl
    entry_html = fetch_html(entry_url)
    parse_entry(entry_html)
  end

  private

  def fetch_html(url)
    sleep 1
    URI.open(url) do |f|
      charset = f.charset
      f.read
    end
  end

  def parse_entry(entry_html)
    doc = Nokogiri::HTML.parse(entry_html, nil, nil)
    title = parse_title(doc)
    body = parse_body(doc)
    img_links = parse_img_links(doc)
    {
      title: title,
      body: body,
      img_links: img_links
    }
  end

  def parse_title(doc)
    doc.css('a.skinArticleTitle').text
  end

  def parse_body(doc)
    body_elements = doc.css('div.skin-entryBody')
    body_elements.css('br').each do |br|
      br.replace("\n")
    end
    body = body_elements.text
  end

  def parse_img_links(doc)
    img_elements = doc.css('div.skin-entryBody img.PhotoSwipeImage')
    img_elements.map do |ele|
      uri = URI.parse(ele.attr(:src))
      "#{uri.scheme}://#{uri.host}#{uri.path}"
    end.uniq
  end
end

if __FILE__ == $PROGRAM_NAME
  entry_url = ARGV[0] || 'https://ameblo.jp/taskhavefun/entry-12548562164.html'
  crawler = AmebloEntryCrawler.new(entry_url)
  puts crawler.entry_crawl
end
