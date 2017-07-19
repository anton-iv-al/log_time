class TimeMark
  attr_reader :time

  def paused?
    @is_paused
  end

  def initialize time, is_paused
    @time = time
    @is_paused = is_paused
  end
end
