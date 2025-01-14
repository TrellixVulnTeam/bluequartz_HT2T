<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class UninstallHandler extends MX_Controller {

    /**
     * Index Page for this controller.
     *
     * Past the login page this loads the page for /swupdate/uninstallHandler.
     *
     */

    public function index() {

        $CI =& get_instance();

        // We load the BlueOnyx helper library first of all, as we heavily depend on it:
        $this->load->helper('blueonyx');
        init_libraries();

        // Need to load 'BxPage' for page rendering:
        $this->load->library('BxPage');

        // Get $CI->BX_SESSION['sessionId'] and $CI->BX_SESSION['loginName'] from Cookie (if they are set):
        $CI->BX_SESSION['sessionId'] = $CI->input->cookie('sessionId');
        $CI->BX_SESSION['loginName'] = $CI->input->cookie('loginName');

        // Line up the ducks for CCE-Connection:
        include_once('ServerScriptHelper.php');
        $CI->serverScriptHelper = new ServerScriptHelper($CI->BX_SESSION['sessionId'], $CI->BX_SESSION['loginName']);
        $CI->cceClient = $CI->serverScriptHelper->getCceClient();
        $user = $CI->BX_SESSION['loginUser'];
        $i18n = new I18n("base-swupdate", $CI->BX_SESSION['loginUser']['localePreference']);
        $system = $CI->getSystem();

        // Initialize Capabilities so that we can poll the access rights as well:
        $Capabilities = new Capabilities($CI->cceClient, $CI->BX_SESSION['loginName'], $CI->BX_SESSION['sessionId']);

        // -- Actual page logic start:

        // Not 'managePackage'? Bye, bye!
        if (!$Capabilities->getAllowed('managePackage')) {
            // Nice people say goodbye, or CCEd waits forever:
            $CI->cceClient->bye();
            $CI->serverScriptHelper->destructor();
            Log403Error("/gui/Forbidden403");
        }

        //
        //-- Do the deeds:
        //

        // Declare some constants
        $uninstallScript = "/usr/sausalito/sbin/pkg_uninstall.pl";

        // Get URL params:
        $get_form_data = $CI->input->get(NULL, TRUE);

        if ((!isset($get_form_data['packageOID'])) || (!isset($get_form_data['nameField']))) {
            // Nice people say goodbye, or CCEd waits forever:
            $CI->cceClient->bye();
            $CI->serverScriptHelper->destructor();
            Log403Error("/gui/Forbidden403");
        }
        else {
            $packageOID = $get_form_data['packageOID'];
            $nameField = $get_form_data['nameField'];
        }

        // Is this really a Package?
        $package = $CI->cceClient->get($packageOID);

        if ((!is_array($package)) || ($package['CLASS'] != "Package")) {
            // OID isn't a Package or doesn't exist:
            // Nice people say goodbye, or CCEd waits forever:
            $CI->cceClient->bye();
            $CI->serverScriptHelper->destructor();
            Log403Error("/gui/Forbidden403#noPKG");
        }

        // Reset
        $CI->cceClient->setObject("System", array("uiCMD" => "", "message" => "", "progress" => 0), "SWUpdate");

        // Initiate the uninstall:
        $CI->serverScriptHelper->fork("$uninstallScript $packageOID", 'root', $CI->BX_SESSION['sessionId']);

        // Nice people say goodbye, or CCEd waits forever:
        $CI->cceClient->bye();
        $CI->serverScriptHelper->destructor();

        //
        //-- Return home:
        //

        // Redirect to the status page during the install:
        header("Location: /swupdate/status?nameField=" . rawurlencode($nameField) . "&backUrl=/swupdate/softwareList&packageOID=". $packageOID . "&A=U");
        exit;
    }
}
/*
Copyright (c) 2016 Michael Stauber, SOLARSPEED.NET
Copyright (c) 2016 Team BlueOnyx, BLUEONYX.IT
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