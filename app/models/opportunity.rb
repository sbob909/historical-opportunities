class Opportunity < ActiveRecord::Base
  attr_accessible :amount, :closed_on, :lead_source, :name, :order_number, :sfdc_id, :stage
end
