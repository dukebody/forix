require 'net/http'
require 'json'
require_relative 'utils'


CURRENCY_STORE = {}


class Price
    def initialize(amount, currency)
        @amount = amount
        @currency = currency
    end
    
    attr_reader :amount
    attr_reader :currency
end


class CurrencyNotFound < ArgumentError  
end 


def get_factor(currency)
    factor = CURRENCY_STORE[currency]
    if factor == nil
        raise CurrencyNotFound, currency
    else
        return factor.to_f
    end
end


def set_factor(currency, factor)
    if not currency.size == 3
        raise ArgumentError("Currency must be a 3-letter code")
    elsif not is_number? factor
        raise ArgumentError('Factor must be a number')
    end
     
    CURRENCY_STORE[currency] = factor
end


def clear_factors
    CURRENCY_STORE.clear
end


def sync_currencies()
    rates_json = Net::HTTP.get('api.fixer.io', '/latest')
    data = JSON.parse(rates_json)
    set_factor(data["base"], 1)
    data["rates"].each do |currency, factor|
        set_factor(currency, factor)
    end
end


def convert_to_currency(price, target_currency) if price.currency == target_currency
        return price
    else
        # check the currencies
        from_factor = get_factor(price.currency)
        to_factor = get_factor(target_currency)
        if to_factor == nil
            raise CurrencyNotFound, target_currency
        elsif from_factor == nil
            raise CurrencyNotFound, price.currency
        end
        factor = to_factor / from_factor
        amount = (price.amount * factor).round(2)
        return Price.new(amount=amount, currency=target_currency)
    end
end

