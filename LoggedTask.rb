class LoggedTask
  attr_reader :name

  def initialize name
    @name = name
    @time_list = []
  end

  def<< time
    @time_list << TimeMark.new(time)
  end

  def total_time
    last = @time_list[0].time.to_i
    sec_to_hour @time_list.inject(0){|total, mark|
      period = total + mark.time.to_i - last
      last = mark.time.to_i
      period
    }
  end
end

def hour_to_sec hours
  hours * 60 * 60
end

def sec_to_hour secs
  secs.to_f / 60 / 60
end
