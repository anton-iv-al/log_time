require_relative 'time_mark'

class LoggedTask
  attr_reader :mark_list

  def initialize
    @mark_list = []
  end

  def self.sec_to_hour secs
    secs.to_f / 60 / 60
  end

  def << mark
    @mark_list << mark
    @mark_list.sort_by!{|m| m.time}
  end

  def last_paused?
    @mark_list.empty? ? false : @mark_list[-1].paused?
  end

  def last_mark_time
    @mark_list[-1].time
  end

  def total_time
    last = @mark_list[0]
    current_period_duration + LoggedTask.sec_to_hour(
        @mark_list.inject(0){|total, mark|
                pause_period = last.paused?
                period = total + mark.time.to_i - last.time.to_i
                last = mark
                pause_period ? 0 : period
    })
  end

  def current_period_duration
    LoggedTask.sec_to_hour(Time.now.to_i - @mark_list[-1].time.to_i)
  end
end

