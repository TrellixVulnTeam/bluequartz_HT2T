<?php defined("NET2FTP") or die("Direct access to this location is not allowed."); ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xml:lang="<?php echo __("en"); ?>" dir="<?php echo __("ltr"); ?>">
<head>
<meta http-equiv="Content-type" content="text/html;charset=<?php echo __("iso-8859-1"); ?>" />
<meta name="keywords" content="net2ftp, web, ftp, based, web-based, xftp, client, PHP, SSL, SSH, SSH2, password, server, free, gnu, gpl, gnu/gpl, net, net to ftp, netftp, connect, user, gui, interface, web2ftp, edit, editor, online, code, php, upload, download, copy, move, delete, zip, tar, unzip, untar, recursive, rename, chmod, syntax, highlighting, host, hosting, ISP, webserver, plan, bandwidth" />
<meta name="description" content="net2ftp is a web based FTP client. It is mainly aimed at managing websites using a browser. Edit code, upload/download files, copy/move/delete directories recursively, rename files and directories -- without installing any software." />
<link rel="shortcut icon" href="favicon.ico" />
<title>net2ftp - a web based FTP client</title>
<?php echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"". $net2ftp_globals["application_rootdir_url"] . "/skins/shinra/css/style.css.php?show_ads=no\"/>\n"; ?>
		</head>

</head>
<body>

	<div id="main">
		<div id="content">

			<div id="container">
				<div id="p_ba7428_progress" class="p_ba7428" style="margin-left:auto; margin-right:auto; width:500px; padding-bottom:5px;">
			</div>
			<div id="head">
				<div id="headleft">
				</div>
				<div style="float: right; text-align: right;">
				</div>
		 	</div>
<?php
if ($net2ftp_result["success"] == false) {
	require_once($net2ftp_globals["application_rootdir"] . "/skins/" . $net2ftp_globals["skin"] . "/error.template.php");
}
?>
<?php require_once($net2ftp_globals["application_skinsdir"] . "/" . $net2ftp_globals["skin"] . "/footer.template.php"); ?>
		</div>
	</div>
</body>
</html>