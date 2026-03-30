@echo off
explorer C:\Users\%username%\.ssh
type C:\Users\%username%\.ssh\id_rsa.pub | clip

::--------------------------------------------
:: Error
:: type C:\Users\%username%\.ssh\id_rsa.pub > clip
