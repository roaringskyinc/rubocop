# frozen_string_literal: true

describe RuboCop::Cop::Lint::Void do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      inspect_source(cop, <<-END.strip_indent)
        a #{op} b
        a #{op} b
        a #{op} b
      END
      expect(cop.offenses.size).to eq(2)
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} if on last line" do
      inspect_source(cop, <<-END.strip_indent)
        something
        a #{op} b
      END
      expect(cop.offenses).to be_empty
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} by itself without a begin block" do
      inspect_source(cop, "a #{op} b")
      expect(cop.offenses).to be_empty
    end
  end

  %w[var @var @@var VAR].each do |var|
    it "registers an offense for void var #{var} if not on last line" do
      inspect_source(cop,
                     ["#{var} = 5",
                      var,
                      'top'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  %w(1 2.0 :test /test/ [1] {}).each do |lit|
    it "registers an offense for void lit #{lit} if not on last line" do
      inspect_source(cop,
                     [lit,
                      'top'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'registers an offense for void `self` if not on last line' do
    expect_offense(<<-RUBY.strip_indent)
      self; top
      ^^^^ `self` used in void context.
    RUBY
  end

  it 'registers an offense for void `defined?` if not on last line' do
    expect_offense(<<-RUBY.strip_indent)
      defined?(x)
      ^^^^^^^^^^^ `defined?(x)` used in void context.
      top
    RUBY
  end

  it 'handles explicit begin blocks' do
    expect_offense(<<-RUBY.strip_indent)
      begin
       1
       ^ Literal `1` used in void context.
       2
      end
    RUBY
  end

  it 'accepts short call syntax' do
    expect_no_offenses(<<-END.strip_indent)
      lambda.(a)
      top
    END
  end

  it 'accepts backtick commands' do
    expect_no_offenses(<<-END.strip_indent)
      `touch x`
      nil
    END
  end

  it 'accepts percent-x commands' do
    expect_no_offenses(<<-END.strip_indent)
      %x(touch x)
      nil
    END
  end
end
