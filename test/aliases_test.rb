require 'test_helper'
require 'emoji/aliases'

class AliasesTest < TestCase
  test "aliases" do
    assert_equal %w[happy joy pleased], Emoji.aliases_for('smile')
  end

  test "no aliases" do
    list = Emoji.aliases_for('unamused')
    assert list.empty?
    assert_raises(RuntimeError) { list.push('a') }
  end
end
