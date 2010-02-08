require 'pp'
require File.dirname(__FILE__) + '/test_helper.rb'

class TestBook
  include Sortable
  
  attr_accessor :author, :title
  
  def initialize(author, title)
    self.author = author
    self.title  = title
  end
end

class BaseBook
  include Sortable
  attr_accessor :author
  sortable :author
  def initialize(opts)
    @author = opts[:author]
  end
end

class SuperBook < BaseBook
  attr_accessor :copies
  sortable :copies
  def initialize(opts)
    @copies = opts[:copies]
    super(opts)
  end
end

class TestSortable < Test::Unit::TestCase
  def setup
    @fforde  = TestBook.new('Fforde', 'Something Rotten')
    @stroud1 = TestBook.new('Stroud', 'The Golem\'s Eye')
    @stroud2 = TestBook.new('Stroud', 'The Amulet of Samarkand')
    @colfer  = TestBook.new('Colfer', 'Artemis Fowl')
    
    @books = [@fforde, @stroud1, @stroud2, @colfer]
  end
  
  def test_sortable_should_be_defined
    assert_nothing_raised do
      Sortable
    end
  end
  
  def test_books_should_sort_by_author_and_title
    TestBook.send(:sortable, :author, :title)
    
    assert_equal [@colfer, @fforde, @stroud2, @stroud1], @books.sort
  end
  
  def test_books_should_sort_by_unaltered_title
    TestBook.send(:sortable, :title, :author)
    
    assert_equal [@colfer, @fforde, @stroud2, @stroud1], @books.sort
  end
  
  def test_books_should_sort_by_altered_title
    TestBook.send(:sortable, lambda {|book| book.title.sub(/^(The|A|An) /, '')}, :author)
    
    assert_equal [@stroud2, @colfer, @stroud1, @fforde], @books.sort
  end
  
  def test_works_with_inheritance
    @bases = [BaseBook.new(:author => "BbbbB"), BaseBook.new(:author => "AaaAA"), BaseBook.new(:author => "CccCC")]
    b, a, c = @bases
    assert_equal [a,b,c], @bases.sort
    
    @supers = [SuperBook.new(:author => "BbbbB", :copies => 999), SuperBook.new(:author => "AaaAA", :copies => 666), SuperBook.new(:author => "CccCC", :copies => 333)]
    nine, six, three = @supers
    assert_equal [three, six, nine], @supers.sort
  end
  
  class EqualClass
    def initialize(n)
      @n = n
    end
    attr_reader :n
    
    include Sortable
    
    sortable :n
  
    def ==(other)
      true
    end
  end
  
  def test_equal_records_are_not_sorted # we want to avoid the overhead of calling lots of methods
    @equals = [EqualClass.new(73), EqualClass.new(12), EqualClass.new(39)]
    assert_equal @equals, @equals.sort
    assert_equal [73, 12, 39], @equals.sort.map{|r| r.n}
  end
  
end
