# -*- coding: utf-8 -*-
import scrapy
from Realtor.items import RealtorItem


class RealtorSoldSjSpider(scrapy.Spider):
    name = 'Realtor_sold_sj'
    allowed_domains = ['realtor.com']
    start_urls = ['https://www.realtor.com/soldhomeprices/San-Jose_CA/pg-36']


    def parse(self, response):
        for link in response.css('ul.srp-list-marginless li.component_property-card div.photo-wrap a::attr(href)').extract():
            quote=response.urljoin(link)
            yield scrapy.Request(quote,callback=self.parse_listing_result_content)
            #item=RealtorItem()

        next_page = response.css('nav.pagination span.next a::attr(href)').extractS_first()
        if next_page is not None:
            next_page = response.urljoin(next_page)
            yield scrapy.Request(next_page, callback=self.parse)


    def parse_listing_result_content(self,response):
        item=RealtorItem()

        

        item['address'] = response.xpath('//*[@id="ldp-address"]/h1/span[1]/text()').extract_first()
        item['city']=response.xpath('//*[@id="ldp-address"]/h1/span[2]/text()').extract_first()
        item['state']=response.xpath('//*[@id="ldp-address"]/h1/span[3]/text()').extract_first()
        item['zip_code'] = response.xpath('//*[@id="ldp-address"]/h1/span[4]/text()').extract_first()
        item['beds'] = response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-beds"]/span/text()').extract_first()
        
        bath_full= response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-bath"]/span/text()').extract_first()
        #bath_full2=response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-baths"]/div[1]/span/text()').extract_first()
        #item['bath_full'] =max(int(bath_full1),int(bath_full2))
        if bath_full is None : 
            item['bath_full'] = response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-baths"]/div[1]/span/text()').extract_first()
        else:
            item['bath_full'] = bath_full

        item['bath_half'] = bath_half=response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-baths"]/div[2]/span/text()').extract_first()
        

        item['area_ft'] = response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-sqft"]/span/text()').extract_first()
        item['lot_ft'] = response.xpath('//*[@id="ldp-property-meta"]/ul//li[@data-label="property-meta-lotsize"]/span/text()').extract_first()
        item['sold_price'] = response.xpath('//*[@id="ldp-pricewrap"]/div/div/span[2]/@content').extract_first()
        item['sold_date'] = response.xpath('//*[@id="listing-header"]/div[1]/div[1]/div[1]/span/text()').extract_first().split('on ')[1]
        item['price_ft']=response.css('#key-fact-carousel ul.owl-carousel li.ldp-key-fact-item div.key-fact-data::text').extract()[1].split('$')[1]
        item['property_type'] = response.css('#key-fact-carousel ul.owl-carousel li.ldp-key-fact-item div.key-fact-data::text').extract()[2]
        item['built_year'] = response.css('#key-fact-carousel ul.owl-carousel li.ldp-key-fact-item div.key-fact-data::text').extract()[3]
        
        #need modify
        days=response.css('#market-summary-data div.data-tile-padding div.summary-datapoint::text').extract()
        days_on=[x for x in days if '%' not in x and '$' not in x]
        item['days_on_market'] = ''.join(days_on).strip()
        item['school1'] = response.xpath('//*[@id="load-more-schools"]/table/tbody/tr[1]/td[1]/span/text()').extract_first()
        item['school2'] = response.xpath('//*[@id="load-more-schools"]/table/tbody/tr[2]/td[1]/span/text()').extract_first()
        item['school3'] = response.xpath('//*[@id="load-more-schools"]/table/tbody/tr[3]/td[1]/span/text()').extract_first()

        yield item