# CSD-File-Upload
PowerShell script that will upload a document to the CSD report folder


1. Edit the $IONAPIFILE variable to point to the location of your tenants .ionapi file.
2. Edit the $INPUTFILE variable to point to the location of the file you wish to upload.
3. Edit the $RESULTFILE variable to provide a name for the file once uploaded to your tenants report folder.
4. Edit the $CONO variable to use a valid CSD Cono
5. Edit the $OPER variable to use a valid operator 
6. Edit the $SUBDIR variable to send your document to the appropriate location in the report folder. 
7. Run the script either via Windows scheduled task or command line like so: powershell.exe ./fileTransfer.ps1
