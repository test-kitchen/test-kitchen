module TestKitchen
  module Project
    class Ruby < Base

      def install_command(runtime=nil)
        cmd = "cd #{guest_test_root}"
        cmd << " && rvm use #{runtime}" if runtime
        cmd << " && #{install}"
      end

      def test_command(runtime=nil)
        cmd = "cd #{guest_test_root}"
        cmd << " && rvm use #{runtime}" if runtime
        cmd << " && #{script}"
      end
    end
  end
end
