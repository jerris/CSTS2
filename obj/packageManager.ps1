[CmdletBinding()]param()
begin{
	# =========================================================
	#	Class: PackageManager
	#		The class definition for the object that will 
	#		help manage package compliance
	# =========================================================
	Class PackageManager{
	
		# =========================================================	
		#	Properties: Static Properties
		#		name 	- The name of the class
		#		desc 	- A detailed description of the class
		# =========================================================
		static $name = "PackageManager"
		static $desc = "Verifies package compliance"
		
		# =========================================================	
		#	Properties: Public Properties
		#		data 		- The results from the applet invocation
		#		dataComp 	- Used to see if any of the data has 
		#						changed between iterations
		#		isChanged	- Has the data changed
		#		tables		- The SQL Tables this object uses
		#		deaults		- The default data loaded in certain 
		#						tables
		# =========================================================
		$data = @()
		$dataComp = @()
		$isChanged = $false
		
		$tables = @{
			"deviceTypes"            = "CREATE TABLE deviceTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"resources"              = "CREATE TABLE resources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"scanTypes"              = "CREATE TABLE scanTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"statuses"               = "CREATE TABLE statuses (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"vendors"                = "CREATE TABLE vendors (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE);";
			
			"contacts"               = "CREATE TABLE contacts (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), organization VARCHAR (256) NOT NULL, firstName VARCHAR (64) NOT NULL, lastName VARCHAR (64) NOT NULL, phone VARCHAR (32) NOT NULL, email VARCHAR (256) NOT NULL);";
			"packages"               = "CREATE TABLE packages (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) NOT NULL, acronym VARCHAR (32) NOT NULL);";
			
			"applications"           = "CREATE TABLE applications (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL);";
			"assets"                 = "CREATE TABLE assets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), model VARCHAR (64), firmware VARCHAR (64), hostname VARCHAR (64), ip VARCHAR (16), description BLOB, osKey VARCHAR (256), location VARCHAR (256), operatingSystemId VARCHAR (36) REFERENCES operatingSystems (id), deviceTypeId VARCHAR (36) REFERENCES deviceTypes (id), vendorId VARCHAR (36) REFERENCES vendors (id));";
			"findings"               = "CREATE TABLE findings (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), iaControl VARCHAR (16), grpId VARCHAR (128), vulnId VARCHAR (64), ruleId VARCHAR (64), pluginId VRCHAR (32), impact VARCHAR (16), likelihood VARCHAR (16), rawRisk INT, description BLOB, correctiveAction BLOB, riskStatement BLOB, findingTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL);";
			"milestones"             = "CREATE TABLE milestones (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (128), scd DATE, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL);"
			"mitigations"            = "CREATE TABLE mitigations (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), residualRisk INT, remediated BOOLEAN, mitigation BLOB, comments BLOB);"
			"operatingSystems"       = "CREATE TABLE operatingSystems (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL);";
			"scans"                  = "CREATE TABLE scans (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, name VARCHAR (256) UNIQUE, version VARCHAR (16), release VARCHAR (16), filename VARCHAR (256));";
			"requirements"           = "CREATE TABLE requirements (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (16), release VARCHAR (16), credentialed BOOLEAN, requirementTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			
			"xAssetsFindings"        = "CREATE TABLE xAssetsFindings (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), comments BLOB, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetRequirements"     = "CREATE TABLE xAssetRequirements (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, requirementId VARCHAR (36) REFERENCES requirements (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetsScans"           = "CREATE TABLE xAssetsScans (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanDate DATE, credentialed BOOLEAN, score DOUBLE, filename VARCHAR (256), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetsApplications"    = "CREATE TABLE xAssetsApplications (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), installDate DATE, applicationId VARCHAR (36) REFERENCES applications (id) NOT NULL, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xFindingsMitigations"   = "CREATE TABLE xFindingsMitigations (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, mitigationId VARCHAR (36) REFERENCES mitigations (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id) NOT NULL);"
			"xFindingsResources"     = "CREATE TABLE xFindingsResources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, resourceId VARCHAR (36) REFERENCES resources (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xMitigationsMilestones" = "CREATE TABLE xMitigationsMilestones (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, mitigationId VARCHAR (36) REFERENCES mitigations (id) NOT NULL, milestoneId VARCHAR (36) REFERENCES milestones (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id) NOT NULL);"
			"xPackageContacts"       = "CREATE TABLE xPackageContacts (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, contactId VARCHAR (36) REFERENCES contacts (id) NOT NULL);";
			"xPackagesAssets"         = "CREATE TABLE xPackagesAssets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL);"
		}
		
		$defaults = @{
			'statuses' = @('Ongoing', 'Completed', 'False Positive', 'Not Applicable', 'Error','Not Reviewed');
			'deviceTypes' = @('Printer', 'Server', 'Workstation', 'Router', 'Switch');
			'resources' = @('ISSO', 'System Administator', 'Database Administrator');
			'scanTypes' = @('ACAS', 'CKL', 'SCAP');
			'vendors' = @('Microsoft', 'Oracle', 'HP', 'Dell');
		}
		
		[void] addPackage(){
			$params = @{
				'@Name' = [GUI]::Get().window.findName('UC').findName('txtPkgName').Text;
				'@Acronym' = [GUI]::Get().window.findName('UC').findName('txtPkgAcronym').Text;
			}
			
			if([Utils]::IsBlank( $params.'@Name') -eq $false -and [Utils]::IsBlank( $params.'@Acronym') -eq $false  ){
				$query = "Insert into packages (name, acronym) values (@Name, @Acronym);"
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery()	
			}
			
		}
		
		
		# =========================================================		
		#	Constructor: PackageManager
		#		Creates the PackageManager applet and updates the 
		#		active module in the CSTS
		# =========================================================
		PackageManager(){
			$global:csts.activeModule = $this
		}
		
		[void] pollEvents(){
			if((compare-object -referenceObject ($this.data) -differenceObject ($this.dataComp) ) -ne $null ){
				$this.dataComp = $this.data
				$this.isChanged = $true
			}else{
				$this.isChanged = $false
			}
		}
		
		# =========================================================
		#	Method: ExportData
		#		Exports the Package Manager
		#
		# 	Parameters:
		# 		exportType - The type of export to perform
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<Test>
		# =========================================================
		[void] ExportData($exportType){
			switch( "$([CSTS_Export]::$($exportType))" ){
				{ "$([CSTS_Export]::XLSX)" } {
					$filename = "$($global:csts.execPath)\results\PackageManager_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"
					$global:csts.libs.Export.Excel( $this.data, $fileName,$false, 'Prevent Sleep')
				}
			}
		}
				
		
		
		# =========================================================
		# 	Method: Initialize
		# 		Intiailizes the package manager
		#
		# 	Parameters:
		# 		NA
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<InvokePreventSleep>
		# =========================================================
		[void] Initialize(){
			$this.verifyDatabase();
		}
		
		[object[]] getPackageInfo(){
			$query = @"
Select 
    p.id, 
    p.name, 
    p.acronym,
    (select count(*) from xPackagesAssets xpa where xpa.packageId = p.id) as Hardware,
    (select count(*) from xAssetsApplications xaa where xaa.packageId = p.id) as Software,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'ACAS' )) ) as ACAS,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'CKL' )) ) as CKL,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'SCAP' )) ) as SCAP,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Open' or name='Error') )) as Open,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Not Reviewed') )) as NotReviewed,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Completed' or name = 'False Positive') )) as Completed,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Not Applicable') )) as NotApplicable
from 
	packages p
order by 
	p.acronym
"@
			return [SQL]::Get('packages.dat').query($query).execAssoc()
		}
		
		[void] createTable ( $table ){
			[GUI]::Get().showModal("Creating table $table")
			[SQL]::Get( 'packages.dat' ).query( $this.tables[$table] ).execNonQuery()
		}

		[bool] verifyTableExists( $table ){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$table' COLLATE NOCASE;"
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[bool] verifyTablePopulated( $table ){
			$query = "SELECT count(*) as ct FROM $table;"
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[void] populateTable( $table ){
			[GUI]::Get().showModal("Populating table $table")
			if($this.defaults.$table -ne $null){
				$this.defaults.$table | %{
					[SQL]::Get( 'packages.dat' ).query( "insert into $($table) (name) values ('$($_)');" ).execNonQuery()	
				}
			}
		}

		[void] pkgDelete($packageId){
			$params = @{
				'@packageId' = $packageId;
			}
			$query = "delete from {{{table}}} where packageId = @packageId"
			@('requirements', 'xPackageContacts', 'xFindingsResources', 'xFindingsMitigations', 'xMitigationsMilestones', 'xAssetsFindings', 'xAssetsScans', 'xPackagesAssets', 'xAssetsApplications', 'xAssetRequirements') | % {
				[SQL]::Get( 'packages.dat' ).query( ($query -replace '{{{table}}}', $_) , $params ).execNonQuery()
			}

			[SQL]::Get( 'packages.dat' ).query( "delete from packages where id = @packageId" , $params ).execNonQuery()
			$global:csts.controllers.Packages.showPkgMgrDashBoard()
		}
		
		[void] removeHosts(){
			
			[GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItems | % {
				$params = @{
					'@assetId' = $_.Id;
					'@packageId' = $global:csts.controllers.Packages.viewModel.pkgSelItem;
				}
				
				$query = "delete from {{{table}}} where packageId = @packageId and assetId = @assetId"
				@('xAssetsFindings', 'xAssetsScans', 'xPackagesAssets', 'xAssetsApplications', 'xAssetRequirements') | % {
					[SQL]::Get( 'packages.dat' ).query( ($query -replace '{{{table}}}', $_) , $params ).execNonQuery()
				}

				$params = @{
					'@assetId' = $_.Id;
				}
				[SQL]::Get( 'packages.dat' ).query( "delete from assets where id = @assetId" , $params ).execNonQuery()

			}

			$global:csts.controllers.Packages.showHardware()
		}
		
		[Object[]] getMetadata($h){
			$hostData = [psCustomObject]@{
				'@ip' = [Net]::getIp($h)
				'@hostname' = [Net]::getHostName($h);
				'@operatingSystemId' = "";
				'@osKey' = "";
				'@deviceTypeId' = "";
				'@vendorId' = "";
				'@model' = "";
				'@firmware' = "";
				'@location' = "";
				'@description' = "";
			}
			
			$ping = [Net]::Ping($h)
			if( ($ping.StatusCode -eq 0 -or $ping.StatusCode -eq $null ) -and [Utils]::isBlank($ping.IPV4Address) -eq $false ) {
				try{
					$os = gwmi win32_operatingSystem -computer $h
				}catch{
					$os = [psCustomObject]@{Caption = 'UNKNOWN'; OSArchitecture = 'UNKNOWN'; }
				}
				
				try{
					$hostData.'@firmware' = (gwmi win32_bios -computer $h).version
				}catch{
					$hostData.'@firmware' = ""
				}
				
				try{
					$hostData.'@model' = (gwmi win32_computerSystem -computer $h).model
				}catch{
					$hostData.'@model' = ""
				}
				
				$params = @{"@Name" = $os.Caption; "@Version" = $os.Version}				
				$query = "select id from operatingSystems where name = @Name and version = @Version;"
				$hostData.'@operatingSystemId' = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()
				if( [Utils]::IsBlank($hostData.'@operatingSystemId') ){
					$query = "select id from vendors where name = 'Microsoft';"
					$osVendor = [SQL]::Get( 'packages.dat' ).query( $query ).execOne()
					
					$params = @{ '@Name' = $os.Caption; '@Version' = $os.Version; '@Vendor' = $osVendor; } 					
					$query = "insert into operatingSystems (Name, Version, VendorId) values (@Name, @Version, @Vendor)"
					[SQL]::Get( 'packages.dat' ).query( $query,$params ).execNonQuery()

					$params = @{ "@Name" = $os.Caption; "@Version" = $os.Version; }						
					$query = "select id from operatingSystems where name = @Name and version = @version;"
					$hostData.'@operatingSystemId' = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()						
				}
				
				if($os.caption -like '*server*'){
					$query = "select id from deviceTypes where name = 'Server';"
					$hostData.'@deviceTypeId' = [SQL]::Get( 'packages.dat' ).query( $query ).execOne()	
				}else{
					$query = "select id from deviceTypes where name = 'Workstation';"
					$hostData.'@deviceTypeId' = [SQL]::Get( 'packages.dat' ).query( $query ).execOne()	
				}
				
				$compSys = gwmi Win32_ComputerSystem -computer $h
				$vendor = $compSys.Manufacturer
				$params = @{ '@Vendor' = $vendor; }
				$query = "select id from vendors where name = @Vendor;"
				$vid = [SQL]::Get( 'packages.dat' ).query( $query,$params ).execOne()
				
				if( [Utils]::IsBlank($vid) ){
					$query = "insert into vendors (name) Values (@Vendor)"
					[SQL]::Get( 'packages.dat' ).query( $query,$params ).execNonQuery()
					$query = "select id from vendors where name = @Vendor;"
					$vid = [SQL]::Get( 'packages.dat' ).query( $query,$params ).execOne()
				}
				$hostdata.'@vendorId' = $vid
				
				try{
				
				$remoteReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$h)
					If ($OS.OSArchitecture -eq '64-bit') {
						$value = $remoteReg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DigitalProductId4')
						$hostData.'@osKey' = [Utils]::decodeProductKey($value)
					} ElseIf($OS.OSArchitecture -eq '32-bit') {                        
						$value = $remoteReg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DigitalProductId')
						$hostData.'@osKey' = [Utils]::decodeProductKey($value)
					}else{
						$hostData.'@osKey' = ""
					}
				}catch{
					$hostData.'@osKey' = ""
				}
			}
			
			return ,$hostData
		}

		[void] reloadMetadata(){
			[GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItems | % {
				$assetId = $_.Id
				$metaData = $this.getMetaData($_.hostname)
				
				$query = @"
update 
		assets 
	set 
		hostname = @hostname, 
		ip = @ip, 
		model = @model, 
		firmware = @firmWare, 
		osKey = @osKey, 
		description = @description, 
		location = @location, 
		operatingSystemId = @operatingSystemId, 
		deviceTypeId = @deviceTypeId, 
		vendorId = @vendorId
	where
		id = @assetId
"@
				$params = @{
					'@ip' = $metaData.'@ip';
					'@hostname' = $metaData.'@hostname';
					'@model' = $metaData.'@model';
					'@firmware' = $metaData.'@firmware';
					'@osKey' = $metaData.'@osKey';
					'@description' = $metaData.'@description';
					'@location' = $metaData.'@location';
					'@operatingSystemId' = $metaData.'@operatingSystemId';
					'@deviceTypeId' = $metaData.'@deviceTypeId';
					'@vendorId' = $metaData.'@vendorId';
					'@assetId' = $assetId;
				}

				[SQL]::Get( 'packages.dat' ).query( $query, $params).execNonQuery()				
			}
			
			$global:csts.controllers.Packages.showHardware()
			[GUI]::Get().hideModal()
				
		}
		
		[void] importHosts(){
			$packageGuid = $global:csts.controllers.Packages.viewModel.pkgSelItem
			$hosts = $global:csts.libs.hosts.Get()
			$hosts.keys | sort | % {
				$ip = [Net]::getIp($_)
				$hostname = [Net]::getHostName($_)
				$ping = [Net]::Ping($hostname)
				
				$query = "select id from xPackagesAssets where packageId = @packageId and assetId in (select id from assets where hostname = @hostname) "
				$params = @{
					'@packageId' = $packageGuid;
					'@hostname' = $hostname;
				}
				
				$exists = [SQL]::Get( 'packages.dat').query( $query, $params).ExecOne()
				
				if($exists.length -eq 0){
					
					$metaData = $this.getMetaData($hostname)
					$query = "insert into assets (hostname, ip, model, firmware, osKey, description, location, operatingSystemId, deviceTypeId, vendorId) values ( @hostname, @ip, @model, @firmware, @osKey, @description, @location, @operatingSystemId, @deviceTypeId, @vendorId)"

					$params = @{
						'@ip' = $ip;
						'@hostname' = $hostname;
						'@model' = $metaData.'@model';
						'@firmware' = $metaData.'@firmware';
						'@osKey' = $metaData.'@osKey';
						'@description' = $metaData.'@description';
						'@location' = $metaData.'@location';
						'@operatingSystemId' = $metaData.'@operatingSystemId';
						'@deviceTypeId' = $metaData.'@deviceTypeId';
						'@vendorId' = $metaData.'@vendorId';
					}

					$assetRowid = [SQL]::Get( 'packages.dat' ).query( $query, $params).execNonQuery()
					
					$params=@{'@rowid' = $assetRowid}
					$assetGuid = [SQL]::Get( 'packages.dat').query( 'select id from assets where rowid = @rowid', $params).ExecOne()
					
					
					$params = @{'@packageId' = $packageGuid; '@assetId' = $assetGuid;}
					$query = "insert into xPackagesAssets (packageId, assetId) values (@packageId,@assetId)"
					[SQL]::Get( 'packages.dat').query( $query, $params).ExecNonQuery()
				}
			}
			
			$global:csts.controllers.Packages.showHardware()
		}

		
		[void] verifyDatabase(){
			$this.tables.keys | % {
				if(!$this.verifyTableExists($_)){
					[GUI]::Get().showModal('Creating Tables')
					$this.createTable($_)
				}
				if(!$this.verifyTablePopulated($_) -and $this.defaults.$($_) -ne $null){
					[GUI]::Get().showModal('Populating Tables')
					$this.populateTable($_)
				}
			}
			[GUI]::Get().hideModal()
		}
		
		
	}
}
Process{
	
}
End{
	
}