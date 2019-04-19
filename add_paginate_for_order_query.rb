require 'order_query'

# cursor_id: default: nil
# strict [true, false] default: true
# direction [:before, :after] default: :after
# step_size: default: 20
module OrderQuery
  class Pagination
    MAX_LIMIT_NO      = 100
    DEFAULT_STEP_SIZE = 20

    attr_reader :unique_column, :direction, :loaded_cursor
    alias :loaded_cursor? :loaded_cursor

    def initialize(space, cursor_id, opts)
      @space             = space
      @current_cursor_id = cursor_id
      @loaded_cursor     = false
      extract_options(opts)
    end

    def step_size
      @step_size ||= DEFAULT_STEP_SIZE
    end

    # 当前页的游标
    def current_cursor
      unless loaded_cursor?
        record          = cursor_record
        @current_cursor = @space.at(record) if record
        @loaded_cursor  = true
      end

      @current_cursor
    end

    # true: 不包含当前游标，false：包含当前游标
    def is_strict?
      case @strict
      when 'true'
        true
      when 'false'
        false
      else
        !is_first_step?
      end
    end

    def paginate
      rel =
        if current_cursor
          current_cursor.side(direction, is_strict?).limit(step_size)
        else
          @space.scope.where('1=0').limit(step_size)
        end

      rel.cattr_accessor(:step_size, :next_cursor_id, :previous_cursor_id, instance_reader: false)
      rel.step_size = step_size

      case direction
      when :after
        rel.next_cursor_id = rel.last.try(unique_column.name)
      when :before
        rel.previous_cursor_id = rel.last.try(unique_column.name)
      end

      rel
    end

    private

    def extract_options(opts)
      @strict        = opts[:strict].to_s
      @direction     = opts[:direction].to_s != 'before' ? :after : :before
      @step_size     = opts[:step_size].to_i if (1..MAX_LIMIT_NO).member?(opts[:step_size].to_i)
      @unique_column = @space.columns.last
    end

    def cursor_record
      if is_first_step?
        asc_scope_by_direction.first
      else
        @space.scope.model.find_by(unique_column.name => @current_cursor_id) || find_near_record
      end
    end

    def is_first_step?
      @current_cursor_id.blank?
    end

    def asc_scope_by_direction
      if @direction == :before
        @space.scope_reverse
      else
        @space.scope
      end
    end

    # 查找最近的一个。只局限于唯一标识排序
    def find_near_record
      return unless @space.columns.one? && @current_cursor_id.present?

      @strict = 'false'
      asc_scope_by_direction.where("#{unique_column.column_name} #{near_record_direction} ?", @current_cursor_id).first
    end

    def near_record_direction
      (@direction == :before && unique_column.direction == :asc) ||
        (@direction != :before && unique_column.direction == :desc) ? '<' : '>'
    end
  end

  class Space
    # 分页信息
    def paginate(cursor_id, opts)
      Pagination.new(self, cursor_id, opts).paginate
    end
  end

  self.wrap_top_level_or = false
end
