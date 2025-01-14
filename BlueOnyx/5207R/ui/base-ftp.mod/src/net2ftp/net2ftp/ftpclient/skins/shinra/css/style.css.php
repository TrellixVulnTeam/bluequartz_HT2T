<?php
header("Content-type: text/css");
if (isset($_GET["ltr"]) == false || $_GET["ltr"] != "rtl") { $left = "left"; $right = "right"; }
else                                                       { $left = "right"; $right = "left"; }
if (isset($_GET["image_url"]) == true) { $image_url = preg_replace("/[\\*\\?\\<\\>\\|]/", "", $_GET["image_url"]); }
else                                   { $image_url = ""; }
if (isset($_GET["show_ads"]) == false || $_GET["show_ads"] != "yes") { $show_ads = "no"; }
else                                                                 { $show_ads = "yes"; }
?>

/* IMPORTS ------------------------------------------------------------*/

@import url('reset.css');

@import url('styled-elements.css');

/* HACKS ------------------------------------------------------------*/

.clear{
	clear:both;
	height:1px;
}

.inv{ display:none; }

.alignleft{
	float: left;
	margin: 5px 10px 5px 0px;
}

/* GENERAL ------------------------------------------------------------*/


body {
	line-height: 1;
	color: #696969;
	background: #f1f1f1 url(../img/bg/patterns/obl-1x1.png);
	font-family: Arial, Helvetica, sans-serif;
	font-size:  100%;
}

#wrapper{
	width: 966px;
	margin: 15px auto;
	background: #363636;
	min-height: 500px;
	font-size: 14px;
	line-height: 1.5em;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#header{
<?php	if   ($show_ads == "no") { echo "height: 100px;\n"; }
	else                     { echo "height: 180px;\n"; } ?>
	position: relative;
	z-index: 10;
}

#main{
	background: #ffffff;
	position: relative;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#content{
	min-height: 400px;
	overflow: hidden;
	margin-bottom: 40px;
}

#footer{
	position: relative;
	color: #fff;
}

#logo{
	position: absolute;
<?php	if   ($show_ads == "no") { echo "top: 40px;\n"; }
	else                     { echo "top: 120px;\n"; } ?>
	left: 30px;
}

#content a{
	color: #696969;
}

#content p{
	margin-bottom: 20px;
}

#content .line-divider{
	clear: both;
	border-bottom: 1px solid #d7d7d7;
	padding-bottom: 20px;
	margin-bottom: 20px;
}

/* breadcrumbs --------------------------------------------------------*/

#header #breadcrumbs{
	position: absolute;
	bottom: 11px;
	left: 30px;
	font-style: italic;
	color: #999;
	font-size: 10px;
}

#header #breadcrumbs a{
	color: #bfbdbd;
	text-decoration: none;
	background: url(../img/breadcrumb-slash.png) no-repeat top right;
	padding-right: 14px;
}

/* TITLE --------------------------------------------------------*/

#page-title{
	overflow: hidden;
	height: 60px;
	margin-bottom: 20px;
	background: #f2f1f1 url(../img/twitter-border.png) repeat-x bottom left;
}

#page-title .title{
	display: block;
	float: left;
	font-family: 'Ubuntu', arial, serif;
	font-size: 30px;
	line-height: 60px;
	margin-left: 30px;
	text-shadow: 0 1px rgba(255, 255, 255, 1);
}

#page-title .subtitle{
	display: block;
	float: left;
	margin-left: 30px;
	line-height: 60px;
	color: #929191;
	font-style: italic;	
}

/* HOME --------------------------------------------------------*/

body.home #header{
	height: 430px;
	position: relative;
	z-index: 10;
}

body.home #header #headline{
	width: 906px;
	margin: 110px  auto 40px auto;
	font-size: 26px;
	line-height: 1.5em;
	font-family: 'Ubuntu', arial, serif;
	color: #ebe7e7;
	text-align: center;
}

body.home #content{
	padding-top: 250px;
}

#headline a{
	text-decoration: none;
	color: #696969;
}

/* HEADERS --------------------------------------------------------*/

h1,h2,h3,h4,h5,h6{ 
	line-height: 1.4em;
	font-family: 'Ubuntu', arial, serif; 
	font-weight: lighter;
	margin-bottom: 10px;
}

h1{ font-size: 30px; }

h2{ font-size: 28px; }

h3{ font-size: 26px; }

h4{ font-size: 24px; }

h5{ font-size: 22px; }

h6{ font-size: 20px; }

/* COLUMNS LAYOUT----------------------------------------------------------*/

.one-half,
.one-third,
.two-third,
.three-fourth,
.one-fourth {
	float:left;
	margin-right:30px;
	position:relative;
}

.one-half{ width: 438px; }

.one-third{ width: 282px; }

.one-fourth{ width: 204px; }

.two-third{ width: 594px; }

.three-fourth{ width: 672px; }

.last {
	clear:right;
	margin-right:0 !important;
}


/* SOCIAL --------------------------------------------------------*/

#social-holder{
	overflow: hidden;
	width: 100%;
<?php	if ($show_ads == "yes") { echo "padding-top: 20px;\n"; }
	else                    { echo "padding-top: 40px;\n"; } ?>
}

.social{
	display: block;
	float: right;
	overflow: hidden;
	margin-right: 20px;
}

.social li{
	display: block;
	width: 32px;
	height: 32px;
	float: left;
	margin-right: 10px;
	margin-bottom: 10px;
}

.social a{
	display: block;
	width: 32px;
	height: 32px;
	text-indent: -9000px;
}


/* SEARCH --------------------------------------------------------*/

.top-search{
	position: absolute;
<?php	if ($show_ads == "yes") { echo "top: 178px;\n"; }
	else                    { echo "top: 98px;\n"; } ?>
	right: 50px;
}

#searchform #s{
	color: #49494b;
	font-size: 12px;
	width: 160px;
	height: 21px;
<?php	if ($show_ads == "yes") { echo "margin: 40px 0px 5px 0px;\n"; }
	else                    { echo "margin: 0px 0px 5px 0px;\n"; } ?>
	padding: 2px 35px 2px 8px;
	border: 0;
	background: #f0efeb;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#searchform #searchsubmit{
	position: absolute; 
<?php	if ($show_ads == "yes") { echo "top: 40px;\n"; }
	else                    { echo "top: 0px;\n"; } ?>
	right: 0px;
	width: 25px;
	height: 25px;
	border: 0px;
	background: url(../img/search-submit.png) no-repeat  transparent -3px 2px;
}

/* NAVIGATION --------------------------------------------------------*/


#nav{
	display: block;
	position: absolute;
<?php	if ($show_ads == "yes") { echo "top: 168px;\n"; }
	else                    { echo "top: 88px;\n"; } ?>
	left: 30px;
	height: 46px;
	width: 906px;
	background: #ffd800;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#nav>li{
	display: block;
	float: left;
	margin-left: 5px;
	margin-top: 12px;
}

#nav>li:first-child{
	margin-left: 10px;
}

#nav>li>a{
	display: block;
	font-size: 12px;
	color: #363636;
	text-decoration: none;
	padding: 7px 10px 6px 10px;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
	text-shadow: 0 1px rgba(255, 255, 255, 0.5);
}

#nav>li>a:hover,
#nav>li.current-menu-item>a{
	color: #fff;
	background: #363636;
	text-shadow: none;
}

/* sub navigation */

#nav>li ul{
	display: block;
	margin-top: -1px;
	background: #ffd800;
	border-radius: 0px 0px 10px 10px;
	-moz-border-radius: 0px 0px 10px 10px;
	-webkit-border-radius: 0px 0px 10px 10px;
}

#nav>li>ul ul{
	margin-top: 0px;
	border-radius: 0px 10px 10px 10px;
	-moz-border-radius: 0px 10px 10px 10px;
	-webkit-border-radius: 0px 10px 10px 10px;
}

#nav>li ul li a{
	display: block;
	padding: 10px 15px;
	display: block;
	font-size: 12px;
	color: #363636;
	text-decoration: none;
}

#nav>li ul li a:hover{
	background: #363636;
	color: #fff;
}

#nav>li ul li:last-child a:hover{ /* last item its rounded at bottom */
	border-radius: 0px 0px 10px 10px;
	-moz-border-radius: 0px 0px 10px 10px;
	-webkit-border-radius: 0px 0px 10px 10px;
}

/* FILTER --------------------------------------------------------*/

#content .filter{
	display: block;
	overflow: hidden;
	border-bottom: 1px solid #d7d7d7;
	padding-bottom: 20px;
	margin-bottom: 30px;
	padding-left: 30px;
	padding-right: 30px;
}

#content .filter li{
	display: block;
	float: left;
	font-size: 12px;
	line-height: 14px;
	margin-right: 5px;
	margin-bottom: 10px;
	padding: 3px 10px;
	background: #363636;	
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#content .filter li:first-child{
	background: none;
}


#content .filter li a{	
	display: block;
	color: #f1f1f1;
	text-decoration: none;
	width: 100%;
	height: 100%;
}

#content .filter li:hover{
	background: #000;	
}

#content .filter li:first-child:hover{
	background: none;
}

#content .filter li.active{
	background: #999;	
}



/* TWITTER --------------------------------------------------------*/

#twitter{
	position: relative;
	background: #f2f1f1;
	height: 170px;
	width: 100%;
	background: #f2f1f1 url(../img/twitter-border.png) repeat-x;	
	border-radius: 0px 0px 10px 10px;
	-moz-border-radius: 0px 0px 10px 10px;
	-webkit-border-radius: 0px 0px 10px 10px;
}

#twitter #prev-tweet{
	display: block;
	position: absolute;
	top: 66px;
	left: 30px;
	width: 30px;
	height: 35px;
	background: transparent url(../img/prev-arrow.png) no-repeat top left;
}

#twitter #next-tweet{
	display: block;
	position: absolute;
	top: 66px;
	right: 30px;
	width: 30px;
	height: 35px;
	background: transparent url(../img/next-arrow.png) no-repeat top right;
}

#twitter #tweets .tweet_list{
	display: block;
	position: absolute;
	top: 0px;
	left: 80px;
	width: 810px;
	height: 170px;
}

#twitter #tweets .tweet_list li{
	display: block;
	width: 810px;
	height: 120px; /* original height 170px */
	font-size: 20px;
	line-height: 1.5em;
	font-style: italic;
	color: #838383;
	text-align: center;
	padding-top: 62px; 
}

#twitter #tweets .tweet_list li .tweet_time a{
	text-decoration: none;
	color: #ccc;
}

#twitter #tweets .tweet_list li a{
	text-decoration: none;
	color: #37b2d1;
}

#twitter #tweets p.loading{
	text-align: center;
	color: #ccc;
	padding-top: 75px;
	font-style: italic;
}

/* PAGES --------------------------------------------------------*/

#page-content{
	float: left;
	width: 906px;
	margin-left: 30px;
}

/* PORTFOLIO --------------------------------------------------------*/

#projects-list{
	overflow: hidden;
}

#projects-list .project{
	position: relative;
	float: left;
	overflow: hidden;
	width: 438px;
	height: 495px;
	margin-left: 30px;
	margin-bottom: 30px;
}

#projects-list .project h1 a{
	display: block;
	text-decoration: none;
	margin-bottom: 30px;
	color: #696969;
}

.project-shadow{
	background: url(../img/shadow-project.png) no-repeat 0px 267px;
}

#projects-list .project .project-thumbnail{
	position: relative;
	overflow: hidden;
	width: 438px;
	height: 267px;
	margin-bottom: 30px;
	background: #f1f1f1;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#projects-list .project .project-thumbnail .cover{
	position: absolute;
	top:0px;
	left: 0px;
}

#projects-list .project .project-thumbnail .meta{
	display: block;
	width: 252px;
	height: 207px;
	font-size: 12px;
	line-height: 2em;
	position: absolute;
	top:30px;
	left: 30px;
}

#projects-list .project .read-more{
	display: block;
	position: absolute;
	top: 325px;
	left: 160px;
	background: #363636;
	line-height: 33px;
	text-decoration: none;
	color: #fff;
	padding: 0px 30px 0px 30px;
	opacity: 0;
	
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
	
	-webkit-box-shadow: 0px 2px 3px #000; 
	-moz-box-shadow: 0px 2px 3px #000; 
	box-shadow: 0px 2px 3px #000;
}

#projects-list .project .read-more:hover{
	color: #fff;
	background: #000;
}

#projects-list .project:hover .read-more{
	opacity: 1;
}


/* PROJECT --------------------------------------------------------*/

.project-column{
	width: 438px;
	float: left;
	margin-left: 30px;
}

.project-column .project-thumbnail{
	overflow: hidden;
	width: 438px;
	height: 267px;
	margin-bottom: 30px;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}


#content .project-column .meta a{
	display: inline;
	font-size: 12px;
	color: #fff;
	padding: 3px 10px;
	text-decoration: none;
	background: #363636;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#content .project-column .meta a:hover{ background: #000;}

.project-column .project-title{
	margin-bottom: 20px;
}

/* PROJECT-GALLERY -----------------------------------------------*/

.project-column .project-gallery{
	display: block;
	overflow: hidden;
	width: 468px;
}

.project-column .project-gallery li{
	display: block;
	float: left;
	overflow: hidden;
	background: url(../img/plus-sign.png) center center no-repeat;
	width: 204;
	height: 148px;
	margin-right: 30px;
	margin-top: 30px;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

/* PROJECT-RELATED -----------------------------------------------*/

.related-title{
	margin-left: 30px;
}

.related-projects{
	display: block;
	overflow: hidden;
}

.related-projects li{
	display: block;
	float: left;
	overflow: hidden;
	width: 204px;
	height: 280px;
	margin-left: 30px;
	margin-top: 30px;
}

.related-projects li strong{
	display: block;
}

.related-projects li a.box{
	display: block;
	overflow: hidden;
	width: 204px;
	height: 148px;
	margin-bottom: 30px;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

.related-projects li a.box img{
	opacity: 0.7;
}

.related-projects li:hover a.box img{
	opacity: 1;
}

#content .related-projects li a{
	text-decoration: none;
	color: #999;
}

/* GALLERY -----------------------------------------------*/

#content .gallery{
	display: block;
	overflow: hidden;
}

#content .gallery li{
	display: block;
	float: left;
	overflow: hidden;
	background: url(../img/plus-sign.png) center center no-repeat;
	width: 204px;
	height: 148px;
	margin-left: 30px;
	margin-bottom: 30px;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#content .gallery.three-cols li{
	width: 282px;
	height: 267px;
}

#content .gallery.two-cols li{
	width: 438px;
	height: 267px;
}

#content .gallery li a{
	display: block;
}


/* BLOG --------------------------------------------------------*/

#posts{
	float: left;
	width: 624px;
}

#posts .post{
	position: relative;
	margin-left: 30px;
	margin-bottom: 30px;
}

#comments-block{
	position: relative;
	margin-left: 30px;
	margin-top: 40px;
	margin-bottom: 30px;
	padding-top: 80px;
}

#posts.single .post{
	border-bottom: none;
}

#posts .post:last-child{
	border-bottom: none;
}

#posts h1 a{
	display: block;
	margin-bottom: 30px;
	width: 514px;
	text-decoration: none;
	color: #696969;
}

#posts .n-comments{
	display: block;
	position: absolute;
	top:0;
	right:0px;
	width: 57px;
	height: 41px;
	color: #fff;
	text-align: center;
	line-height: 32px;
	background: url(../img/balloon.png) no-repeat;
}


#posts.single .post .n-comments{
	position: static;
}

.post .thumb-shadow{
	background: url(../img/shadow-blog.png) no-repeat 0px 270px;
}

#posts .post .post-thumbnail{
	position: relative;
	overflow: hidden;
	width: 596px;
	height: 270px;
	margin-bottom: 30px;
	background: #f1f1f1;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}


#posts .post .post-thumbnail .cover{
	position: absolute;
	top:0px;
	left: 0px;
}

#posts .post .the-excerpt{
	padding-bottom: 30px;
	background: url(../img/post-divider.png) center bottom no-repeat;
}

#posts .post .post-thumbnail .meta{
	display: block;
	width: 252px;
	height: 207px;
	font-size: 12px;
	line-height: 2em;
	position: absolute;
	top:30px;
	left: 30px;
}

#posts.single .post .meta{
	display: block;
	background: #f1f1f1;
	padding: 20px;
	border-color: #e7e6e6 #ececec #ececec #ececec;
	border-width: 3px 1px 1px 1px;
	border-style: solid;
	
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#posts .post .read-more{
	display: block;
	position: absolute;
	top: 325px;
	left: 257px;
	background: #363636 ;
	line-height: 33px;
	padding: 0px 14px 0px 14px;
	text-decoration: none;
	color: #f1f1f1;
	opacity: 0;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
	
	-webkit-box-shadow: 0px 2px 3px #000; 
	-moz-box-shadow: 0px 2px 3px #000; 
	box-shadow: 0px 2px 3px #000;
}

#posts .post .read-more:hover{
	background: #000;
}

#posts .post:hover .read-more{
	opacity: 1;
}

#posts .post .meta a{
	text-decoration: none;
}

#posts .post .meta-tags{
	overflow: hidden;
}

#posts .post .meta-tags a{
	float: left;
	font-size: 12px;
	line-height: 14px;
	color: #f1f1f1;
	background: #696969;
	padding: 3px 10px;
	margin-right: 5px;
	margin-bottom: 5px;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}

#posts .post .meta-tags a:hover{
	background: #000;
}

/* COMMENTS-BLOCK ------------------------------------------------------------*/



#comments-block .n-comments{
	left:0px;
}

#comments-block .n-comments{
	left:0px;
}

#comments-block .n-comments-text{
	display: block;
	position: absolute;
	top: 4px;
	left:68px;
	font-family: 'Ubuntu', arial, serif; 
	font-size: 28px;
}

/* COMMENTSLIST ------------------------------------------------------------*/

.commentlist{
	display: block;
}

.commentlist li{
	display: block;
	margin-bottom: 0px;
	padding: 10px 10px 10px 0px;
	line-height: 1.5em;
}

.commentlist ul{
	padding-left: 40px;
	border-left: 1px dashed #ccc;
}

.commentlist li .comment-body{
	overflow: hidden;
	position: relative;
	padding: 0px 0px 20px 0px;
}


.commentlist li img{
	display: block;
	float: left;
	margin: 0px 12px 20px 0px;
}

.commentlist .meta-date{
	display: block;
	float: right;
}

#content .commentlist .reply a{
	display: block;
	text-decoration: none;
	float: right;
	padding: 2px 8px;
	background: #ccc;
	color: #f1f1f1;
	font-size: 12px;
	border-radius: 5px;
	-moz-border-radius: 5px;
	-webkit-border-radius: 5px;
}

/* COMMENTS PAGINATION ------------------------------------------------------------*/

#content .comments-pagination {
	clear:both;
	overflow: hidden;
	padding:20px 0;
	position:relative;
	font-size:11px;
	line-height:13px;
	margin-bottom: 10px;
}
 
#content .comments-pagination span,
#content .comments-pagination a {
	display:block;
	float:left;
	margin: 2px 4px 2px 0;
	padding:6px 9px 5px 9px;
	text-decoration:none;
	width:auto;
	color:#fff;
	background: #555;
	border-radius: 10px;
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
}
 
#content .comments-pagination a:hover{
	color:#fff;
	background: #000000;
}
 
#content .comments-pagination .current{
	padding:6px 9px 5px 9px;
	background: #000000;
	color:#fff;
}

/* LEAVE COMMENT --------------------------------------------------------*/

.leave-comment{
	margin-top: 20px;
	padding-top:30px;
	background: url(../img/post-divider-inverted.png) no-repeat;
}

.leave-comment h2{
	margin-bottom: 20px;
}

/* CONTACT --------------------------------------------------------*/

.one-column{
	width: 438px;
	float: left;
	margin-left: 30px;
}

/* FORMS ------------------------------------------------------------*/

#BrowseForm{
	margin-bottom: 15px;
}

#BrowseForm input,
#BrowseForm select,
#BrowseForm textarea,
#LoginForm1 input,
#LoginForm1 select,
#LoginForm1 textarea,
#LoginForm2 input,
#LoginForm2 select,
#LoginForm2 textarea,
#LoginForm3 input,
#LoginForm3 select,
#LoginForm3 textarea{
	background: #fff;
	border: 1px solid #ccc;
	border-radius: 5px;
	-moz-border-radius: 5px;
	-webkit-border-radius: 5px;
	color: #606060;
	font-size: 14px;
	padding: 5px 10px;
}

#LoginForm1 input,
#LoginForm1 select,
#LoginForm2 input,
#LoginForm2 select,
#LoginForm3 input,
#LoginForm3 select{
	width: 320px;
}

#LoginForm3 input,
#LoginForm3 select{
	position: absolute;
	left: 120px;
}

#LoginForm1 textarea,
#LoginForm2 textarea,
#LoginForm3 textarea{
	width: 380px;
}

#LoginForm1 #LoginButton1,
#LoginForm2 #LoginButton2,
#LoginForm3 #LoginButton3{
	background: #072854b3; 
	color: #FFF;
	margin: 20px 2px;
	padding: 10px 15px;
	width: 100px;
}

#LogoutButton{
	background: #ffd800; 
	color: #363636;
	margin: 2px 2px;
	padding: 5px 15px;
	width: 100px;
}

#LoginForm2 #smallbutton,
#LoginForm3 #smallbutton,
#BrowseForm #smallbutton{
	background: #072854b3; 
	color: #FFF;
	padding: 1px 3px;
}

#LoginForm1 #LoginButton1:hover,
#LoginForm2 #LoginButton2:hover,
#LoginForm3 #LoginButton3:hover,
#LoginForm2 #smallbutton:hover,
#LoginForm3 #smallbutton:hover,
#BrowseForm #smallbutton:hover{
	background: #363636;
	color: #FFF;
}

#LoginForm1 #LoginButton1:active,
#LoginForm2 #LoginButton2:active,
#LoginForm3 #LoginButton3:active,
#LoginForm2 #smallbutton:active,
#LoginForm3 #smallbutton:active,
#BrowseForm #smallbutton:active{
	background: #000;
	color: #FFF;
}

#LoginForm1 label,
#LoginForm2 label,
#LoginForm3 label{
	font-size: 14px;
	line-height: 2.5em;
	font-weight: light;
}

#LoginForm1 label,
#LoginForm2 label{
	display: block;
}

table, tr, td{
	padding: 5px;
	border: 0;
	outline: 0;
	font-size: 100%;
	vertical-align: baseline;
	background: transparent;
}

.browse_rows_actions {
	background-color: #f2f1f1;
	color: #696969;
	font-size: 80%;
	font-weight: normal;
	text-align: <?php echo $left; ?>;
}

.browse_rows_heading {
	background-color: #f2f1f1;
	color: #696969;
	font-size: 100%;
	font-weight: bold;
}

.browse_rows_odd, .browse_rows_even {
	color: #696969; 
	font-size: 100%;
	font-weight: normal;
	text-align: <?php echo $left; ?>;
}


/* PAGER ------------------------------------------------------------*/

.pager{
	padding-top: 0px;
	overflow: hidden;
	display: block;
	height: 33px;
	margin-top: 20px;
	margin-left: 30px;
	margin-bottom: 20px;
}

.pager li{
	display: block;
	width: 33px;
	height: 33px;
	margin-right: 8px;
	float: left;
}

#content .pager li a{
	display: block;
	width: 100%;
	height: 100%;
	line-height: 33px;
	text-align: center;
	text-decoration: none;
	color: #ffd800;
	background: #363636;
	border-radius: 15px;
	-moz-border-radius: 15px;
	-webkit-border-radius: 15px;
}

#content .pager li:hover a,
#content .pager li.active a{
	color: #363636;
	background: #ffd800;	
}

/* SIDEBAR ------------------------------------------------------------*/

#sidebar{
	float: left;
	width: 282px;
	margin-left: 30px;
}

#sidebar>li{
	margin-bottom: 20px;
}

#sidebar>li h6{
	padding-bottom: 20px;
}

#sidebar ul>li{
	line-height: 40px;
	text-decoration: none;
	border-bottom: 1px solid #d7d7d7;
}

#sidebar ul>li:last-child{ border-bottom: none; }

#sidebar ul>li a{
	display: block;
	height: 100%;
	width: 100%;
	text-decoration: none;
	color: #696969;
}

#sidebar ul>li:hover{
	background: #f1f1f1;
}

/* FOOTER - COLS ------------------------------------------------------------*/

#footer-cols{
	display: block;
	overflow: hidden;
	color: #bbbaba;
	line-height: 1.5em;
	margin-top: 40px;
}

#footer-cols li.col{
	display: block;
	width: 282px;
	float: left;
	margin-left: 30px;
	margin-bottom: 30px;
}

#footer-cols li.col>h6{
	color: #d7d7d7;
	margin-bottom: 30px;
	text-shadow: -2px -1px rgba(0, 0, 0, .8);
}

#footer-cols li.clear-col{ clear:left; }

#footer-cols li.col ul{
	display: block;
}

#footer-cols li.col ul li{
	display: block;
	line-height: 35px;
	border-top: 1px solid #4a4a4a;
	border-bottom: 1px solid #000;
}

#footer-cols li.col ul li:first-child{ border-top: none; }

#footer-cols li.col ul li:last-child{ border-bottom: none; }

#footer-cols li.col ul li a{
	text-decoration: none;
	color: #bbbaba;
}

#footer-cols li.col ul li a:hover{
	color: #fff;
}

/* FOOTER BOTTOM --------------------------------------------------------*/

#footer #bottom{
	position: relative;
	width: 100%;
	font-size: 12px;
	line-height: 1.5em;
	line-height: 80px;
	text-align: center;
	color: #868686;
	background: url(../img/bottom-shadow.png) repeat-x;
}

#footer #bottom a{
	color: #ffd800;
	text-decoration: none;
}

#footer #bottom #to-top{
	position: absolute;
	right: 30px;
	top: 26px;
	width: 33px;
	height: 33px;
	background: url(../img/to-top.png) no-repeat;
	cursor: pointer;
}
