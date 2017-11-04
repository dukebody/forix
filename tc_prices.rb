require_relative "prices"
require "test/unit"
 
class TestPrice < Test::Unit::TestCase
  def setup
    set_factor('SEK', 0.1)
    set_factor('EUR', 1)
  end

  def teardown
    clear_factors
  end
 
  def test_no_conversion
    price = Price.new(12.10, 'EUR')
    assert_equal(convert_to_currency(price, 'EUR'), price)
  end
  
  def test_convert_to_sek
    price = Price.new(12.10, 'EUR')
    price_sek = convert_to_currency(price, 'SEK')
    assert_equal((12.10 * 0.1).round(2), price_sek.amount)
    assert_equal('SEK', price_sek.currency)
  end

  def test_currency_not_found
     price = Price.new(1, 'EUR')
     assert_raise(CurrencyNotFound) {convert_to_currency(price, 'BTC')}
  end
 
end
