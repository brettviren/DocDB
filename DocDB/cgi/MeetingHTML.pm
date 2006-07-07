#        Name: MeetingHTML.pm
# Description: HTML producing routines for meetings and conferences
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Stephen Wood (saw@jlab.org)

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub LocationBox (;%) {
  require "FormElements.pm";

  my (%Params) = @_;
  
  my $Default  = $Params{-default}   || "";
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<div class=\"LocationEntry\">\n";
  my $ElementTitle = &FormElementTitle(-helplink  => "location", 
                                       -helptext  => "Location",
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     
  print $query -> textfield (-name => 'location', -default => $Default,
                             -size => 40, -maxlength => 64, $Booleans);
  print "</div>\n";
};

sub EventURLBox (;%) {
  require "FormElements.pm";

  my (%Params) = @_;
  
  my $Default  = $Params{-default}   || "";
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<div class=\"EventURLEntry\">\n";
  my $ElementTitle = &FormElementTitle(-helplink  => "confurl", 
                                       -helptext  => "URL",
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     
  print $query -> textfield (-name => 'url', -default => $Default,
                             -size => 40, -maxlength => 240, $Booleans);
  print "</div>\n";
};

sub ConferencePreambleBox {
  require "FormElements.pm";
  my $ElementTitle = &FormElementTitle(-helplink  => "meetpreepi", 
                                       -helptext  => "Event Preamble");
  print $ElementTitle,"\n";                                     
  print $query -> textarea (-name => 'meetpreamble', -default => $MeetingDefaultPreamble,
                            -columns => 50, -rows => 7);
};

sub ConferenceEpilogueBox {
  require "FormElements.pm";
  my $ElementTitle = &FormElementTitle(-helplink  => "meetpreepi", 
                                       -helptext  => "Event Epilogue");
  print $ElementTitle,"\n";                                     
  print $query -> textarea (-name => 'meetepilogue', -default => $MeetingDefaultEpilogue,
                            -columns => 50, -rows => 7);
};

sub ConferenceShowAllTalks {
  require "FormElements.pm";
  print &FormElementTitle(-helplink  => "meetshowall", -helptext  => "Show All Talks?", -nobreak => $TRUE, -nocolon => $TRUE);
  if ($MeetingDefaultShowAllTalks) {
    print $query -> checkbox(-name => "meetshowall", -value => 1, -label => 'Yes', -checked => 'Yes');
  } else {
    print $query -> checkbox(-name => "meetshowall", -value => 1, -label => 'Yes');
  }
}

sub SessionEntryForm (%) {
  require "FormElements.pm";

  my %Params = @_;
 
  my $ConferenceID    =   $Params{-conferenceid}     || 0;
  my $OffsetDays      =   $Params{-offsetdays}       || 0;
  my @MeetingOrderIDs = @{$Params{-meetingorderids}};
  
  print "<table id=\"SessionEntry\" class=\"MedPaddedTable Alternating CenteredTable\">\n";
  print "<thead>\n";
  print "<tr><th colspan=\"4\">\n";
  print &FormElementTitle(-helplink  => "sessions", -helptext  => "Sessions", -nobreak => $TRUE, -nocolon => $TRUE);
  print "</th></tr>\n";

  print "<tr>\n";
   print "<th>",&FormElementTitle(-helplink  => "meetingorder", -helptext  => "Order", -nobreak => $TRUE, -nocolon => $TRUE),                          " or<br/>";
   print        &FormElementTitle(-helplink  => "sessiondelete", -helptext  => "Delete", -nobreak => $TRUE, -nocolon => $TRUE),                        "</th>\n";
   print "<th>",&FormElementTitle(-helplink  => "meetingseparator", -helptext  => "Break", -nobreak => $TRUE, -nocolon => $TRUE),                      "</th>\n";
   print "<th>",&FormElementTitle(-helplink  => "sessioninfo", -helptext  => "Session", -nobreak => $TRUE, -nocolon => $TRUE),                         "</th>\n";
   print "<th>",&FormElementTitle(-helplink  => "sessioninfo", -helptext  => "Location<br/>Start Date and Time", -nobreak => $TRUE, -nocolon => $TRUE),"</th>\n";
  print "</tr>\n";
  print "</thead>\n";
  
  # Sort session IDs by order
  
  my $ExtraSessions = $InitialSessions;

  for (my $Session=1;$Session<=$ExtraSessions;++$Session) {
    push @MeetingOrderIDs,"n$Session";
  }
  
  my $SessionOrder = 0;
  my $RowClass;
  foreach $MeetingOrderID (@MeetingOrderIDs) {
    ++$SessionOrder;
    if ($SessionOrder % 2) { 
      $RowClass = "Odd";
    } else {
      $RowClass = "Even";
    }    
    
    $SessionDefaultOrder = $SessionOrder;  
    if (grep /n/,$MeetingOrderID) {# Erase defaults
      if ($ConferenceID) {
        &FetchConferenceByConferenceID($ConferenceID);
        $SessionDefaultDateTime = $Conferences{$ConferenceID}{StartDate}." 9:00:00";
      } else {
        require "SQLUtilities.pm";
        $SessionDefaultDateTime = &SQLNow(-dateonly => $TRUE)." 9:00:00";
      }
      $SessionDefaultLocation    = "";
      $SessionDefaultTitle       = "";
      $SessionDefaultDescription = "";
      $SessionSeparatorDefault   = "";
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($MeetingOrders{$MeetingOrderID}{SessionID}) {
        my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
	$SessionDefaultDateTime    = $Sessions{$SessionID}{StartTime};
        $SessionDefaultLocation    = $Sessions{$SessionID}{Location}    || "";
	$SessionDefaultTitle       = $Sessions{$SessionID}{Title}       || "";
	$SessionDefaultDescription = $Sessions{$SessionID}{Description} || "";
	$SessionSeparatorDefault   = "No";
      } elsif ($MeetingOrders{$MeetingOrderID}{SessionSeparatorID}) {
        my $SessionSeparatorID = $MeetingOrders{$MeetingOrderID}{SessionSeparatorID};
	$SessionDefaultDateTime    = $SessionSeparators{$SessionSeparatorID}{StartTime};
        $SessionDefaultLocation    = $SessionSeparators{$SessionSeparatorID}{Location}    || "";
	$SessionDefaultTitle       = $SessionSeparators{$SessionSeparatorID}{Title}       || "";
	$SessionDefaultDescription = $SessionSeparators{$SessionSeparatorID}{Description} || "";
	$SessionSeparatorDefault   = "Yes";
      }
    } 
    if ($OffsetDays) {
      use DateTime;

      my ($StartDate,$StartTime) = split /\s+/,$SessionDefaultDateTime;
      my ($StartYear,$StartMonth,$StartDay) = split /-/,$StartDate;
      my $Start = DateTime -> new(year => $StartYear, month => $StartMonth, day => $StartDay);
      $Start -> add(days => $OffsetDays);
      $SessionDefaultDateTime = $Start -> ymd()." ".$StartTime;
    }  
        
    print "<tbody>\n";
    print "<tr class=\"$RowClass\">\n";

    print "<td rowspan=\"2\">";
    if ($OffsetDays) {  # We are copying, not modifiying the original
      $query -> param('meetingorderid',"n$SessionOrder"); #FIXME: Try to remove
      print $query -> hidden(-name => 'meetingorderid', -default => "n$SessionOrder");
    } else { 
      $query -> param('meetingorderid',$MeetingOrderID); #FIXME: Try to remove
      print $query -> hidden(-name => 'meetingorderid', -default => $MeetingOrderID);
    }
    &SessionOrder;                       print "<br/>\n";
    &SessionModifyLink($MeetingOrderID); print "<br/>\n";
    &SessionDelete($MeetingOrderID);   
    print "</td>\n";

    print "<td>\n"; &SessionSeparator($MeetingOrderID);  print "</td>\n";
    print "<td>\n"; &SessionTitle($SessionDefaultTitle); print "</td>\n";
    print "<td>\n"; &SessionLocation;                    print "</td>\n";

    print "</tr>\n";
    print "<tr class=\"$RowClass\">\n";

    print "<td>&nbsp;</td>\n";
    print "<td>\n";              &SessionDescription;                 print "</td>\n";
    print "<td>\n";    
    &DateTimePulldown(-name    => "session", -oneline => $TRUE, -onetime  => $TRUE, -granularity => 15,
                      -default => $SessionDefaultDateTime,      -required => $RequiredEntries{StartDate} );
    print "</td>\n";

    print "</tr>\n";
    print "</tbody>\n";
  }
  print "</table>\n";
}

sub SessionOrder {
  $query -> param('sessionorder',$SessionDefaultOrder);
  print $query -> textfield (-name => 'sessionorder', -value => $SessionDefaultOrder, 
                             -size => 4, -maxlength => 5);
}

sub SessionSeparator ($) {
  my ($MeetingOrderID) = @_;

  if ($SessionSeparatorDefault eq "Yes") {
    print "Yes\n";	      
  } elsif ($SessionSeparatorDefault eq "No") {
    print "No\n";	      
  } else {
    print $query -> checkbox(-name => "sessionseparator", -value => "$MeetingOrderID", -label => 'Break');
  }
}

sub SessionDelete ($) {
  my ($MeetingOrderID) = @_;
  if ($SessionSeparatorDefault eq "Yes" || $SessionSeparatorDefault eq "No") {
    print $query -> checkbox(-name => "sessiondelete", -value =>
    "$MeetingOrderID", -label => 'Delete');
  } else {
    print "&nbsp;\n";
  }
}

sub SessionModifyLink ($) {
  my ($MeetingOrderID) = @_;
  if ($SessionSeparatorDefault eq "No") {
    my $SessionID = $MeetingOrders{$MeetingOrderID}{SessionID};
    print "<a href=\"$SessionModify?sessionid=$SessionID\">Modify session<br/>agenda</a>\n";
  } else {
    print "&nbsp;\n";
  }
}

sub SessionTitle ($) {
  $query -> param('sessiontitle',$SessionDefaultTitle);
  print $query -> textfield (-name => 'sessiontitle', -size => 40, -maxlength => 128, 
                             -default => $SessionDefaultTitle);
}

sub SessionDescription {
  $query -> param('sessiondescription',$SessionDefaultDescription);
  print $query -> textarea (-name => 'sessiondescription',-value => $SessionDefaultDescription, 
                            -columns => 40, -rows => 3);
}

sub SessionLocation {
  $query -> param('sessionlocation',$SessionDefaultLocation);
  print $query -> textfield (-name => 'sessionlocation', -size => 30, -maxlength => 128, 
                             -default => $SessionDefaultLocation);
};

sub SessionLink (%) {
  my %Params = @_;
  
  my $SessionID   = $Params{-sessionid};
  my $Format      = $Params{-format}  || "short";
  my $ToolTipMode = $Params{-tooltip} || "Session";

  require "ResponseElements.pm";
  require "SQLUtilities.pm";

  my $URL = "$DisplayMeeting?sessionid=$SessionID";
  
  my $Text;
  my $ToolTip;
  if ($ToolTipMode eq "TimeAndLoc") {
    $ToolTip = EuroTimeHM($Sessions{$SessionID}{StartTime})." ".
               EuroDate($Sessions{$SessionID}{StartTime});
  } else {
    if ($Conferences{$Sessions{$SessionID}{ConferenceID}}{Title} eq $Sessions{$SessionID}{Title}) {
      $ToolTip = $Sessions{$SessionID}{Title};
    } else {  
      $ToolTip = $Conferences{$Sessions{$SessionID}{ConferenceID}}{Title}." - ".$Sessions{$SessionID}{Title};
    }
  }
  if ($Sessions{$SessionID}{Location}) {
    $ToolTip .= " - ".$Sessions{$SessionID}{Location};
  }  
  # Would like to use newlines instead of -. See mozilla bugs Bug 67127 and 45375
  
  if ($Format eq "full") {
    if ($Conferences{$Sessions{$SessionID}{ConferenceID}}{Title} && $Sessions{$SessionID}{Title} &&
        $Conferences{$Sessions{$SessionID}{ConferenceID}}{Title} ne $Sessions{$SessionID}{Title}) { 
      $Text = $Conferences{$Sessions{$SessionID}{ConferenceID}}{Title}.":".$Sessions{$SessionID}{Title};
    } else {
      $Text = $Conferences{$Sessions{$SessionID}{ConferenceID}}{Title};
    }  
  } else {
    if ($Text = $Sessions{$SessionID}{Title}) {
      $Text = $Sessions{$SessionID}{Title};
    } else {
      $Text = $Conferences{$Sessions{$SessionID}{ConferenceID}}{Title};
    }   
  }
  
  my $Link = "<a href=\"$URL\" title=\"$ToolTip\">$Text</a>";
  
  return $Link;
}   

sub SessionSeparatorLink ($) {
  my ($ArgRef) = @_;
  my $SessionSeparatorID = exists $ArgRef->{-sessionseparatorid} ? $ArgRef->{-sessionseparatorid} : 0;
  my $Format             = exists $ArgRef->{-short}              ? $ArgRef->{-short}              : "short";
  my $ToolTipMode        = exists $ArgRef->{-tooltip}            ? $ArgRef->{-tooltip}            : "Session";

  require "ResponseElements.pm";
  require "SQLUtilities.pm";

  my $URL = "$DisplayMeeting?sessionseparatorid=$SessionSeparatorID";
  
  my $Text;
  my $ToolTip;
  if ($ToolTipMode eq "TimeAndLoc") {
    $ToolTip = EuroTimeHM($SessionSeparators{$SessionSeparatorID}{StartTime})." ".
               EuroDate($SessionSeparators{$SessionSeparatorID}{StartTime});
  } else {
    $ToolTip = $Conferences{$SessionSeparators{$SessionSeparatorID}{ConferenceID}}{Title}
               ." - ".$SessionSeparators{$SessionSeparatorID}{Title};
  }
  if ($SessionSeparators{$SessionSeparatorID}{Location}) {
    $ToolTip .= " - ".$SessionSeparators{$SessionSeparatorID}{Location};
  }  

  # Would like to use newlines instead of -. See mozilla bugs Bug 67127 and 45375
  
  if ($Format eq "full") {
    $Text = $Conferences{$SessionSeparators{$SessionSeparatorID}{ConferenceID}}{Title}
            .":".$SessionSeparators{$SessionSeparatorID}{Title};
  } else {
    $Text = $SessionSeparators{$SessionSeparatorID}{Title};
  }
  
  my $Link = "<a href=\"$URL\" title=\"$ToolTip\">$Text</a>";
  
  return $Link;
}   

sub PrintSession (%) {
  my %Params = @_;
  
  my $SessionID  = $Params{-sessionid};
  my $SkipHeader = $Params{-skipheader} || $FALSE;

  require "Sorts.pm";
  require "TalkSQL.pm";
  require "TalkHintSQL.pm";
  require "TalkHTML.pm";
  require "SQLUtilities.pm";
  require "Utilities.pm";
  require "DocumentHTML.pm";
  require "DocumentUtilities.pm";
  
  unless ($SkipHeader) {
    PrintSessionHeader($SessionID);
  }
  
  my @SessionTalkIDs   = FetchSessionTalksBySessionID($SessionID);
  my @TalkSeparatorIDs = FetchTalkSeparatorsBySessionID($SessionID);
  my @SessionOrderIDs  = FetchSessionOrdersBySessionID($SessionID);
  my $EventID          = $Sessions{$SessionID}{ConferenceID};
  FetchConferenceByConferenceID($EventID);
  my $EventGroupID = $Conferences{$EventID}{EventGroupID};

  my ($AccumSec,$AccumMin,$AccumHour) = SQLDateTime($Sessions{$SessionID}{StartTime});
  my $AccumulatedTime = AddTime("$AccumHour:$AccumMin:$AccumSec","0:0:0");
    
# Sort talks and separators, build start time arrays

  @SessionOrderIDs = sort SessionOrderIDByOrder @SessionOrderIDs;
  foreach my $SessionOrderID (@SessionOrderIDs) {
    $SessionOrders{$SessionOrderID}{StartTime} = $AccumulatedTime;
    if ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) { # TalkSeparator
      my $TalkSeparatorID =  $SessionOrders{$SessionOrderID}{TalkSeparatorID};
      $AccumulatedTime = AddTime($AccumulatedTime,$TalkSeparators{$TalkSeparatorID}{Time});
    } elsif ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
      my $SessionTalkID =  $SessionOrders{$SessionOrderID}{SessionTalkID};
      $AccumulatedTime = AddTime($AccumulatedTime,$SessionTalks{$SessionTalkID}{Time});
    }
  }

  if (@SessionOrderIDs) {
    my %FieldListOptions = (-default => "Event Agenda", -eventid => $EventID, -eventgroupid => $EventGroupID);
    my %FieldList = PrepareFieldList(%FieldListOptions);
    DocumentTable(-sessionorderids => \@SessionOrderIDs, -fieldlist => \%FieldList);
  } else {
    print "<h4>No talks in agenda</h4>\n";
  }  
  print "<hr/>\n"; 
}

sub PrintSessionSeparator ($) {
  my ($SessionSeparatorID) = @_;
  
  require "SQLUtilities.pm";
  
  print "<table class=\"MedPaddedTable CenteredTable\"><tr>\n";
  print "<td><div><dl><dt><b>$SessionSeparators{$SessionSeparatorID}{Title}</b></dt>\n";
  print "<dd>",&EuroDate($SessionSeparators{$SessionSeparatorID}{StartTime});
  print " at ";
  print &EuroTimeHM($SessionSeparators{$SessionSeparatorID}{StartTime});
  print "</dd></dl></div></td> \n";
  if ($SessionSeparators{$SessionSeparatorID}{Location}) {
    print "<td><div><dl><dt><b>Location:</b></dt><dd>$SessionSeparators{$SessionSeparatorID}{Location}</dd></dl></div></td>\n";
  }
  if ($SessionSeparators{$SessionSeparatorID}{Description}) {
    print "<td><div><dl><dt><b>Description:</b></dt><dd>$SessionSeparators{$SessionSeparatorID}{Description}</dd></dl></div></td>\n";
  }
  print "</tr></table>\n";
  print "<hr/>\n";   
}

sub PrintSessionHeader ($) {
  my ($SessionID) = @_;

  require "SQLUtilities.pm";
  require "Utilities.pm";

  my $ConferenceID = $Sessions{$SessionID}{ConferenceID};

  print "<h4><a name=\"sess$SessionID\" />Session: ".
        "<a href=\"$DisplayMeeting?sessionid=$SessionID\">$Sessions{$SessionID}{Title}</a> begins \n";
  print &EuroDate($Sessions{$SessionID}{StartTime});
  print " at ";
  print &EuroTimeHM($Sessions{$SessionID}{StartTime});
  print "</h4>\n";
  if ($Sessions{$SessionID}{Location}) {
    print "<h5>Location: $Sessions{$SessionID}{Location}</h5>\n";
  }
  
  if (CanCreate() || CanModifyMeeting($ConferenceID)) {
    print "<table class=\"CenteredTable LowPaddedTable\"><tr>\n";
    if (CanCreate()) {
      print "<th>\n";
      TalkUploadButton(-sessionid => $SessionID);
      print "</th>\n";
    }
    if (CanModifyMeeting($ConferenceID)) {
      print "<th>\n";
      SessionModifyButton(-sessionid => $SessionID);
      print "</th>\n";
    }
    print "</tr></table>\n";
  }
  
  if ($Sessions{$SessionID}{Description}) {
    my $Description = AddLineBreaks($Sessions{$SessionID}{Description});
    print "<div class=\"SessionDescription\"> ",URLify($Description),"</div>\n";
  }
}

sub PrintEventLeftSidebar ($) {
  my ($ArgRef) = @_;
  my $EventID     = exists $ArgRef->{-eventid}     ? $ArgRef->{-eventid}     : 0;
  my $SessionID   = exists $ArgRef->{-sessionid}   ? $ArgRef->{-sessionid}   : 0;
#  my $SeparatorID = exists $ArgRef->{-separatorid} ? $ArgRef->{-separatorid} : 0;
  my $DisplayMode = exists $ArgRef->{-displaymode} ? $ArgRef->{-displaymode} : "";
  
  print "<div id=\"UpdateButtons\">\n";
  
  if ((CanCreate()) || CanModifyMeeting($EventID)) {
    if (CanCreate()) {
      if ($DisplayMode eq "SingleSession" || $DisplayMode eq "Session") {
        print "<p/>\n";
        TalkUploadButton(-sessionid => $SessionID);
      } elsif  ($DisplayMode eq "Event"){
        print "<p/>\n";
        TalkUploadButton(-eventid => $EventID);
      } 
    }
    if (CanModifyMeeting($EventID)) {
      if ($DisplayMode eq "SingleSession") { 
        print "<p/>\n";
        SessionModifyButton(-eventid => $EventID,     -buttontext => "Modify Agenda");
      } elsif ($DisplayMode eq "Session") {
        print "<p/>\n";
        SessionModifyButton(-sessionid => $SessionID, -buttontext => "Modify Session");
      }

      print "<p/>\n";
      if ($DisplayMode eq "SingleSession") { 
        EventModifyButton(-eventid => $EventID, -buttontext => "Add Sessions");
      } else {
        EventModifyButton(-eventid => $EventID, -buttontext => "Modify Event");
      }
      print "<p/>\n";
      EventCopyButton(-eventid => $EventID);
    }
  }
  
  unless ($DisplayMode eq "Separator") { 
    print "<p/>\n";
    EventDisplayButton( {-eventid => $EventID} );
  }
   
  print "<p><a href=\"$ListBy?eventid=$EventID\">Simple document list</a></p>\n";

  print "</div>\n"; # UpdateButtons
}

sub PrintEventRightSidebar ($) {
  my ($ArgRef) = @_;
  my $EventID     = exists $ArgRef->{-eventid}     ? $ArgRef->{-eventid}     : 0;
  my $SessionID   = exists $ArgRef->{-sessionid}   ? $ArgRef->{-sessionid}   : 0;
  my $SeparatorID = exists $ArgRef->{-separatorid} ? $ArgRef->{-separatorid} : 0;
  my $DisplayMode = exists $ArgRef->{-displaymode} ? $ArgRef->{-displaymode} : "";

  my $EventGroupID   = $Conferences{$EventID}{EventGroupID};
  my $EventGroupLink = EventGroupLink(-eventgroupid => $EventGroupID, -format => "short");

  print '<ul class="compact">';  
  print "<li>$EventGroupLink";
    
### Get and sort other events in this group
    
  my @EventIDs = FetchEventsByGroup($EventGroupID);
  foreach my $OtherEventID (@EventIDs) {
    FetchConferenceByConferenceID($OtherEventID);
  }
  my @EventIDs = sort EventsByDate @EventIDs;

  my $EventIndex = IndexOf($EventID,@EventIDs);

### Display list of other events in group    
   
  my $ForeDots = $FALSE; 
  my $AftDots  = $FALSE; 
  my $Index    = 0; 
  print '<ul class="compact">';  
  foreach my $OtherEventID (@EventIDs) {
    if ($EventID == $OtherEventID) {
    
      if ($DisplayMode eq "SingleSession" || $DisplayMode eq "Event") { 
        print "<li><strong>",$Conferences{$EventID}{Title},"</strong>\n";
      } else {
        print "<li>",EventLink(-eventid => $OtherEventID, -tooltip => "Date"),"\n";
      } 
### Find and print links to sessions      

      if ($DisplayMode ne "SingleSession") { 
        my @MeetingOrderIDs = FetchMeetingOrdersByConferenceID($EventID);
        @MeetingOrderIDs = sort MeetingOrderIDByOrder @MeetingOrderIDs; 
        print '<ul class="compact">';  
        foreach $MeetingOrderID (@MeetingOrderIDs) { # Loop over sessions/breaks
          my $OtherSessionID   = $MeetingOrders{$MeetingOrderID}{SessionID};
          my $OtherSeparatorID = $MeetingOrders{$MeetingOrderID}{SessionSeparatorID};
          if ($OtherSessionID) {
            if ($OtherSessionID == $SessionID) {
              print "<li><strong>",$Sessions{$SessionID}{Title},"</strong></li>\n";
            } else {              
              FetchSessionByID($OtherSessionID);
              my $Link = SessionLink(-sessionid => $OtherSessionID, 
                                     -tooltip   => "TimeAndLoc",);
              print "<li>",$Link,"</li>\n";
            }  
          } elsif ($OtherSeparatorID) {
            if ($OtherSeparatorID == $SeparatorID) {
              print "<li><strong>",$SessionSeparators{$SeparatorID}{Title},"</strong></li>\n";
            } else {              
              FetchSessionSeparatorByID($OtherSeparatorID);
              my $Link = SessionSeparatorLink({-sessionseparatorid => $OtherSeparatorID,
                                               -tooltip            => "TimeAndLoc", });
              print "<li>",$Link,"</li>\n";
            }  
          } 
        }
        print "</ul>";
      }
         
      print "</li>\n";
    } elsif (defined $EventIndex && $EventIndex-$Index > 2 && !$ForeDots) {
      $ForeDots = $TRUE;
      print "<li>....</li>\n";
    } elsif (defined $EventIndex && $Index-$EventIndex > 2 && !$AftDots) {
      $AftDots = $TRUE;
      print "<li>....</li>\n";
      last;
    } elsif (abs($Index-$EventIndex) <= 2) {
      print "<li>",EventLink(-eventid => $OtherEventID),"</li>\n";
    }
    ++$Index;
  }
  print "</ul></li></ul>\n";
  
}

sub PrintEventHeader ($) {
  my ($ArgRef) = @_;
  my $EventID     = exists $ArgRef->{-eventid}     ? $ArgRef->{-eventid}     : 0;
  my $SessionID   = exists $ArgRef->{-sessionid}   ? $ArgRef->{-sessionid}   : 0;
  my $SeparatorID = exists $ArgRef->{-separatorid} ? $ArgRef->{-separatorid} : 0;
  my $DisplayMode = exists $ArgRef->{-displaymode} ? $ArgRef->{-displaymode} : "";
 
  require "SQLUtilities.pm";
  require "Utilities.pm";
   
  my $SessionTitle       = $Sessions{$SessionID}{Title};
  my $EventTitle         = $Conferences{$EventID}{LongDescription};
  my $SessionStartTime   = $Sessions{$SessionID}{StartTime};
  my $SeparatorStartTime = $SessionSeparators{$SeparatorID}{StartTime};

  my %SkipFields   = ();
  my %RenameFields = ();
  my %Fields       = ();
  my @Fields       = ();
    
  if ($DisplayMode eq "SingleSession") {
    %SkipFields   = ( "Event Dates"  => $TRUE, "Event Location" => $TRUE,);
    %RenameFields = ( "Session Info" => "Event Info",);
  }
  if ($DisplayMode eq "Session" || $DisplayMode eq "Separator") {
    %SkipFields   = ( "Event Info"  => $TRUE, "Event URL" => $TRUE, "Event Wrapup" => $TRUE,);
  }
  
  if ($DisplayMode eq "Session" || $DisplayMode eq "Separator") {
    push @Fields,"Event";
    $Fields{"Event"} = $EventTitle;
  } else {
    push @Fields,"Full Title";
    $Fields{"Full Title"} = $EventTitle;
  }
  
  if ($Conferences{$EventID}{StartDate}) {
    push @Fields,"Event Dates";
    if ($Conferences{$EventID}{StartDate} ne $Conferences{$EventID}{EndDate}) {
      $Fields{"Event Dates"} = EuroDate($Conferences{$EventID}{StartDate}).
                        " to ".EuroDate($Conferences{$EventID}{EndDate});
    } else {
      $Fields{"Event Dates"} = EuroDate($Conferences{$EventID}{StartDate});
    }
  }  

  if ($Conferences{$EventID}{Location}) {
    push @Fields,"Event Location";
    $Fields{"Event Location"} = $Conferences{$EventID}{Location};
  }  

  if ($SessionStartTime) {
    push @Fields,"Date &amp; Time";
    $Fields{"Date &amp; Time"} = EuroDate($SessionStartTime)." at ".EuroTimeHM($SessionStartTime);
  }  

  if ($SeparatorStartTime) {
    push @Fields,"Date &amp; Time";
    $Fields{"Date &amp; Time"} = EuroDate($SeparatorStartTime)." at ".EuroTimeHM($SeparatorStartTime);
  }  

  if ($Sessions{$SessionID}{Location}) {
    push @Fields,"Location";
    $Fields{"Location"} = $Sessions{$SessionID}{Location};
  }
  
  if ($Conferences{$EventID}{URL}) {
    push @Fields,"Event URL";
    $Fields{"Event URL"} = "<a href=\"$Conferences{$EventID}{URL}\">$Conferences{$EventID}{Title}</a>";
  }
  
  if ($Conferences{$EventID}{Preamble}) {
    push @Fields,"Event Info";
    $Fields{"Event Info"} = Paragraphize($Conferences{$EventID}{Preamble});
  }

  if ($Conferences{$EventID}{Epilogue} && $SeparatorID) {
    push @Fields,"Event Wrapup";
    $Fields{"Event Wrapup"} = Paragraphize($Conferences{$EventID}{Epilogue});
  }

  if ($Sessions{$SessionID}{Description}) {
    push @Fields,"Session Info";
    $Fields{"Session Info"} = URLify(AddLineBreaks($Sessions{$SessionID}{Description}));
  }

  if ($SessionSeparators{$SeparatorID}{Description}) {
    push @Fields,"Session Info";
    $Fields{"Session Info"} = URLify(AddLineBreaks($SessionSeparators{$SeparatorID}{Description}));
  }

  if (@Fields) {
    print '<table class="LeftHeader Alternating CenteredTable MedPaddedTable" id="EventSummary">';
    my $Row = 0;
    foreach my $Field (@Fields) {
      if ($SkipFields{$Field}) {next;}
      ++$Row; 
      my $RowClass = ("Even","Odd")[$Row % 2];
      print "<tr class=\"$RowClass\">\n";
      my $Text = $Fields{$Field};
      if ($RenameFields{$Field}) {
        $Field = $RenameFields{$Field};
      }  
      print "<th>$Field:</th>\n";
      print "<td>$Text</td>\n";
      print "</tr>";
    }
    print "</table>\n";
  }

}

sub PrintMeetingEpilogue($) {

  require "Utilities.pm";
  my ($ConferenceID) = @_;

  if ($Conferences{$ConferenceID}{Epilogue}) {
    print '<table class="MedPaddedTable LeftHeader CenteredTable Alternating" id="EventEpilogue">';
    print '<tr class="Odd"><th>Event Wrapup:</th>';
    print "<td>\n";
    print URLify(AddLineBreaks($Conferences{$ConferenceID}{Epilogue}));
    print "</td></tr></table>\n";
  }
}

sub PrintSessionInfo ($) {
  my ($SessionID) = @_;
  
  require "TalkSQL.pm";
  require "SQLUtilities.pm";
  
  FetchSessionByID($SessionID);
 
  # DocumentList puts a class on every cell, this only on Date
 
  print "<td><a href=\"$DisplayMeeting?sessionid=$SessionID\">";
  print      "$Sessions{$SessionID}{Title}</a></td>\n";
  print "<td class=\"Date\">",&EuroDateHM($Sessions{$SessionID}{StartTime}),"</td>\n";
  print "<td>",$Sessions{$SessionID}{Description}           ,"</td>\n";
  print "<td>",$Sessions{$SessionID}{Location}              ,"</td>\n";
}

sub PrintSessionSeparatorInfo ($) {
  my ($SessionSeparatorID) = @_;
  
  require "TalkSQL.pm";
  require "SQLUtilities.pm";
  
  FetchSessionSeparatorByID($SessionSeparatorID);
  my $Link = SessionSeparatorLink( {-sessionseparatorid => $SessionSeparatorID} );

  # DocumentList puts a class on every cell, this only on Date
 
  print "<td>$Link</td>\n";
  print "<td class=\"Date\">",EuroDateHM($SessionSeparators{$SessionSeparatorID}{StartTime}),"</td>\n";
  print "<td>",$SessionSeparators{$SessionSeparatorID}{Description},"</td>\n";
  print "<td>",$SessionSeparators{$SessionSeparatorID}{Location},"</td>\n";
}

sub EventGroupLink (%) {
  my %Params = @_;
  my $EventGroupID = $Params{-eventgroupid} || 0;
  my $Format       = $Params{-format}       || "long";
  
  require "MeetingSQL.pm";

  FetchEventGroup($EventGroupID);
  
  my $Link = "<a href=\"";
  $Link .= $ListAllMeetings."?eventgroupid=".$EventGroupID;
  $Link .= "\">";
  if ($Format eq "short")  {
    $Link .= $EventGroups{$EventGroupID}{ShortDescription};
  } else {
    $Link .= $EventGroups{$EventGroupID}{LongDescription};
  }  
  $Link .= "</a>";
  return $Link;
}

sub EventLink (%) {
  my %Params = @_;
  my $EventID     = $Params{-eventid} || 0;
  my $Format      = $Params{-format}  || "short";
  my $LinkTo      = $Params{-linkto}  || "agenda";
  my $Class       = $Params{-class}   || "Event";
  my $ToolTipMode = $Params{-tooltip} || "Full";
  
  require "MeetingSecurityUtilities.pm";
  require "EventUtilities.pm";
  require "MeetingSQL.pm";
  
  FetchConferenceByConferenceID($EventID);
  unless (CanAccessMeeting($EventID)) {
    return "";
  }  

  my $URL;
  if ($LinkTo eq "listby" || SessionCountByEventID($EventID) == 0) {
    $URL = "$ListBy?eventid=$EventID&amp;mode=conference";
  } else {  
    $URL = "$DisplayMeeting?conferenceid=$EventID";
  }  
  
  my $ToolTip;
  if ($ToolTipMode eq "Date") {
    $ToolTip = $Conferences{$EventID}{StartDate};
  } else {
    $ToolTip = $Conferences{$EventID}{Full};
  }
  push @DebugStack,$ToolTipMode;
  my $Link  = "<a href=\"$URL\" class=\"$Class\" title=\"$ToolTip\">";
  if ($Format eq "long") {
    $Link .= $Conferences{$EventID}{LongDescription};
  } else {  
    $Link .= $Conferences{$EventID}{Title};
  }  
  $Link .= "</a>";
        
  return $Link;
}

sub ModifyEventLink ($) {
  require "EventUtilities.pm";
  require "MeetingSecurityUtilities.pm";
 
  my ($EventID) = @_;
    
  FetchConferenceByConferenceID($EventID);
  unless (CanAccessMeeting($EventID)) { # May want CanModifyMeeting
    return "";
  }  

  my $URL;
  
  if (SessionCountByEventID($EventID) == 1) {
    $URL = "$SessionModify?eventid=$EventID&amp;singlesession=1";
  } else {  
    $URL = "$MeetingModify?conferenceid=$EventID";
  }
  
  my $Title = $Conferences{$EventID}{Title};
  my $ToolTip = $Conferences{$EventID}{Full};
  
  my $Link  = "<a href=\"$URL\">";
     $Link .= $Title;
     $Link .= "</a>";
        
  return $Link;
}

sub EventsTable {
  require "Sorts.pm";

  my ($ArgRef) = @_;
  my $Mode        = exists $ArgRef->{-mode}        ? $ArgRef->{-mode}        : "display";
  my $MaxPerGroup = exists $ArgRef->{-maxpergroup} ? $ArgRef->{-maxpergroup} : 8;
  
  my $NCols = 2;
  my $Col   = 0;
  my $Row   = 0;
  my @EventGroupIDs = sort EventGroupsByName &GetAllEventGroups();
  
  print "<table class=\"HighPaddedTable\">\n";
  foreach my $EventGroupID (@EventGroupIDs) {
    unless ($Col % $NCols) {
      if ($Row) {
        print "</tr>\n";
      }  
      print "<tr>\n";
      ++$Row;
    }
    print "<td>\n";
    EventsByGroup( {-groupid => $EventGroupID, -mode => $Mode, -maxevents => $MaxPerGroup} );
    print "</td>\n";
    ++$Col;
  }  
  print "</tr>\n";
  print "</table>\n";
}

sub EventsByGroup (%) {
  require "Sorts.pm";
  require "ResponseElements.pm";
  
  my ($ArgRef) = @_;
  my $EventGroupID =        $ArgRef->{-groupid};
  my $Mode         = exists $ArgRef->{-mode}        ? $ArgRef->{-mode}        : "display";
  my $MaxEvents    = exists $ArgRef->{-maxevents}   ? $ArgRef->{-maxevents}   : 0;
  my $SingleGroup  = exists $ArgRef->{-singlegroup} ? $ArgRef->{-singlegroup} : $FALSE;

  my @EventIDs = keys %Conferences;
  my @DisplayEventIDs = ();
  foreach my $EventID (@EventIDs) {
    if ($Conferences{$EventID}{EventGroupID} == $EventGroupID) { 
      push @DisplayEventIDs,$EventID;
    }  
  }

  @DisplayEventIDs = reverse sort EventsByDate @DisplayEventIDs;
  FetchEventGroup($EventGroupID);

  my $TableClass = "LowPaddedTable";
  my ($Big,$EBig);
  if ($SingleGroup) {
    ($Big,$EBig) = ("<big>","</big>");
    $TableClass .= " CenteredTable";
  }  
  print "<table class=\"$TableClass\">";
  print "<tr><td colspan=\"4\">\n";
   
  if ($Mode eq "display") {
    print "<strong>$Big<a href=\"$ListBy?eventgroupid=$EventGroupID\">$EventGroups{$EventGroupID}{ShortDescription}</a>$EBig</strong>\n";
  } else {
    print "<strong>$Big$EventGroups{$EventGroupID}{ShortDescription}$EBig</strong>\n";
  }
  print "</td></tr>\n";
  my $EventCount = 0;
  my $Truncated = $FALSE;
  foreach my $EventID (@DisplayEventIDs) {
    my $MeetingLink;
    if ($Mode eq "modify") {
      $MeetingLink = ModifyEventLink($EventID);
    } else {
      $MeetingLink = EventLink(-eventid => $EventID);
    }
    unless ($MeetingLink) {
      next;
    }  
    
    ++$EventCount;
    print "<tr>\n";
    if ($EventCount > $MaxEvents && $MaxEvents) { # Put ...show all... at bottom
      $Truncated = $TRUE;
      print '<th colspan="2">';
      if ($Mode eq "display") {
        print "<a href=\"$ListAllMeetings?eventgroupid=$EventGroupID\">...more events and information...</a>\n"; 
      } else {
        print "<a href=\"$ListAllMeetings?eventgroupid=$EventGroupID&amp;mode=modify\">...more events and information...</a>\n"; 
      }
      print "</th>";
      last;
    } else { # Print normal entry
      print "<td>$MeetingLink</td>\n";
      print "<td>",EuroDate($Conferences{$EventID}{StartDate}),"</td>\n";

      if ($SingleGroup) { # Add end date and location for singe group display
        if ($Conferences{$EventID}{StartDate} ne $Conferences{$EventID}{EndDate}) {
          print "<td>-</td><td>".EuroDate($Conferences{$EventID}{EndDate})."</td>\n";
        } else {
          print "<td></td><td></td>\n";
        }
        print "<td>",$Conferences{$EventID}{Location},"</td>";
      }  
    }
    print "</tr>\n";
    
    # Put more info at bottom if not there already
    
  }  
  if (!$Truncated && !$SingleGroup) {
    print '<tr><th colspan="2">';
    if ($Mode eq "display") {
      print "<a href=\"$ListAllMeetings?eventgroupid=$EventGroupID\">...more information...</a>\n"; 
    } else {
      print "<a href=\"$ListAllMeetings?eventgroupid=$EventGroupID&amp;mode=modify\">...more information...</a>\n"; 
    }
    print "</th></tr>";
  }
  print "</table>\n";
}
 
sub EventGroupSelect ($) {
  my ($ArgRef) = @_;

  my $Disabled = exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : "0";
  my $Format   = exists $ArgRef->{-format}   ?   $ArgRef->{-format}   : "short";
  my $HelpLink = exists $ArgRef->{-helplink} ?   $ArgRef->{-helplink} : "eventgroups";
  my $HelpText = exists $ArgRef->{-helptext} ?   $ArgRef->{-helptext} : "Event Groups";           
  my $Multiple = exists $ArgRef->{-multiple} ?   $ArgRef->{-multiple} : "0";
  my $Name     = exists $ArgRef->{-name}     ?   $ArgRef->{-name}     : "eventgroups";
  my $OnChange = exists $ArgRef->{-onchange} ?   $ArgRef->{-onchange} : undef;
  my $Required = exists $ArgRef->{-required} ?   $ArgRef->{-required} :  "0";
  my @Defaults = exists $ArgRef->{-default}  ? @{$ArgRef->{-default}} : ();

  require "FormElements.pm";
  require "MeetingSQL.pm";
  require "Sorts.pm";
 
  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  
  if ($OnChange) {
    $Options{-onchange} = $OnChange;
  }  

  GetAllEventGroups(); 
  my @EventGroupIDs = sort EventGroupsByName keys %EventGroups;
  my %Labels        = ();
  foreach my $EventGroupID (@EventGroupIDs) {
    if ($Format eq "full") {
      $Labels{$EventGroupID} = $EventGroups{$EventGroupID}{ShortDescription}.
      ":".$EventGroups{$EventGroupID}{LongDescription}; 
    } else {  
      $Labels{$EventGroupID} = $EventGroups{$EventGroupID}{ShortDescription}; 
    }
  }      
  
  print FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText, -required => $Required);
  print $query -> scrolling_list(-name     => $Name,     -values  => \@EventGroupIDs, 
                                 -labels   => \%Labels,  -size    => 10, 
                                 -multiple => $Multiple, -default => \@Defaults,
                                 %Options);
}

sub EventSelect ($) {
  my ($ArgRef) = @_;

  my $Disabled =  exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : "0";
  my $Format   =  exists $ArgRef->{-format}   ?   $ArgRef->{-format}   : "full";
  my $HelpLink =  exists $ArgRef->{-helplink} ?   $ArgRef->{-helplink} : "events";
  my $HelpText =  exists $ArgRef->{-helptext} ?   $ArgRef->{-helptext} : "Events";           
  my $Multiple =  exists $ArgRef->{-multiple} ?   $ArgRef->{-multiple} : "0";
  my $Name     =  exists $ArgRef->{-name}     ?   $ArgRef->{-name}     : "events";
  my @Defaults =  exists $ArgRef->{-default}  ? @{$ArgRef->{-default}} : ();
  
  require "FormElements.pm";
  require "MeetingSQL.pm";
  require "Sorts.pm";

  my $Booleans = ""; # FIXME: Does not scale, use %Options
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  

  GetConferences(); 
  GetAllEventGroups(); 

  my @ConferenceIDs = reverse sort EventsByDate keys %Conferences;
  my %Labels        = ();
  foreach my $ConferenceID (@ConferenceIDs) {
    if ($Format eq "full") {
      $Labels{$ConferenceID} = $EventGroups{$Conferences{$ConferenceID}{EventGroupID}}{ShortDescription}.":".
                               $Conferences{$ConferenceID}{Title} .
                               " (".EuroDate($Conferences{$ConferenceID}{StartDate}).")"; 
    }
  }      
  
  print FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText);
  print $query -> scrolling_list(-name     => $Name,     -values  => \@ConferenceIDs, 
                                 -labels   => \%Labels,  -size    => 10, 
                                 -multiple => $Multiple, -default => \@Defaults,
                                 $Booleans);
}

sub TalkUploadButton (%) {
  my %Params = @_;

  my $EventID   = $Params{-eventid}; 
  my $SessionID = $Params{-sessionid}; 

  print $query -> startform('POST',$DocumentAddForm),"<div>\n";
  print $query -> submit (-value => "Upload Document");
  if ($EventID) {
    print $query -> hidden(-name => 'conferenceid', -default => $EventID);
  } elsif ($SessionID) {
    print $query -> hidden(-name => 'sessionid',    -default => $SessionID);
  }    
  print "\n</div>\n",$query -> endform,"\n";
}

sub SessionModifyButton (%) {
  my %Params = @_;

  my $EventID    = $Params{-eventid}; 
  my $SessionID  = $Params{-sessionid}; 
  my $LabelText  = $Params{-labeltext}  || ""; 
  my $ButtonText = $Params{-buttontext} || "Modify"; 

  print $query -> startform('POST',$SessionModify),"<div>\n";
  print $query -> submit (-value => $ButtonText);
  print $LabelText;
  if ($EventID) {
    print $query -> hidden(-name => 'eventid',    -default => $EventID);
    print $query -> hidden(-name => 'singlesession',    -default => 1);
  } elsif ($SessionID) {
    print $query -> hidden(-name => 'sessionid',    -default => $SessionID);
  }    
  print "\n</div>\n",$query -> endform,"\n";
}

sub EventModifyButton (%) {
  my %Params = @_;

  my $EventID    = $Params{-eventid}; 
  my $ButtonText = $Params{-buttontext} || "Modify agenda"; 
  my $LabelText  = $Params{-labeltext}  || ""; 

  print $query -> startform('POST',$MeetingModify),"<div>\n";
  print $query -> submit (-value => $ButtonText);
  print $LabelText; 
  print $query -> hidden(-name => 'conferenceid',    -default => $EventID);
  print "\n</div>\n",$query -> endform,"\n";
}

sub EventCopyButton (%) {
  my %Params = @_;

  my $EventID    = $Params{-eventid}; 
  
  my @Offsets = (1,2,3,4,5,6,7,14,21,28,35,42,49,56,63,70);
  my %Labels  = (1  => "1 day",    2 => "2 days",   3 => "3 days",
                 4  => "4 days",   5 => "5 days",   6 => "6 days",
                 7  => "1 week",  14 => "2 weeks", 21 => "3 weeks",
                 28 => "4 weeks", 35 => "5 weeks", 42 => "6 weeks",
                 49 => "7 weeks", 56 => "8 weeks", 63 => "9 weeks",
                 70 => "10 weeks");

  print $query -> startform('POST',$MeetingModify),"<div>\n";
  print $query -> hidden(-name => "mode",         -default => "copy");
  print $query -> hidden(-name => "conferenceid", -default => $EventID);
  print $query -> submit (-value => "Schedule Similar");
  print "<br/> in "; 
  print $query -> popup_menu(-name => "offsetdays", -values => \@Offsets, -labels => \%Labels, -default => 7);
  print "\n</div>\n",$query -> endform,"\n";
}

sub EventDisplayButton ($) {
  my ($ArgRef) = @_;
  
  my $EventID = exists $ArgRef->{-eventid} ? $ArgRef->{-eventid} : 0;
  print $query -> startform('POST',$CustomListForm),"<div>\n";
  print $query -> hidden(-name => "eventid", -default => $EventID);
  print $query -> submit (-value => "Change Display");
  print "\n</div>\n",$query -> endform,"\n";
}

1;
