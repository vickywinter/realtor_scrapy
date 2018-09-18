# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class RealtorItem(scrapy.Item):
    # define the fields for your item here like:
    address = scrapy.Field()
    city=scrapy.Field()
    state=scrapy.Field()
    zip_code = scrapy.Field()
    beds = scrapy.Field()
    bath_full = scrapy.Field()
    bath_half = scrapy.Field()
    area_ft = scrapy.Field()
    lot_ft = scrapy.Field()
    sold_price = scrapy.Field()
    sold_date = scrapy.Field()
    price_ft=scrapy.Field()
    property_type = scrapy.Field()
    built_year = scrapy.Field()
    days_on_market = scrapy.Field()
    school1 = scrapy.Field()
    school2 = scrapy.Field()
    school3 = scrapy.Field()

    pass
