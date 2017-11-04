require_relative "prices"
require "test/unit"
 
class DummyCurrencySource
    def get_factors
        return {"EUR" => 1.11, "GBP" => 12.1}
    end 
end


class TestPrice < Test::Unit::TestCase
  def setup
    @exchange = CurrencyExchange.new
    
    @exchange.set_factor('SEK', 0.1)
    @exchange.set_factor('EUR', 1)
  end

  def teardown
    @exchange.clear_factors
  end
 
  def test_no_conversion
    price = Price.new(12.10, 'EUR')
    assert_equal(@exchange.convert_to_currency(price, 'EUR'), price)
  end
  
  def test_convert_to_sek
    price = Price.new(12.10, 'EUR')
    price_sek = @exchange.convert_to_currency(price, 'SEK')
    assert_equal((12.10 * 0.1).round(2), price_sek.amount)
    assert_equal('SEK', price_sek.currency)
  end

  def test_currency_not_found
     price = Price.new(1, 'EUR')
     assert_raise(CurrencyNotFound) {@exchange.convert_to_currency(price, 'BTC')}
  end
  
  def test_sync_currencies
    currency_source = DummyCurrencySource.new
    @exchange.sync(currency_source)
    assert_equal(1.11, @exchange.get_factor("EUR"))
    assert_equal(12.1, @exchange.get_factor("GBP"))
  end
 
end
