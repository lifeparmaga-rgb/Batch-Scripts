@echo off
set SqlExpress_Default_ConnectionString="Server=.\\SQLEXPRESS;Database= ;Trusted_Connection=True;TrustServerCertificate=True"

echo %SqlExpress_Default_ConnectionString% | clip 
