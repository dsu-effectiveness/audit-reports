# Libraries ####

library(pins)
library(keyring)

# Pulling from Pins ####

# Obtain the API key from environment variable.
api_key <- Sys.getenv("RSCONNECT_SERVICE_USER_API_KEY")
# Local development: If API key is not available as environment variable,
# get API key from keyring entry. 
# To set API key run the following: 
# keyring::key_set("pins", "api_key")
# Then enter API key as prompted
if ( api_key == "" ) {
  api_key <- keyring::key_get("pins", "api_key")
}
# Register the connection to the pinning board.
board_register_rsconnect(key=api_key, server="https://data.dixie.edu")

# pull data from pins (pin names set from original pins)
student_sql <- pin_get("audit_reports_students_pin", board="rsconnect")
student_courses_sql <- pin_get("audit_reports_student_courses_pin", board="rsconnect")
courses_sql <- pin_get("audit_reports_courses_pin", board="rsconnect")
spbpers_sql <- pin_get("audit_reports_spbpers_pin", board="rsconnect")
sorhsch_sql <- pin_get("audit_reports_sorhsch_pin", board="rsconnect")

