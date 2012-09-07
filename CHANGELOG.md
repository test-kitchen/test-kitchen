Release Notes - test-kitchen Version ???

    ** Bug
        * [KITCHEN-4] - decouple rvm use for running integration/unit tests

Release Notes - test-kitchen - Version 0.5.4

** Bug
    * [KITCHEN-6] - document requirement that a valid "knife.rb" is present
    * [KITCHEN-18] - scaffold generates Gemfile with private github repository for test-kitchen gem
    * [KITCHEN-26] - Subsequent calls to `kitchen test` don't converge node anymore

** Improvement
    * [KITCHEN-8] - Document Autmatic Dependency Resolution via Librarian in the README
    * [KITCHEN-10] - Add Memory Option to Cookbook Section of the Readme
    * [KITCHEN-19] - Constrain foodcritic to major (1.x)

** New Feature
    * [KITCHEN-17] - Add lint[:ignore] to cookbook DSL for foodcritic tags or rules to ignore

Release Notes - test-kitchen version 0.5.2

** Bug
    * [KITCHEN-1] - remove "remove test-kitchen entry from Gemfile" from recipe
    * [KITCHEN-2] - update foodcritic version

Release Notes - test-kitchen version 0.5.0

** Initial Release
