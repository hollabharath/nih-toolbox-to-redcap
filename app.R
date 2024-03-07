# NIH Toolbox CSV to REDCap Import Conversion
# Converts CSV exports from the NIH Toolbox into a format suitable for REDCap import.
# Author: Dr. Bharath Holla
# Version: 1.0
# Last Updated: 2024-03-08

library(shiny)
library(dplyr)
library(stringr)
# Define cohort and visit data
cohort_df <- data.frame(
  arm_num = 0:6,
  name = c("","S", "D", "A", "MS", "HC", "FDR"),
  stringsAsFactors = FALSE
)

visit_df <- data.frame(
  event_name = c("","Baseline", "First Follow Up (1m)", "Second Follow Up (3m)", "Third Follow Up (6m)"),
  stringsAsFactors = FALSE
)


# Define event mapping
event_df <- data.frame(
  event_name = c("Baseline", "First Follow Up (1m)", "Second Follow Up (3m)", "Third Follow Up (6m)",
                 "Baseline", "First Follow Up (1m)", "Second Follow Up (3m)", "Third Follow Up (6m)",
                 "Baseline", "First Follow Up (1m)", "Second Follow Up (3m)", "Third Follow Up (6m)",
                 "Baseline", "First Follow Up (1m)", "Second Follow Up (3m)", "Third Follow Up (6m)",
                 "Baseline", "Baseline"),
  arm_num = c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 6),
  unique_event_name = c("baseline_arm_1", "first_follow_up_1m_arm_1", "second_follow_up_3_arm_1", "third_follow_up_6m_arm_1",
                        "baseline_arm_2", "first_follow_up_1m_arm_2", "second_follow_up_3_arm_2", "third_follow_up_6m_arm_2",
                        "baseline_arm_3", "first_follow_up_1m_arm_3", "second_follow_up_3_arm_3", "third_follow_up_6m_arm_3",
                        "baseline_arm_4", "first_follow_up_1m_arm_4", "second_follow_up_3_arm_4", "third_follow_up_6m_arm_4",
                        "baseline_arm_5", "baseline_arm_6"),
  stringsAsFactors = FALSE
)
# Shiny UI
ui <- fluidPage(
  titlePanel("NIH Toolbox CSV export to REDCap Import Conversion"),
  sidebarLayout(
    sidebarPanel(
      # Adding instructions for the user
      h4("Instructions:"),
      p("Please select a CSV file that includes 'NarrowStructure' in its name."),
      fileInput("file1", "Choose CSV File - ScoresExportNarrowStructure",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      fileInput("file2", "Choose CSV File -  RegistrationExportNarrowStructure",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      fileInput("file3", "Choose CSV File -  ItemExportNarrowStructure",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      selectInput("cohort", "Select Cohort", choices = cohort_df$name),
      uiOutput("visit_ui"),
      downloadButton("downloadData", "Download Processed CSV")
    ),
    mainPanel(
      textOutput("fileUploadStatus"),
      textOutput("status")
    )
  ),
  div(class = "footer", 
      style = "position: fixed; left: 0; bottom: 0; width: 100%; background-color: #f5f5f5; text-align: center; padding: 10px;",
      HTML("YANTRA | App Version: 1.0 | Author: Dr. Bharath Holla"))
)


# Shiny Server

server <- function(input, output, session) {
  
  # Reactive value to store the data
  study_id <- reactiveVal()
  study_id_row <- reactiveVal(data.frame())
  scores_data <- reactiveVal(data.frame())
  reg_data <- reactiveVal(data.frame())
  item_data <- reactiveVal(data.frame())
  event_name_row <- reactiveVal(data.frame())
  
  # Validate and process the ScoresExportNarrowStructure CSV file upon upload
  observeEvent(input$file1, {
    if (!grepl("ScoresExportNarrowStructure_.*\\.csv$", input$file1$name)) {
      showNotification("Please upload a 'ScoresExportNarrowStructure' CSV file.", type = "error")
    } else {
      data <- read.csv(input$file1$datapath, stringsAsFactors = FALSE)
      unique_pid <- unique(data$PID)[1]  # Taking the first unique PID
      study_id(unique_pid)  # Update the reactive value
      
      # Prepare `study_id_row`
      study_id_row(data.frame(
        `Variable / Field Name` = "study_id",
        Record = unique_pid,
        stringsAsFactors = FALSE,
        check.names = FALSE
      ))
      
      # Define the function to extract capitals 
      extractCapitals <- function(title) {
        tolower(str_extract_all(title, "[A-Z]") %>% unlist() %>% paste(collapse = ""))
      }
      
      # Apply transformations directly on 'data'
      scores_data(data.frame(
        `Variable / Field Name` = paste0(ifelse(nchar(data$TestName) > 0, 
                                                tolower(data$TestName), 
                                                paste0(sapply(data$InstrumentTitle, extractCapitals), "_3")), "_", sapply(data$Key, extractCapitals)),
        Record = data$Value,
        stringsAsFactors = FALSE,
        check.names = FALSE
      ))
    }
  })
  
  # Validate and process the RegistrationExportNarrowStructure CSV file upon upload
  observeEvent(input$file2, {
    if (!grepl("RegistrationExportNarrowStructure_.*\\.csv$", input$file2$name)) {
      showNotification("Please upload a 'RegistrationExportNarrowStructure' CSV file.", type = "error")
    } else {
      reg <- read.csv(input$file2$datapath, stringsAsFactors = FALSE)
      
      # Check if the unique_pid from file1 matches PIDs in file2
      if (!all(reg$PID %in% study_id())) {
        showNotification("The PIDs in the registration file do not match the unique PID from the Scores file.", type = "error")
      } else {
        # If the PIDs match, proceed with transformations for reg_data
        transformed_reg_data <- reg %>%
          mutate(`Variable / Field Name` = case_when(
            tolower(Key) == "age" ~ "age_nihtb",
            tolower(Key) == "name" ~ "name_nihtb",
            TRUE ~ tolower(Key)
          ),
          Record = Value) %>%
          select(`Variable / Field Name`, Record)
        
        # Update reg_data (assuming reg_data is a reactive variable)
        reg_data(transformed_reg_data)
      }
    }
  })
  
  # Validate and process the ItemExportNarrowStructure CSV file upon upload
  observeEvent(input$file3, {
    if (!grepl("ItemExportNarrowStructure_.*\\.csv$", input$file3$name)) {
      showNotification("Please upload a 'ItemExportNarrowStructure' CSV file.", type = "error")
    } else {
      item <- read.csv(input$file3$datapath, stringsAsFactors = FALSE)
      item <- item %>%
        filter(
          (str_detect(ItemID, regex("DCCS_MIXED_TRIAL([0-9]|1[0-9]|2[0-9]|30)", ignore_case = TRUE)) & Key %in% c("Score", "ResponseTime")) |
            (str_detect(ItemID, regex("FLANKER_FISH_TRIAL([0-9]|1[0-9]|2[0-9]|30)", ignore_case = TRUE)) & Key %in% c("Score", "ResponseTime")) |
            (str_detect(ItemID, regex("LSWM_\\d?List_Live_Item_[A-X]", ignore_case = TRUE)) & Key == "Score") |
            (str_detect(ItemID, regex("^OSD\\d{3}$", ignore_case = TRUE)) & Key == "Score")|
            (str_detect(ItemID, regex("15_T\\d?_Total_Adjacent", ignore_case = TRUE)) & Key == "Score")|
            (str_detect(ItemID, regex("RAVLTT\\d?_Items_B", ignore_case = TRUE)) & Key == "Score") |
            (str_detect(ItemID, regex("^RAVLTT1_[A-Za-z]+_Delay$", ignore_case = TRUE)) & Key == "Score") |
            (str_detect(ItemID, regex("PC_Live_Item_Trial_([1-133])", ignore_case = TRUE)) & Key %in% c("Score", "ResponseTime")) 
        )
      extractCapitals <- function(title) {
        tolower(str_extract_all(title, "[A-Z]") %>% unlist() %>% paste(collapse = ""))
      }
      # Check if the unique_pid from file1 matches PIDs in file3
      if (!all(item$PID %in% study_id())) {
        showNotification("The PIDs in the ItemExportNarrowStructure file do not match the unique PID from the Scores file.", type = "error")
      } else {
        # If the PIDs match, proceed with transformations for reg_data
        item_data(data.frame(
          `Variable / Field Name` = paste0(str_remove(tolower(item$ItemID), "live_item_"),"_", sapply(item$Key, extractCapitals)),
          Record = item$Value,
          stringsAsFactors = FALSE,
          check.names = FALSE
        ))
      }
    }
  })
  
  # Dynamically update available visits based on selected cohort
  output$visit_ui <- renderUI({
    if (input$cohort %in% c("HC", "FDR")) {
      selectInput("visit", "Visit", choices = "Baseline")
    } else {
      selectInput("visit", "Visit", choices = visit_df$event_name)
    }
  })
  
  # Display the study_id as a message after file upload
  output$fileUploadStatus <- renderText({
    if (!is.null(study_id())) {
      paste("Study ID: ", study_id())
    } else {
      "No study ID found."
    }
  })
  
  # Process selection of cohort and visit to determine redcap_event_name
  observe({
    selected_arm_num <- cohort_df$arm_num[cohort_df$name == input$cohort]
    selected_event_name <- input$visit
    matched_event <- event_df$unique_event_name[event_df$arm_num == selected_arm_num & event_df$event_name == selected_event_name]
    redcap_event_name <- matched_event[1]  
    event_name_row(data.frame(
        `Variable / Field Name` = "redcap_event_name",
        Record = redcap_event_name,
        stringsAsFactors = FALSE,
        check.names = FALSE
      ))
 
  })
  
  # Prepare and download final_data
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(study_id(), "_upload_Column_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      req(study_id_row(), event_name_row())
      if(nrow(reg_data()) == 0) {
        showNotification("Registration data is empty.", type = "error")
        return()  # Stop execution if reg_data is empty
      }
      if(nrow(scores_data()) == 0) {
        showNotification("Scores data is empty.", type = "error")
        return()  # Stop execution if reg_data is empty
      }

      final_data <- rbind(study_id_row(), event_name_row(), reg_data(), scores_data(), item_data())
      
      # Export final_data to the specified file
      write.csv(final_data, file, row.names = FALSE)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
