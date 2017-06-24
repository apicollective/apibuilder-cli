load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Preconditions do

  it "ApibuilderCli::Preconditions.check_argument" do
    ApibuilderCli::Preconditions.check_argument(true, "Noop")
    expect {
      ApibuilderCli::Preconditions.check_argument(false, "Should be this")
    }.to raise_error(RuntimeError)
  end

  it "ApibuilderCli::Preconditions.check_state" do
    ApibuilderCli::Preconditions.check_argument(1 > 0, "Noop")
    expect {
      ApibuilderCli::Preconditions.check_argument(1 < 0, "Should be this")
    }.to raise_error(RuntimeError)
  end

  it "ApibuilderCli::Preconditions.check_not_null" do
    ApibuilderCli::Preconditions.check_argument("", "Noop")
    expect {
      ApibuilderCli::Preconditions.check_argument(nil, "Should be this")
    }.to raise_error(RuntimeError)
  end

  it "ApibuilderCli::Preconditions.check_not_blank" do
    expect {
      ApibuilderCli::Preconditions.check_not_blank(nil, "Should be this")
    }.to raise_error(RuntimeError)

    expect {
      ApibuilderCli::Preconditions.check_not_blank("")
    }.to raise_error(RuntimeError)
  end

  it "ApibuilderCli::Preconditions.assert_empty_opts" do
    ApibuilderCli::Preconditions.assert_empty_opts({})
    expect {
      ApibuilderCli::Preconditions.assert_empty_opts({ "a" => "b" })
    }.to raise_error(RuntimeError)
  end

  it "ApibuilderCli::Preconditions.assert_class" do
    ApibuilderCli::Preconditions.assert_class("string", String)
    ApibuilderCli::Preconditions.assert_class(1, Integer)
    expect {
      ApibuilderCli::Preconditions.assert_class(1, String)
    }.to raise_error(RuntimeError)
  end

  it "ApibuilderCli::Preconditions.assert_class_or_nil" do
    ApibuilderCli::Preconditions.assert_class_or_nil("string", String)
    ApibuilderCli::Preconditions.assert_class_or_nil(nil, String)
    ApibuilderCli::Preconditions.assert_class_or_nil(1, Integer)
    expect {
      ApibuilderCli::Preconditions.assert_class_or_nil(1, String)
    }.to raise_error(RuntimeError)
  end

end
