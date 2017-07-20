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

  def empty?
    @mark_list.empty?
  end

  def last_mark_time
    @mark_list[-1].time
  end

  def total_time marks_count = @mark_list.length
    marks = @mark_list.reverse.first(marks_count)
    last = marks[0]
    current_period_duration + TimeMark.sec_to_hour(
        marks.inject(0){|total, mark|
                total = total +  last.time.to_i - mark.time.to_i unless mark.paused?
                last = mark
                total
    })
  end

  def current_period_duration
    if last_paused?
      0
    else
      TimeMark.sec_to_hour(Time.now.to_i - @mark_list[-1].time.to_i)
    end
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

    marks.each_with_index{|m, i|
      elapsed_hours = total_time(i+1)
      spaces_count = spaces_for_max + max_name_length - (m.paused? ? "paused" : "unpaused").length
      m.puts_mark(elapsed_hours, spaces_count)
    }
  end
end

