"highlight words that start with uppercase as 'types'
syntax match UserType /\<[A-Z][A-Za-z0-9_]*/
highlight link UserType Include

syntax match UserConstant /\<[A-Z_]*\>/
highlight link  UserConstant String

syntax match CatchMacro /SCENARIO\|GIVEN\|WHEN\|THEN\|REQUIRE\|CHECK\|SECTION\|TEST_CASE/
highlight link CatchMacro identifier
