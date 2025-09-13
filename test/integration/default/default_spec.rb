dir = os.windows? ? "c:\\tk_test_directory" : "/tk_test_directory"

describe directory(dir) do
  it { should exist }
end
