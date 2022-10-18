USAGE:

You'll need RStudio to make this work! You can get it off the internet or an older version is available for you on Anaconda.

1) Download this repo and unzip to the desired location.
3) Open up Main.r (notepad or your IDE) and change the following:

      setwd("U:\\SCRIPT_DIRECTORY")
      filepath <- "U:\\XLSX_DIRECTORY"
      
Change the setwd string to where this script is located. Make sure you use two backslashes. For example, C:\\Users\\You\\ThisScript.
Do the same for the filepath which is a folder containing the Excel files exported by QuantStudio. You'll need to generate these yourself.

Run Main.r in RStudio. It should populate the folder with jpegs. You can use these or you can select them all and, on windows, Print > Print to PDF
to combine them into one .pdf.

This script was designed to get around the Virtual Machine limitations and export some easy to use curves and Ct values. It should be easy to expand for analysis, though.



