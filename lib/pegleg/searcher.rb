# encoding: utf-8
module Pegleg
  class Searcher

    attr_accessor :q
    attr_accessor :host

    def initialize q, host='thepiratebay.se'
      @q = q
      @host = host
    end

    def run
      @doc = Nokogiri::HTML(open("http://#{host}/search/#{URI::encode(q)}/0/7/0"))
      self
    end

    def results
      a = @doc.css('table#searchResult tr').map { |x| if x.css('th').size == 0 then result_from_tr(x) else nil end }
      a.reject! { |x| x.nil? }
      a
    end

    def result_from_tr tr
      r = Result.new
      tds = tr.css('td')
      r.title = tr.css('.detName').text
      r.seeds = tds[2].text
      r.leachers = tds[3].text
      r.url = tds[1].css('a')[1].attr('href')
      r
    end

  end
end
