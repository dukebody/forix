require 'net/http'
require 'json'
require_relative 'utils'


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


class CurrencySource
    def get_factors
        raise "Return a hashmap of {currency_code => factor}"
    end
end


class FixerIO < CurrencySource
    def get_factors
        rates_json = Net::HTTP.get('api.fixer.io', '/latest')
        data = JSON.parse(rates_json)
        factors = data["rates"]
        # inject base factor (EUR)
        factors[data["base"]] = 1
        return factors 
    end
end


class CurrencyExchange
    def initialize()
        @store = {}
    end
    
    def get_factor(currency)
        factor = @store[currency]
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
         
        @store[currency] = factor
    end


    def clear_factors
        @store.clear
    end


    def sync(currency_source)
        clear_factors

        factors = currency_source.get_factors
        factors.each do |currency, factor|
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

end

