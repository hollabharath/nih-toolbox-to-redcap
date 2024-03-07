# nih-toolbox-to-redcap
This Shiny application streamlines the conversion of CSV exports from the NIH Toolbox into a format suitable for REDCap import (with records in columns) for the YANTRA Project.


## Features

- **Uses the NIH Exported NarrowStructure Files**: The application enables processing of `ScoresExportNarrowStructure`, `RegistrationExportNarrowStructure`, and `ItemExportNarrowStructure` CSV files exported from the NIH Toolbox. It merges these files into a format compatible for import into REDCap.

- **Generates REDCap Event Name**: Users are prompted to select a cohort and visit, upon which the application automatically creates a `redcap_event_name`. This feature streamlines the process of organizing data according to YANTRA study design specifics in REDCap.

- **Prepares a Processed CSV File**: Users can then download a REDCap-compatible CSV file, ready for direct import into REDCap. This simplifies the data migration and integration process, ensuring that data is accurately reflected in REDCap.

- **REDCap Data Import Tool Compatibility**: Use the Columns Record Format while importing this CSV file into REDCap. Before importing verify that the study_id matches with the REDCap record.


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Before running this application, you need to have R and Shiny installed on your system. You can install R from [The Comprehensive R Archive Network (CRAN)](https://cran.r-project.org/).
Additionally, ensure the `Shiny`, `dplyr` and `stringr` packages are installed using the following command in R:

```R
install.packages(c("dplyr", "stringr", "shiny"))
```


### Running the Application

To run the app locally:

1. Clone this repository or download the source code to your local machine.
2. Open R or RStudio, and set your working directory to the folder containing the app files (`setwd("path/to/app")`).
3. Run the app with the command on terminal:

```bash
Rscript -e "shiny::runApp('app.R', launch.browser = TRUE)"
```

The application should now be running on your local machine, and it will automatically open in your web browser.

## Running the Application on Windows

### Prepare a Batch File:

Create a new text document using Notepad or another text editor.

Copy and paste the following script into the document:

```
@echo off
REM Change the directory to where your app.R script is located
cd C:\path\to\your\shiny\app

REM Run the app using Rscript
Rscript -e "shiny::runApp('app.R', launch.browser = TRUE)"

REM Pause the batch file to see any messages after closing the app
pause
```

Replace C:\path\to\your\shiny\app with the actual path to the folder containing your Shiny app (app.R).

Save the file with the name `nihtb2redcap.bat`. Make sure to select "All Files" in the "Save as type" dropdown menu in Notepad to avoid saving it as a text file.

### Run the Batch File:

Double-click on `nihtb2redcap.bat` to launch the Shiny app. The application should automatically open in your default web browser.
If you encounter any issues, ensure that Rscript is accessible from the command line and that the path to your app directory is correct in the batch file.

## Usage

1. **Select CSV Files**: Use the file input widgets to select your `ScoresExportNarrowStructure`, `RegistrationExportNarrowStructure`, and `ItemExportNarrowStructure` CSV files.
2. **Choose Cohort and Visit**: Select the appropriate cohort and visit for your data processing needs.
3. **Download Processed CSV**: Click the "Download Processed CSV" button to generate and download your REDCap-compatible CSV file.


## License

This project is licensed under the MIT License 
