require File.dirname(__FILE__) + '/helper'

begin
require 'sass'

class SassTest < Test::Unit::TestCase
  def sass_app(&block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    }
    get '/'
  end

  it 'renders inline Sass strings' do
    sass_app { sass "#sass\n  :background-color white\n" }
    assert ok?
    assert_equal "#sass {\n  background-color: white; }\n", body
  end

  it 'renders .sass files in views path' do
    sass_app { sass :hello }
    assert ok?
    assert_equal "#sass {\n  background-color: white; }\n", body
  end
  
  it 'renders .scss files in views path' do
    sass_app { scss :hello }
    assert ok?
    assert_equal "#scss {\n  background-color: white; }\n", body
  end

  it 'ignores the layout option' do
    sass_app { sass :hello, :layout => :layout2 }
    assert ok?
    assert_equal "#sass {\n  background-color: white; }\n", body
  end

  it "raises error if template not found" do
    mock_app {
      get('/') { sass :no_such_template }
    }
    assert_raise(Errno::ENOENT) { get('/') }
  end

  it "passes SASS options to the Sass engine" do
    sass_app {
      sass "#sass\n  :background-color white\n  :color black\n",
        :style => :compact
    }
    assert ok?
    assert_equal "#sass { background-color: white; color: black; }\n", body
  end

  it "passes default SASS options to the Sass engine" do
    mock_app {
      set :sass, {:style => :compact} # default Sass style is :nested
      get '/' do
        sass "#sass\n  :background-color white\n  :color black\n"
      end
    }
    get '/'
    assert ok?
    assert_equal "#sass { background-color: white; color: black; }\n", body
  end

  it "merges the default SASS options with the overrides" do
    mock_app {
      # default Sass attribute_syntax is :normal (with : in front)
      set :sass, {:style => :compact, :attribute_syntax => :alternate }
      get '/' do
        sass "#sass\n  background-color: white\n  color: black\n"
      end
      get '/raised' do
        # retains global attribute_syntax settings
        sass "#sass\n  :background-color white\n  :color black\n",
          :style => :expanded
      end
      get '/expanded_normal' do
        sass "#sass\n  :background-color white\n  :color black\n",
          :style => :expanded, :attribute_syntax => :normal
      end
    }
    get '/'
    assert ok?
    assert_equal "#sass { background-color: white; color: black; }\n", body
    assert_raise(Sass::SyntaxError) { get('/raised') }
    get '/expanded_normal'
    assert ok?
    assert_equal "#sass {\n  background-color: white;\n  color: black;\n}\n",
      body
  end
end

rescue
  warn "#{$!.to_s}: skipping sass tests"
end
