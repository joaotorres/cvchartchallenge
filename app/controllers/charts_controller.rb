class ChartsController < ApplicationController
  require 'open-uri'
  before_action :parse, only: [:home]


  def home
    @days = Rate.pluck(:date)
    @usd = currency_conversion(Rate.pluck(:usd))
    @eur = currency_conversion(Rate.pluck(:eur))
    @ars = currency_conversion(Rate.pluck(:ars))
  end

  private

  def currency_conversion(currency)
    currency.map { |quote| (1 / quote).round(2) }
  end

  def set_date_str(date)
    @day = date.strftime("%d")
    @month = date.strftime("%m")
    @year = date.strftime("%Y")
  end

  def set_period
    today = Date.today
    last_day = today - 6
    @period = []

    until last_day == today
      @period << last_day
      last_day += 1
    end

    @period << today
  end

  def parse

    set_period

    @period.each do |date|
      if !Rate.find_by(date: date)
        set_date_str(date)
        stream = open(
          "http://apilayer.net/api/historical"+
          "?access_key=66be6bb04f96fdcd9f881be872d752f1"+
          "&date=#{@year}-#{@month}-#{@day}"+
          "&currencies=BRL,USD,EUR,ARS"+
          "&format=1"
        )
        data = stream.read
        rate = JSON.parse(data)
        create_rate(rate)
      end

    end

  end

  def create_rate(rate)
      quote = rate["quotes"]
      Rate.create(date: rate["date"].to_date,
                  usd: (1 / quote["USDBRL"]),
                  eur: (1 / (quote["USDBRL"] / quote["USDEUR"])),
                  ars: (1 / (quote["USDBRL"] /quote["USDARS"]))
                  )
  end
end

