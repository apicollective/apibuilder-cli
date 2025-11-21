load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Util do

  describe "Util.file_join" do
    it "should eliminate nils" do
      expect(ApibuilderCli::Util.file_join(nil, "foo", "bar")).to eq("foo/bar")
    end

    it "should eliminate empty strings" do
      expect(ApibuilderCli::Util.file_join("", "foo", "bar")).to eq("foo/bar")
      expect(ApibuilderCli::Util.file_join("  ", "foo", "bar")).to eq("foo/bar")
    end
  end

  it "Util.write_to_temp_file" do
    path = ApibuilderCli::Util.write_to_temp_file("foo")
    expect(IO.read(path)).to eq("foo")
  end

  it "Util.write_to_file" do
    path = "/tmp/apibuilder-cli.test.tmp"
    ApibuilderCli::Util.write_to_file(path, "foo")
    expect(IO.read(path)).to eq("foo")
    File.delete(path)
  end

  it "Util.read_non_empty_string" do
    expect(ApibuilderCli::Util.read_non_empty_string("  foo  ")).to eq("foo")
    expect(ApibuilderCli::Util.read_non_empty_string("    ")).to be(nil)
  end

  it "Util.read_non_empty_integer" do
    expect(ApibuilderCli::Util.read_non_empty_integer("  5  ")).to eq(5)
    expect(ApibuilderCli::Util.read_non_empty_integer("    ")).to be(nil)
    expect(ApibuilderCli::Util.read_non_empty_integer("  s  ")).to be(nil)
  end

  it "Util.mask" do
    expect(ApibuilderCli::Util.mask("abcde")).to eq("XXX-XXXX-XXXX")
    expect(ApibuilderCli::Util.mask("abcdefghijabcdefghijabcdefghij")).to eq("abc-XXXX-ghij")
  end

  describe "Util.normalize_generator_attributes" do
    # Define the Attribute class for testing if it's not already loaded
    unless defined?(Io::Apibuilder::Generator::V0::Models::Attribute)
      module Io
        module Apibuilder
          module Generator
            module V0
              module Models
                class Attribute
                  attr_reader :name, :value

                  def initialize(opts = {})
                    @name = opts[:name]
                    @value = opts[:value]
                  end

                  def ==(other)
                    other.is_a?(self.class) &&
                      other.name == name &&
                      other.value == value
                  end
                end
              end
            end
          end
        end
      end
    end

    it "returns empty array for nil input" do
      result = ApibuilderCli::Util.normalize_generator_attributes(nil)
      expect(result).to eq([])
    end

    it "returns empty array for empty hash" do
      result = ApibuilderCli::Util.normalize_generator_attributes({})
      expect(result).to eq([])
    end

    it "returns empty array for empty array" do
      result = ApibuilderCli::Util.normalize_generator_attributes([])
      expect(result).to eq([])
    end

    describe "with legacy hash format" do
      it "converts simple string key-value pairs" do
        input = { "key1" => "value1", "key2" => "value2" }
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(2)
        expect(result[0].name).to eq("key1")
        expect(result[0].value).to eq("value1")
        expect(result[1].name).to eq("key2")
        expect(result[1].value).to eq("value2")
      end

      it "converts non-string values to JSON" do
        input = {
          "string_key" => "string_value",
          "number_key" => 42,
          "boolean_key" => true,
          "array_key" => [1, 2, 3],
          "hash_key" => { "nested" => "value" }
        }
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(5)

        string_attr = result.find { |a| a.name == "string_key" }
        expect(string_attr.value).to eq("string_value")

        number_attr = result.find { |a| a.name == "number_key" }
        expect(number_attr.value).to eq("42")

        boolean_attr = result.find { |a| a.name == "boolean_key" }
        expect(boolean_attr.value).to eq("true")

        array_attr = result.find { |a| a.name == "array_key" }
        expect(array_attr.value).to eq("[1,2,3]")

        hash_attr = result.find { |a| a.name == "hash_key" }
        expect(hash_attr.value).to eq('{"nested":"value"}')
      end
    end

    describe "with array format" do
      it "handles array of hashes with name/value string pairs" do
        input = [
          { "name" => "key1", "value" => "value1" },
          { "name" => "key2", "value" => "value2" }
        ]
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(2)
        expect(result[0].name).to eq("key1")
        expect(result[0].value).to eq("value1")
        expect(result[1].name).to eq("key2")
        expect(result[1].value).to eq("value2")
      end

      it "handles array of hashes with complex value objects" do
        input = [
          { "name" => "filter", "value" => { "operations" => ["GET", "POST"] } },
          { "name" => "config", "value" => { "enabled" => true, "timeout" => 30 } }
        ]
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(2)

        filter_attr = result[0]
        expect(filter_attr.name).to eq("filter")
        expect(filter_attr.value).to eq('{"operations":["GET","POST"]}')

        config_attr = result[1]
        expect(config_attr.name).to eq("config")
        expect(config_attr.value).to eq('{"enabled":true,"timeout":30}')
      end

      it "handles nil values in array format" do
        input = [
          { "name" => "key1", "value" => nil },
          { "name" => "key2", "value" => "" }
        ]
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(2)
        expect(result[0].name).to eq("key1")
        expect(result[0].value).to eq("")
        expect(result[1].name).to eq("key2")
        expect(result[1].value).to eq("")
      end

      it "preserves Attribute objects that are already the correct type" do
        attr1 = Io::Apibuilder::Generator::V0::Models::Attribute.new(:name => "key1", :value => "value1")
        attr2 = Io::Apibuilder::Generator::V0::Models::Attribute.new(:name => "key2", :value => "value2")

        input = [attr1, attr2]
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(2)
        expect(result[0]).to eq(attr1)
        expect(result[1]).to eq(attr2)
      end

      it "handles mixed array with Attribute objects and hashes" do
        attr1 = Io::Apibuilder::Generator::V0::Models::Attribute.new(:name => "key1", :value => "value1")

        input = [
          attr1,
          { "name" => "key2", "value" => "value2" }
        ]
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(2)
        expect(result[0]).to eq(attr1)
        expect(result[1].name).to eq("key2")
        expect(result[1].value).to eq("value2")
      end
    end

    describe "error handling" do
      it "raises error for invalid attribute format in array" do
        input = [{ "invalid" => "format" }]
        expect {
          ApibuilderCli::Util.normalize_generator_attributes(input)
        }.to raise_error(/Invalid attribute format/)
      end

      it "raises error for non-Hash/Array input" do
        expect {
          ApibuilderCli::Util.normalize_generator_attributes("string")
        }.to raise_error(/Invalid attributes format: expected Hash or Array/)
      end

      it "raises error for array with non-hash elements" do
        input = ["string_element"]
        expect {
          ApibuilderCli::Util.normalize_generator_attributes(input)
        }.to raise_error(/Invalid attribute format/)
      end
    end

    describe "real-world scenarios" do
      it "handles complex nested structure from API response" do
        input = [
          {
            "name" => "scala_generator_config",
            "value" => {
              "package" => "com.example.api",
              "models" => {
                "prefix" => "Api",
                "suffix" => "Model"
              },
              "features" => ["json", "validation"]
            }
          }
        ]
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result.size).to eq(1)
        expect(result[0].name).to eq("scala_generator_config")

        parsed_value = JSON.parse(result[0].value)
        expect(parsed_value["package"]).to eq("com.example.api")
        expect(parsed_value["models"]["prefix"]).to eq("Api")
        expect(parsed_value["features"]).to eq(["json", "validation"])
      end

      it "maintains ordering of attributes" do
        input = { "z" => "last", "a" => "first", "m" => "middle" }
        result = ApibuilderCli::Util.normalize_generator_attributes(input)

        expect(result[0].name).to eq("z")
        expect(result[1].name).to eq("a")
        expect(result[2].name).to eq("m")
      end
    end
  end

end
