require_relative 'time_mark'

class LoggedTask
  def initialize
    @mark_list = []
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
    current_period_duration + TimeMark.sec_to_hour(
        @mark_list.inject(0){|total, mark|
                pause_period = last.paused?
                period = total + mark.time.to_i - last.time.to_i
                last = mark
                pause_period ? 0 : period
    })
  end

  def current_period_duration
    TimeMark.sec_to_hour(Time.now.to_i - @mark_list[-1].time.to_i)
  end

  def puts_marks_list max_lines
    if @mark_list.empty?
      puts "have no @mark_list"
      return
    end

    max_name_length = "unpaused".length
    spaces_for_max = 4

    marks = @mark_list.reverse
    marks = @mark_list.first(max_lines) if max_lines > 0

    marks.each{|m| m.puts_mark(spaces_for_max + max_name_length - (m.paused? ? "paused" : "unpaused").length)}
  end
end

