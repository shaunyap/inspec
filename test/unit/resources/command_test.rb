require "helper"
require "inspec/resource"
require "inspec/resources/command"
require "inspec/resources/os"

describe Inspec::Resources::Cmd do
  let(:x) { rand.to_s }
  def resource(command, options = {} )
    load_resource("command", command, options)
  end

  it "prints as a bash command" do
    resource(x).to_s.must_equal "Command: `#{x}`"
  end

  it "runs a valid mocked command" do
    resource("env").result.wont_be_nil
    resource("env").stdout.must_equal "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\n"
    resource("env").stderr.must_equal ""
    resource("env").exit_status.must_equal 0
  end

  it "exist? returns false on nil os name" do
    Inspec::Resources::OSResource.any_instance.stubs(:name).returns(nil)
    resource("test").exist?.must_equal false
  end

  it "exist? returns false on mock os name" do
    Inspec::Resources::OSResource.any_instance.stubs(:name).returns("mock")
    resource("test").exist?.must_equal false
  end

  it "raises when called with nil as a command" do
    proc { resource(nil).result }.must_raise StandardError
  end

  it "fails the resource if `redact_regex` is not a regular expression" do
    result = resource("env", redact_regex: "string")
    result.resource_failed?.must_equal true
    result.resource_exception_message.must_match(/must be a regular expression/)
  end

  it "redacts output if `redact_regex` is passed with caputure groups" do
    cmd = "command_with_password -p supersecret -d no_redact"
    expected_to_s = "Command: `command_with_password -p REDACTED -d no_redact`"
    resource(cmd, redact_regex: /(-p ).*( -d)/).to_s.must_equal(expected_to_s)
  end

  it "redacts output if `redact_regex` is passed without a caputure group" do
    cmd = "command_with_password -p supersecret -d no_redact"
    expected_to_s = "Command: `command_with_password REDACTED no_redact`"
    resource(cmd, redact_regex: /-p .* -d/).to_s.must_equal(expected_to_s)
  end
end
