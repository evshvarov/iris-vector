#!/usr/bin/env iriscli

 zpm "load /home/irisowner/app -v": 1
 
 zpm "install vscode-per-namespace-settings": 1
 
 set namespace = $system.Process.NameSpace()
 set installDir = $system.Util.InstallDirectory()
 set ^UnitTestRoot = installDir _ ".vscode/" _ namespace _ "/UnitTestRoot"
 