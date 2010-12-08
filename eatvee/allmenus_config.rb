#allmenus config
#
#

config = {

  :linkfinder => {
    :base_url => 'http://www.allmenus.com',
    :start_urls => [
      'http://www.allmenus.com/sitemap-1.xml', 
      'http://www.allmenus.com/sitemap-2.xml', 
      'http://www.allmenus.com/sitemap-3.xml', 
      'http://www.allmenus.com/sitemap-4.xml', 
      'http://www.allmenus.com/sitemap-5.xml', 
      'http://www.allmenus.com/sitemap-6.xml', 
      'http://www.allmenus.com/sitemap-7.xml', 
      'http://www.allmenus.com/sitemap-8.xml', 
      'http://www.allmenus.com/sitemap-9.xml'],
    :site => 'allmenus',
    :steps => {
      :extract_url => [
	['xsl', "//loc"],
	['inner_text', ""],
	['ruby', 'doc.map {|x| x if x =~ /www.allmenus.com\/(ca|ny).*menu\/$/ }.compact']
      ],
    },
  },

  :extractor => {
    :site => 'allmenus',
    :steps => {
      :name => [
        ['xsl', "//div[@id='restaurant_info']/h1"],
        ['inner_text', ""],
      ],
      :address => [
        ['xsl', "//meta[@property*='street-address']"],
        ['attr', "content"],
      ],
      :city => [
        ['xsl', "//meta[@property*='locality']"],
        ['attr', "content"],
      ],
      :state => [
        ['xsl', "//meta[@property*='region']"],
        ['attr', "content"],
      ],
      :website => [
        ['xsl', "//div[@id='restaurant_info']//a[text()*='Website']"],
        ['attr', "href"],
      ],
      :phone => [
	['xsl', "//div[@id='phone']"],
	['inner_text', ""],
	['ruby', 'doc.map {|x| x.gsub(/\D/, "")}'],
      ],
      :menu_link => [
	['ruby', '@link'],
      ],
    }
  }
}
