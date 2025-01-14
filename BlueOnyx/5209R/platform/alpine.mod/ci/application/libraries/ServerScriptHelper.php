<?php

/**
 * ServerScriptHelper.php
 *
 * BlueOnyx ServerScriptHelper for Codeigniter
 *
 * Description:
 *
 * This class is designed to ease the development of server-side scripts. It is
 * a library of commonly used functions.
 *
 * applicability:
 * Server-side scripts that uses session, UIFC, I18n and/or CCE.
 *
 * Usage:
 *
 * Construct a new ServerScriptHelper at the start of every server-side script.
 * It will automagically get session information, knows who is the login user
 * and connect to CCE to find out more information about the user. The "get"
 * methods can be used to get information about the script. Always call
 * destructor() at the end of the scripts. Don't forget.
 *
 * @package   ServerScriptHelper
 * @author    Michael Stauber, Patrick Bose, Kevin K.M. Chiu
 * @link      http://www.blueonyx.it
 * @license   http://devel.blueonyx.it/pub/BlueOnyx/licenses/SUN-modified-BSD-License.txt
 * @version   2.0
 */

include_once("System.php");
include_once("I18n.php");
include_once("ArrayPacker.php");
include_once("uifc/HtmlComponentFactory.php");
include_once("uifc/Stylist.php");
include_once("Capabilities.php");

class ServerScriptHelper {

    //
    // private variables
    //

    var $cceClient;
    // hash of "<domain>/<localePreference>" to i18n objects
    var $i18n;
    var $loginName;
    var $sessionId;
    var $loginUser;
    var $isMonterey;

    var $capabilities;
    var $errors;
    var $BxPageTemp;
    var $debugActive;

    var $CAPABILITIESGLOBALOBJECT;

    //
    // public functions
    //

    public function getBxPage() {
        return $this->BxPageTemp;
    }

    public function setBxPage($page) {
        $this->BxPageTemp = $page;
    }

    // description: constructor
    // param: sessionId: the session Id in string. Optional.
    //     If not supplied, cookie setting is used.
    // param: loginName: the login name of the user in string. Optional.
    //     If not supplied, , cookie setting is used.
    function ServerScriptHelper($sessionId = "", $loginName = "") {

        // Call me a dirty little bastard. But CCEd gets stuck sometimes.
        // Which throws a wrench into the entire GUI. So this is how we
        // handle it: This script tries to establish a connection to CCEd.
        // It has a timeout of five seconds. After which it reports 'TIMEOUT':
        $cce_check = shell_exec('/usr/sausalito/bin/check_cce.pl');
        // If we do have a 'TIMEOUT' or no output at all, then we get down and dirty:
        if (($cce_check == "TIMEOUT") || ($cce_check == "")) {
            // We run the unstuck script vi SUDO. This is the ONLY command that user
            // 'admserv' has sudo capabilities for and it kills off stray CCEd processes,
            // pperld and cced.init. It then does a fast cced.init rehash to get us back up:
            $cce_unstuck = shell_exec('/usr/bin/sudo /usr/sausalito/bin/cced_unstuck.sh');
        }
        // If we get here, CCEd should be running. Either again, or because it was fine.

        // Set default allowed list for capabilities:
        $this->_listAllowed = array();
        $seen = array();

        $CI =& get_instance();

        // Get $sessionId and $loginName from Cookie (if they are set):
        if (!isset($sessionId)) {
            $sessionId = $CI->input->cookie('sessionId');
        }
        if (!isset($loginName)) {    
            $loginName = $CI->input->cookie('loginName');
        }

        if (is_file("/etc/DEBUG")) {
            $this->setDebug(TRUE);
        }
        else {
            $this->setDebug(FALSE);
        }

        // save parameters
        $this->loginName = $loginName;
        $this->sessionId = $sessionId;

        // Check if debugging is active
        if (is_file("/etc/DEBUGSSH")) {
            $this->debugActive = TRUE;
        }
        else {
            $this->debugActive = FALSE;
        }

        // initialize cceClient
        // does authentication via CCE
        $system = new System();

        $product = $this->getProductCode();

        $this->isMonterey = preg_match("/35[0-9][0-9]R/", $product);

        // Bit of a hack: If BASEPATH is not set, we can assume that the calling page is
        // old-Style BlueOnyx and not using CodeIgniter. So instead of showing that class
        // CceClient is unknown, we show the user a page which explains him to update his
        // stuff via YUM, SWUpdate and if that doesn't fit it, then to ask for help:
        if ( ! defined('BASEPATH')) {
            header('Location: /gui/NotYetDone');
            exit;
        }

        // Call me a dirty little bastard. But CCEd gets stuck sometimes.
        // Which throws a wrench into the entire GUI. So this is how we
        // handle it: This script tries to establish a connection to CCEd.
        // It has a timeout of five seconds. After which it reports 'TIMEOUT':
        $cce_check = shell_exec('/usr/sausalito/bin/check_cce.pl');
        // If we do have a 'TIMEOUT' or no output at all, then we get down and dirty:
        if (($cce_check == "TIMEOUT") || ($cce_check == "")) {
            // We run the unstuck script vi SUDO. This is the ONLY command that user
            // 'admserv' has sudo capabilities for and it kills off stray CCEd processes,
            // pperld and cced.init. It then does a fast cced.init rehash to get us back up:
            $cce_unstuck = shell_exec('/usr/bin/sudo /usr/sausalito/bin/cced_unstuck.sh');
        }
        // If we get here, CCEd should be running. Either again, or because it was fine.
        if ($this->hasCCE()) {

            if ((!isset($this->cceClient)) || (!isset($cceClient))) {
                $this->cceClient = new CceClient();
                $cceClient =& $this->cceClient;
            }

            if(!$cceClient->connect()) {
                // CCE is down
                // read the reason from message file
                // why did we get another System here?
                // $system = new System();
                // This is commented out because this will override 
                // system settings for products that aren't fully Sausalito
                // $defaultLocale = $system->getConfig("defaultLocale");
                $path = $system->getConfig("ccedMessagePath");
                $messageTag = "[[palette.cceDown]]";
                if(file_exists($path)) {
                    $messageFile = fopen($path, "r");
                    $messageTag = fgets($messageFile, 1024);
                    fclose($messageFile);
                }
                // we use default locale here because locale preference is stored in CCE
                $i18n = new I18n;
                $message = $i18n->interpolate($messageTag);

                error_log("ServerScriptHelper.ServerScriptHelper(): CCE is down: $message");
                header("cache-control: no-cache");
                print("
                    <HTML>
                    <HEAD>
                    <META HTTP-EQUIV=\"expires\" CONTENT=\"-1\">
                    <META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">
                    </HEAD>
                    <BODY>
                    <CENTER>
                    <BR><BR><BR><BR>
                    <TABLE WIDTH=\"60%\"><TR>
                    <TD><FONT COLOR=\"#990000\">$message</FONT></TD>
                    </TR></TABLE>
                    </CENTER>
                    </BODY>
                    </HTML>");
                exit;
            }

            // only AUTH if not on Monterey
            if (!$this->isMonterey) {
                $auth_attempt = $cceClient->authkey($this->loginName, $this->sessionId);
                if (!$auth_attempt) {
                    // Auth failed. We redirect to GUI login page. But to speed things up we delete the cookies to prevent that another authkey is tried with them:
                    delete_cookie("loginName");
                    delete_cookie("sessionId");
                    error_log("ServerScriptHelper.ServerScriptHelper(): Cannot authenticate to CCE (login name: $loginName, session ID: $sessionId)"); 
                    // tell users their sessions are expired and redirect
                    // set the target here to point to where to go back to after login
                    header("cache-control: no-cache");
                    print("
                    <HTML>
                    <HEAD>
                    <META HTTP-EQUIV=\"expires\" CONTENT=\"-1\">
                    <META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">
                    </HEAD>
                    <BODY onLoad=\"redirect()\">
                    <SCRIPT LANGUAGE=\"javascript\">
                    function redirect() {
                    var pathname = top.location.pathname;
                    // IE4.0 has a bug that location.pathname contains port at the beginning
                    if(top.location.port != null && top.location.port != \"\" && pathname.indexOf(\"/:\"+top.location.port) == 0)
                    pathname = pathname.substring(2+top.location.port.length);
                    var url = \"/expired/true/target\"+escape(pathname+top.location.search+top.location.hash);

                    top.location = url;
                    top.focus();
                    }
                    </SCRIPT>
                    </BODY>
                    </HTML>");
                    exit;
                }
                $this->loginUser = $cceClient->get($cceClient->whoami());
            }

            // initialize
            $this->i18n = array();
            // initialize timezone
            $retvalTZ = @date_default_timezone_get();
            if (!$retvalTZ) {
                $timeObj = $cceClient->getObject("System", array(), "Time");
            }
            if (!isset($timeObj["timeZone"])) {
                $timeObj["timeZone"] = "America/New_York";
            }
            $systemTimeZone = $timeObj["timeZone"];
            @date_default_timezone_set($systemTimeZone);

            // UserShell:
            $userShell = $this->cceClient->get($this->loginUser['OID'], 'Shell');

            // Store BX_SESSION:
            $CI->setBX_SESSION($loginName, $sessionId, $this->loginUser, $userShell['enabled']);
        }
    }

    // description: destructor
    function destructor($whodidit='') {
        $cceClient = $this->cceClient;
        //$cceClient->commit();
        if ($this->hasCCE()) {
            if ($whodidit != '') {
                if ($this->DEBUG) {
                    error_log("ServerScriptHelper: BYE initiated by: $whodidit");
                }
            }
            $cceClient->bye();
        }

        // clean up cache
        unset($this->i18n);
    }

    // description: Returns the contents of a file using the unix permissions 
    //   granted to the current CCE user
    // param: filename: The filename of the file to be opened
    // returns: the contents of the file
    function getFile($filename) {
        $rv = $this->shell("/bin/ls -s --block-size=1 $filename", $ls);
        if (!$rv) {
            preg_match("/^([0-9]+)[[:space:]]/", $ls, $regs);
            $size = $regs[1];
            $fh = $this->popen("/bin/cat $filename");
            // Removed by: Brian Smith
            // Reason    : would not load past 4096 bytes
            // $ret = fread($fh, $size);  

            // Fix.  Loop through until it is finished
            $ret = "";
            while ( !feof($fh) ) {
                $ret .= fgets($fh);
            }
        }
        if (isset($fh)) {
            pclose($fh);
        }
        return $ret;
    }

    // description: Writes the given data into the given file as the currently
    //   logged in user.  The current user becomes the owner, 'users' is the group
    //   and the permissions are 0600.
    // param: filename: Name of the file to write
    // param: data: data to be written to the file
    // TODO: This needs error checking
    function putFile($filename, $data) {
        $fh = $this->popen("/usr/sausalito/sbin/writeFile.pl $filename", "w");
        fwrite($fh, $data);
        pclose($fh);
    }

    // description: given a capabilitygroup name, this function will expand it
    //   and it's children into a list composed of both capabilitygroup names and
    //   and cce-level capabilities
    // param: capName - the name of the capability to be expanded.
    // returns: an expanded list of the capabilities entailed by $capName 
    function expandCaps($capName, $seen = array()) {
        if ($this->capabilities == null) {
            $this->capabilities = $this->getGlobalCapabilitiesObject($this->cceClient);
        }

        // Return value used to be this, but this doesn't work:
        //return $this->capabilities->expandCaps($capName, $seen);
        $returnCap = array();
        foreach ($this->getAllCapabilityGroups() as $capA => $capContend) {
            if ($capContend['CLASS'] == "CapabilityGroup") {
                if ($capContend['name'] == $capName) {
                    if (!in_array($capName, $returnCap)) {
                        $returnCap[] = $capName;
                    }
                    $tmpreturnCap = scalar_to_array($capContend['capabilities']);
                    foreach ($tmpreturnCap as $key => $value) {
                        if (!in_array($value, $returnCap)) {
                            $returnCap[] = $value;
                        }
                    }
                }
                else {
                    if (!in_array($capName, $returnCap)) {
                        $returnCap[] = $capName;
                    }
                }
            }
        }
        return $returnCap;
    }

    // description: returns the global capabilities object
    function getCapabilitiesObject() {
        if ($this->capabilities == null) {
            $this->capabilities = $this->getGlobalCapabilitiesObject($this->cceClient);
            return $this->capabilities;
        }
    }
      

    // description: opens a read-only stream wrapped by CCE
    // param: program: A string containing the program to execute, including
    //   the path and any arguments
    // param: mode: The mode to use in this popen
    // param: runas: the user to run the program as, defaults to the currently
    //  logged in user if not specified
    // returns: a file handle to be read from
    function popen($cmd, $mode = "r", $runas = "") {
        if (!isset($sessionId)) {
            $CI =& get_instance();
            $sessionId = $CI->input->cookie('sessionId');
        }
        $product = $this->getProductCode();
        $this->isMonterey = preg_match("/35[0-9][0-9]R/", $product);

        putenv("CCE_SESSIONID=" . $sessionId);
        putenv("CCE_USERNAME=" . $this->loginName);
        putenv("CCE_REQUESTUSER=" . $runas);
        putenv('PERL_BADLANG=0');

        if ($this->isMonterey) {
            $handle = popen("$cmd", $mode);
        }
        else {
            $handle = popen("/usr/sausalito/bin/ccewrap $cmd", $mode);
        }
        putenv("CCE_SESSIONID=");
        putenv("CCE_USERNAME=");
        putenv('CCE_REQUESTUSER=');

        return $handle;
    }

    // description: allows one to execute a program as
    //   the currently logged in user
    // param: program: A string containing program to execute, including 
    //   path and any arguments
    // param: output variable that picks up the output sent by the program
    // param: the user to run this program as (defaults to the currently
    //   logged in user 
    // returns: 0 an success, errno on error
    function shell($cmd, &$output, $runas="", $sessionId="") {
        $CI =& get_instance();
        if ((!isset($sessionId)) || ($sessionId == "")) {
            $sessionId = $CI->input->cookie('sessionId');
        }
        $product = $this->getProductCode();
        $this->isMonterey = preg_match("/35[0-9][0-9]R/", $product);

        // call ccewrap
        //$cmd = escapeShellCmd($cmd);
        putenv("CCE_SESSIONID=". $sessionId);
        putenv("CCE_USERNAME=". $this->loginName);
        putenv("CCE_REQUESTUSER=". $runas);
        putenv("PERL_BADLANG=0");

        if ($this->isMonterey) {
            exec("$cmd", $array, $ret);
        }
        else {
            exec("/usr/sausalito/bin/ccewrap $cmd", $array, $ret);
        }

        // prepare return
        while (list($key,$val)=each($array)) {
            $output .= "$val\n";  
        }

        // clean up
        putenv("CCE_SESSIONID=");
        putenv("CCE_USERNAME=");
        putenv("CCE_REQUESTUSER=");

        return $ret;
    }

    // description: allows one to fork a program as
    //   the currently logged in user.  Notice that NO interaction between the 
    //   called program and the caller can be made.
    // param: program: A string containing program to execute, including 
    //   path and any arguments
    // param: the user this program should run as.  Defaults to the currently
    //   logged in user
    // returns: 0 an success, errno on error
    function fork($cmd, $runas = "") {
        $this->shell("$cmd >/dev/null 2>&1 < /dev/null &", $out, $runas);
    }

    // descriptions: get an array of access rights
    // returns: an array of access rights in strings
    function getAccessRights() {

        $CI =& get_instance();

        // Get loginName:
        $loginName = $CI->BX_SESSION['loginName'];
        if (!$loginName) {
            $loginName = $CI->input->cookie('loginName');
        }

        $accessRights = array();

        // include rights specified in uiRights property
        if ($this->loginUser["uiRights"] != "") {
            $accessRights = stringToArray($this->loginUser["uiRights"]);
        }

        // add the list of capabilityGroups AND cce-level capabilities
        if (isset($this->loginUser["capLevels"])) {
            $accessRights = array_merge($accessRights, $this->listAllowed());
        }

        // This catches extra admins:
        $admin_users = posix_getgrnam("admin-users");
        if (is_array($admin_users)) {
            if (in_array($loginName, $admin_users['members'])) {
                $accessRights[] = "serverManage";
            }
        }

        if (is_array($CI->BX_SESSION['loginUser'])) {
            // Reuse loginUser from BX_SESSION if present:
            $user = $CI->BX_SESSION['loginUser'];
            $userShell['enabled'] = $CI->BX_SESSION['userShell'];
        }
        else {
            // If not present, fetch him via CCE:
            $user = $this->cceClient->getObject("User", array("name" => $loginName));
            $userShell = $this->cceClient->get($user['OID'], 'Shell');
        }

        if ($userShell['enabled'] == "1") {
            if (!in_array('shellAccessEnabled', $accessRights)) {
                $accessRights[] = 'shellAccessEnabled';
            }
        }

        if (($loginName == "admin") || ($this->loginUser['systemAdministrator'] == '1')) {
            if (!in_array('admin', $accessRights)) {
                $accessRights[] = "admin";
            }
            if (!in_array('systemAdministrator', $accessRights)) {
                $accessRights[] = "systemAdministrator";
            }            
        }

        if (in_array($loginName, posix_getgrnam("site-adm"))) {
            if (!in_array('siteAdministrator', $accessRights)) {
                $accessRights[] = "siteAdministrator";
            }
        } 

        return array_unique(array_values($accessRights));
    }

    // description: get a connected and authenticated CceClient
    // returns: a CceClient object
    function getCceClient() {
        return $this->cceClient;
    }

    // description: get a HtmlComponentFactory object to construct HtmlComponents
    // param: i18nDomain: the I18n domain used for construction
    // param: formAction: the action of the form where HtmlComponents sit in
    // returns: a HtmlComponentFactory object
    //function getHtmlComponentFactory($BxPage, $i18n, $formAction = "") {
    function getHtmlComponentFactory($i18nDomain, $formAction = "") {
        // Please note: With the "$this" at the end we pass the entire ServerScriptHelper object along:
        $factory = new HtmlComponentFactory(array(), $this->getI18n($i18nDomain), $formAction, $this);
        return $factory;
    }


    // description: get the right I18n object
    // param: domain: the domain of the I18n object. Optional
    // param: httpAcceptLanguage: the HTTP_ACCEPT_LANGUAGE header. Optional.
    //     If not supplied, global $HTTP_ACCEPT_LANGUAGE is used
    // returns: an I18n object
    function getI18n($domain = "", $httpAcceptLanguage = "") {
        // use global $HTTP_ACCEPT_LANGUAGE if no $httpAcceptLanguage
        if ($httpAcceptLanguage == "") {
            global $HTTP_ACCEPT_LANGUAGE;
            $httpAcceptLanguage = $HTTP_ACCEPT_LANGUAGE;
        }

        // find locale preference
        $ini_langs = initialize_languages(FALSE);
        $localePreference = $ini_langs['locale'];

        // make key for i18n hash
        $key = "$domain/$localePreference";

        // put new object in hash if necessary
        if (!isset($this->i18n[$key])) {
            $this->i18n[$key] = new I18n($domain, $localePreference);
        }

        return $this->i18n[$key];
    }

    // description: get the preferred locale specified by the logged in user
    //     if "browser" is preferred, locale from HTTP_ACCEPT_LANGUAGE is used
    //     if no locale is preferred, use defaultLocale specified in ui.cfg
    // param: httpAcceptLanguage: the HTTP_ACCEPT_LANGUAGE header. Optional.
    //     global HTTP_ACCEPT_LANGUAGE is used if not supplied
    // returns: a list of locales in string, comma separated
    function getLocalePreference($httpAcceptLanguage = "") {
        $localePreference = $this->loginUser["localePreference"];

        // use defaultLocale in ui.cfg if user do not have preference
        if ($localePreference == "") {
            $system = new System();
            return $system->getConfig("defaultLocale");
        }

        // return what the user specified
        if ($localePreference != "browser") {
            return $localePreference;
        }

        // use global HTTP_ACCEPT_LANGUAGE if it is not supplied
        if ($httpAcceptLanguage == "") {
            global $HTTP_ACCEPT_LANGUAGE;
            $httpAcceptLanguage = $HTTP_ACCEPT_LANGUAGE;
        }

        // use defaultLocale in ui.cfg as default if preference is "browser" and
        // HTTP accept language is empty
        if ($httpAcceptLanguage == "") {
            $system = new System();
            return $system->getConfig("defaultLocale");
        }

        // For HTTP_ACCEPT_LANGUAGE, IE gives something like "en", "en,ja",
        // "sq,ja;q=0.7,en-us;q=0.3" or "ja,en-us;q=0.5"
        // NN gives something like "en", "en, ja"
        // preferrence is from left to right

        // remove all spaces
        $httpAcceptLanguage = str_replace(" ", "", $httpAcceptLanguage);

        $locales = explode(",", $httpAcceptLanguage);
        $httpAcceptLanguage = "";
        for ($i = 0; $i < count($locales); $i++) {
            $locale = $locales[$i];

            // remove all the q stuff because IE already sorted the entries
            $index = strpos($locale, ";");
            if ($index) {
                $locale = substr($locale, 0, $index);
            }
            // make country code uppercase
            if (strlen($locale) > 3) {
                $locale = substr($locale, 0, 3).strtoupper(substr($locale, 3, strlen($locale)-3));
            }
            if ($i > 0) {
                $httpAcceptLanguage .= ",";
            }
            $httpAcceptLanguage .= $locale;
        }

        $httpAcceptLanguage = str_replace("-", "_", $httpAcceptLanguage);

        return $httpAcceptLanguage;
    }

    // description: get the name of the logged in user
    // returns: login name in string
    function getLoginName() {
        return $this->loginName;
    }

    // description: get the style preferred by the logged in user
    //     if user has no preference or if the preference is not available,
    //     use any style available on the system
    // returns: style ID in string
    function getStylePreference() {
        $preference = $this->loginUser["stylePreference"];

        if (!is_object($this->stylist)) {
            $this->stylist = new Stylist();
        }
        $styleIds = $this->stylist->getAllResourceIds();

        // very bad error if the system has no style
        if (count($styleIds) == 0) {
            $err = "Error: No style available on the system.";
            print($err);
            error_log($err, 0);
            exit();
        }

        $product = $this->getProductCode();
        $this->isMonterey = preg_match("/35[0-9][0-9]R/", $product);

        // use preference if it is available
        // then use trueBlue if it is available
        // otherwise, use any style available
        if (in_array($preference, $styleIds)) {
            return $preference;
        }
        elseif ($this->isMonterey && in_array("classic", $styleIds)) {
            return "classic";
        }
        elseif (in_array("BlueOnyx", $styleIds)) {
            return "BlueOnyx";
        }
        else {
            return $styleIds[0];
        }
    }

    // description: get the stylist who gives right styles according to the
    //     style preference of the logged in user
    // returns: a Stylist object
    function getStylist($styleId="") {
        $this->stylist = new Stylist($styleId);

        // get style preference
        $style = $this->getStylePreference();

        // each style has its own i18n domain
        $i18n = $this->getI18n($style);

        // get locale
        $locales = $i18n->getLocales();
        $locale = (count($locales) > 0) ? $locales[0] : "";

        // set style resource
        $this->stylist->setResource($style, $locale);

        return $this->stylist;
    }

    // description: get the HTML page to be printed out by UI page handlers
    // param: returnUrl: the URL the handler returns to. Optional
    // param: errors: an array of Error objects for errors occured within the
    //     handler. Optional
    function toHandlerHtml($returnUrl = "", $errors = array(), $preserveData = true) {
        $onLoad = '';
        $CI =& get_instance();

        // see if the post vars should be passed down
        if (count($errors) > 0) {
            // try to maintain as little overhead as possible by only adding stuff that is absolutely needed
            $post_vars_html = "<FORM METHOD=\"POST\" ENCTYPE=\"multipart/form-data\" ACTION=\"$returnUrl\">\n";
           
            // serialize the errors array, to preserve all data for field marking
            $post_vars_html .= "<INPUT TYPE=\"HIDDEN\" NAME=\"_serialized_errors\" VALUE=\"" . urlencode(serialize($errors)) . "\">\n";

            $form_data = $CI->input->post(NULL, TRUE);
            while(list($var, $value) = @each($form_data)) {
                // just pass through all values and assume the other side knows what to do
                $post_vars_html .= "<INPUT TYPE=\"HIDDEN\" NAME=\"$var\" VALUE=\"$value\">\n";
            }

            $post_vars_html .= "</FORM>\n";

            $onLoad = "document.forms[0].submit();";
        }
        else {
            $post_vars_html = '';
        }

        $onLoad .= (count($errors) == 0) ? "flow_success = true;" : "flow_success = false;";

        if (!headers_sent())
            header("cache-control: no-cache");

        /*
         * make sure the encoding is correct otherwise, if we aren't preserving
         * data, japanese strings may be corrupted, because the browser gets
         * confused.
         */
        $i18n = $this->getI18n();
        $encoding = $i18n->getProperty('encoding', 'palette');

        $CI =& get_instance();
        $ini_langs = initialize_languages(FALSE);

        $encoding = $ini_langs['charset'];

        if ($encoding != 'none') {
            $encoding = "; charset=$encoding";
        }
        else {
            $encoding = '';
        }
        return "
            <HTML>
            <HEAD>
            <META HTTP-EQUIV=\"Content-type\" CONTENT=\"text/html$encoding\">
            <META HTTP-EQUIV=\"expires\" CONTENT=\"-1\">
            <META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">
            </HEAD>
            <BODY onLoad=\"$onLoad\">
            $post_vars_html
            </BODY>
            </HTML>
            ";
    }

    /* description: Given a style name and a javascript method, generate
                    style information based on properties and target. 
               This method makes at least these, ahem, assumptions:
               - all style properties beginning with "background" will be handled
                 by the toBackgroundStyle method of Style.php
               - all style properties  beginning with "font" will be handled by
                 the toTextStyle method of Style.php
               - if useTarget is true (default), the property name passed to javascript 
                 method consists of property name + Target (uppercase first char on target). 
                 This is bad but at least consistent
      returns:     Javascript style text in a string
      uses:      Use this method when you have a style with n targets so that you don't
                  need to hard code your targets. You can add new targets just by adding 
                  them to the style file.
      params: 
        styleName - name of a style (e.g. 'info')
        jsMethod  - name of javascript method to call with the style info
        useTarget - construct js property name using property name and target (eg 'nextIconHelp')
      
    */            
    function getStyleJavascript($styleName, $jsMethod, $useTarget=true) {

        $stylist = $this->getStylist();
        $style = $stylist->getStyle($styleName);
        $properties = $style->getPropertyIds();   

        while (list(,$P) = each($properties)) {

            list($name, $target) = $P;
            //construct js property name using property name and target
            $Utarget = $useTarget ? ucfirst ($target) : ""; 

            $prop = $name . $Utarget; 
            $text = "";
             
            // Get the style text
            switch(true) {
                case strpos($name, "background") === 0:   // is 0 and is same type (ie not false).
                    // We do bg style based on target, so only do it once for each target
                    if (!(${$target ."bgStyle"})) {
                        $text = $style->toBackgroundStyle($target);
                        $prop = "backgroundStyle$Utarget";
                        ${$target . "bgStyle"} = true; // flag for this target
                    }
                break;
                
                case strpos($name, "font") === 0:   // is 0 and is same type (ie not false).
                    // We do text style based on target, so only do it once for each target
                    if( !(${$target ."textStyle"})) {
                        $text = $style->toTextStyle($target);
                        $prop = "textStyle$Utarget";
                        ${$target . "textStyle"} = true; // flag for this target
                    }
                break;
                            
                default:
                    $text = $style->getProperty($name, $target);
             }
             
            // put the style together
            if ($text) {
                $result .= "$jsMethod(\"$prop\", \"$text\");\n";
            }
        }
        return $result;
    }


    // description: get Javascript to set style for collapsible list
    // returns: Javascript in string
    function getCListStyleJavascript() {
        $stylist = $this->getStylist();
        $style = $stylist->getStyle("collapsibleList");

        $properties = array(
            "aLinkColor" => $style->getProperty("aLinkColor"),
            "backgroundStyleListNear" => $style->toBackgroundStyle("listNear"),
            "backgroundStyleListNormal" => $style->toBackgroundStyle("listNormal"),
            "backgroundStyleListSelected" => $style->toBackgroundStyle("listSelected"),
            "backgroundStylePage" => $style->toBackgroundStyle("page"),
            "borderColor" => $style->getProperty("borderColor"),
            "borderThickness" => $style->getProperty("borderThickness"),
            "collapsedIcon" => $style->getProperty("collapsedIcon"),
            "dividerImage" => $style->getProperty("dividerImage"),
            "expandedIcon" => $style->getProperty("expandedIcon"),
            "selectedIcon" => $style->getProperty("selectedIcon"),
            "unselectedIcon" => $style->getProperty("unselectedIcon"),
            "textStyleNear" => $style->toTextStyle("near"),
            "textStyleNormal" => $style->toTextStyle("normal"),
            "textStyleSelected" => $style->toTextStyle("selected"),
            "width" => $style->getProperty("width")
        );

        $keys = array_keys($properties);
        for ($i = 0; $i < count($keys); $i++) {
            $result .= "top.code.cList_setStyle(\"".$keys[$i]."\", \"".$properties[$keys[$i]]."\");\n";
        }
        return $result;
    }

    // description: get Javascript to set style for flow navigation
    // returns: Javascript in string
    function getFlowControlStyleJavascript() {
        $stylist = $this->getStylist();
        $style = $stylist->getStyle("flowControl");

        $properties = array(
            "controlBackgroundStyle" => $style->toBackgroundStyle(),
            "backImage" => $style->getProperty("backImage"),
            "backImageDisabled" => $style->getProperty("backImageDisabled"),
            "finishImage" => $style->getProperty("finishImage"),
            "finishImageDisabled" => $style->getProperty("finishImageDisabled"),
            "nextImage" => $style->getProperty("nextImage"),
            "nextImageDisabled" => $style->getProperty("nextImageDisabled"),
        );

        $keys = array_keys($properties);
        for ($i = 0; $i < count($keys); $i++) {
            $result .= "top.code.flow_setStyle(\"".$keys[$i]."\", \"".$properties[$keys[$i]]."\");\n";
        }
        return $result;
    }

    // description: get Javascript to set style for info
    // returns: Javascript in string
    function getInfoStyleJavascript() {
        return($this->getStyleJavascript("info", "top.code.info_setStyle"));
    }

    // description: get Javascript to set style for tab
    // returns: Javascript in string
    function getTabStyleJavascript() {
        $stylist = $this->getStylist();
        $style = $stylist->getStyle("tab");

        $properties = array(
            "aLinkColor" => $style->getProperty("aLinkColor"),
            "backgroundStyle" => $style->toBackgroundStyle(),
            "logo" => $style->getProperty("logo"),
            "logoutImage" => $style->getProperty("logoutImage"),
            "monitorOffImage" => $style->getProperty("monitorOffImage"),
            "monitorOnImage" => $style->getProperty("monitorOnImage"),
            "selectedImageLeft" => $style->getProperty("selectedImageLeft"),
            "selectedImageRight" => $style->getProperty("selectedImageRight"),
            "selectedImageFill" => $style->getProperty("selectedImageFill"),
            "textStyleSelected" => $style->toBackgroundStyle("selected").$style->toTextStyle("selected"),
            "textStyleUnselected" => $style->toBackgroundStyle("unselected").$style->toTextStyle("unselected"),
            "top" => $style->getProperty("top"),
            "unselectedImageLeft" => $style->getProperty("unselectedImageLeft"),
            "unselectedImageRight" => $style->getProperty("unselectedImageRight"),
            "unselectedImageFill" => $style->getProperty("unselectedImageFill"),
            "updateOffImage" => $style->getProperty("updateOffImage"),
            "updateOnImage" => $style->getProperty("updateOnImage"),
            "manualOffImage" => $style->getProperty("manualOffImage")
        );

        $keys = array_keys($properties);
        for ($i = 0; $i < count($keys); $i++) {
            $result .= "top.code.tab_setStyle(\"".$keys[$i]."\", \"".$properties[$keys[$i]]."\");\n";
        }
        return $result;
    }

    // description: get Javascript to set style for title
    // returns: Javascript in string
    function getTitleStyleJavascript() {
        $stylist = $this->getStylist();
        $style = $stylist->getStyle("title");

        $properties = array(
            "backgroundStyle" => $style->toBackgroundStyle(),
            "descriptionStyle" => $style->toTextStyle("description"),
            "logo" => $style->getProperty("logo"),
            "titleStyle" => $style->toTextStyle("title"),
        );

        $keys = array_keys($properties);
        for($i = 0; $i < count($keys); $i++) {
            $result .= "top.code.title_setStyle(\"".$keys[$i]."\", \"".$properties[$keys[$i]]."\");\n";
        }
        return $result;
    }

    function hasCCE() {
        return TRUE;
    }

    // this should not be used outside this class
    function getProductCode() {
        //Get product info 
        $build_file = "/etc/build";
        $BUILD_FILE = fopen($build_file, "r");
        $buildtext = fread($BUILD_FILE,filesize($build_file)); 
        fclose($BUILD_FILE);
        if (preg_match("/for a ([A-Za-z0-9\-]+) in/", $buildtext, $regs)) {
            $product = $regs[1];
        }
        return $product;
    }

    // unserialize and return the array of Error objects from the
    // handler page
    function &getErrors() {
        global $_serialized_errors;
        $errors = array();

        // handle serialized errors if present
        if(isset($_serialized_errors)) {
            $errors = unserialize(urldecode($_serialized_errors));
        }
        return $errors;
    }

    // description: get a list of all the capabilities the given user has
    // param: the oid of the user to check (defaults: current)
    // returns: a list of all the capabilities the current user has
    function listAllowed($oid = -1) {
        if ($oid == -1) {
            $currentuser = 1;
            $oid = $this->loginUser["OID"];
        }

        if (!isset($this->_listAllowed[$oid])) {
            $this->_listAllowed[$oid] = TRUE;
        }

        if (is_array($this->_listAllowed[$oid])) {
            return $this->_listAllowed[$oid];
        }

        $ret = array();
        // get all the capLevels and expand them.
        if (isset($currentuser)) {
            $uirights = stringToArray($this->loginUser["uiRights"]);
            if (in_array("systemAdministrator", $uirights) || $this->loginUser["systemAdministrator"]) {
                // I am god, so I get ALL the capgroups :)
                $groups = $this->getAllCapabilityGroups();
                $caplevels = array();
                foreach($groups as $groupkey=>$groupval) {
                    $caplevels[] = $groupkey;
                }
            } 
            else { // get the capLevels from this user 
                $caplevels = stringToArray($this->loginUser["capLevels"]);
            }
        } 
        else { // i'm asking about another user, so I say what I can about them.
            $user = $this->cceClient->get($oid);
            $caplevels = stringToArray($user["capLevels"]);
        } 

        $returnCap = array();

        foreach ($caplevels as $key => $capName) {
            foreach ($this->getAllCapabilityGroups() as $capA => $capContend) {
                if ($capContend['CLASS'] == "CapabilityGroup") {
                    if ($capContend['name'] == $capName) {
                        if (!in_array($capName, $returnCap)) {
                            $returnCap[] = $capName;
                        }
                        $tmpreturnCap = scalar_to_array($capContend['capabilities']);
                        foreach ($tmpreturnCap as $key => $value) {
                            if (!in_array($value, $returnCap)) {
                                $returnCap[] = $value;
                            }
                        }
                    }
                    else {
                        if (!in_array($capName, $returnCap)) {
                            $returnCap[] = $capName;
                        }
                    }
                }
            }
        }

        // New method via CI 'BX_SESSION':
        $CI =& get_instance();
        if ($CI->BX_SESSION['userShell'] == "1") {
            $returnCap[] = 'shellAccessEnabled';
        }

        // Remove blank entries, make unique and store:
        $returnCap = array_filter(array_unique($returnCap));
        if ($this->_listAllowed[$oid] == TRUE) {
            $this->_listAllowed[$oid] = $returnCap;
        }
        return $returnCap;
    }

    // description: checks to see if a user is granted the given capability.
    // param: the name of the CapabilityGroup or CCE-Level capability to check
    // param: the user to check for (default: current)
    // returns: true if the current user has this capability, false otherwise

    function getAllowed($capName, $oid = -1) {
        // this is quicker besides systemAdministrator should be
        // able to view everything whether there is a capability group
        // or not
        $currentuser = 0;
        if ($oid == -1) {
            $currentuser = 1;
            $oid = $this->loginUser["OID"];
        }

        if (($currentuser == 1) && ($this->loginUser['systemAdministrator'])) {
            // We want to know the caps for the current users. AND that user is
            // 'systemAdministrator'. Spare the trouble and return a fast 'yes':
            return 1;
        }

        if ((!$this->loginUser['systemAdministrator']) && ($oid == -1) && ($capName == 'adminUser')) { 
            // Fast 'no' to the question for 'adminUser', because we simply aren't.
            // Do not get get confused here. Resellers are 'adminUser', but we do
            // NOT treat them as such unless they also have the 'systemAdministrator'
            // flag. Without that flag, we do not rate them as 'adminUser':
            return 0;
        }

        $caps = $this->listAllowed($oid);
        if (in_array($capName, $caps)) {
            return 1;
        }
        else {
            return 0;
        }
        return 0;
    }

    // description: checks to see if a user is in a certain group or a reseller of it.
    // param: the group of the User/Vsite to check
    // param: the user to check for (default: current)
    // returns: true if the current user has this capability, false otherwise

    function getGroup($group, $oid = -1) {
        if ($oid == -1) {
            $currentuser = 1;
            $oid = $this->loginUser["OID"];
        }
        // Find out if the Group exists:
        $site = $this->cceClient->getObject('Vsite', array('name' => $group));
        if (!isset($site['fqdn'])) {
            // Group doesn't exist. So we fail right here:
            return 0;
        }
        if ($this->loginUser['systemAdministrator']) {
            // Fast 'yes' to all rights, because we are system administrator:
            return 1;
        }
        // Check if this user belongs to the given group OR is Reseller of this group:
        if (($this->loginUser['site'] == $group) || ($this->getReseller($group))) {
            // This user is listed as 'createdUser', so we return yes:
            return 1;
        }
        return 0;
    }

    // description: checks to see if a user is systemAdministrator, siteAdmin 
    // or a reseller of a group and if the group exists.
    // param: the group of the User/Vsite to check
    // param: the user to check for (default: current)
    // returns: true if the current user has this capability, false otherwise

    function getGroupAdmin($group, $oid = -1) {
        if ($oid == -1) {
            $currentuser = 1;
            $oid = $this->loginUser["OID"];
        }
        // Find out if the Group exists:
        $site = $this->cceClient->getObject('Vsite', array('name' => $group));
        if (!isset($site['fqdn'])) {
            // Group doesn't exist. So we fail right here:
            return 0;
        }
        if ($this->loginUser['systemAdministrator']) {
            // Fast 'yes' to all rights, because we are system administrator:
            return 1;
        }
        // Check if this user is Reseller of this group:
        if (($this->loginUser['site'] == "") && ($this->getReseller($group) == "1")) {
            // This is a reseller (has no group) and can manage the specified group as Reseller.
            return 1;
        }
        // Check if this user belongs to this group and is siteAdmin of this group:
        if (($this->loginUser['site'] == $group) && ($this->getSiteAdmin($group))) {
            // This user belongs to this group and is siteAdmin OR Reseller.
            return 1;
        }
        return 0;
    }

    // description: checks to see if a user is a reseller (createdUser) of a 
    // given Vsite group.
    // param: the group of the Vsite to check
    // param: the user to check for (default: current)
    // returns: true if the current user has this capability, false otherwise

    function getReseller($group, $oid = -1) {
        if ($oid == -1) {
            $currentuser = 1;
            $oid = $this->loginUser["OID"];
        }
        // Find out if the Group exists:
        $site = $this->cceClient->getObject('Vsite', array('name' => $group));
        if (!isset($site['fqdn'])) {
            // Group doesn't exist. So we fail right here:
            return 0;
        }
        if ($this->loginUser['systemAdministrator']) {
            // Fast 'yes' to all rights, because we are system administrator:
            return 1;
        }
        // Check Vsite's 'createdUser':
        if ($site['createdUser'] == $this->loginUser['name']) {
            // This user is listed as 'createdUser', so we return yes:
            return 1;
        }
        return 0;
    }

    // description: checks to see if a user is a siteAdmin of a given Vsite group.
    // param: the group of the Vsite to check
    // param: the user to check for (default: current)
    // returns: true if the current user has this capability, false otherwise

    function getSiteAdmin($group, $oid = -1) {
        if ($oid == -1) {
            $currentuser = 1;
            $oid = $this->loginUser["OID"];
        }
        // Find out if the Group exists:
        $site = $this->cceClient->getObject('Vsite', array('name' => $group));
        if (!isset($site['fqdn'])) {
            // Group doesn't exist. So we fail right here:
            return 0;
        }
        if ($this->loginUser['systemAdministrator']) {
            // Fast 'yes' to all rights, because we are system administrator:
            return 1;
        }
        // Check if this user belongs to the given group:
        if ($this->loginUser['site'] == $group) {
            // This user is listed as 'createdUser', so we return yes:
            return 1;
        }
        else {
            // He might be a siteAdmin elsewhere, but sure not here.
            return 0;
        }
        // Check if this user has the capability 'siteAdmin':
        $caps = $this->listAllowed($oid);
        if (in_array('siteAdmin', $caps)) {
            return 1;
        }
        return 0;
    }

    function debug_log ($msg) {
        if ($this->debugActive) {
            error_log($msg);
        }
    }

    // description: returns an array of ALL the capabilityGroups
    function getAllCapabilityGroups() {
        $this->debug_log("getAllCapabilityGroups: via ServerScriptHelper");

        $capabilityGroups_file_name = "/usr/sausalito/capcache/$this->loginName" . "_capabilityGroups";

        if (isset($this->_gotAllCapabilityGroups)) {
            $this->debug_log("getAllCapabilityGroups: From memory");
            return $this->capabilityGroups;
        }
        elseif (is_file($capabilityGroups_file_name)) {
            $capabilityGroups_file_data = read_file($capabilityGroups_file_name);
            $this->capabilityGroups = json_decode($capabilityGroups_file_data, true);
            if (!is_array($this->capabilityGroups)) {
                system("rm -f $capabilityGroups_file_name");
                error_log("getAllCapabilityGroups: Capability cache $capabilityGroups_file_name not readable or garbled. Deleting cachefile and continuing with full run for now.");
            }
            else {
                $this->_gotAllCapabilityGroups = 1;
                return $this->capabilityGroups;                
            }
        }
        else {
            $this->debug_log("getAllCapabilityGroups: Full run");
        }

        $cce =& $this->cceClient;
        $oids = $cce->find("CapabilityGroup");

        foreach($oids as $oid) {
            $obj = $cce->get($oid);
            $this->getCapabilityGroup($obj['name'], $obj);
        }
        $this->_gotAllCapabilityGroups = 1;

        // Store temporary file:
        $capabilityGroups_file_data = json_encode($this->capabilityGroups);
        if (!write_file($capabilityGroups_file_name, $capabilityGroups_file_data)) {
            system("rm -f $capabilityGroups_file_name");
        }
        return $this->capabilityGroups;
    }

    // description: returns an array of all the declared cce-level capabilities
    function getAllCapabilities() {
        $this->debug_log("getAllCapabilities: via ServerScriptHelper");
        if (count($this->capabilities)) {
           return ($this->capabilities); 
        }
        $this->capabilities = $this->cceClient->names("Capabilities");
        return $this->capabilities;
    }


    // description:  gets the capabilityGroup and caches it
    function &getCapabilityGroup($capName, $data = null) {
        $this->debug_log("getCapabilityGroup: via ServerScriptHelper");

        if ($data) {
            // we are given the data to cache.
            $this->capabilityGroups[$capName] = $data;
            return $this->capabilityGroups[$capName];
        }
        // check if we already checked and couldn't find this capname
        if (isset($this->capabilityGroups[$capName])) {
            if (isset($this->notCapabilityGroups[$capName]) || ($this->capabilityGroups[$capName]==null && $this->_gotAllCapabilityGroups)) {
               return null;
            }
        }
        $cce = $this->cceClient;
        if (isset($this->capabilityGroups[$capName])) {
            if ($this->capabilityGroups[$capName]!=null) {
               return $this->capabilityGroups[$capName];
            }
        }
        if (($group = $this->cceClient->getObject("CapabilityGroup", array("name"=>$capName)))!=null) {
            $this->capabilityGroups[$capName] = $group;
            return $this->capabilityGroups[$capName];
        }
        $this->notCapabilityGroups[$capName] = 1;
        $null = "NULL";
        return $null;
    } 


    function getGlobalCapabilitiesObject($cce = null) {

        $cap_file_name = "/usr/sausalito/capcache/$this->loginName" . "_cap";
        $this->debug_log("getGlobalCapabilitiesObject: via ServerScriptHelper");

        if (is_file($cap_file_name)) {
            $cap_file_data = read_file($cap_file_name);
            $this->CAPABILITIESGLOBALOBJECT = json_decode($cap_file_data, true);
        }

        if (is_array($this->CAPABILITIESGLOBALOBJECT)) {
            $this->debug_log("getGlobalCapabilitiesObject: from File");
            return $this->CAPABILITIESGLOBALOBJECT;
        }
        else {
            $this->debug_log("getGlobalCapabilitiesObject: full run");
            $this->CAPABILITIESGLOBALOBJECT = new Capabilities($cce);

            // Store temporary file:
            $cap_file_data = json_encode($this->CAPABILITIESGLOBALOBJECT);

            if (!write_file($cap_file_name, $cap_file_data)) {
                system("rm -f $cap_file_name");
            }
            return $this->CAPABILITIESGLOBALOBJECT;
        }
    }

    function Capabilities($cce = NULL, $loginName = NULL, $sessionId = NULL) {

        $this->debug_log("Capabilities: via ServerScriptHelper");

        if ($cce != NULL) {
           $this->cceClient =& $cce;
        }
        else {
            $this->cceClient = new CceClient();
            // FIXME check connect and authkey for failure
            $this->cceClient->connect();
            $this->cceClient->authkey($loginName, $sessionId);
            $this->myCce = 1;
        }

        // New method via CI 'BX_SESSION':
        $CI =& get_instance();
        $userCap = $CI->BX_SESSION['loginUser'];
        $iam = $userCap['OID'];
        $this->loginUser = $userCap;

        $this->capabilityGroups = array();
        $this->capabilities = array();
        $this->notCapabilityGroups = array();
        $this->_listAllowed = array();
        $this->_debug = false;

        // this makes us get all the capgroup stuff right away, making CCE not 
        // to worry about pulling capgroups out by indexed names
        $this->getAllCapabilityGroups();
        $this->getAllCapabilities();
        $this->listAllowed();
    }

    function setDebug($DEBUG = "") {
        $this->DEBUG = $DEBUG;
    }

    function getDebug() {
        return $this->DEBUG;
    }
}

/*
Copyright (c) 2014-2017 Michael Stauber, SOLARSPEED.NET
Copyright (c) 2014-2017 Team BlueOnyx, BLUEONYX.IT
Copyright (c) 2003 Sun Microsystems, Inc. 
All Rights Reserved.

1. Redistributions of source code must retain the above copyright 
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright 
   notice, this list of conditions and the following disclaimer in 
   the documentation and/or other materials provided with the 
   distribution.

3. Neither the name of the copyright holder nor the names of its 
   contributors may be used to endorse or promote products derived 
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.

You acknowledge that this software is not designed or intended for 
use in the design, construction, operation or maintenance of any 
nuclear facility.

*/
?>