require "active_record"

class Record < ActiveRecord::Base

  enum record_type: [:real_time, :toi] 
end