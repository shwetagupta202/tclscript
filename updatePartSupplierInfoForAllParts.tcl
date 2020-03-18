
tcl;
eval {
		set sLogFileName "updatePartSupplierInfoForParts_[clock format [clock seconds] -format %m-%d-%y].log"
        set fLogFile [open "$sLogFileName" w];          
       
		puts $fLogFile "*************************************Started for parts for IsSupplier*************************************"
        set sPartInfoOIDs [split [mql temp query bus "Part" * * where "from\[IsSupplier\].to.attribute\[Primary Key\]!=''" select id dump |] \n]
		puts $fLogFile " Found parts \['$sPartInfoOIDs'\]"		
            
        foreach sOID $sPartInfoOIDs {
			set partOID [lindex [split $sOID |] end] 
			puts $fLogFile "*************************************Started for partOID $partOID*************************************"
			set partSupplierAccess [mql print bus $partOID  select "attribute\[Supplier Access\]" dump];
			puts $fLogFile "partSupplierAccess $partSupplierAccess"
			set partSupplierAccessNew $partSupplierAccess;
			set lStruc [split [mql expand bus $partOID from relationship "IsSupplier"  select bus "attribute\[Primary Key\]" select rel "attribute\[GEHC_ASLDisabled\]" "attribute\[GEHC_ASLStatus\]" "attribute\[GEHC_ManuallyRestrictPart\]" dump |] \n]
            puts $fLogFile "lStruc $lStruc"
			foreach sLine $lStruc {
				puts $fLogFile "sLine $sLine"
				set sRelInfos [split $sLine |]
				set suppPrimaryKey [lindex $sRelInfos 6]
				puts $fLogFile "suppPrimaryKey $suppPrimaryKey"
                set aSLDisabled [lindex $sRelInfos 7]
				puts $fLogFile "aSLDisabled $aSLDisabled"
				set aSLStatus [lindex $sRelInfos 8]
				puts $fLogFile "aSLStatus $aSLStatus"
				set manuallyRestrictPart [lindex $sRelInfos 9]
				puts $fLogFile "manuallyRestrictPart $manuallyRestrictPart"
				if { $aSLDisabled != "Yes" && $aSLStatus == "Approved" && $manuallyRestrictPart != "Yes" } {
					puts $fLogFile "Yes"
					if { $partSupplierAccessNew == "" } {
						puts $fLogFile "Access Yes partSupplierAccessNew  $partSupplierAccessNew  "
						append partSupplierAccessNew  $suppPrimaryKey;
						puts $fLogFile "Updated Access Yes partSupplierAccessNew   $partSupplierAccessNew  "

						
					} else {
						puts $fLogFile "$suppPrimaryKey $partSupplierAccessNew"
						puts $fLogFile "[string first "$suppPrimaryKey" "$partSupplierAccessNew"]";
						if { [string first "$suppPrimaryKey" "$partSupplierAccessNew"] == -1 } {
							puts $fLogFile "Else Access Yes partSupplierAccessNew   $partSupplierAccessNew  "
							append partSupplierAccessNew "|" $suppPrimaryKey;
							puts $fLogFile "Updated Else Access Yes partSupplierAccessNew   $partSupplierAccessNew  "

						} 
					}
					
				}
				puts $fLogFile "partSupplierAccessNew $partSupplierAccessNew"	
				puts $fLogFile "partSupplierAccess $partSupplierAccess"	
            }
			if { $partSupplierAccessNew != $partSupplierAccess } {
				puts $fLogFile "Modifying Attribte 'Supplier Access' from $partSupplierAccess to $partSupplierAccessNew"
				mql mod bus $partOID  "Supplier Access" $partSupplierAccessNew;
				puts $fLogFile "Modified Attribte 'Supplier Access' from $partSupplierAccess to $partSupplierAccessNew"
			}
            puts $fLogFile "*************************************Ended for partOID $partOID*************************************"
			
        }
		puts $fLogFile "*************************************Ended for parts for IsSupplier*************************************"
		
        puts $fLogFile "**************************************Started for parts for RFQ*****************************************"
		set sPartInfoOIDs [split [mql temp query bus "Part" * * where "to\[Line Item Object\].from.to\[Line Item\].from.from\[RFQ Supplier\].to.attribute\[Primary Key\]!=''" select id dump |] \n]
		puts $fLogFile " Found parts \['$sPartInfoOIDs'\]"		
            
        foreach sOID $sPartInfoOIDs {
			set partOID [lindex [split $sOID |] end] 
			puts $fLogFile "*************************************Started for RFQ partOID $partOID*************************************"
			set partSupplierAccess [mql print bus $partOID  select "attribute\[Supplier Access\]" dump];
			puts $fLogFile "partSupplierAccess $partSupplierAccess"
			set partSupplierAccessNew $partSupplierAccess;
			set partSupplierIds [split [mql print bus $partOID  select "to\[Line Item Object\].from.to\[Line Item\].from.from\[RFQ Supplier\].to.attribute\[Primary Key\]" dump |] |];
			puts $fLogFile "partSupplierIds $partSupplierIds"
			foreach sLine $partSupplierIds {
				puts $fLogFile "sLine $sLine"
				if { $sLine != "" } {
					puts $fLogFile "Yes"
					if { $partSupplierAccessNew == "" } {
						puts $fLogFile "Blank 'Supplier Access' Yes"
						append partSupplierAccessNew  $sLine;
						puts $fLogFile "Updated Blank 'Supplier Access' Yes partSupplierAccessNew $partSupplierAccessNew  "

						
					} else {
					
						if { [string first "$sLine" "$partSupplierAccessNew"] == -1 } {
							puts $fLogFile "Non Blank 'Supplier Access' Yes"
							append partSupplierAccessNew "|" $sLine;
							puts $fLogFile "Updated Non Blank 'Supplier Access' Yes partSupplierAccessNew  $partSupplierAccessNew  "

						} 
					}
				
				}
				puts $fLogFile "partSupplierAccessNew $partSupplierAccessNew"	
				puts $fLogFile "partSupplierAccess $partSupplierAccess"	
            }
			if { $partSupplierAccessNew != $partSupplierAccess } {
				puts $fLogFile "Modifying Attribte 'Supplier Access' from $partSupplierAccess to $partSupplierAccessNew"
				mql mod bus $partOID  "Supplier Access" $partSupplierAccessNew;
				puts $fLogFile "Modified Attribte 'Supplier Access' from $partSupplierAccess to $partSupplierAccessNew"
			}
            puts $fLogFile "*************************************Ended for RFQ partOID $partOID*************************************"
			
        }
        puts $fLogFile "*************************************Ended for parts for RFQ*************************************"
        
		puts $fLogFile "*****"  
        close $fLogFile;
        
}

