From - Thu Nov 11 15:27:24 1999
Received: from smtp.eecs.umich.edu (root@smtp.eecs.umich.edu [141.213.4.44])
	by cello.eecs.umich.edu (8.9.3/8.9.3/Debian/GNU) with ESMTP id NAA27886
	for <hernan@cello.eecs.umich.edu>; Thu, 11 Nov 1999 13:15:59 -0500
Received: from kidgalahad.rs.itd.umich.edu (kidgalahad.rs.itd.umich.edu [141.211.83.34])
	by smtp.eecs.umich.edu (8.9.3/8.9.3/Debian/GNU) with ESMTP id NAA15340;
	Thu, 11 Nov 1999 13:15:57 -0500
Received: (from daemon@localhost)
	by kidgalahad.rs.itd.umich.edu (8.9.3/3.0) with X.500 id NAA23400; Thu, 11 Nov 1999 13:15:40 -0500 (EST)
Received: (from daemon@localhost)
	by kidgalahad.rs.itd.umich.edu (8.9.3/3.0) with X.500 id NAA23364
	for fMRIgroup-members@umich.edu; Thu, 11 Nov 1999 13:15:36 -0500 (EST)
Received: from vivalasvegas.rs.itd.umich.edu (vivalasvegas.rs.itd.umich.edu [141.211.83.35])
	by kidgalahad.rs.itd.umich.edu (8.9.3/3.0) with ESMTP id NAA23352
	for <fmrigroup@umich.edu>; Thu, 11 Nov 1999 13:15:35 -0500 (EST)
Received: from umich.edu (ia-01.groupwise.med.umich.edu [141.214.2.28])
	by vivalasvegas.rs.itd.umich.edu (8.9.1/3.1r) with SMTP id NAA27449
	for <fmrigroup@umich.edu>; Thu, 11 Nov 1999 13:15:32 -0500 (EST)
Received: from ia-01-Message_Server by umich.edu
	with Novell_GroupWise; Thu, 11 Nov 1999 13:15:27 -0500
Message-Id: <s82ac16f.096@umich.edu>
X-Mailer: Novell GroupWise 5.2
Date: Thu, 11 Nov 1999 13:15:09 -0500
From: "Robert Welsh" <rcwelsh@umich.edu>
To: fmrigroup@umich.edu
Subject:  clone_hdr
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_D38ACDAF.F0916B32"
X-Mozilla-Status: 8001
X-Mozilla-Status2: 00000000
X-UIDL: 649e7583da2e337921c6dce5dfc26cce

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=_D38ACDAF.F0916B32
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline

Find the file clone_hdr attached.

Robert



--=_D38ACDAF.F0916B32
Content-Type: text/plain
Content-Disposition: attachment; filename="clone_hdr"

# Script to replicate a given header into many copies.
# This may be useful for mass producing spm-compatible
# headers until (or in lieu of) matlab-produced
# header script is complete.
# TLChenevert UMich; Oct 8, 1997.
echo "Basename of header to be cloned (eg. 's1_oct24_97_e1262s3r1', but no quotes)? "
#echo " "
set master = $<
echo "Lable of header to be cloned (eg. '001', but no quotes)? "
#echo " "
set mindx = $<
set us = '_'
#echo "Prefix for clones ? "
#echo -n " "
set clone = $master$us
echo -n "First Index Number for Clones (eg. '2', but no quotes)? ? "
echo -n " "
set indx = $<

echo -n "Last Index Number for Clones (eg. '100', but no quotes)? ? "
echo -n " "
set nlast = $<

@ z1 = 0
#@ indx = 1
while ( $indx <= $nlast )
	if ( ( $indx >= 1 ) && ($indx <= 9) ) then
#		cp $master:r.hdr $clone$z1$z1$indx:r.hdr
		cp $master$us$mindx:r.hdr $clone$z1$z1$indx:r.hdr
	endif
	if ( ($indx >= 10 ) && ($indx <= 99) ) then
		cp $master$us$mindx:r.hdr $clone$z1$indx:r.hdr
	endif
	if ( $indx >= 100 ) then	
		cp $master$us$mindx:r.hdr $clone$indx:r.hdr
	endif
@ indx++
end



--=_D38ACDAF.F0916B32--

