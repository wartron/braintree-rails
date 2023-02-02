module Helper
  def fixture(name)
    File.read(File.join(FIXTURE_PATH, name)).gzip
  end

  def stub_braintree_request(method, path, response)
    configuration = Braintree::Configuration.instantiate
    request_header = {
      :basic_auth => [BraintreeRails::Configuration.public_key, BraintreeRails::Configuration.private_key],
      :headers => {
        'Accept'=>'application/xml',
        'Accept-Encoding'=>'gzip',
        'User-Agent'=> configuration.user_agent,
        'X-Apiversion'=> configuration.api_version
      }
    }
    response_header = {
      :headers => {
        'Content-Type' => ['application/xml', 'charset=utf-8'],
        'Content-Encoding' => 'gzip'
      }
    }
    stub_request(method, BraintreeBaseUri+path).with(request_header).to_return(response.reverse_merge(response_header))
  end

  def address_hash
    {
      :first_name => 'Brain',
      :last_name => 'Tree',
      :company => 'Braintree',
      :street_address => "#{(1000..9999).to_a.sample} Crane Avenue",
      :extended_address => "Suite #{(100..999).to_a.sample}",
      :locality => 'Menlo Park',
      :region => 'CA',
      :postal_code => ("00001".."99999").to_a.shuffle.first,
      :country_name => 'United States of America'
    }
  end

  def credit_card_hash
    {
      :token => 'credit_card_id',
      :number => (Braintree::Test::CreditCardNumbers::All -
                  Braintree::Test::CreditCardNumbers::AmExes -
                  Braintree::Test::CreditCardNumbers::AmexPayWithPoints::All).shuffle.first,
      :cvv => ("100".."999").to_a.shuffle.first,
      :cardholder_name => 'Brain Tree',
      :expiration_month => ("01".."12").to_a.shuffle.first,
      :expiration_year => ("2012".."2035").to_a.shuffle.first,
      :billing_address => address_hash,
    }
  end

  def customer_hash
    {
      :first_name => "Brain#{(1..100).to_a.sample}",
      :last_name => "Tree#{(1..100).to_a.sample}"
    }
  end

  def subscription_hash
    {
      :id => 'subscription_id',
      :plan_id => 'plan_id',
      :payment_method_token => 'credit_card_id',
      :first_billing_date => Date.tomorrow,
      :price => ''
    }
  end

  def merchant_account_hash(kind = :email)
    {
      :master_merchant_account_id => BraintreeRails::Configuration.default_merchant_account_id,
      :tos_accepted => true,
      :individual => individual_details_hash,
      :funding => send("#{kind.to_s}_funding_details_hash"),
      :business => business_details_hash,
    }
  end

  def individual_details_hash
    {
      :first_name => "Brain",
      :last_name => "Tree",
      :email => "braintree-rails@exameple.com",
      :date_of_birth => "1983-01-01",
      :address => address_details_hash
    }
  end

  def business_details_hash
    {
      :legal_name => "braintree-rails",
      :dba_name => "braintree-rails",
      :tax_id => "98-7654321"
    }
  end

  def email_funding_details_hash
    {
      :destination => Braintree::MerchantAccount::FundingDestination::Email,
      :email => "braintree-rails@exameple.com"
    }
  end

  def bank_funding_details_hash
    {
      :destination => Braintree::MerchantAccount::FundingDestination::Bank,
      :email => "braintree-rails@example.com",
      :mobile_phone => '2015551212',
      :account_number => '1234567890',
      :routing_number => '071101307'
    }
  end

  def address_details_hash
    {
      :street_address => "#{(1000..9999).to_a.sample} Crane Avenue",
      :locality => 'Menlo Park',
      :region => 'CA',
      :postal_code => ("00001".."99999").to_a.shuffle.first,
    }
  end
end
