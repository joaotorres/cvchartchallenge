class ChartsController < ApplicationController
  require 'open-uri'
  PREVIOUS_DAYS = 6

  def index
    parse
    @first_day = Time.zone.today - PREVIOUS_DAYS
    rates = Rate.where('date >= ?', Date.today - 6).order(:date)
    @usd_rates = currency_conversion(rates.pluck(:usd))
    @eur_rates = currency_conversion(rates.pluck(:eur))
    @ars_rates = currency_conversion(rates.pluck(:ars))
  end

  private

  def parse
    date_range.each do |date|
      unless Rate.find_by(date: date)
        stream = open(
          "http://apilayer.net/api/historical"+
          "?access_key=66be6bb04f96fdcd9f881be872d752f1"+
          "&date=#{date.strftime("%Y-%m-%d")}"+
          "&currencies=BRL,USD,EUR,ARS"+
          "&format=1"
        )
        data = stream.read
        rate = JSON.parse(data)
        create_rate(rate)
      end
    end
  end

  def date_range
    today = Time.zone.today
    last_day = today - PREVIOUS_DAYS
    (last_day..today)
  end

  def create_rate(rate)
      quote = rate["quotes"]
      Rate.create(date: rate["date"].to_date,
                  usd: (1 / quote["USDBRL"]),
                  eur: (1 / (quote["USDBRL"] / quote["USDEUR"])),
                  ars: (1 / (quote["USDBRL"] /quote["USDARS"]))
                  )
  end

  def currency_conversion(currency)
    currency.map { |quote| (1 / quote).round(2) }
  end

end

