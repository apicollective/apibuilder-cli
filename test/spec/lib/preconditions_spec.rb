load File.join(File.dirname(__FILE__), '../../init.rb')

RSpec.describe ApidocCli::Preconditions do

  it "ApidocCli::Preconditions.check_argument" do
    ApidocCli::Preconditions.check_argument(true, "Noop")
    expect {
      ApidocCli::Preconditions.check_argument(false, "Should be this")
    }.to raise_error(RuntimeError)
  end

  it "ApidocCli::Preconditions.check_state" do
    ApidocCli::Preconditions.check_argument(1 > 0, "Noop")
    expect {
      ApidocCli::Preconditions.check_argument(1 < 0, "Should be this")
    }.to raise_error(RuntimeError)
  end

  it "ApidocCli::Preconditions.check_not_null" do
    ApidocCli::Preconditions.check_argument("", "Noop")
    expect {
      ApidocCli::Preconditions.check_argument(nil, "Should be this")
    }.to raise_error(RuntimeError)
  end

  it "ApidocCli::Preconditions.check_not_blank" do
    expect {
      ApidocCli::Preconditions.check_not_blank(nil, "Should be this")
    }.to raise_error(RuntimeError)

    expect {
      ApidocCli::Preconditions.check_not_blank("")
    }.to raise_error(RuntimeError)
  end

  it "ApidocCli::Preconditions.assert_empty_opts" do
    ApidocCli::Preconditions.assert_empty_opts({})
    expect {
      ApidocCli::Preconditions.assert_empty_opts({ "a" => "b" })
    }.to raise_error(RuntimeError)
  end

  it "ApidocCli::Preconditions.assert_class" do
    ApidocCli::Preconditions.assert_class("string", String)
    ApidocCli::Preconditions.assert_class(1, Integer)
    expect {
      ApidocCli::Preconditions.assert_class(1, String)
    }.to raise_error(RuntimeError)
  end

  it "ApidocCli::Preconditions.assert_class_or_nil" do
    ApidocCli::Preconditions.assert_class_or_nil("string", String)
    ApidocCli::Preconditions.assert_class_or_nil(nil, String)
    ApidocCli::Preconditions.assert_class_or_nil(1, Integer)
    expect {
      ApidocCli::Preconditions.assert_class_or_nil(1, String)
    }.to raise_error(RuntimeError)
  end

end
