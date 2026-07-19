
:: set /p searchWord = "Enter Word To Search On Youtube"
:: start https://www.youtube.com/watch?v=%searchWord%

@echo off
set /p search="Enter your YouTube search query: "
set searchQuery=%search:"=+%
start https://www.youtube.com/results?search_query=%searchQuery%

