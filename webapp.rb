require 'sinatra'
require 'json'
require_relative 'prices'
require_relative 'utils'

class Forix < Sinatra::Base
    @@exchange = CurrencyExchange.new

    def self.sync_currencies
       @@exchange.sync_currencies
    end

    get '/sync' do
        @@sync_currencies
        return "Synced!"
    end

    get '/convert' do
        required_params = ['amount', 'from', 'to']
        missing_params = required_params.find_all { |param| !params.include? param }
        if !missing_params.empty?
            halt 400, JSON.generate({:error => "Params #{missing_params} are missing"})
        end

        from_amount = params['amount']
        if not is_number? from_amount
            halt 400, JSON.generate({:error => "Param 'amount' must be a number"})
        end

        from_currency = params['from'].upcase
        to_currency = params['to'].upcase

        price = Price.new(from_amount.to_f, from_currency)
        begin
            new_price = @@exchange.convert_to_currency(price, to_currency)
        rescue CurrencyNotFound => currency
            halt 400, JSON.generate({:error => "Currency not found: #{currency}"})
        else
            JSON.generate({:original_amount => price.amount, :original_currency => price.currency,
             :converted_amount =>new_price.amount, :converted_currency => new_price.currency})
        end
    end

end
