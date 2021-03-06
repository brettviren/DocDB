#
# Description: Routines to deal with cookies
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:
#

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub GetPrefsCookie {

  # FIXME: Move to using UserPreferences directly as possible.

  $UploadTypePref   = $query -> cookie('archive');
  $NumFilesPref     = $query -> cookie('numfile');
  $UploadMethodPref = $query -> cookie('upload');
  $TopicModePref    = $query -> cookie('topicmode');
  $AuthorModePref   = $query -> cookie('authormode');
  $DateOverridePref = $query -> cookie('overdate');

  $UserPreferences{AuthorID}     = $query -> cookie('userid');
  $UserPreferences{UploadType}   = $UploadTypePref  ;
  $UserPreferences{NumFiles}     = $NumFilesPref    ;
  $UserPreferences{UploadMethod} = $UploadMethodPref;
  $UserPreferences{TopicMode}    = $TopicModePref   ;
  $UserPreferences{AuthorMode}   = $AuthorModePref  ;
  $UserPreferences{DateOverride} = $DateOverridePref;
}

sub GetGroupsCookie {
  my @GroupIDs = ();
  if ($query) {
    my $GroupIDs = $query -> cookie('groupids');
    if ($GroupIDs) {
      push @DebugStack,"Found group limiting cookie";
      @GroupIDs = split /,/,$GroupIDs;
    }
  }
  return @GroupIDs;
}

1;

