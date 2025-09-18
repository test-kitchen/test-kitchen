dir = os.windows? ? "c:\\tk_test_directory" : "/tmp/tk_test_directory"

describe directory(dir) do
  it { should exist }
end
