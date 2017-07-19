class TimeMark
  attr_reader :time

  def self.sec_to_hour secs
    secs.to_f / 60 / 60
  end

  def paused?
    @is_paused
  end

  def initialize time, is_paused
    @time = time
    @is_paused = is_paused
  end

  def puts_mark spaces_count = 4
    puts "#{@is_paused ? "paused" : "unpaused"}"+ '.'*spaces_count +
             "#{@time}....[elapsed_time]: #{TimeMark.sec_to_hour(Time.now - @time.to_i)} hours ago"
  end
end
