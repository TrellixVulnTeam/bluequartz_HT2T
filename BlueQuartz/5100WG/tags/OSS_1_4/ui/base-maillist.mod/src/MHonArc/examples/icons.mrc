<!--	MHonArc resource file

	icons.mrc 1.3 99/06/25

	This example file makes use of the icons feature of
	MHonArc.
  -->

<main>
<sort>
<nothread>
<noreverse>

<!--	Have LISTBEGIN contain last updated information
  -->
<listbegin>
<address>
Last update: $LOCALDATE$<br>
$NUMOFMSG$ messages<br>
</address>
<p>
Messages listed in chronological order.  Listing format is the following:
<blockquote>
<img src="/icons/gletter.gif" alt="* ">
<strong>Subject</strong><code>  </code>
(# of follow-ups)<code>  </code>
<em>From</em>.
</blockquote>
<p>
<hr>
</listbegin>

<!--	A compact listing template with icon usage
  -->
<litemplate>
<img src="$ICONURL$" alt="* "><strong>$SUBJECT:40$</strong>
($NUMFOLUP$) <em>$FROMNAME$</em><br>
</litemplate>

<listend>
</listend>

<labelstyles>
-default-
subject:strong
from:strong
</labelstyles>

<fieldstyles>
-default-
subject:strong
from:strong
</fieldstyles>

<!--	Specify icons for message types
  -->
<icons>
audio/basic:/icons/gsound.gif
image/gif:/icons/gimage.gif
image/jpeg:/icons/gimage.gif
image/tiff:/icons/ggraphic.gif
multipart/alternative:/icons/gmulti.gif
multipart/digest:/icons/gtext.gif
multipart/mixed:/icons/gdoc2.gif
multipart/parallel:/icons/gdoc.gif
text/enriched:/icons/gdoc.gif
text/html:/icons/gdoc.gif
text/plain:/icons/gletter.gif
unknown:/icons/gunknown.gif
video/mpeg:/icons/gmovie.gif
</icons>
