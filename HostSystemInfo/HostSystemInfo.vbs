'************************************************************************************************************************************************
' KellTec Domain Audit Tool - Written by Dave Kelly
'************************************************************************************************************************************************
' This script is well used amended and tested, but I take no responsibility for any mishaps, crashes, sackings or unusual weather patterns which
' may have been caused by the use of this script. This script is a cut down version of a large process script I wrote for a client and as such,
' may contain some lines of code that are not applicable to a simple audit application.
'************************************************************************************************************************************************
'Hope you enjoy !!!
'************************************************************************************************************************************************

Dim objADFile, objFSO, objNodesInAD, objAliveNodeFile, objDeadNodeFile, strComputer, strDialogMessage, MessageDelay, objExplorer, txtOutput, fs, CSVFile, HardwareFile, objReg, objRegFile, objLogFile, ProgressLine, ProgressCounter
Dim strCompFile, TheActualDateTime, strNetworkAdapterGUID, ToolVersion, LastMessage, strHTime, strMTime, strDDate, strMDate, objSharesFile, strShareName, strSharePath
Dim strNetworkDHCPEnabled,strNetworkDHCPServer,strNetworkDNSDomain,strNetworkFullDNSRegistration, strNetworkIPAddress,strNetworkSubnet,strNetworkDefaultGateway,strNetworkDNS1,strNetworkDNS2,strNetworkDNS3,strNetworkDNS4, objSysServFile
Dim NetworkFile, cmdLineFile, strCurrentRunPath, TeamDetails, strAdminPWStatus, strLineInfo, strCurrTZ, strDaylightSave, strFreeRAM, strPFBaseSizeMB, strPFCurrentUsageMB, strPFPeakUsageMB, strPFLocation, InfoFile, objAlertsFile
Dim strOSVersion , strOSSPMAJVersion, strDriveTotSize, strDriveFreeSpace, strHalfTotSize, strSpaceRemaining, strProcUsage, strLowRAMWarn, SPUpgradeFile, SPDetails, SPUpgradeBatch
Dim strPFPeakUsageKB, strPFPeakUsageBY, strPFCurrentUsageKB, strPFCurrentUsageBY, strPFBaseSizeKB, strPFBaseSizeBY, numMemCap2, strRAM2
Dim strRAMConfig, strRAMConfigTemp, strMemTemp, objGPOFile, objRootDSE, strDNSDomain, adoCommand, adoConnection, objServicesFile, GPOLine, GPOName, POGUID, GPOID, GPOAccessDenied, GPOEnabled, GPOFileSystemPath, GPOFilterAllowed, GPOFilterID, GPOVersion, i, strToolOptions, strServices
Dim strQuery, count, countfrom, SVCLine, SVCCaption, SVCName, SVCState, SVCStartMode, SVCStartName, SVCPathName, strItem 
ReDim arrDupName(0)

'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************

Set wshShell = WScript.CreateObject( "WScript.Shell" )
strComputerName = wshShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )
strCurrentRunPath = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")
strCurrentRunPath = strCurrentRunPath & "\\"
ToolVersion = "v1.3.1.2"
MessageDelay = 2
singleton = strComputerName
DoDateFormat
If singleton = "Full" Then
	stage001
	stage002
	Stage003
	'Stage004
	Stage101
ElseIf Left (singleton,5) = "Range" Then
	On Error Resume Next
	Set objFso = CreateObject("Scripting.FileSystemObject")
	objFSO.CreateFolder("./Reports")
	objFSO.CreateFolder("./Reports/General Info")
	objFSO.CreateFolder("./System Files")
	Set objNodesInAD = objFSO.CreateTextFile(".\\System Files\\Nodes-In-AD.csv",1)
	singleton = Replace (singleton,"Range ","")
	For x = 1 To 254
		strx = String(x)
		objNodesInAD.WriteLine(singleton & "." & x)
	Next
	objNodesInAD.Close
	Stage003
	'Stage004
	Stage101
ElseIf Left (singleton,4) = "Part" Then
	On Error Resume Next
	Set objFso = CreateObject("Scripting.FileSystemObject")
	objFSO.CreateFolder("./Reports")
	objFSO.CreateFolder("./Reports/General Info")
	objFSO.CreateFolder("./System Files")
	Set objNodesInAD = objFSO.CreateTextFile(".\\System Files\\Nodes-In-AD.csv",1)
	singleton = Replace (singleton,"Part ","")
	If InStr(Left(singleton,3)," ") = False Then
		count = Left(singleton,3)
	ElseIf InStr(Left(singleton,2)," ") = False Then
		count = Left(singleton,2)
	ElseIf InStr(Left(singleton,2)," ") = False Then
		count = Left(singleton,2)
	End If
	WScript.Echo(count)
	singleton = Replace (singleton,count,"",1,1)
	singleton = Trim(singleton)
	WScript.Echo(singleton)
	If InStr(Right(singleton,3),".") = False Then
		countfrom = Right(singleton,3)
	ElseIf InStr(Right(singleton,2),".") = False Then
		countfrom = Right(singleton,2)
	ElseIf InStr(Right(singleton,1),".") = False Then
		countfrom = Right(singleton,1)
	End If
	singleton = Trim(singleton)
	WScript.Echo("The full starting IP address: " & singleton)
	singleton = StrReverse(singleton)
	WScript.Echo("The full starting IP address: " & singleton)
	countfrom = StrReverse(countfrom)
	singleton = Replace(singleton,countfrom,"",1,1)
	countfrom = StrReverse(countfrom)
	singleton = Replace(singleton,".","",1,1)
	singleton = StrReverse(singleton)
	count = CInt(countfrom) ++ CInt(count)
	If CInt(count) > 254 Then
	count = 255
	MsgBox("IP range exceeds .254 and has been trimmed")
	End If
	count = count -- 1
	For x = countfrom To count
		objNodesInAD.WriteLine(singleton & "." & x)
	Next
	objNodesInAD.Close
	Stage003
	Stage101
ElseIf singleton = "CANCEL" Or singleton = "" Then
	Finished
Else
	On Error Resume Next
	strComputer = singleton
	Set objFso = CreateObject("Scripting.FileSystemObject")
	objFSO.CreateFolder("./Reports")
	objFSO.CreateFolder("./Reports/General Info")
	objFSO.CreateFolder("./System Files")
	Set objNodesInAD = objFSO.CreateTextFile(".\\System Files\\Nodes-In-AD.csv",1)
	objNodesInAD.WriteLine(strComputer)
	objNodesInAD.Close
	Stage003
	Stage101	
End If
Finished

'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************

Sub DoDateFormat
	strHTime=Hour(Time())
	strMTime=Minute(Time())
	strDDate=Day(Date())
	strMDate=Month(Date())
	If strHTime < 10 Then
		strHTime = "0"&strHTime
	End If
	If strMTime < 10 Then
		strMTime = "0"&strMTime
	End If
	If strDDate < 10 Then
		strDDate = "0"&strDDate
	End If
	If strMDate < 10 Then
		strMDate = "0"&strMDate
	End If
	TheActualDateTime = ((strDDate)& (strMDate)& Year(Date())& "-" & (strHTime)&(strMTime))
	'Call DialogMessage("Audit started at "&Now())
	'Call DialogMessage("Tool Version = "&ToolVersion)
End Sub



'************************************************************************************************************************************************
'************************************************************************************************************************************************


Sub stage001
	'Call DialogMessage("Starting AD Info")
	On Error Resume Next
	Set objFso = CreateObject("Scripting.FileSystemObject")
	objFSO.CreateFolder("./Reports")
	objFSO.CreateFolder("./Reports/General Info")
	objFSO.CreateFolder("./System Files")
	Set objADFile = objFSO.CreateTextFile("./Reports/General Info/AD Information.txt")
	Set objSitesFile = objFSO.CreateTextFile("./System Files/Sites.txt",2)
	On Error Resume Next
	Set objRootDSE = GetObject("LDAP://RootDSE")
	If Err.Number = 0 Then
		On Error Goto 0
		strConfig = objRootDSE.Get("configurationNamingContext")
		'Determine AD Name
		Set WSHNetwork = CreateObject("WScript.Network")
		strDomain = WSHNetwork.UserDomain
		Set WSHNetwork = Nothing
		objADFile.WriteLine "Domain Name: " & strDomain
		objADFile.WriteLine
		objADFile.WriteLine
		'Determine AD Sites
		strSitesContainer = "LDAP://cn=Sites," & strConfig
		Set objSitesContainer = GetObject(strSitesContainer)
		objSitesContainer.Filter = Array("site")
		objADFile.WriteLine "AD Sites:"
		For Each objSite In objSitesContainer
			objADFile.WriteLine "  Site Name: " & removeCN(objSite.Name)
			objSitesFile.WriteLine removeCN(objSite.Name)
		Next
		objADFile.WriteLine
		objADFile.WriteLine
		'Find Domain Controllers
		Set objCommand = CreateObject("ADODB.Command")
		Set objConnection = CreateObject("ADODB.Connection")
		objConnection.Provider = "ADsDSOObject"
		objConnection.Open "Active Directory Provider"
		objCommand.ActiveConnection = objConnection
		strQuery = "<LDAP://" & strConfig & ">;(ObjectClass=nTDSDSA);AdsPath;subtree"
		objCommand.CommandText = strQuery
		objCommand.Properties("Page Size") = 100
		objCommand.Properties("Timeout") = 30
		objCommand.Properties("Cache Results") = False
		Set objRecordSet = objCommand.Execute
		objADFile.WriteLine "Domain Controllers:"
		i = 0
		ReDim arrDC(0)
		Do Until objRecordSet.EOF
			i = i + 1
			ReDim Preserve arrDC(i)
			Set objDC = GetObject(GetObject(objRecordSet.Fields("AdsPath")).Parent)
			Set objSite = GetObject(GetObject(objDC.Parent).Parent)
			arrDC(i) = objDC.cn
			objADFile.WriteLine "    DC: " & removeCN(objDC.cn)
			objADFile.WriteLine "  Site: " & removeCN(objSite.Name)
			objADFile.WriteLine
			objRecordSet.MoveNext
		Loop
		objADFile.WriteLine
		objADFile.WriteLine
		' Clean up.
		objConnection.Close
		Set objCommand = Nothing
		Set objConnection = Nothing
		Set objRecordSet = Nothing
		Set objDC = Nothing
		Set objSite = Nothing
		objADFile.WriteLine "FSMO Role Holders:"
		'Schema Master
		Set objSchema = GetObject("LDAP://" & objRootDSE.Get("schemaNamingContext"))
		strSchemaMaster = objSchema.Get("fSMORoleOwner")
		Set objNtds = GetObject("LDAP://" & strSchemaMaster)
		Set objComputer = GetObject(objNtds.Parent)
		objADFile.WriteLine "  Forest-wide Schema Master FSMO:        " & removeCN(objComputer.Name)
		Set objNtds = Nothing
		Set objComputer = Nothing
		'Domain Naming Master
		Set objPartitions = GetObject("LDAP://CN=Partitions," & objRootDSE.Get("configurationNamingContext"))
		strDomainNamingMaster = objPartitions.Get("fSMORoleOwner")
		Set objNtds = GetObject("LDAP://" & strDomainNamingMaster)
		Set objComputer = GetObject(objNtds.Parent)
		objADFile.WriteLine "  Forest-wide Domain Naming Master FSMO: " & removeCN(objComputer.Name)
		Set objNtds = Nothing
		Set objComputer = Nothing
		'PDC Emulator
		Set objDomain = GetObject("LDAP://" & objRootDSE.Get("defaultNamingContext"))
		strPdcEmulator = objDomain.Get("fSMORoleOwner")
		Set objNtds = GetObject("LDAP://" & strPdcEmulator)
		Set objComputer = GetObject(objNtds.Parent)
		objADFile.WriteLine "  Domain's PDC Emulator FSMO:            " & removeCN(objComputer.Name)
		Set objNtds = Nothing
		Set objComputer = Nothing
		'RID Master
		Set objRidManager = GetObject("LDAP://CN=RID Manager$,CN=System," & objRootDSE.Get("defaultNamingContext"))
		strRidMaster = objRidManager.Get("fSMORoleOwner")
		Set objNtds = GetObject("LDAP://" & strRidMaster)
		Set objComputer = GetObject(objNtds.Parent)
		objADFile.WriteLine "  Domain's RID Master FSMO:              " & removeCN(objComputer.Name)
		Set objNtds = Nothing
		Set objComputer = Nothing
		'Infrastructure Master
		Set objInfrastructure = GetObject("LDAP://CN=Infrastructure," & objRootDSE.Get("defaultNamingContext"))
		strInfrastructureMaster = objInfrastructure.Get("fSMORoleOwner")
		Set objNtds = GetObject("LDAP://" & strInfrastructureMaster)
		Set objComputer = GetObject(objNtds.Parent)
		objADFile.WriteLine "  Domain's Infrastructure Master FSMO:   " & removeCN(objComputer.Name)
		Set objNtds = Nothing
		Set objComputer = Nothing
		objADFile.WriteLine
		objADFile.WriteLine
		Set objRootDSE = Nothing
		'Find GC's
		Const NTDSDSA_OPT_IS_GC = 1
		objADFile.WriteLine "Global Catalogs:"
		On Error Resume Next
		For i = 1 To UBound(arrDC)
			Set objRootDSE = GetObject("LDAP://" & arrDC(i) & "/rootDSE")
			strDsServiceDN = objRootDSE.Get("dsServiceName")
			Set objDsRoot  = GetObject("LDAP://" & arrDC(i) & "/" & strDsServiceDN)
			intOptions = objDsRoot.Get("options")
			If intOptions And NTDSDSA_OPT_IS_GC Then
				objADFile.WriteLine "  " & arrDC(i)
			End If
		Next
		Set objDsRoot = Nothing
		Set objRootDSE = Nothing
	Else
		objADFile.WriteLine
		objADFile.WriteLine "No Active Directory Domain Found."
		MsgBox "No Domain information could be gathered. Please ensure you are running this on a valid Domain Controller.", vbInformation 
		'Call DialogMessage ("No Domain was found")
		Err.Clear
		objExplorer.Quit
		WScript.Quit
	End If
	On Error Goto 0
	objADFile.Close
	'Call DialogMessage("AD Info Complete")
End Sub

'************************************************************************************************************************************************
'************************************************************************************************************************************************

Sub stage002
	'Call DialogMessage("Getting list of domain computers")
	Const FileName =".\\System Files\\Nodes-In-AD.csv"
	Set cmd = CreateObject("ADODB.Command")
	Set cn = CreateObject("ADODB.Connection")
	Set rs = CreateObject("ADODB.Recordset")
	cn.open "Provider=ADsDSOObject;"
	cmd.activeconnection = cn
	On Error Resume Next
	Set objRoot = GetObject("LDAP://RootDSE")
	cmd.commandtext = "<LDAP://" & objRoot.Get("defaultNamingContext") & ">;(objectCategory=Computer);" & "name,operatingsystem,operatingsystemservicepack, operatingsystemversion;subtree"
	cmd.properties("page size")=1000
	Set rs = cmd.Execute
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFolder = objFSO.CreateFolder(".\\System Files")
	Set objCSV = objFSO.createtextfile(FileName)
	q = """"
	While rs.eof <> True And rs.bof <> True
		objcsv.writeline(rs("name"))
		rs.MoveNext
	Wend
	objCSV.Close
	cn.Close
	'Call DialogMessage("Domain computers established")
End Sub

'************************************************************************************************************************************************
'************************************************************************************************************************************************

Sub Stage003
	On Error Resume Next
	Set objFso = CreateObject("Scripting.FileSystemObject")
	Set objNodesInAD = objFso.OpenTextFile(".\\System Files\\Nodes-In-AD.csv",1)
	Set objAliveNodeFile = objFso.CreateTextFile(".\\Reports\\General Info\\Alive-Nodes.txt",2)
	Set objDeadNodeFile = objFso.CreateTextFile(".\\Reports\\General Info\\Dead-Nodes.txt",2)
	Set objAlertsFile = objFso.CreateTextFile(".\\Reports\\ALERTS.txt",2)
	Do Until objNodesInAD.AtEndOfStream
		strComputer = objNodesInAD.ReadLine
		Set objWMIService = GetObject("winmgmts:\\\\.\\root\\cimv2")
		txtOutput = ""
		txtOutput=txtOutput & "Pinging " & strComputer
		'Call DialogMessage (txtOutput)
		Set colItems = objWMIService.ExecQuery("Select * from Win32_PingStatus " & "Where Address = '" & strComputer & "'")
		For Each objItem In colItems
			If objItem.StatusCode = 0 Then 
				objAliveNodeFile.WriteLine (strComputer)
				txtOutput = ""
				txtOutput=txtOutput & strComputer & "  Contacted"
				'Call DialogMessage (txtOutput)
			Else
				objDeadNodeFile.WriteLine (strComputer)
				objAlertsFile.WriteLine
				objAlertsFile.WriteLine(strComputer & " was requested for audit but cannot be contacted")
				txtOutput = ""
				txtOutput=txtOutput & strComputer & "  NOT THERE"
				'Call DialogMessage (txtOutput)
			End If   
		Next
	Loop
	cn.Close
	C'all DialogMessage ("Alive nodes found")
End Sub

'************************************************************************************************************************************************
'************************************************************************************************************************************************

Sub Stage101
	Setup101
	On Error Resume Next
	'Call DialogMessage ("Starting Audit")
	Do Until strCompFile.AtEndOfStream
		strComputer = strCompFile.ReadLine
		Set objWMIService = GetObject("winmgmts:\\\\.\\root\\cimv2")
		Set colItems = objWMIService.ExecQuery("Select * from Win32_PingStatus " & "Where Address = '" & strComputer & "'")
		For Each objItem In colItems
			AuditNode (strComputer)
		Next
	Loop
	'Call DialogMessage ("Audit Completed")
End Sub

'*********************************************************************************************
'*********************************************************************************************

Sub Setup101
	'Call DialogMessage ("Reading Files")
	On Error Resume Next
	Set objFso = CreateObject("Scripting.FileSystemObject")
	Set objFolder = objFSO.CreateFolder(".\\Reports\\Computers\\")
	Set strCompFile = objFso.OpenTextFile(".\\Reports\\General Info\\Alive-Nodes.txt",1)
	Set objRegFile = objFso.CreateTextFile(".\\Reports\\Computers\\Applications.csv",2)
	Set objSharesFile = objFso.CreateTextFile(".\\Reports\\Computers\\Shares.csv",2)
	Set HardwareFile = objFso.CreateTextFile (".\\Reports\\Computers\\Hardware.csv",2)
	Set NetworkFile = objFSO.CreateTextFile (".\\Reports\\Computers\\Network.csv",2)
	Set objServicesFile = objFSO.CreateTextFile (".\\Reports\\Computers\\Services.csv",2)
	Set InfoFile = objFso.CreateTextFile (".\\Reports\\Computers\\Info.csv",2)
	Set objGPOFile = objFso.CreateTextFile (".\\Reports\\Computers\\GroupPolicy.csv",2)
	Set objAlertsFile = objFso.CreateTextFile(".\\Reports\\ALERTS.txt",8)
	'Call DialogMessage ("Setting up computer audit")
	ObjGPOFile.WriteLine ("Computer,Name,GUID Name,ID,Access Denied ?,Enabled ?,System Path,Filter Allowed ?,Filter ID,Version")
	HardwareFile.WriteLine "Computer,Manufacurer,Model,Service Tag,Serial Number,Bios Version,Operating System,OS Edition,Number of CPUs,Processor,Processor Usage,Total RAM,Free RAM,RAM Config,CDROM,Active Network Adaptor,Hard Drives"
	objRegFile.WriteLine "Computer,Software,Version,Install Date,Install Location"
	objSharesFile.WriteLine "Computer,Share Name,Share Path"
	objServicesFile.WriteLine "Computer,Service Long Name,Service Short Name,State,Startup Option,Account,Path to Executable"
	NetworkFile.WriteLine "Computer,Adapter Name,IP Address,MAC Address,Subnet Mask,Default Gateway,DHCP Enabled,DHCP Server,DNS Domain,DNS Full Reg,DNS Server 1,DNS Server 2,DNS Server 3, DNS Server 4,Network Adapter Type,Adapter GUID"
	InfoFile.WriteLine "Computer,BIOS Admin Password State,Current TimeZone,Daylight Saving,Page File Allocated Size,Page File In Use,Page File Peak Use,Page File Location"
	'Call DialogMessage ("Reading Files Completed")
End Sub

'*********************************************************************************************
'*********************************************************************************************


Set objShell = CreateObject("Wscript.shell")
objShell.run("powershell -noexit -file C:\temp\HostSystemInfo\CSVtoEXCEL.ps1")

'************************
'Sub ArchiveFolder (zipFile, sFolder)

'    With CreateObject("Scripting.FileSystemObject")
'        zipFile = .GetAbsolutePathName(zipFile)
'		sFolder = .GetAbsolutePathName(sFolder)

'        With .CreateTextFile(zipFile, True)
'            .Write Chr(80) & Chr(75) & Chr(5) & Chr(6) & String(18, chr(0))
'        End With
'    End With

 '   With CreateObject("Shell.Application")
 '       .NameSpace(zipFile).CopyHere .NameSpace(sFolder).Items

 '       Do Until .NameSpace(zipFile).Items.Count = _
 '                .NameSpace(sFolder).Items.Count
 '           WScript.Sleep 1000 
 '       Loop
 '   End With

'End Sub

Sub Finished
'	ArchiveFolder strComputerName &".zip", ".\\Reports"
	
	 Set objMessage = CreateObject("CDO.Message")
		objMessage.Subject = "Auto-generated Email about System Information - " & strComputerName 
		objMessage.From = "AdminScript@oakton.com.au"
		objMessage.To = "%USERNAME%@oakton.com.au"
		objMessage.TextBody = "This attachement contains entire " & strComputerName & " Information"
		objMessage.AddAttachment "C:\temp\HostSystemInfo\"& strComputerName&".xlsx"
		objMessage.Configuration.Fields.Item _
		("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
		objMessage.Configuration.Fields.Item _
		("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "cluster1.ap.messagelabs.com" 
		objMessage.Configuration.Fields.Item _
		("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
		objMessage.Configuration.Fields.Update
		objMessage.Send
	objExplorer.Quit
	WScript.Sleep 1000
	
	WScript.Quit
End Sub





'*********************************************************************************************
'*********************************************************************************************

Sub AuditNode(strComputer)
	On Error Resume Next
	objAlertsFile.WriteLine
	objAlertsFile.WriteLine ("************")
	objAlertsFile.WriteLine	(strComputer)
	objAlertsFile.WriteLine ("************")
	Set objWMIService= GetObject("winmgmts:\\"  & strComputer & "\root\CIMV2") 
	If Err.Number <> 0 Then
		objAlertsFile.WriteLine ("ERROR: A problem has occurred connecting to "&strComputer&" the error number is "&Err.Number&" "&Err.Description)
		Err.Clear
		On Error Goto 0
	Else
		On Error Goto 0
		Set colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
		For Each objItems In colItems
			strComputer = objItems.CSName
			strOS = Trim(objItems.Caption)
			strOS = Replace(strOS,","," ")
			If (InStr(strOS, "200") Or InStr(UCase(strOS), "W")) > 0 Then
				bIsNT = False
				strOSSP = Trim(objItems.ServicePackMajorVersion & "." & objItems.ServicePackMinorVersion)
			Else 
				bIsNT = True
				strOSSP = "."
			End If
			If strOSSP <> "." Then
				strOS = strOS & " SP: " & strOSSP
			End If
			If InStr (strOS,",") = 0 Then
				strOS = strOS & ","
			End If 
		Next
		Set colItems = Nothing
		If InStr(UCase(strOS), "W") > 0 Then
			Set colItems = objWMIService.ExecQuery("Select * from Win32_Processor")
			numCPUs = 0
			For Each objItems In colItems
				numCPUs = NumCPUs + 1
				strCPUName = Trim(objItems.Name)
			Next
			Set colItems = Nothing
			bFound = False
			For i = 1 To UBound(arrDupName)
				If UCase(arrDupName(i)) = UCase(strComputer) Then
					bFound = True
					Exit For
				End If
			Next
			If bFound = False Then
				'Call DialogMessage("Auditing : " & strComputer)
				i = UBound(arrDupName) + 1
				ReDim Preserve arrDupName(i)
				arrDupName(i) = strComputer
				strNoOffCPU = ""
				If numCPUs > 1 Then
					strNoOffCPU = numCPUs
				End If
				If strNoOffCPU = "" Then
					strNoOffCPU="1"
				End If
				
				'Get Computer Info
				If bIsNT = False Then
					Set colItems = objWMIService.ExecQuery("Select * from Win32_BaseBoard")
					For Each objItem In colItems
						strSN = Trim(objItem.SerialNumber)
					Next
					Set colItems = Nothing
					
					'Get Computer Model and Status
					Set colItems = objWMIService.ExecQuery("Select * from Win32_ComputerSystem")
					For Each objItem In colItems
						strModel = Trim(objItem.Model)
						strModel = Replace(strModel,","," ")
						strStatus = Trim(objItem.Status)
						strManufacturer = Trim(objItem.Manufacturer)
						strManufacturer = Replace(strManufacturer,","," ")
						strAdminPWStatus = Trim(objItem.AdminPasswordStatus)
						strCurrTZ = Trim(objItem.CurrentTimeZone)
						strDaylightSave = Trim(objItem.DaylightInEffect)
					Next
					Set colItems = Nothing
					
					'Get Service Tag
					Set colItems = objWMIService.ExecQuery("Select * from Win32_BIOS") 
					For Each objItem In colItems
						strBiosVers = Trim(objItem.SMBIOSBIOSVersion)
						strServiceTag = Trim(objItem.SerialNumber)
					Next
					Set colItems = Nothing
					
					'Get CD Drive Info
					Set colItems = objWMIService.ExecQuery("Select * from Win32_CDROMDrive")
					On Error Resume Next	
					For Each objItem In colItems
						strCDROM = Trim(objItem.Caption)
					Next
					Set colItems = Nothing
					
					'Get Pagefile Info
					'Call DialogMessage("Auditing : " & strComputer & " - Pagefile Info")
					Set colItems = objWMIService.ExecQuery("Select * from Win32_PageFileUsage")
					On Error Resume Next	
					For Each objItem In colItems
						strPFBaseSizeMB = Trim(objItem.AllocatedBaseSize)
						strPFCurrentUsageMB = Trim(objItem.CurrentUsage)
						strPFPeakUsageMB = Trim(objItem.PeakUsage)
						strPFBaseSizeKB = strPFBaseSizeMB * 1024
						strPFBaseSizeBY = strPFBaseSizeKB * 1024
						strPFCurrentUsageKB = strPFCurrentUsageMB * 1024
						strPFCurrentUsageBY = strPFCurrentUsageKB * 1024
						strPFPeakUsageKB = strPFPeakUsageMB * 1024
						strPFPeakUsageBY = strPFPeakUsageKB * 1024
						strPFLocation = Trim(objItem.Caption)
					Next
					strPFThreshold = Int(strPFBaseSizeMB / 5)
					strPFThreshold = Int(strPFThreshold * 4)
					If Int(strPFPeakUsageMB) > Int(strPFThreshold) Then
						objAlertsFile.WriteLine (strComputer&" peak page file use is unusually excessive")
					End If
					If Int(strPFCurrentUsageMB) > Int(strPFThreshold) Then
						objAlertsFile.WriteLine (strComputer&" current page file use is unusually excessive")
					End If
					Set colItems = Nothing
					
					'Get Processor Usage Info
					Set colItems = objWMIService.ExecQuery("Select * from Win32_Processor")
					On Error Resume Next	
					For Each objItem In colItems
						strProcUsage = Trim(objItem.LoadPercentage)
					Next
					Set colItems = Nothing
					If Int(strProcUsage > 50) Then
						objAlertsFile.WriteLine (strComputer&"'s processor is running at over 50% ("&strProcUsage&"%)")
					End If
					
					'Check OS and SP Versions
					'Call DialogMessage("Auditing : " & strComputer & " - OS and Service Pack Versions")
					Set colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
					On Error Resume Next	
					For Each objItem In colItems
						strOSVersion = Trim(objItem.Caption)
						strOSSPMAJVersion = Trim(objItem.ServicePackMajorVersion)
					Next
					Set colItems = Nothing
					If Left (strOSVersion,33) = "Microsoft Windows XP Professional" And Int(strOSSPMAJVersion) < 3 Then
						objAlertsFile.WriteLine (strComputer&" is not at the latest service pack version")
					ElseIf Left (strOSVersion,35) = "Microsoft(R) Windows(R) Server 2003" And Int(strOSSPMAJVersion) < 2 Then
						objAlertsFile.WriteLine (strComputer&" is not at the latest service pack version")
					ElseIf Left (strOSVersion,32) = "Microsoft Windows 7 Professional" And Int(strOSSPMAJVersion) < 1 Then
						objAlertsFile.WriteLine (strComputer&" is not at the latest service pack version")
					ElseIf Left (strOSVersion,29) = "Microsoft Windows Server 2008" And Int(strOSSPMAJVersion) < 2 Then
						objAlertsFile.WriteLine (strComputer&" is not at the latest service pack version")
					ElseIf Left (strOSVersion,33) = "Microsoft Windows XP Professional" And Int(strOSSPMAJVersion) = 3 Then
						'Nothing
					ElseIf Left (strOSVersion,35) = "Microsoft(R) Windows(R) Server 2003" And Int(strOSSPMAJVersion) = 2 Then
						'Nothing
					ElseIf Left (strOSVersion,32) = "Microsoft Windows 7 Professional" And Int(strOSSPMAJVersion) = 1 Then
						'Nothing
					ElseIf Left (strOSVersion,29) = "Microsoft Windows Server 2008" And Int(strOSSPMAJVersion) = 2 Then
						'Nothing
					Else
						objAlertsFile.WriteLine (strComputer&" has an operating system and/or service pack level that is unrecognised by this tool " & strOSVersion)
					End If
					
					'Get Share Info
					'Call DialogMessage("Auditing : " & strComputer & " - Shares")
					Set colItems = objWMIService.ExecQuery("Select * from Win32_Share")
					On Error Resume Next	
					For Each objItem In colItems
						strShareName = Trim(objItem.Name)
						strSharePath = Trim(objItem.Path)
						strLineShares = strComputer & "," & strShareName & "," & strSharePath
						objSharesFile.WriteLine strLineShares
					Next
					Set colItems = Nothing
					
					'Get Network Info
					'Call DialogMessage("Auditing : " & strComputer & " - Network Info")
					On Error Resume Next	
					Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapter Where NetConnectionStatus = '2'")
					NicCount = 0
					For Each objItem In colItems
						NicCount = NicCount + 1
						strNetworkProductName = Trim(objItem.ProductName)
						strNetworkConnectionName = Trim(objItem.NetConnectionID)
						strNetworkMacAddress = Trim(objItem.MACAddress)
						strNetworkCaption = Trim(objItem.Caption)
						strNETPNPID = Trim(objItem.PNPDeviceID)	
						'Call DialogMessage("Auditing : " & strComputer & " - Network Info Stage 2 for - "&strNetworkCaption)	
						Call NetworkAuditPart2(strComputer,strNetworkMacAddress,strNetworkCaption)
						strLineNetwork = strComputer & "," & strNetworkConnectionName & "," & strNetworkIPAddress & "," & strNetworkMacAddress & "," & strNetworkSubnet & "," & strNetworkDefaultGateway & "," & strNetworkDHCPEnabled & "," & strNetworkDHCPServer & "," & strNetworkDNSDomain & "," & strNetworkFullDNSRegistration & "," & strNetworkDNS1 & "," & strNetworkDNS2 & "," & strNetworkDNS3 & "," & strNetworkDNS4 & "," & strNetworkProductName & "," & strNetworkAdapterGUID
						NetworkFile.WriteLine strLineNetwork
						If InStr (strNetworkProductName,"Virtual") <> 0 And strNetworkConnectionName <> "NIC Team" Then
							TeamDetails.WriteLine (strComputer)
							TeamDetails.Writeline (strNetworkProductName)
							TeamDetails.Writeline ("{4D36E972-E325-11CE-BFC1-08002BE10318}")
							TeamDetails.Writeline (strNetworkAdapterGUID)
						Else						
						End If
						If InStr (strNetworkProductName,"Virtual") <> 0 And InStr (strNetworkProductName,"Intel") <> 0 Then
							objAlertsFile.WriteLine (strComputer&" is using an Intel Team")
						End If
						If InStr (strNetworkProductName,"Realtek") <> 0 Then
							objAlertsFile.WriteLine (strComputer&" has a RealTek NIC card installed")
						End If
					Next
					'Call DialogMessage("Auditing : " & strComputer & " - Network Info Completed")	
					If Int(NicCount) <> 3 Then
						objAlertsFile.WriteLine (strComputer&" does not have redundant teamed NIC cards **Probably Fine**")
					End If
					Set colItems = Nothing
					
					'Get Total Physical Memory Info
					'Call DialogMessage("Auditing : " & strComputer & " - Memory Setup")
					Set colItems = objWMIService.ExecQuery("Select * from Win32_PhysicalMemory")
					numMemCap = 0
					strRAMConfig = ""
					numMemCap2 = 0
					strRAMConfigTemp = ""
					For Each objItem In colItems
						numMemCap2 = numMemCap2 + objItem.Capacity
						numMemCap = numMemCap + objItem.Capacity
						strMemTemp = objItem.Capacity
						strRAMConfigTemp = prepSize(strMemTemp)
						strRAMConfig = strRAMConfig & " + " & strRAMConfigTemp
					Next
					strRAM2 = prepSize(numMemCap2)
					strRAMConfig = Trim(strRAMConfig)
					strRAMConfig = Replace(strRAMConfig,"+","",1,1)
					strRAMConfig = Trim(strRAMConfig)
					If Int(strPFBaseSizeBY) > Int(numMemCap * 1.5) Then
						objAlertsFile.WriteLine (strComputer&" page file base size is larger than expected ("&strPFBaseSizeMB&" MB)")
					End If
					If Int(numMemcap) < 506870912 And Left (strOSVersion,33) = "Microsoft Windows XP Professional" Then
						objAlertsFile.WriteLine (strComputer&" is below reccomended minimum RAM ("&strRAM2&")")
					End If
					If Int(numMemcap) < 1003741824 And Left (strOSVersion,35) = "Microsoft(R) Windows(R) Server 2003" Then
						objAlertsFile.WriteLine (strComputer&" is below reccomended minimum RAM ("&strRAM2&")")
					End If
					strRAM = prepSize(numMemCap)
					Set colItems = Nothing
					
					'Get Free Physical Memory Info
					Set colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
					numMemCap = 0
					For Each objItem In colItems
						strLowRAMWarn = Trim(objItem.FreePhysicalMemory)
						numMemCap = objItem.FreePhysicalMemory * 1024
					Next
					strFreeRAM = prepSize(numMemCap)
					If Int(strLowRAMWarn) < 24000 Then
						objAlertsFile.WriteLine (strComputer&" has low free RAM ("&strFreeRAM&")")
					End If
					Set colItems = Nothing
				End If
				
				'Get Logical Drive Info
				'Call DialogMessage("Auditing : " & strComputer & " - HDD Info")
				Set colItems = objWMIService.ExecQuery("Select * from Win32_LogicalDisk")
				strHardDrive = ""
				t = 0
				For Each objItem In colItems
					If objItem.DriveType = 3 Then
						t = t + 1
						If t > 1 Then
							strHardDrive = strHardDrive & ","
						End If
						strHardDrive = strHardDrive & objItem.Name & " " & prepSize(objItem.Size) & " (" & prepSize(objItem.FreeSpace) & " free)"
						strDriveTotSize = Int(objItem.Size)
						strDriveFreeSpace = Int(objItem.FreeSpace)
						strHalfTotSize = Int(strDriveTotSize / 2)
						strSpaceRemaining = prepSize(objItem.FreeSpace)
						If strDriveFreeSpace < strHalfTotSize Then
							objAlertsFile.WriteLine ("The "& objItem.Name & " Drive on "& strComputer & " is more than half used")
						End If
						If strDriveFreeSpace < 1073741824 Then
							objAlertsFile.WriteLine ("The "& objItem.Name & " Drive on "& strComputer & " has only " & strSpaceRemaining & " remaining")
						End If
					End If
				Next
				Set colItems = Nothing
				
				'Audit Services
				'Call DialogMessage("Auditing : " & strComputer & " - Services")
				Set colItems = objWMIService.ExecQuery("Select * from Win32_Service")
				For Each objItem In colItems
					SVCCaption = Trim(objItem.Caption)
					SVCName = Trim(objItem.Name)
					SVCPathName = Trim(objItem.PathName)
					SVCState = Trim(objItem.State)
					SVCStartMode = Trim(objItem.StartMode)
					SVCStartName = Trim(objItem.StartName)
					SVCLine = strComputer & "," & SVCCaption & "," & SVCName & "," & SVCState & "," & SVCStartMode & "," & SVCStartName & "," & SVCPathName
					ObjServicesFile.WriteLine (SVCLine)
				Next
				Set colItems = Nothing
				
				'Collect Group Policy Details
				''Call DialogMessage("Auditing : " & strComputer & " - Group Policy Details")
				Set objWMIService = GetObject("winmgmts:\\\\" & strComputer & "\\root\\rsop\\computer")
				Set colItems = objWMIService.ExecQuery("Select * from RSOP_GPO")
				For Each objItem In colItems
					GPOName = Trim(objItem.Name)
					GPOGUID = Trim(objItem.GUIDName)
					GPOID = Trim(objItem.ID)
					GPOID = Replace(GPOID,",","")
					GPOAccessDenied = Trim(objItem.AccessDenied)
					GPOEnabled = Trim(objItem.Enabled)
					GPOFileSystemPath = Trim(objItem.FileSystemPath)
					GPOFilterAllowed = Trim(objItem.FilterAllowed)
					GPOFilterID = Trim(objItem.FilterId)
					GPOFilterID = Replace(GPOFilterID,",","")
					GPOVersion = Trim(objItem.Version)
					GPOLine = strComputer & "," & GPOName & "," & GPOGUID & "," & GPOID & "," & GPOAccessDenied & "," & GPOEnabled & "," & GPOFileSystemPath & "," & GPOFilterAllowed & "," & GPOFilterID & "," & GPOVersion
					ObjGPOFile.WriteLine (GPOLine)
				Next
				Set colItems = Nothing
				
				'Collect Installed Software Info from the Registry
				''Call DialogMessage("Auditing : " & strComputer & " - Installed Software")
				Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE
				strKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\"
				strEntry1 = "DisplayName"
				strEntry2 = "DisplayVersion"
				strEntry3 = "Comments"
				strEntry4 = "InstallDate"
				strEntry5 = "InstallLocation"
				strEntry6 = "Version"
				strEntry7 = "VersionMajor"
				strEntry8 = "VersionMinor"
				Set objReg = GetObject("winmgmts://" & strComputer & "/root/default:StdRegProv")
				objReg.EnumKey HKLM, strKey, arrSubkeys
				For Each strSubkey In arrSubkeys
					intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey, strEntry1, strValue1)
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry1, strValue1
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry2, strValue2
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry3, strValue3
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry4, strValue4
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry5, strValue5
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry6, strValue6
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry7, strValue7
					objReg.GetStringValue HKLM, strKey & strSubkey, strEntry8, strValue8
					If strValue1 <> "Null" Then
						objRegFile.WriteLine (strComputer & "," & strValue1 & "," & strValue2 & "," & strValue4 & "," & strValue5)
					Else
					End If
					If InStr(strValue1, "Broadcom") > 0.9 And InStr(strValue1, "Management") > 0.9 And InStr(strOS, "2003") > 0.9 And strModel <> "PowerEdge 2950" And strValue2 <> "8.12.01" Then
						objAlertsFile.WriteLine (strComputer&" has the wrong Broadcom software and drivers installed. Install v7.7.7")
					ElseIf InStr(strValue1, "Broadcom") > 0.9 And InStr(strValue1, "Management") > 0.9 And InStr(strOS, "2003") > 0.9 And strValue2 = "8.12.01" Then
						''Call DialogMessage("Auditing : " & strComputer & " - Broadcom Drivers and Software Ok")						
					End If
				Next
				
				'Make sence of Admin Password Status
				If strAdminPWStatus = "1" Then
					strAdminPWStatus = "DISABLED"
					objAlertsFile.WriteLine (strComputer&" has the BIOS password disabled")
					
				ElseIf strAdminPWStatus = "2" Then
					strAdminPWStatus = "Enabled"
				ElseIf strAdminPWStatus = "3" Then
					strAdminPWStatus = "NOT SET"
					objAlertsFile.WriteLine (strComputer&" does not have a BIOS password set **Probably Fine**")
					
				ElseIf strAdminPWStatus = "4" Then
					strAdminPWStatus = "UNKNOWN"
					objAlertsFile.WriteLine (strComputer&" has an unknown BIOS password state")
					
				End If
				
				'See if time zone is correct
				If strCurrTZ <> "60" Then
					strCurrTZ = "None GMT"
					objAlertsFile.WriteLine (strComputer&" has a non GMT time zone **Probably Fine**")
					
				Else
					strCurrTZ = "GMT Timezone"
				End If
				
				'Save Info to csv files
				''Call DialogMessage("Auditing : " & strComputer & " - Writing Info")
				strLineHardware = strComputer & "," & strManufacturer & "," & strModel & "," & strServiceTag & "," & strSN & "," & strBiosVers & "," & strOS & "," & strNoOffCPU & "," & strCPUName & "," & strProcUsage & "," & strRAM & "," & strFreeRAM & "," & strRAMConfig& "," & strCDROM & "," & strNetworkProductName & "," & strHardDrive
				HardwareFile.WriteLine strLineHardware
				strLineInfo = strComputer & "," & strAdminPWStatus & "," & strCurrTZ & "," & strDaylightSave & "," & strPFBaseSizeMB & "," & strPFCurrentUsageMB & "," & strPFPeakUsageMB & "," & strPFLocation
				InfoFile.WriteLine strLineInfo
			Else
				Set colItems = Nothing
			End If
		End If
		Set objWMIService = Nothing
	End If
	''Call DialogMessage("Auditing : " & strComputer & " - Finished")
End Sub


'************************************************************************************************************************************************
'************************************************************************************************************************************************
'************************************************************************************************************************************************

Function removeCN(strName)
	removeCN = Replace(strName, "CN=", "")
End Function

'*********************************************************************************************
'*********************************************************************************************

Function Integer8Date(ByVal objDate, ByVal lngBias)
	Dim lngAdjust, lngDate, lngHigh, lngLow
	lngAdjust = lngBias
	lngHigh = objDate.HighPart
	lngLow = objdate.LowPart
	If (lngLow < 0) Then
		lngHigh = lngHigh + 1
	End If
	If (lngHigh = 0) And (lngLow = 0) Then
		lngAdjust = 0
	End If
	lngDate = #1/1/1601# + (((lngHigh * (2 ^ 32))+ lngLow) / 600000000 - lngAdjust) / 1440
	On Error Resume Next
	Integer8Date = CDate(lngDate)
	If (Err.Number <> 0) Then
		On Error Goto 0
		Integer8Date = #1/1/1601#
	End If
	On Error Goto 0
End Function

'*********************************************************************************************
'*********************************************************************************************

'*********************************************************************************************
'*********************************************************************************************

Function CSVLine(ByVal arrValues)
	Dim strItem
	CSVLine = ""
	For Each strItem In arrValues
		If (strItem <> "") Then
			strItem = Replace(strItem, """", """" & """")
		End If
		If (CSVLine = "") Then
			CSVLine = """" & strItem & """"
		Else
			CSVLine = CSVLine & ",""" & strItem & """"
		End If
	Next
End Function

'*********************************************************************************************
'*********************************************************************************************


Function DialogMessage(strDialogMessage)
	On Error Resume Next
	objExplorer.Document.Body.InnerHTML = strDialogMessage
	If Len(objExplorer.Document.Title) < 75 Then
		objExplorer.Document.Title = objExplorer.Document.Title & "*"
	Else
		objExplorer.Document.Title = "KellTec Audit Tool "&ToolVersion& " *"
	End If
	WScript.Sleep (MessageDelay)
	Set objFso = CreateObject("Scripting.FileSystemObject")
	Set objFolder = objFSO.CreateFolder(".\\Reports\\")
	Set objLogFile = objFSO.CreateTextFile(".\\Reports\\Audit Log.txt",8)
	objLogFile.writeline (Now() & " : " & strDialogMessage)
	If (objExplorer.document.body.innerText) = LastMessage Then
		If MsgBox("Do you want to stop the audit ?", vbQuestion + vbYesNoCancel, "DS2000 Server Audit") = vbYes Then
			Set objFso = CreateObject("Scripting.FileSystemObject")
			Set objLogFile = objFSO.CreateTextFile("./Reports/Audit Log.txt",8)
			objLogFile.writeline (Now() & " : " & "Audit Aborted By User")
			MsgBox "Audit Aborted"
			WScript.Sleep 1000
			WScript.Quit
		Else
			ReOpenDialogWindow
		End If
	Else
		LastMessage = strDialogMessage
	End If
End Function

'*********************************************************************************************
'*********************************************************************************************

Function prepSize(numSize)
	If numSize > 0 Then
		numSize = (numSize / 1024) / 1024
		strMem = "MB"
		If numSize > 1000 Then
			strMem = "GB"
			numSize = numSize / 1024
		End If
		numSize = Round(numSize, 2)
		prepSize = numSize & " " & strMem
	Else 
		prepSize = ""
	End If
End Function

'*********************************************************************************************
'*********************************************************************************************

Function NetworkAuditPart2(strComputer,strNetworkMacAddress,strNetworkCaption)
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\\\" & strComputer & "\\root\\cimv2")
	SQLQuery = ("Select * from Win32_NetworkAdapterConfiguration Where MACAddress = '"&strNetworkMacAddress&"' And Caption = '"&strNetworkCaption&"'")
	Set colItems = objWMIService.ExecQuery(SQLQuery)
	''Call DialogMessage("Auditing : " & strComputer & " - Network Info IP Details for - "&strNetworkCaption)	
	For Each objItem In colItems
		strNetworkAdapterGUID = Trim(objItem.SettingID)
		strNetworkDHCPEnabled = Trim(objItem.DHCPEnabled)
		strNetworkDHCPServer = Trim(objItem.DHCPServer)
		strNetworkDNSDomain = Trim(objItem.DNSDomain)
		strNetworkFullDNSRegistration = Trim(objItem.FullDNSRegistrationEnabled)
		strNetworkIPAddress = Trim(objItem.IPAddress(0))
		strNetworkSubnet =  Trim(objItem.IPSubnet(0))
		strNetworkDefaultGateway = Trim(objItem.DefaultIPGateway(0))
		strNetworkDNS1 = Trim(objItem.DNSServerSearchOrder(0))
		strNetworkDNS2 = Trim(objItem.DNSServerSearchOrder(1))
		strNetworkDNS3 = Trim(objItem.DNSServerSearchOrder(2))
		strNetworkDNS4 = Trim(objItem.DNSServerSearchOrder(3))
	Next
	Set colItems = Nothing
	''Call DialogMessage("Auditing : " & strComputer & " - Network Info IP Details Done for - "&strNetworkCaption)
End Function

'*********************************************************************************************
'*********************************************************************************************
'*********************************************************************************************

Sub DialogWindow
	Set objExplorer = WScript.CreateObject("InternetExplorer.Application")
	objExplorer.Navigate "about:blank"
	objExplorer.ToolBar = 0
	objExplorer.StatusBar = 0
	objExplorer.Width = 600
	objExplorer.Height = 100
	objExplorer.Left = 10
	objExplorer.Top = 10
	txtOutput="Starting Up"
	objExplorer.Document.Body.InnerHTML = txtOutput
	objExplorer.Document.Title = "KellTec Audit Tool "&ToolVersion
	Do While (objExplorer.Busy)
		WScript.Sleep 200
	Loop
	objExplorer.Visible = 1
End Sub
