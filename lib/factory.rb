# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# + each
# + each_pair
# + dig
# + size/length
# + members
# + select
# + to_a
# + values_at
# + ==, eql?

class Factory
  class << self

    def new(*fields, &methods)
      if fields[0].is_a? String
        class_name, *fields = fields
        const_set(class_name, create_class(*fields, &methods))
      else
        create_class(*fields, &methods)
      end
    end

    def create_class(*fields, &methods)
      Class.new do
        attr_accessor(*fields)

        define_method :initialize do |*values|
          raise ArgumentError, "Wrong number of parameters" if values.size != fields.size  
          fields.each_with_index { |field, index| instance_variable_set "@#{field}", values[index] }
        end

        define_method :[] do |field|
          instance_variable_get field.is_a?(Integer) ? instance_variables[field] : "@#{field}"          
        end

        define_method :[]= do |field, value|
          instance_variable_set field.is_a?(Integer) ? instance_variables[field] : "@#{field}", value
        end

        def ==(other)
          self.class == other.class && self.to_a == other.to_a
        end
        alias :eql? :==

        def to_a
          instance_variables.map { |value| instance_variable_get value }
        end

        def each(&block)
          to_a.each(&block)
        end

        define_method :members do
          fields
        end

        def each_pair(&block)
          members.zip(to_a).each(&block)
        end

        def size
          instance_variables.size
        end
        alias :length :size

        def values_at(*indexes)
          to_a.values_at(*indexes)
        end

        def dig(*keys)
          keys.inject(self) { |values, key| values[key] if values }
        end

        def select(&block)
          to_a.select(&block)
        end

        class_eval &methods if block_given?
      end
    end
  end
end
