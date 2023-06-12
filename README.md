# ApplicationManager-Yamagata-QADistiller

Automatic Job for QA Review with Yamagata [QADistiller](https://www.qa-distiller.com/en)

## Introduction
Yamagata's QA Distiller is a free stand-alone tool for finding translation errors in bilingual files. The solution has a so-called batch mode function: the QA check can be carried out automatically from the command line without a user interface, provided that all the necessary parameters are also transferred.
The Plunet BusinessManager has an ApplicationManager module with which additional programs can be called up from the command line. This is done via an automatic job in a workflow.
Consequently, it is possible to set up the QA Distiller as an automatic job in Plunet and, depending on the result of the QA check, to let the workflow continue, stop it or trigger different follow-up jobs.

## Technical Requirements
Plunet BusinessManager 7.4+ and additional module ApplicationManager
Yamagata QA-Distiller 9* (https://www.yamagata-europe.com/en-gb/qa-distiller)
*last successfully checked version

## Configuration
#### QADistiller - Installation 
The QA Distiller must be installed on the server. The storage location should normally be %ProgramFiles(x86)%\Yamagata\QADistiller9\
#### QADistiller - Settings / Profiles
The settings or profiles for later processing should be defined for each customer. For this purpose, the QA Distiller normally uses a Userlists folder. You can find more information here:
https://www.qa-distiller.com/help/en-us/concept/co_about_user_lists.html
Attention: At present, only one profile per customer can actually be used by the integration

#### Plunet - Customer Profile
Each customer has his own folder in Plunet BusinessManager. The customer specific profile (QADistiller Userlist folder) should be stored here. The folder must have the same name in every customer profile (e.g. QASettings).

#### Plunet - Storing the Script
The script to start the process must be stored in the Plunet document directory (where the folders Order, Customer, etc. are located). Ideally you name this folder App and put the qadistiller.bat file there.
If you decide to use a different path or file name, this has to be adjusted in the definition of the program call.

Additional necessary configuration is laid out in the [detailed documentation](https://github.com/PlunetBusinessManager/ApplicationManager-Yamagata-QADistiller/blob/main/QADistiller_Integration_en.pdf).

## Usage
### Source Files
To start the QA Distiller job, a bilingual .ttx or .xliff file must have been delivered in the previous job (IN folder). Alternatively, a bilingual file can also be manually stored in the OUT folder of the automatic job, which would then be taken into account (more suitable for testing purposes).

### Project-specific terminology data
If the predecessor job (IN folder) or the OUT folder of the automatic job contains a terminology file in .dict format that is specific to the respective project, the QA Distiller automatically takes this into account.

### Application Workflow
The QADistiller Job will be started automatically, if the previous step is set to delivered (depending on the settings this may vary).
The following work steps are then performed:

- The delivered files of the previous job are copied into the OUT folder of the QADistiller job
- The script is started and the parameters CustomerID and Job Number are passed along
- Tasks of the script:
  - A configuration file relevant for the QADistiller is created for the project (nomenclature: job number.qadbatch) with the following information:
  - Folder where the customer profile for QADistiller is stored
  -	Bilingual files to be checked including storage location
  -	Terminology data to be considered in .dict format including storage location
  -	Output formats to be created and their content
  -	Display of progress (should always be set to 0)
  -	QADistiller is started by transferring the configuration file
  -	Script checks when the QADistiller is finished and has stored all generated files in the IN folder of the QADistiller job
  -	Unneeded files are moved to a subfolder QAResults (so that they are not available in for the resource of the follow-up job
  -	The CSV file of the QA result is analyzed, the total number of errors is written into a result.txt, which can later be used for the conditional workflow
  -	The original bilingual data and terminology data as well as the QA result as HTML file are moved into the IN folder of the QADistiller job (they are automatically available for the resource of the follow-up job)
-	The QA Distiller job is automatically set to delivered, the "relevant" follow-on job is automatically started, if assigned and waiting.




